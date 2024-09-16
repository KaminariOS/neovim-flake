{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.binds.whichKey;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = ["which-key"];

    vim.luaConfigRC.whichkey = nvim.dag.entryAnywhere ''
      local wk = require("which-key")
      wk.setup ({
        replace = {
          key = {
            {"<space>", "SPACE"},
            {"<leader>", "SPACE"},
            {"<cr>", "RETURN"},
            {"<tab>", "TAB"},
          }
        },

        ${lib.optionalString config.vim.ui.borders.plugins.which-key.enable ''
        win = {
          border = "${config.vim.ui.borders.plugins.which-key.style}",
        },
      ''}
      })

      wk.add({
        ${
        if config.vim.tabline.nvimBufferline.enable
        then ''
          -- Buffer
          { "<leader>b", group = "Buffer" },
          { "<leader>bm", group = "BufferLineMove" },
          { "<leader>bs", group = "BufferLineSort" },
          { "<leader>bsi", group = "BufferLineSortById" },
        ''
        else ""
      }

        ${
        if config.vim.telescope.enable
        then ''
          { "<leader>f", group = "Telescope" },
          { "<leader>fl", group = "Telescope LSP" },
          { "<leader>fm", group = "Cellular Automaton" },
          { "<leader>fv", group = "Telescope Git" },
          { "<leader>fvc", group = "Commits" },
        ''
        else ""
      }

        ${
        if config.vim.lsp.trouble.enable
        then ''
          -- Trouble
          { "<leader>lw", group = "Workspace" },
          { "<leader>x", group = "Trouble" },
          { "<leader>l", group = "Trouble" },
        ''
        else ""
      }

        ${
        if config.vim.lsp.nvimCodeActionMenu.enable
        then ''
          -- Parent Groups
          { "<leader>c", group = "CodeAction" },
        ''
        else ""
      }

        ${
        if config.vim.minimap.codewindow.enable || config.vim.minimap.minimap-vim.enable
        then ''
          -- Minimap
          { "<leader>m", group = "Minimap" },
        ''
        else ""
      }

        ${
        if config.vim.notes.mind-nvim.enable || config.vim.notes.obsidian.enable || config.vim.notes.orgmode.enable
        then ''
          -- Notes
          { "<leader>o", group = "Notes" },
          -- TODO: options for other note taking plugins and their individual binds
          -- TODO: move all note-taker binds under leader + o
        ''
        else ""
      }

        ${
        # TODO: This probably will need to be reworked for custom-keybinds
        if config.vim.filetree.nvimTree.enable
        then ''
          -- NvimTree
          { "<leader>t", group = "NvimTree" },
        ''
        else ""
      }

        ${
        if config.vim.git.gitsigns.enable
        then ''
          -- Git
          { "<leader>g", group = "Gitsigns" },
        ''
        else ""
      }

        ${
        if config.vim.languages.markdown.glow.enable
        then ''
          -- Markdown
          { "<leader>pm", group = "Preview Markdown" },
        ''
        else ""
      }

      })
    '';
  };
}
