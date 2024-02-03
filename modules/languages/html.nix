{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types nvim mkIf mkMerge optional;

  cfg = config.vim.languages.html;
in {
  options.vim.languages.html = {
    enable = mkEnableOption "HTML language support";

    treesitter = {
      enable = mkOption {
        description = "Enable HTML treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "html";

      autotagHtml = mkOption {
        description = "Enable autoclose/autorename of html tags (nvim-ts-autotag)";
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enable {
      vim.startPlugins = with pkgs; [vscode-langservers-extracted];
      vim.luaConfigRC.html = ''
        --Enable (broadcasting) snippet capability for completion
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        require'lspconfig'.html.setup{
          capabilities = capabilities,
          cmd = { "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server", "--stdio" }
        }
        require'lspconfig'.cssls.setup{
          capabilities = capabilities,
          cmd = { "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server", "--stdio" }
        }
        require'lspconfig'.eslint.setup{
          cmd = { "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server", "--stdio" }
        }
      '';
    })
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];

      vim.startPlugins =
        optional cfg.treesitter.autotagHtml "nvim-ts-autotag";

      vim.luaConfigRC.html-autotag = mkIf cfg.treesitter.autotagHtml (nvim.dag.entryAnywhere ''
        require('nvim-ts-autotag').setup()
      '');
    })
  ]);
}
