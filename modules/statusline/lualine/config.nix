{
  config,
  lib,
  ...
}: let
  cfg = config.vim.statusline.lualine;
  breadcrumbsCfg = config.vim.ui.breadcrumbs;
  inherit (lib) mkIf nvim boolToString optionalString;
in {
  config = (mkIf cfg.enable) {
    vim.startPlugins = [
      "lualine"
    ];

    vim.luaConfigRC.lualine = nvim.dag.entryAnywhere ''
      local colors = {
        bg       = '#202328',
        fg       = '#bbc2cf',
        yellow   = '#ECBE7B',
        cyan     = '#008080',
        darkblue = '#081633',
        green    = '#98be65',
        orange   = '#FF8800',
        violet   = '#a9a1e1',
        magenta  = '#c678dd',
        blue     = '#51afef',
        red      = '#ec5f67',
      }
      local lualine = require('lualine')
      lualine.setup {
        options = {
          icons_enabled = ${boolToString cfg.icons.enable},
          theme = "${cfg.theme}",
          component_separators = {"${cfg.componentSeparator.left}","${cfg.componentSeparator.right}"},
          section_separators = {"${cfg.sectionSeparator.left}","${cfg.sectionSeparator.right}"},
          disabled_filetypes = { 'alpha' },
          always_divide_middle = true,
          globalstatus = ${boolToString cfg.globalStatus},
          ignore_focus = {'NvimTree'},
          extensions = {${optionalString config.vim.filetree.nvimTree.enable "'nvim-tree'"}},
          refresh = {
            statusline = ${toString cfg.refresh.statusline},
            tabline = ${toString cfg.refresh.tabline},
            winbar = ${toString cfg.refresh.winbar},
          },
        },
        -- active sections
        sections = {
          lualine_a = ${nvim.lua.luaTable (cfg.activeSection.a ++ cfg.extraActiveSection.a)},
          lualine_b = ${nvim.lua.luaTable (cfg.activeSection.b ++ cfg.extraActiveSection.b)},
          lualine_c = ${nvim.lua.luaTable (cfg.activeSection.c ++ cfg.extraActiveSection.c)},
          lualine_x = ${nvim.lua.luaTable (cfg.activeSection.x ++ cfg.extraActiveSection.x)},
          lualine_y = ${nvim.lua.luaTable (cfg.activeSection.y ++ cfg.extraActiveSection.y)},
          lualine_z = ${nvim.lua.luaTable (cfg.activeSection.z ++ cfg.extraActiveSection.z)},
        },
        -- inactive sections
        inactive_sections = {
          lualine_a = ${nvim.lua.luaTable (cfg.inactiveSection.a ++ cfg.extraInactiveSection.a)},
          lualine_b = ${nvim.lua.luaTable (cfg.inactiveSection.b ++ cfg.extraInactiveSection.b)},
          lualine_c = ${nvim.lua.luaTable (cfg.inactiveSection.c ++ cfg.extraInactiveSection.c)},
          lualine_x = ${nvim.lua.luaTable (cfg.inactiveSection.x ++ cfg.extraInactiveSection.x)},
          lualine_y = ${nvim.lua.luaTable (cfg.inactiveSection.y ++ cfg.extraInactiveSection.y)},
          lualine_z = ${nvim.lua.luaTable (cfg.inactiveSection.z ++ cfg.extraInactiveSection.z)},
        },
        tabline = {},
        extensions = {
          ${
        if (config.vim.filetree.nvimTree.enable)
        then "\"nvim-tree\","
        else ""
      }
          ${
        if (config.vim.debugger.nvim-dap.enable)
        then "\"nvim-dap-ui\","
        else ""
      }

          ${
        if (config.vim.terminal.toggleterm.enable)
        then "\"toggleterm\","
        else ""
      }

          ${
        if (config.vim.lsp.trouble.enable)
        then "\"trouble\","
        else ""
      }
        },

        ${optionalString (breadcrumbsCfg.enable && breadcrumbsCfg.source == "nvim-navic") ''
        winbar = {
          lualine_c = {
            {
                "navic",
                draw_empty = ${boolToString config.vim.ui.breadcrumbs.alwaysRender}
            }
          }
        },
      ''}
      }
    '';
  };
}
