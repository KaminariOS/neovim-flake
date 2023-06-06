{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.tex;

  defaultServer = "texlab";
  servers = {
    texlab = {
      package = pkgs.texlab;
      lspConfig = ''
        lspconfig.texlab.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${cfg.lsp.package}/bin/texlab"},
        }
      '';
    };
  };
in {
  options.vim.languages.tex = {
    enable = mkEnableOption "Tex language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Tex treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "tex";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Tex LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Tex LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Tex LSP server package";
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
      vim.lsp.lspconfig.sources.tex-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
