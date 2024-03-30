{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) isList nvim mkEnableOption mkOption types mkIf mkMerge;

  cfg = config.vim.languages.vue;

  defaultServer = "vue";
  servers = {
    vue = {
      package = pkgs.nodePackages.vls;
      lspConfig = ''
        lspconfig.vuels.setup {
          capabilities = capabilities;
          on_attach = attach_keymaps,
          cmd = ${
          if isList cfg.lsp.package
          then nvim.lua.expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/vls", "--stdio"}''
        }
        }
      '';
    };
  };

  # TODO: specify packages
  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = pkgs.nodePackages.prettier;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.prettier.with({
            command = "${cfg.format.package}/bin/prettier",
          })
        )
      '';
    };
  };

  # TODO: specify packages
  defaultDiagnostics = [
  # "eslint_d"
  ];
  diagnostics = {
    # eslint_d = {
    #   package = pkgs.nodePackages.eslint_d;
    #   nullConfig = pkg: ''
    #     table.insert(
    #       ls_sources,
    #       null_ls.builtins.diagnostics.eslint_d.with({
    #         command = "${lib.getExe pkg}",
    #       })
    #     )
    #   '';
    # };
  };
in {
  options.vim.languages.vue = {
    enable = mkEnableOption "Vue language support";

    treesitter = {
      enable = mkEnableOption "Vue treesitter" // {default = config.vim.languages.enableTreesitter;};

      vuePackage = nvim.types.mkGrammarOption pkgs "svelte";
    };

    lsp = {
      enable = mkEnableOption "Vue LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Vue LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Vue LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = with types; either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "Vue formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Vue formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Vue formatter package";
        type = types.package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Vue diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = lib.nvim.types.diagnostics {
        langDesc = "Vue";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.vuePackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.vue-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.none-ls.enable = true;
      vim.lsp.none-ls.sources.vue-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.none-ls.enable = true;
      vim.lsp.none-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "vue";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })
  ]);
}
