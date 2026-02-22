local ok, nvim_tree = pcall(require, 'nvim-tree')
if not ok then
  return
end

nvim_tree.setup {
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
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NvimTree',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    local api_ok, api = pcall(require, 'nvim-tree.api')
    if api_ok then
      api.tree.open()
    end
  end,
})

local function set_nvim_tree_folder_highlights()
  local folder_color = '#6f94b6'
  local opened_folder_color = '#7ea1c4'
  local symlink_color = '#5f9ea8'

  vim.api.nvim_set_hl(0, 'NvimTreeNormal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NvimTreeNormalNC', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NvimTreeEndOfBuffer', { bg = 'none' })

  vim.api.nvim_set_hl(0, 'NvimTreeFolderName', { fg = folder_color })
  vim.api.nvim_set_hl(0, 'NvimTreeFolderIcon', { fg = folder_color })
  vim.api.nvim_set_hl(0, 'NvimTreeOpenedFolderName', { fg = opened_folder_color, bold = true })
  vim.api.nvim_set_hl(0, 'NvimTreeEmptyFolderName', { fg = folder_color, italic = true })
  vim.api.nvim_set_hl(0, 'NvimTreeSymlink', { fg = symlink_color, italic = true })
  vim.api.nvim_set_hl(0, 'NvimTreeSymlinkIcon', { fg = symlink_color })
end

set_nvim_tree_folder_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = set_nvim_tree_folder_highlights,
})

-- Autocommand to close Neovim if the NvimTree is the only buffer left
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function()
    if vim.fn.winnr('$') == 1 and vim.b.term_type == 'tree' then
      vim.cmd('quit')
    end
  end,
})
