local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not ok then
  return
end

local capabilities = cmp_nvim_lsp.default_capabilities()

vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.lsp.enable('dartls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('yamlls')
vim.lsp.enable('nixd')
vim.lsp.enable('omnisharp')
vim.lsp.enable('terraform-ls')
