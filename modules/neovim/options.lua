vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.laststatus = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 1
vim.opt.fillchars:append({ eob = ' ' })
vim.opt.mouse = ''
vim.opt.timeout = true
vim.opt.timeoutlen = 350
vim.opt.autoindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smarttab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.encoding = 'utf-8'
vim.opt.clipboard:append('unnamedplus')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.textwidth = 0
    vim.opt_local.colorcolumn = ''
  end,
})

vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]
