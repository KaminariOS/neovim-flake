{
  lib,
  config,
  ...
}:
with lib;
with builtins; {
  options.vim = {
    autosaving = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable autosaving";
      };
    };
  };
}
