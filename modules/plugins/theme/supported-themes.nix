{
  config,
  lib,
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString warnIf;
  inherit (lib.nvim.lua) toLuaObject;
in {
  base16 = {
    setup = {base16-colors, ...}: ''
      -- Base16 theme
      require('base16-colorscheme').setup(${toLuaObject base16-colors})
    '';
  };

  onedark = {
    setup = {style ? "dark", ...}: ''
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
      ...
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
      ...
    }: ''
      require('tokyonight').setup {
        transparent = ${boolToString transparent};
      }
      vim.cmd[[colorscheme tokyonight-${style}]]
    '';
    styles = ["day" "night" "storm" "moon"];
  };

  dracula = {
    setup = {transparent, ...}: ''
      require('dracula').setup({
        transparent_bg = ${boolToString transparent},
      });
      require('dracula').load();
    '';
  };

  catppuccin = {
    setup = {
      style ? "mocha",
      transparent ? false,
      ...
    }: ''
      -- Catppuccin theme
      require('catppuccin').setup {
        flavour = "${style}",
        transparent_background = ${boolToString transparent},
        term_colors = true,
        integrations = {
      	  nvimtree = {
      		  enabled = true,
      		  transparent_panel = ${boolToString transparent},
      		  show_root = true,
      	  },

          hop = true,
      	  gitsigns = true,
      	  telescope = true,
      	  treesitter = true,
          treesitter_context = true,
      	  ts_rainbow = true,
          fidget = true,
          alpha = true,
          leap = true,
          markdown = true,
          noice = true,
          notify = true, -- nvim-notify
          which_key = true,
          navic = {
            enabled = true,
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
      ...
    }: let
      style' =
        warnIf (style == "light") "oxocarbon: light theme is not well-supported" style;
    in ''
       require('oxocarbon')
       vim.opt.background = "${style'}"
       vim.cmd.colorscheme = "oxocarbon"
      ${optionalString transparent ''
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        ${optionalString config.vim.filetree.nvimTree.enable ''
          vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
        ''}
      ''}
    '';
    styles = ["dark" "light"];
  };

  gruvbox = {
    setup = {
      style ? "dark",
      transparent ? false,
      ...
    }: ''
      -- Gruvbox theme
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = ${boolToString transparent},
      })
      vim.o.background = "${style}"
      vim.cmd("colorscheme gruvbox")
    '';
    styles = ["dark" "light"];
  };
  rose-pine = {
    setup = {
      style ? "main",
      transparent ? false,
      ...
    }: ''
      require("rose-pine").setup({
        dark_variant = "${style}", -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
          migrations = true,
        },

        styles = {
          bold = false,
          italic = false, -- I would like to add more options for this
          transparency = ${boolToString transparent},
        },
      })

      vim.cmd("colorscheme rose-pine")
    '';
    styles = ["main" "moon" "dawn"];
  };
}
