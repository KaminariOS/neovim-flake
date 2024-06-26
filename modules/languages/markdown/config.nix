{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) nvim mkIf mkMerge mkOption types mkBinding;
  inherit (builtins) attrNames;

  cfg = config.vim.languages.markdown;
  defaultServer = "marksman";
  servers = {
    marksman = {
      package = pkgs.marksman;
      lspConfig = ''
        lspconfig.marksman.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${cfg.lsp.package}/bin/marksman", "server"};
        }
      '';
    };
  };
in {
  options.vim.languages.markdown = {
    lsp = {
      enable = mkOption {
        description = "Enable Markdown LSP support";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      server = mkOption {
        description = "Markdown LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };
      package = mkOption {
        description = "Markdown LSP server package";
        type = types.package;
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;

      vim.treesitter.grammars = [cfg.treesitter.mdPackage cfg.treesitter.mdInlinePackage];
    })
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.markdown-lsp = servers.${cfg.lsp.server}.lspConfig;
      vim.startPlugins = [pkgs.marksman];
    })
    (mkIf cfg.glow.enable {
      vim.startPlugins = ["glow-nvim" pkgs.glow];

      vim.globals = {
        # "glow_binary_path" = "${pkgs.glow}/bin";
      };

      vim.configRC.glow = nvim.dag.entryAnywhere ''
        autocmd FileType markdown noremap <leader>gl <cmd>Glow<CR>
      '';
    })
    (mkIf cfg.glow.enable {
      vim.startPlugins = with pkgs.vimPlugins; [markdown-preview-nvim];
      vim.maps.normal = mkMerge [
        (mkBinding "<leader>p" ":MarkdownPreviewToggle<cr>" "[Markdown]Preview toggle")
      ];
      vim.luaConfigRC.glow = nvim.dag.entryAnywhere ''
        require('glow').setup({
         glow_path = "${pkgs.glow}/bin/glow";
          -- your override config
        })
      '';
    })
  ]);
}
