inputs: let
  modulesWithInputs = import ./modules inputs;

  neovimConfiguration = {
    modules ? [],
    pkgs,
    lib ? pkgs.lib,
    check ? true,
    extraSpecialArgs ? {},
  }:
    modulesWithInputs {
      inherit pkgs lib check extraSpecialArgs;
      configuration.imports = modules;
    };

  tidalConfig = {
    config.vim.languages.tidal.enable = !true;
  };

  mainConfig = isMaximal: {
    config = {
      vim = {
        viAlias = true;
        vimAlias = true;
        debugMode = {
          enable = false;
          level = 20;
          logFile = "/tmp/nvim.log";
        };
      };

      vim.lsp = {
        formatOnSave = false;
        lspkind.enable = false;
        lightbulb.enable = true;
        lspsaga.enable = false;
        nvimCodeActionMenu.enable = true;
        trouble.enable = true;
        lspSignature.enable = true;
        lsplines.enable = isMaximal;
        nvim-docs-view.enable = isMaximal;
      };

      vim.debugger = {
        nvim-dap = {
          enable = true;
          ui.enable = true;
        };
      };

      vim.languages = {
        enableLSP = true;
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nix.enable = true;
        html = {
          enable = true;
          treesitter.autotagHtml = true;
        };
        clang = {
          enable = true;
          lsp.server = "clangd";
        };
        sql.enable = isMaximal;
        bash.enable = true;
        vim.enable = isMaximal;
        tex.enable = true;
        yaml.enable = isMaximal;
        toml.enable = isMaximal;
        cmake.enable = isMaximal;
        json.enable = isMaximal;
        rust = {
          enable = true;
          crates.enable = true;
        };
        java.enable = isMaximal;
        ts.enable = isMaximal;
        svelte.enable = isMaximal;
        vue.enable = true;
        go.enable = isMaximal;
        zig.enable = isMaximal;
        python.enable = true;
        dart.enable = isMaximal;
        elixir.enable = false;
        terraform.enable = isMaximal;
        markdown.enable = true;
      };

      vim.visuals = {
        enable = true;
        nvimWebDevicons.enable = true;
        scrollBar.enable = true;
        smoothScroll.enable = true;
        cellularAutomaton.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;

        indentBlankline = {
          enable = true;
          fillChar = null;
          eolChar = null;
          scope = {
            enabled = true;
          };
        };

        cursorline = {
          enable = true;
          lineTimeout = 0;
        };
      };

      vim.statusline = {
        lualine = {
          enable = true;
          theme = "catppuccin";
        };
      };

      vim.theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = true;
      };
      vim = {
        autopairs.enable = true;
        autosaving.enable = true;
      };

      vim.autocomplete = {
        enable = true;
        type = "nvim-cmp";
      };

      vim.filetree = {
        nvimTree = {
          enable = true;
          renderer = {
            rootFolderLabel = true;
          };
          view = {
            width = 25;
          };
          actions = {
            openFile = {
              quitOnOpen = true;
            };
          };
          # openTreeOnNewTab = false;
          openOnSetup = false;
          diagnostics = {
            enable = true;
            showOnDirs = true;
          };
          git = {
            enable = true;
          };
          modified = {
            enable = true;
          };
          renderer = {
            highlightGit = true;
            highlightModified = "all";
            highlightOpenedFiles = "all";
            icons = {
              gitPlacement = "after";
              modifiedPlacement = "before";
              show = {
                git = true;
                modified = true;
              };
            };
          };
        };
      };

      vim.tabline = {
        nvimBufferline.enable = true;
      };

      vim.treesitter.context.enable = true;

      vim.binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      vim.telescope.enable = true;

      vim.git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions = false; # throws an annoying debug message
      };

      vim.minimap = {
        minimap-vim.enable = false;
        codewindow.enable = true; # lighter, faster, and uses lua for configuration
      };

      vim.dashboard = {
        dashboard-nvim.enable = false;
        alpha.enable = true;
      };

      vim.notify = {
        nvim-notify.enable = true;
      };

      vim.projects = {
        project-nvim.enable = true;
      };

      vim.utility = {
        ccc.enable = isMaximal;
        vim-wakatime.enable = false;
        icon-picker.enable = isMaximal;
        surround.enable = isMaximal;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = true;
        };
      };

      vim.notes = {
        obsidian.enable = false; # FIXME neovim fails to build if obsidian is enabled
        orgmode.enable = false;
        mind-nvim.enable = true;
        todo-comments.enable = true;
      };

      vim.terminal = {
        toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
      };

      vim.ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false; # the theme looks terrible with catppuccin
        illuminate.enable = true;
        breadcrumbs = {
          enable = isMaximal;
          navbuddy.enable = isMaximal;
        };
        smartcolumn = {
          enable = !true;
          columnAt.languages = {
            # this is a freeform module, it's `buftype = int;` for configuring column position
            nix = 110;
            ruby = 120;
            java = 130;
            go = [90 130];
          };
        };
      };

      vim.assistant = {
        copilot = {
          enable = isMaximal;
          cmp.enable = true;
        };
      };

      vim.session = {
        nvim-session-manager.enable = true;
        neoconf.enable = true;
      };

      vim.gestures = {
        gesture-nvim.enable = false;
      };

      vim.comments = {
        comment-nvim.enable = true;
      };

      vim.presence = {
        presence-nvim = {
          enable = true;
          auto_update = true;
          image_text = "The Superior Text Editor";
          client_id = "793271441293967371";
          main_image = "neovim";
          show_time = true;
          rich_presence = {
            editing_text = "Editing %s";
          };
        };
      };
    };
  };
in {
  inherit neovimConfiguration mainConfig tidalConfig;
}
