local ok, nvim_tree = pcall(require, "nvim-tree")
if not ok then
  return
end

local api_ok, api = pcall(require, "nvim-tree.api")
local uv = vim.uv or vim.loop
local git_repo_sign_group = "NvimTreeGitRepoSigns"
local git_repo_clean_sign_name = "NvimTreeGitRepoCleanSign"
local git_repo_dirty_sign_name = "NvimTreeGitRepoDirtySign"
local git_repo_ahead_sign_name = "NvimTreeGitRepoAheadSign"
local git_repo_dirty_ahead_sign_name = "NvimTreeGitRepoDirtyAheadSign"
local git_status_cache = {}
local git_status_ttl_ms = 10000
local tree_refresh_scheduled = false
local mark_git_repo_folders

vim.fn.sign_define(git_repo_clean_sign_name, {
  text = "",
  texthl = "NvimTreeGitRepoCleanSign",
})

vim.fn.sign_define(git_repo_dirty_sign_name, {
  text = "!",
  texthl = "NvimTreeGitRepoDirtySign",
})

vim.fn.sign_define(git_repo_ahead_sign_name, {
  text = "^",
  texthl = "NvimTreeGitRepoAheadSign",
})

vim.fn.sign_define(git_repo_dirty_ahead_sign_name, {
  text = "*",
  texthl = "NvimTreeGitRepoDirtyAheadSign",
})

nvim_tree.setup({
  filters = {
    git_ignored = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
  view = {
    width = 36,
    preserve_window_proportions = true,
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  update_focused_file = {
    enable = true,
    update_root = false,
  },
})

local function is_git_repo(path)
  local git_path = path .. "/.git"
  local stat = uv.fs_stat(git_path)
  if not stat then
    return false
  end

  return stat.type == "directory" or stat.type == "file"
end

local function parse_git_status_output(output)
  local has_uncommitted_changes = false
  local has_unpushed_commits = false

  for line in output:gmatch("[^\r\n]+") do
    if line:sub(1, 12) == "# branch.ab " then
      local ahead = line:match("# branch%.ab %+(%d+)%s%-%d+")
      if ahead and tonumber(ahead) and tonumber(ahead) > 0 then
        has_unpushed_commits = true
      end
    elseif line:sub(1, 1) ~= "#" and line ~= "" then
      has_uncommitted_changes = true
    end
  end

  return {
    has_uncommitted_changes = has_uncommitted_changes,
    has_unpushed_commits = has_unpushed_commits,
  }
end

local function schedule_tree_refresh()
  if tree_refresh_scheduled then
    return
  end

  tree_refresh_scheduled = true
  vim.defer_fn(function()
    tree_refresh_scheduled = false
    if mark_git_repo_folders then
      mark_git_repo_folders()
    end
  end, 80)
end

local function queue_git_status_refresh(path)
  local cached = git_status_cache[path]
  if cached and cached.pending then
    return
  end

  git_status_cache[path] = cached or {}
  git_status_cache[path].pending = true

  if vim.system then
    vim.system({ "git", "-C", path, "status", "--porcelain=2", "--branch" }, { text = true }, function(result)
      local status = {
        has_uncommitted_changes = false,
        has_unpushed_commits = false,
      }

      if result.code == 0 and result.stdout then
        status = parse_git_status_output(result.stdout)
      end

      local entry = git_status_cache[path] or {}
      entry.has_uncommitted_changes = status.has_uncommitted_changes
      entry.has_unpushed_commits = status.has_unpushed_commits
      entry.last_checked = uv.now()
      entry.pending = false
      git_status_cache[path] = entry

      vim.schedule(schedule_tree_refresh)
    end)
    return
  end

  local output = vim.fn.systemlist(string.format(
    "git -C %s status --porcelain=2 --branch",
    vim.fn.shellescape(path)
  ))

  local status = {
    has_uncommitted_changes = false,
    has_unpushed_commits = false,
  }

  if vim.v.shell_error == 0 then
    status = parse_git_status_output(table.concat(output, "\n"))
  end

  local entry = git_status_cache[path] or {}
  entry.has_uncommitted_changes = status.has_uncommitted_changes
  entry.has_unpushed_commits = status.has_unpushed_commits
  entry.last_checked = uv.now()
  entry.pending = false
  git_status_cache[path] = entry
end

local function get_repo_git_status(path)
  local cached = git_status_cache[path]
  if not cached then
    queue_git_status_refresh(path)
    return {
      has_uncommitted_changes = false,
      has_unpushed_commits = false,
    }
  end

  local age_ms = uv.now() - (cached.last_checked or 0)
  if age_ms > git_status_ttl_ms and not cached.pending then
    queue_git_status_refresh(path)
  end

  return {
    has_uncommitted_changes = cached.has_uncommitted_changes or false,
    has_unpushed_commits = cached.has_unpushed_commits or false,
  }
end

local function get_git_repo_sign_name(path)
  local status = get_repo_git_status(path)
  if status.has_uncommitted_changes and status.has_unpushed_commits then
    return git_repo_dirty_ahead_sign_name
  end

  if status.has_uncommitted_changes then
    return git_repo_dirty_sign_name
  end

  if status.has_unpushed_commits then
    return git_repo_ahead_sign_name
  end

  return git_repo_clean_sign_name
end

mark_git_repo_folders = function()
  if not api_ok then
    return
  end

  local tree_win = api.tree.winid()
  if not tree_win or tree_win == 0 or not vim.api.nvim_win_is_valid(tree_win) then
    return
  end

  local tree_buf = vim.api.nvim_win_get_buf(tree_win)

  if vim.bo[tree_buf].filetype ~= "NvimTree" then
    return
  end

  vim.wo[tree_win].signcolumn = "yes:1"
  vim.fn.sign_unplace(git_repo_sign_group, { buffer = tree_buf })

  vim.api.nvim_win_call(tree_win, function()
    local current_cursor = vim.api.nvim_win_get_cursor(tree_win)
    local line_count = vim.api.nvim_buf_line_count(tree_buf)

    for line = 1, line_count do
      vim.api.nvim_win_set_cursor(tree_win, { line, 0 })

      local node = api.tree.get_node_under_cursor()
      if node and node.type == "directory" and node.absolute_path and is_git_repo(node.absolute_path) then
        local sign_name = get_git_repo_sign_name(node.absolute_path)
        vim.fn.sign_place(0, git_repo_sign_group, sign_name, tree_buf, {
          lnum = line,
          priority = 10,
        })
      end
    end

    vim.api.nvim_win_set_cursor(tree_win, current_cursor)
  end)
end

if api_ok and api.events and api.events.Event.TreeRendered then
  api.events.subscribe(api.events.Event.TreeRendered, function()
    vim.schedule(mark_git_repo_folders)
  end)
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function(data)
    local argc = vim.fn.argc()
    local should_open = false

    if argc == 0 and data.file == "" then
      should_open = true
    elseif argc == 1 then
      local arg = vim.fn.argv(0)
      should_open = vim.fn.isdirectory(arg) == 1
    end

    if not should_open then
      return
    end

    local api_ok, api = pcall(require, "nvim-tree.api")
    if api_ok then
      api.tree.open()
    end
  end,
})

local function set_nvim_tree_folder_highlights()
  local folder_color = "#6f94b6"
  local opened_folder_color = "#7ea1c4"
  local symlink_color = "#5f9ea8"
  local git_repo_clean_color = "#b58d52"
  local git_repo_dirty_color = "#c97b87"
  local git_repo_ahead_color = "#7fa766"
  local git_repo_dirty_ahead_color = "#d4bc8a"

  vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

  vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = folder_color })
  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = folder_color })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = opened_folder_color, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName", { fg = folder_color, italic = true })
  vim.api.nvim_set_hl(0, "NvimTreeSymlink", { fg = symlink_color, italic = true })
  vim.api.nvim_set_hl(0, "NvimTreeSymlinkIcon", { fg = symlink_color })
  vim.api.nvim_set_hl(0, "NvimTreeGitRepoCleanSign", { fg = git_repo_clean_color, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitRepoDirtySign", { fg = git_repo_dirty_color, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitRepoAheadSign", { fg = git_repo_ahead_color, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitRepoDirtyAheadSign", { fg = git_repo_dirty_ahead_color, bold = true })
end

set_nvim_tree_folder_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_nvim_tree_folder_highlights,
})

-- Autocommand to close Neovim if the NvimTree is the only buffer left
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.b.term_type == "tree" then
      vim.cmd("quit")
    end
  end,
})
