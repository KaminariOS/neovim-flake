{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  config = {
    vim.theme = {
      enable = mkDefault false;
      name = mkDefault "onedark";
      style = mkDefault "darker";
      transparent = mkDefault true;
      extraConfig = mkDefault "";
    };
  };
}
