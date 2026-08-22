{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.preview.markdownPreview;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [pkgs.vimPlugins.markdown-preview-nvim];

    vim.globals = {
      mkdp_auto_start = cfg.autoStart;
      mkdp_auto_close = cfg.autoClose;
      mkdp_refresh_slow = cfg.lazyRefresh;
      mkdp_filetypes = cfg.filetypes;
      mkdp_command_for_global = cfg.alwaysAllowPreview;
      mkdp_open_to_the_world = cfg.broadcastServer;
      mkdp_open_ip = cfg.customIP;
      mkdp_port = cfg.customPort;
    };

    vim.pluginRC.markdown-preview-external-changes = mkIf cfg.watchExternalChanges (entryAnywhere ''
      do
        local filetypes = ${toLuaObject (lib.genAttrs cfg.filetypes (_: true))}
        local watchers = {}

        local function stop_watcher(bufnr)
          local watcher = watchers[bufnr]
          if not watcher then
            return
          end

          watchers[bufnr] = nil
          watcher:stop()
          if not watcher:is_closing() then
            watcher:close()
          end
        end

        local function refresh_preview(bufnr)
          if vim.b[bufnr].MarkdownPreviewToggleBool ~= 1 then
            return
          end

          vim.api.nvim_buf_call(bufnr, function()
            vim.fn['mkdp#rpc#preview_refresh']()
          end)
        end

        local function watch_buffer(bufnr)
          stop_watcher(bufnr)

          if not vim.api.nvim_buf_is_valid(bufnr)
            or not vim.api.nvim_buf_is_loaded(bufnr)
            or not filetypes[vim.bo[bufnr].filetype]
          then
            return
          end

          local path = vim.api.nvim_buf_get_name(bufnr)
          if path == "" or not vim.uv.fs_stat(path) then
            return
          end

          vim.bo[bufnr].autoread = true
          local watcher = vim.uv.new_fs_event()
          if not watcher then
            return
          end

          watchers[bufnr] = watcher
          watcher:start(path, {}, function(err)
            if err then
              return
            end

            vim.schedule(function()
              if watchers[bufnr] ~= watcher then
                return
              end

              stop_watcher(bufnr)
              if vim.api.nvim_buf_is_valid(bufnr)
                and vim.api.nvim_buf_is_loaded(bufnr)
                and not vim.bo[bufnr].modified
              then
                vim.api.nvim_buf_call(bufnr, function()
                  vim.cmd('silent checktime')
                end)
              end

              vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  watch_buffer(bufnr)
                end
              end, 100)
            end)
          end)
        end

        local group = vim.api.nvim_create_augroup('markdown_preview_external_changes', { clear = true })

        vim.api.nvim_create_autocmd('FileType', {
          group = group,
          pattern = ${toLuaObject cfg.filetypes},
          callback = function(args)
            watch_buffer(args.buf)
          end,
        })

        vim.api.nvim_create_autocmd({ 'BufFilePost', 'BufWritePost' }, {
          group = group,
          callback = function(args)
            if filetypes[vim.bo[args.buf].filetype] then
              watch_buffer(args.buf)
            end
          end,
        })

        vim.api.nvim_create_autocmd('FileChangedShellPost', {
          group = group,
          callback = function(args)
            if filetypes[vim.bo[args.buf].filetype] then
              refresh_preview(args.buf)
            end
          end,
        })

        vim.api.nvim_create_autocmd('BufWipeout', {
          group = group,
          callback = function(args)
            stop_watcher(args.buf)
          end,
        })

        vim.api.nvim_create_autocmd('VimLeavePre', {
          group = group,
          callback = function()
            for bufnr in pairs(watchers) do
              stop_watcher(bufnr)
            end
          end,
        })
      end
    '');
  };
}
