vim.keymap.set('n', '<C-s>', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })

local function run_in_split(cmd)
  vim.cmd('botright split')
  vim.cmd('resize 12')
  vim.cmd('terminal ' .. cmd)
end

local telescope_ok, builtin = pcall(require, 'telescope.builtin')
if telescope_ok then
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
end

vim.keymap.set('n', '<leader>db', function()
  run_in_split('dotnet build')
end, { desc = 'Dotnet build' })

vim.keymap.set('n', '<leader>dt', function()
  run_in_split('dotnet test')
end, { desc = 'Dotnet test' })

vim.keymap.set('n', '<leader>dr', function()
  run_in_split('dotnet run')
end, { desc = 'Dotnet run' })

vim.keymap.set('n', '<leader>nf', function()
  vim.cmd('write')
  run_in_split('alejandra ' .. vim.fn.shellescape(vim.fn.expand('%:p')))
end, { desc = 'Format Nix file' })

vim.keymap.set('n', '<leader>ns', function()
  run_in_split('statix check .')
end, { desc = 'Statix check' })

vim.keymap.set('n', '<leader>nd', function()
  run_in_split('deadnix .')
end, { desc = 'Deadnix check' })

local spectre_ok, spectre = pcall(require, 'spectre')
if spectre_ok then
  vim.keymap.set('n', '<leader>S', function()
    spectre.toggle()
  end, { desc = 'Toggle Spectre' })

  vim.keymap.set('n', '<leader>sW', function()
    spectre.open_visual({ select_word = true })
  end, { desc = 'Replace current word' })

  vim.keymap.set('v', '<leader>sW', function()
    spectre.open_visual()
  end, { desc = 'Replace selection' })

  vim.keymap.set('n', '<leader>sp', function()
    spectre.open_file_search({ select_word = true })
  end, { desc = 'Search on current file' })
end
