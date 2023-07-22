{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages;
in {
  config = mkIf cfg.enableDebugger (mkMerge [
  (
    {
      vim.startPlugins = with pkgs.vimPlugins; [
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
        telescope-dap-nvim
        # neodev.nvim 
      ] ++ [pkgs.lldb];
      
     # vim.nnoremap = {
     #    "<leader>db" = "<cmd>lua require'dap'.toggle_breakpoint()<CR>";
     #    "<leader>dr" = "<cmd>lua require'dap'.continue()<CR>";
     #    "<leader>ds" = "<cmd>lua require'dap'.step_over()<CR>";
     #    "<leader>di" = "<cmd>lua require'dap'.step_into()<CR>";
     #    # "<leader>de" = "<cmd>lua require'dap'.repl.toggle()<CR>";
     #    "<leader>du" = "<cmd>lua require'dapui'.toggle()<CR>";
     #    "<leader>de" = "<cmd>lua require'dapui'.eval()<CR>";
     # };
      vim.luaConfigRC.debugger = nvim.dag.entryAnywhere ''
        local dap = require('dap')
        require("dapui").setup()
        require("nvim-dap-virtual-text").setup()

        dap.adapters.lldb = {
          type = 'executable',
          command = '${pkgs.lldb}/bin/lldb-vscode', -- adjust as needed, must be absolute path
          name = 'lldb'
        }

        dap.configurations.cpp = {
          {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},

            -- 💀
            -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
            --
            --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
            --
            -- Otherwise you might get the following error:
            --
            --    Error on launch: Failed to attach to the target process
            --
            -- But you should be aware of the implications:
            -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
            -- runInTerminal = false,
          },
        }

        -- If you want to use this for Rust and C, add something like this:

        dap.configurations.c = dap.configurations.cpp

      '';
    })

  ]); 
}
