local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not ok then
  return
end

local capabilities = cmp_nvim_lsp.default_capabilities()
local default_publish_diagnostics = vim.lsp.handlers['textDocument/publishDiagnostics']

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

vim.lsp.config('nixd', {
  capabilities = capabilities,
  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
      if result and result.diagnostics then
        local filtered = {}
        for _, diagnostic in ipairs(result.diagnostics) do
          local message = diagnostic.message or ''
          if not message:find('prelude builtin', 1, true) then
            table.insert(filtered, diagnostic)
          end
        end

        result = vim.deepcopy(result)
        result.diagnostics = filtered
      end

      return default_publish_diagnostics(err, result, ctx, config)
    end,
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
