{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.json;

  defaultServer = "vscode-json-languageserver";
  servers = {
    vscode-json-languageserver = {
      package = pkgs.nodePackages.vscode-json-languageserver;
      lspConfig = ''
        lspconfig.jsonls.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${cfg.lsp.package}/bin/vscode-json-languageserver", "--stdio"},
        }
      '';
    };
  };
in {
  options.vim.languages.json = {
    enable = mkEnableOption "Json language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Json treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "json";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Json LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Json LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Json LSP server package";
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
      vim.lsp.lspconfig.sources.json-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
