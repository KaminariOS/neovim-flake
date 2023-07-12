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
            on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          
   -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map('n', '<leader>hs', gs.stage_hunk)
    map('n', '<leader>hr', gs.reset_hunk)
    map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
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
