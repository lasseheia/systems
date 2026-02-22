local ok, which_key = pcall(require, 'which-key')
if not ok then
  return
end

which_key.setup {}

which_key.add {
  { '<leader>s', group = 'Search' },
  { '<leader>g', group = 'Git' },
  { '<leader>e', group = 'Edit' },
  { '<leader>d', group = 'Dotnet' },
  { '<leader>?', '<cmd>WhichKey<CR>', desc = 'Show keymaps' },
}
