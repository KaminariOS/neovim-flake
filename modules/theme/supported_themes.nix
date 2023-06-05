{lib}: {
  onedark = {
    setup = {
      style ? "dark",
      transparent,
    }: ''
      -- OneDark theme
      require('onedark').setup {
        style = "${style}"
      }
      require('onedark').load()
    '';
    styles = ["dark" "darker" "cool" "deep" "warm" "warmer"];
  };

  nightfox = {
    setup = {
      style ? "mocha",
      transparent ? false,
    }: ''
-- Default options
require('nightfox').setup({
  options = {
    -- Compiled file's destination location
    compile_path = vim.fn.stdpath("cache") .. "/nightfox",
    compile_file_suffix = "_compiled", -- Compiled file suffix
    transparent = ${lib.boolToString transparent},     -- Disable setting background
    terminal_colors = true,  -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
    dim_inactive = false,    -- Non focused panes set to alternative background
    module_default = true,   -- Default enable value for modules
    colorblind = {
      enable = false,        -- Enable colorblind support
      simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
      severity = {
        protan = 0,          -- Severity [0,1] for protan (red)
        deutan = 0,          -- Severity [0,1] for deutan (green)
        tritan = 0,          -- Severity [0,1] for tritan (blue)
      },
    },
    styles = {               -- Style to be applied to different syntax groups
      comments = "NONE",     -- Value is any valid attr-list value `:help attr-list`
      conditionals = "NONE",
      constants = "NONE",
      functions = "NONE",
      keywords = "NONE",
      numbers = "NONE",
      operators = "NONE",
      strings = "NONE",
      types = "NONE",
      variables = "NONE",
    },
    inverse = {             -- Inverse highlight for different types
      match_paren = false,
      visual = false,
      search = false,
    },
    modules = {             -- List of various plugins and additional options
    },
  },
  palettes = {},
  specs = {},
  groups = {},
})

-- setup must be called before loading
vim.cmd("colorscheme nightfox")
    '';
    styles = ["mocha"];
  };

  tokyonight = {
    setup = {
      style ? "night",
      transparent,
    }: ''
      require('tokyonight').setup {
        transparent = ${lib.boolToString transparent};
      }
      vim.cmd[[colorscheme tokyonight-${style}]]
    '';
    styles = ["day" "night" "storm" "moon"];
  };

  dracula = {
    setup = {
      style ? null,
      transparent,
    }: ''
      require('dracula').setup({
        transparent_bg = ${lib.boolToString transparent},
      });
      require('dracula').load();
    '';
  };

  catppuccin = {
    setup = {
      style ? "mocha",
      transparent ? false,
    }: ''
      -- Catppuccin theme
      require('catppuccin').setup {
        flavour = "${style}",
        transparent_background = ${lib.boolToString transparent},
        integrations = {
      	  nvimtree = {
      		  enabled = true,
      		  transparent_panel = ${lib.boolToString transparent},
      		  show_root = true,
      	  },

          hop = true,
      	  gitsigns = true,
      	  telescope = true,
      	  treesitter = true,
      	  ts_rainbow = true,
          fidget = true,
          alpha = true,
          leap = true,
          markdown = true,
          noice = true,
          notify = true, -- nvim-notify
          which_key = true,
          navic = {
            enabled = false,
            custom_bg = "NONE", -- "lualine" will set background to mantle
          },
        },
      }
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = ["latte" "frappe" "macchiato" "mocha"];
  };

  oxocarbon = {
    setup = {
      style ? "dark",
      transparent ? false,
    }: let
      style' =
        lib.warnIf (style == "light") "oxocarbon: light theme is not well-supported" style;
    in ''
      require('oxocarbon')
      vim.opt.background = "${style'}"
      vim.cmd.colorscheme = "oxocarbon"
    '';
    styles = ["dark" "light"];
  };
}
