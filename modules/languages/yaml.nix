{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.yaml;

  defaultServer = "yaml-language-server";
  servers = {
    yaml-language-server = {
      package = pkgs.nodePackages.yaml-language-server;
      lspConfig = ''
        lspconfig.yamlls.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
        }
      '';
    };
  };
in {
  options.vim.languages.yaml = {
    enable = mkEnableOption "Yaml language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Yaml treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "yaml";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Yaml LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Yaml LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Yaml LSP server package";
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
      vim.lsp.lspconfig.sources.yaml-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
