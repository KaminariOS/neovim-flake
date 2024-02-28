{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.vim.lsp;
in {
  options.vim.lsp.none-ls = {
    enable = mkEnableOption "none-ls, also enabled automatically";

    sources = mkOption {
      description = "none-ls sources";
      type = with types; attrsOf str;
      default = {};
    };
  };
}
