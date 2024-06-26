{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.bash;

  defaultServer = "bash-language-server";
  servers = {
    bash-language-server = {
      package = pkgs.nodePackages_latest.bash-language-server;
      lspConfig = ''
        lspconfig.bashls.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${cfg.lsp.package}/bin/bash-language-server", "start"},
        }
      '';
    };
  };
in {
  options.vim.languages.bash = {
    enable = mkEnableOption "Bash language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Bash treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "bash";
    };

    lsp = {
      enable = mkOption {
        description = "Enable Bash LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Bash LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Bash LSP server package";
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
      vim.lsp.lspconfig.sources.bash-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf config.vim.debugger.nvim-dap.enable {
      vim.startPlugins = with pkgs; [
        bashdb
      ];
      vim.luaConfigRC.pythonDebug = nvim.dag.entryAfter ["debugger"] ''
        dap.adapters.bashdb = {
          type = 'executable';
          command =  "${pkgs.bashdb}/bin/bashdb";
          name = 'bashdb';
        }
        dap.configurations.sh = {
          {
            type = 'bashdb';
            request = 'launch';
            name = "Launch file";
            showDebugOutput = true;
            pathBashdb = "${pkgs.bashdb}/bin/bashdb";
            pathBashdbLib = "${pkgs.bashdb}/share/bashdb/lib";
            trace = true;
            file = "''${file}";
            program = "''${file}";
            cwd = "''${workspaceFolder}";
            pathCat = "cat";
            pathBash = "${pkgs.bash}/bin/bash";
            pathMkfifo = "mkfifo";
            pathPkill = "pkill";
            args = {};
            env = {};
            terminalKind = "integrated";
          }
        }
      '';
    })
  ]);
}
