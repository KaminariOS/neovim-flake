{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.cmake;

  defaultServer = "cmake-language-server";
  servers = {
    cmake-language-server = {
      package = pkgs.cmake-language-server;
      lspConfig = ''
        lspconfig.cmake.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${cfg.lsp.package}/bin/cmake-language-server"},
        }
      '';
    };
  };
in {
  options.vim.languages.cmake = {
    enable = mkEnableOption "Cmake language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Cmake treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "cmake";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Cmake LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Cmake LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Cmake LSP server package";
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
      vim.lsp.lspconfig.sources.cmake-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
