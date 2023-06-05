{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.autosaving;
in {
  config =
    mkIf (cfg.enable)
    {
      vim.startPlugins = with pkgs.vimPlugins; [auto-save-nvim];
    };
}
