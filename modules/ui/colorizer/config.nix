{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.lua) attrsetToLuaTable;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.ui.colorizer;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "nvim-colorizer-lua"
    ];

    vim.luaConfigRC.colorizer = entryAnywhere ''
      require('colorizer').setup({
        filetypes = ${attrsetToLuaTable cfg.filetypes},
        user_default_options = {
          RGB           = ${boolToString cfg.options.rgb};
          RRGGBB        = ${boolToString cfg.options.rrggbb};
          RRGGBBAA      = ${boolToString cfg.options.rrggbbaa};
          names         = ${boolToString cfg.options.names};
          rgb_fn        = ${boolToString cfg.options.rgb_fn};
          hsl_fn        = ${boolToString cfg.options.hsl_fn};
          css           = ${boolToString cfg.options.css};
          css_fn        = ${boolToString cfg.options.css_fn};
          mode          = '${toString cfg.options.mode}';
          tailwind      = ${boolToString cfg.options.tailwind};
          sass          = ${boolToString cfg.options.tailwind};
          always_update = ${boolToString cfg.options.alwaysUpdate};
        }
      })
    '';
  };
}
