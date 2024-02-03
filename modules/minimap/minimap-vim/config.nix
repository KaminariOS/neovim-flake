{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.vim.minimap.minimap-vim;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "minimap-vim"
    ];
  };
}
