{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types elem optional;

  supported_themes = import ./supported_themes.nix;
  colorPuccin =
    if config.vim.statusline.lualine.theme == "catppuccin"
    then "#181825"
    else "none";
in {
  options.vim.statusline.lualine = {
    enable = mkEnableOption "lualine statusline plugin";

    icons = {
      enable = mkEnableOption "icons for lualine" // {default = true;};
    };

    refresh = {
      statusline = mkOption {
        type = types.int;
        description = "Refresh rate for lualine";
        default = 1000;
      };
      tabline = mkOption {
        type = types.int;
        description = "Refresh rate for tabline";
        default = 1000;
      };
      winbar = mkOption {
        type = types.int;
        description = "Refresh rate for winbar";
        default = 1000;
      };
    };

    globalStatus = mkOption {
      type = types.bool;
      description = "Enable global status for lualine";
      default = true;
    };

    theme = let
      themeSupported = elem config.vim.theme.name supported_themes;
    in
      mkOption {
        description = "Theme for lualine";
        type = types.enum ([
            "auto"
            "16color"
            "gruvbox"
            "ayu_dark"
            "ayu_light"
            "ayu_mirage"
            "codedark"
            "dracula"
            "everforest"
            "gruvbox"
            "gruvbox_light"
            "gruvbox_material"
            "horizon"
            "iceberg_dark"
            "iceberg_light"
            "jellybeans"
            "material"
            "modus_vivendi"
            "molokai"
            "nightfly"
            "nord"
            "oceanicnext"
            "onelight"
            "palenight"
            "papercolor_dark"
            "papercolor_light"
            "powerline"
            "seoul256"
            "solarized_dark"
            "tomorrow"
            "wombat"
          ]
          ++ optional themeSupported config.vim.theme.name);
        default = "auto";
        # TODO: xml generation error if the closing '' is on a new line.
        # issue: https://gitlab.com/rycee/nmd/-/issues/10
        defaultText = ''`config.vim.theme.name` if theme supports lualine else "auto"'';
      };

    sectionSeparator = {
      left = mkOption {
        type = types.str;
        description = "Section separator for left side";
        default = "";
      };

      right = mkOption {
        type = types.str;
        description = "Section separator for right side";
        default = "";
      };
    };

    componentSeparator = {
      left = mkOption {
        type = types.str;
        description = "Component separator for left side";
        default = "";
      };

      right = mkOption {
        type = types.str;
        description = "Component separator for right side";
        default = "";
      };
    };

    activeSection = {
      a = mkOption {
        type = with types; listOf str;
        description = "active config for: | (A) | B | C       X | Y | Z |";
        default = [
          ''
            {
              "mode",
              icons_enabled = true,
              separator = {
              },
            }
          ''
        ];
      };

      b = mkOption {
        type = with types; listOf str;
        description = "active config for: | A | (B) | C       X | Y | Z |";
        default = [
          ''
            {
              "filetype",
              colored = true,
              icon_only = true,
              icon = { align = 'left' },
              color = {bg='none', fg='lavender'},
            }
          ''
          ''
            {
              "filename",
              color = {bg='none'},
              symbols = {modified = '', readonly = ''},
              path = 3,        -- 0: Just the filename
                               -- 1: Relative path
                               -- 2: Absolute path
                               -- 3: Absolute path, with tilde as the home directory
                               -- 4: Filename and parent dir, with tilde as the home directory
            }
          ''
        ];
      };

      c = mkOption {
        type = with types; listOf str;
        description = "active config for: | A | B | (C)       X | Y | Z |";
        default = [
          ''
            {
              "diff",
              colored = true,
              diff_color = {
                -- Same color values as the general color option can be used here.
                added = { fg = "#99c794", bg='none'},
                modified = { fg = "#5bb7b8",bg='none'},
                removed = { fg = "#ec5f67", bg='none'},
              },
              symbols = {added = '+', modified = '~', removed = '-'}, -- Changes the diff symbols
              -- color = {
              -- bg='none',
                -- fg= colors.red
              -- },
            }
          ''
        ];
      };

      x = mkOption {
        type = with types; listOf str;
        description = "active config for: | A | B | C       (X) | Y | Z |";
        default = [
          ''
            {'searchcount'},
            {
              -- Lsp server name
              function()
                local buf_ft = vim.api.nvim_get_option_value('filetype', {})

                -- List of buffer types to exclude
                local excluded_buf_ft = {"toggleterm", "NvimTree", "TelescopePrompt"}

                -- Check if the current buffer type is in the excluded list
                for _, excluded_type in ipairs(excluded_buf_ft) do
                  if buf_ft == excluded_type then
                    return ""
                  end
                end

                -- Get the name of the LSP server active in the current buffer
                local clients = vim.lsp.get_active_clients()
                local msg = 'No Active Lsp'

                -- if no lsp client is attached then return the msg
                if next(clients) == nil then
                  return msg
                end

                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                  end
                end

                return msg
              end,
              icon = ' ',
            }
          ''
          ''
            {
              "diagnostics",
              colored = true,
              sources = {'nvim_lsp', 'nvim_diagnostic', 'coc'},
              symbols = {error = '󰅙  ', warn = '  ', info = '  ', hint = '󰌵 '},
              diagnostics_color = {
                color_error = { fg = 'red' },
                color_warn = { fg = 'yellow' },
                color_info = { fg = 'cyan' },
              },
            }
          ''
          ''
            {
                symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '}
              }
          ''
        ];
      };

      y = mkOption {
        type = with types; listOf str;
        description = "active config for: | A | B | C       X | (Y) | Z |";
        default = [
          ''
            {
              "fileformat",
              color = {bg='none'},
              symbols = {
                unix = '', -- e712
                dos = '',  -- e70f
                mac = '',  -- e711
              },
            }
          ''
        ];
      };

      z = mkOption {
        type = with types; listOf str;
        description = "active config for: | A | B | C       X | Y | (Z) |";
        default = [
          ''
            {
              "progress",
              color = {bg='none', fg=colors.orange},
            }
          ''
          ''
            {
              "location",
              color = {bg='none', fg=colors.yellow},
            }
          ''
          ''
            {
              "branch",
              icon = ' •',
              color = {bg='none', fg=colors.blue},
            }
          ''
          ''
            {
              "datetime",
              style = "%H:%M",
              color = {bg='none', fg=colors.green},
            }
          ''
        ];
      };
    };
    extraActiveSection = {
      a = mkOption {
        type = with types; listOf str;
        description = "Extra entries for activeSection.a";
        default = [];
      };
      b = mkOption {
        type = with types; listOf str;
        description = "Extra entries for activeSection.b";
        default = [];
      };
      c = mkOption {
        type = with types; listOf str;
        description = "Extra entries for activeSection.c";
        default = [];
      };
      x = mkOption {
        type = with types; listOf str;
        description = "Extra entries for activeSection.x";
        default = [];
      };
      y = mkOption {
        type = with types; listOf str;
        description = "Extra entries for activeSection.y";
        default = [];
      };
      z = mkOption {
        type = with types; listOf str;
        description = "Extra entries for activeSection.z";
        default = [];
      };
    };

    inactiveSection = {
      a = mkOption {
        type = with types; listOf str;
        description = "inactive config for: | (A) | B | C       X | Y | Z |";
        default = [];
      };

      b = mkOption {
        type = with types; listOf str;
        description = "inactive config for: | A | (B) | C       X | Y | Z |";
        default = [];
      };

      c = mkOption {
        type = with types; listOf str;
        description = "inactive config for: | A | B | (C)       X | Y | Z |";
        default = ["'filename'"];
      };

      x = mkOption {
        type = with types; listOf str;
        description = "inactive config for: | A | B | C       (X) | Y | Z |";
        default = ["'location'"];
      };

      y = mkOption {
        type = with types; listOf str;
        description = "inactive config for: | A | B | C       X | (Y) | Z |";
        default = [];
      };

      z = mkOption {
        type = with types; listOf str;
        description = "inactive config for: | A | B | C       X | Y | (Z) |";
        default = [];
      };
    };
    extraInactiveSection = {
      a = mkOption {
        type = with types; listOf str;
        description = "Extra entries for inactiveSection.a";
        default = [];
      };
      b = mkOption {
        type = with types; listOf str;
        description = "Extra entries for inactiveSection.b";
        default = [];
      };
      c = mkOption {
        type = with types; listOf str;
        description = "Extra entries for inactiveSection.c";
        default = [];
      };
      x = mkOption {
        type = with types; listOf str;
        description = "Extra entries for inactiveSection.x";
        default = [];
      };
      y = mkOption {
        type = with types; listOf str;
        description = "Extra entries for inactiveSection.y";
        default = [];
      };
      z = mkOption {
        type = with types; listOf str;
        description = "Extra entries for inactiveSection.z";
        default = [];
      };
    };
  };
}
