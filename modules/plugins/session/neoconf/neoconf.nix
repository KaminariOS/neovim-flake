{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.session.neoconf = {
    enable = mkEnableOption "neoconf.nvim: a Neovim plugin to manage global and project-local settings.";
  };
}
