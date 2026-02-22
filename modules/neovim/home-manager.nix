{ pkgs, ... }:

{
  home.packages = [
    pkgs.nodejs # Required for nvim-copilot
    pkgs.ripgrep # For nvim-telescope and nvim-spectre
    pkgs.fd # For nvim-telescope
    pkgs.tree-sitter # For nvim-treesitter
    pkgs.dotnet-sdk # For .NET development
    pkgs.omnisharp-roslyn # For C# LSP
    pkgs.netcoredbg # For .NET debugging
    pkgs.gcc # For nvim-lspconfig
    pkgs.typescript # For nvim-lspconfig
    pkgs.nixd # For nvim-lspconfig
    pkgs.alejandra # For Nix formatting
    pkgs.statix # For Nix linting
    pkgs.deadnix # For Nix dead code detection
    pkgs.nodePackages.typescript-language-server # For nvim-lspconfig
    pkgs.yaml-language-server # For nvim-lspconfig
    pkgs.terraform-ls # For nvim-lspconfig
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = builtins.readFile ./vimrc;
    initLua = builtins.concatStringsSep "\n" [
      (builtins.readFile ./options.lua)
      (builtins.readFile ./keymaps.lua)
    ];
    plugins =
      let
        mkLuaPlugin = plugin: file: {
          inherit plugin;
          type = "lua";
          config = builtins.readFile file;
        };

        corePlugins = [
          pkgs.vimPlugins.diffview-nvim
          pkgs.vimPlugins.nvim-web-devicons
          pkgs.vimPlugins.vim-visual-multi
        ];

        uiPlugins = [
          (mkLuaPlugin pkgs.vimPlugins.material-nvim ./plugins/material.lua)
          (mkLuaPlugin pkgs.vimPlugins.which-key-nvim ./plugins/which-key.lua)
          (mkLuaPlugin pkgs.vimPlugins.nvim-tree-lua ./plugins/nvim-tree-lua.lua)
          (mkLuaPlugin pkgs.vimPlugins.gitsigns-nvim ./plugins/gitsigns-nvim.lua)
        ];

        lspPlugins = [
          (mkLuaPlugin pkgs.vimPlugins.nvim-lspconfig ./plugins/nvim-lspconfig.lua)
        ];

        searchPlugins = [
          (mkLuaPlugin pkgs.vimPlugins.telescope-nvim ./plugins/telescope-nvim.lua)
          (mkLuaPlugin pkgs.vimPlugins.nvim-spectre ./plugins/nvim-spectre.lua)
          (mkLuaPlugin pkgs.vimPlugins.searchbox-nvim ./plugins/searchbox-nvim.lua)
          pkgs.vimPlugins.nui-nvim
          (mkLuaPlugin pkgs.vimPlugins.nvim-treesitter ./plugins/nvim-treesitter.lua)
        ];

        completionPlugins = [
          (mkLuaPlugin pkgs.vimPlugins.nvim-cmp ./plugins/nvim-cmp.lua)
          pkgs.vimPlugins.cmp-nvim-lsp
          pkgs.vimPlugins.cmp-buffer
          pkgs.vimPlugins.cmp-path
          pkgs.vimPlugins.cmp-git
          pkgs.vimPlugins.cmp-cmdline
          pkgs.vimPlugins.cmp-vsnip
          pkgs.vimPlugins.vim-vsnip
          pkgs.vimPlugins.markdown-preview-nvim
        ];
      in
      corePlugins
      ++ [ (mkLuaPlugin pkgs.vimPlugins.copilot-vim ./plugins/copilot-vim.lua) ]
      ++ uiPlugins
      ++ lspPlugins
      ++ searchPlugins
      ++ completionPlugins;
  };
}
