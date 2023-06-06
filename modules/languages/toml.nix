{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.toml;

  defaultServer = "taplo-lsp";
  servers = {
    taplo-lsp = {
      package = pkgs.taplo-lsp;
      lspConfig = ''
        lspconfig.taplo.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${cfg.lsp.package}/bin/taplo", "lsp", "stdio"},
        }
      '';
    };
  };
in {
  options.vim.languages.toml = {
    enable = mkEnableOption "Toml language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Toml treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "toml";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Toml LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Toml LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Toml LSP server package";
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
      vim.lsp.lspconfig.sources.toml-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
