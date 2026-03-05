local ok, nvim_tree = pcall(require, "nvim-tree")
if not ok then
  return
end

local api_ok, api = pcall(require, "nvim-tree.api")
local uv = vim.uv or vim.loop
local git_repo_sign_group = "NvimTreeGitRepoSigns"
local git_repo_sign_name = "NvimTreeGitRepoSign"

vim.fn.sign_define(git_repo_sign_name, {
  text = "",
  texthl = "NvimTreeGitRepoSign",
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

local function mark_git_repo_folders()
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
        vim.fn.sign_place(0, git_repo_sign_group, git_repo_sign_name, tree_buf, {
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
  local git_repo_color = "#b58d52"

  vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

  vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = folder_color })
  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = folder_color })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = opened_folder_color, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName", { fg = folder_color, italic = true })
  vim.api.nvim_set_hl(0, "NvimTreeSymlink", { fg = symlink_color, italic = true })
  vim.api.nvim_set_hl(0, "NvimTreeSymlinkIcon", { fg = symlink_color })
  vim.api.nvim_set_hl(0, "NvimTreeGitRepoSign", { fg = git_repo_color, bold = true })
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
