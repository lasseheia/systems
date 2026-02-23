local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not ok then
  return
end

local capabilities = cmp_nvim_lsp.default_capabilities()

vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.lsp.config('yamlls', {
  capabilities = capabilities,
  settings = {
    yaml = {
      validate = true,
      keyOrdering = false,
      schemaStore = {
        enable = true,
        url = 'https://www.schemastore.org/api/json/catalog.json',
      },
      schemas = {
        ['https://json.schemastore.org/kustomization.json'] = {
          'kustomization.yaml',
          'kustomization.yml',
        },
      },
    },
  },
})

vim.lsp.enable('dartls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('yamlls')
vim.lsp.enable('nixd')
vim.lsp.enable('roslyn_ls')
vim.lsp.enable('terraform-ls')
vim.lsp.config('terraform-ls', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "terraform" },
})
