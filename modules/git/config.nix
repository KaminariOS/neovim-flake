{
  config,
  lib,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib) addDescriptionsToMappings mkIf mkMerge mkSetExprBinding mkSetLuaBinding nvim;

  cfg = config.vim.git;

  self = import ./git.nix {inherit lib;};
  gsMappingDefinitions = self.options.vim.git.gitsigns.mappings;

  gsMappings = addDescriptionsToMappings cfg.gitsigns.mappings gsMappingDefinitions;
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.gitsigns.enable (mkMerge [
      {
        vim.startPlugins = ["gitsigns-nvim"];

        vim.maps.normal = mkMerge [
          (mkSetExprBinding gsMappings.nextHunk ''
            function()
              if vim.wo.diff then return ${toJSON gsMappings.nextHunk.value} end

              vim.schedule(function() package.loaded.gitsigns.next_hunk() end)

              return '<Ignore>'
            end
          '')
          (mkSetExprBinding gsMappings.previousHunk ''
            function()
              if vim.wo.diff then return ${toJSON gsMappings.previousHunk.value} end

              vim.schedule(function() package.loaded.gitsigns.prev_hunk() end)

              return '<Ignore>'
            end
          '')

          (mkSetLuaBinding gsMappings.stageHunk "package.loaded.gitsigns.stage_hunk")
          (mkSetLuaBinding gsMappings.resetHunk "package.loaded.gitsigns.reset_hunk")
          (mkSetLuaBinding gsMappings.undoStageHunk "package.loaded.gitsigns.undo_stage_hunk")

          (mkSetLuaBinding gsMappings.stageBuffer "package.loaded.gitsigns.stage_buffer")
          (mkSetLuaBinding gsMappings.resetBuffer "package.loaded.gitsigns.reset_buffer")

          (mkSetLuaBinding gsMappings.previewHunk "package.loaded.gitsigns.preview_hunk")

          (mkSetLuaBinding gsMappings.blameLine "function() package.loaded.gitsigns.blame_line{full=true} end")
          (mkSetLuaBinding gsMappings.toggleBlame "package.loaded.gitsigns.toggle_current_line_blame")

          (mkSetLuaBinding gsMappings.diffThis "package.loaded.gitsigns.diffthis")
          (mkSetLuaBinding gsMappings.diffProject "function() package.loaded.gitsigns.diffthis('~') end")

          (mkSetLuaBinding gsMappings.toggleDeleted "package.loaded.gitsigns.toggle_deleted")
        ];

        vim.maps.visual = mkMerge [
          (mkSetLuaBinding gsMappings.stageHunk "function() package.loaded.gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end")
          (mkSetLuaBinding gsMappings.resetHunk "function() package.loaded.gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end")
        ];

        vim.luaConfigRC.gitsigns = nvim.dag.entryAnywhere ''
          require('gitsigns').setup {
            keymaps = {
              noremap = true,

              ['n <leader>gn'] = { expr = true, "&diff ? \'\' : '<cmd>Gitsigns next_hunk<CR>'"},
              ['n <leader>gp'] = { expr = true, "&diff ? \'\' : '<cmd>Gitsigns prev_hunk<CR>'"},

              ['n <leader>gs'] = '<cmd>Gitsigns stage_hunk<CR>',
              ['v <leader>gs'] = ':Gitsigns stage_hunk<CR>',
              ['n <leader>gu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
              ['n <leader>gr'] = '<cmd>Gitsigns reset_hunk<CR>',
              ['v <leader>gr'] = ':Gitsigns reset_hunk<CR>',
              ['n <leader>gR'] = '<cmd>Gitsigns reset_buffer<CR>',
              ['n <leader>gp'] = '<cmd>Gitsigns preview_hunk<CR>',
              ['n <leader>gb'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
              ['n <leader>gS'] = '<cmd>Gitsigns stage_buffer<CR>',
              ['n <leader>gU'] = '<cmd>Gitsigns reset_buffer_index<CR>',
              ['n <leader>gts'] = ':Gitsigns toggle_signs<CR>',
              ['n <leader>gtn'] = ':Gitsigns toggle_numhl<CR>',
              ['n <leader>gtl'] = ':Gitsigns toggle_linehl<CR>',
              ['n <leader>gtw'] = ':Gitsigns toggle_word_diff<CR>',

              -- Text objects
              ['o ih'] = ':<C-U>Gitsigns select_hunk<CR>',
              ['x ih'] = ':<C-U>Gitsigns select_hunk<CR>'
            },
            current_line_blame = true,
          }
        '';
      }

      (mkIf cfg.gitsigns.codeActions {
        vim.lsp.null-ls.enable = true;
        vim.lsp.null-ls.sources.gitsigns-ca = ''
          table.insert(
            ls_sources,
            null_ls.gcode_actions.gitsigns
          )
        '';
      })
    ]))
  ]);
}
