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
    mkIf cfg.enable
    {
      vim.startPlugins = ["auto-save-nvim"];
      vim.luaConfigRC.autosave = nvim.dag.entryAnywhere ''
          require("auto-save").setup {
		-- your config goes here
		-- or just leave it empty :)
	      }
      '';
    };
}
