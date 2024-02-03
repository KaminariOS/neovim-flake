{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.vim;

  defaultServer = "vim-language-server";
  servers = {
    vim-language-server = {
      package = pkgs.nodePackages.vim-language-server;
      lspConfig = ''
        lspconfig.vimls.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = { "${cfg.lsp.package}/bin/vim-language-server", "--stdio" };
        }
      '';
    };
  };
in {
  options.vim.languages.vim = {
    enable = mkEnableOption "Vim language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Vim treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "vim";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Vim LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Vim LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Vim LSP server package";
        type = types.package;
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.vim-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
