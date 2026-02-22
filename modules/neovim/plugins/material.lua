local ok, material = pcall(require, 'material')
if not ok then
  return
end

material.setup {
  disable = {
    background = true,
    colored_cursor = true,
    borders = true,
  },
  plugins = {
    "gitsigns",
    "nvim-tree",
    "telescope",
    "which-key",
  },
}

vim.cmd.colorscheme('material')
