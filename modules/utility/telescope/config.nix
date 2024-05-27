{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf mkMerge mkSetBinding nvim;

  cfg = config.vim.telescope;
  self = import ./telescope.nix {inherit lib;};
  mappingDefinitions = self.options.vim.telescope.mappings;

  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins =
      [
        "telescope"
      ]
      ++ (with pkgs.vimPlugins; [
        telescope-live-grep-args-nvim
      ]);

    vim.maps.normal = mkMerge [
      (mkSetBinding mappings.findFiles "<cmd> Telescope find_files<CR>")
      (mkSetBinding mappings.liveGrep "<cmd> Telescope live_grep<CR>")
      (mkSetBinding mappings.buffers "<cmd> Telescope buffers<CR>")
      (mkSetBinding mappings.helpTags "<cmd> Telescope help_tags<CR>")
      (mkSetBinding mappings.open "<cmd> Telescope<CR>")

      (mkSetBinding mappings.gitCommits "<cmd> Telescope git_commits<CR>")
      (mkSetBinding mappings.gitBufferCommits "<cmd> Telescope git_bcommits<CR>")
      (mkSetBinding mappings.gitBranches "<cmd> Telescope git_branches<CR>")
      (mkSetBinding mappings.gitStatus "<cmd> Telescope git_status<CR>")
      (mkSetBinding mappings.gitStash "<cmd> Telescope git_stash<CR>")

      (mkIf config.vim.lsp.enable (mkMerge [
        (mkSetBinding mappings.lspDocumentSymbols "<cmd> Telescope lsp_document_symbols<CR>")
        (mkSetBinding mappings.lspWorkspaceSymbols "<cmd> Telescope lsp_workspace_symbols<CR>")

        (mkSetBinding mappings.lspReferences "<cmd> Telescope lsp_references<CR>")
        (mkSetBinding mappings.lspImplementations "<cmd> Telescope lsp_implementations<CR>")
        (mkSetBinding mappings.lspDefinitions "<cmd> Telescope lsp_definitions<CR>")
        (mkSetBinding mappings.lspTypeDefinitions "<cmd> Telescope lsp_type_definitions<CR>")
        (mkSetBinding mappings.diagnostics "<cmd> Telescope diagnostics<CR>")
      ]))

      (
        mkIf config.vim.debugger.nvim-dap.enable (
          mkMerge [
            (mkSetBinding mappings.dapCommands "<cmd> Telescope dap commands<CR>")
            (mkSetBinding mappings.dapConfigurations "<cmd> Telescope dap configurations<CR>")
            (mkSetBinding mappings.dapListVariables "<cmd> Telescope dap variables<CR>")
            (mkSetBinding mappings.dapListFrames "<cmd> Telescope dap frames<CR>")
            (mkSetBinding mappings.dapListBreakpoints "<cmd> Telescope dap breakpoints<CR>")
          ]
        )
      )
      (
        mkIf config.vim.treesitter.enable
        (mkSetBinding mappings.treesitter "<cmd> Telescope treesitter<CR>")
      )

      (
        mkIf config.vim.projects.project-nvim.enable
        (mkSetBinding mappings.findProjects "<cmd> Telescope projects<CR>")
      )

      (mkSetBinding mappings.aerial "<cmd> Telescope aerial<CR>")
    ];

    vim.luaConfigRC.telescope = nvim.dag.entryAnywhere ''
      local telescope = require('telescope')
      telescope.setup {
        defaults = {
          vimgrep_arguments = {
            "${pkgs.ripgrep}/bin/rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--no-ignore",
          },
          pickers = {
            find_command = {
              "${pkgs.fd}/bin/fd",
            },
          },
          file_ignore_patterns = { "node_modules", ".git/", "dist", "build", "target", "result" }, -- TODO: make this configurable
        },
        prompt_prefix = "     ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.8,
          height = 0.8,
          preview_cutoff = 120,
        },
        color_devicons = true,
        path_display = { "absolute" },
        set_env = { ["COLORTERM"] = "truecolor" },
        winblend = 0,
        border = {},
      }
      telescope.load_extension('live_grep_args')

      ${
        if config.vim.ui.noice.enable
        then "telescope.load_extension('noice')"
        else ""
      }

      ${
        if config.vim.notify.nvim-notify.enable
        then "telescope.load_extension('notify')"
        else ""
      }

      ${
        if config.vim.projects.project-nvim.enable
        then "telescope.load_extension('projects')"
        else ""
      }

      ${
        if config.vim.debugger.nvim-dap.enable
        then "telescope.load_extension('dap')"
        else ""
      }
    '';
  };
}
