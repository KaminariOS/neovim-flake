{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) isList nvim mkEnableOption mkOption types mkIf mkMerge optionalString boolToString optionals mkBinding;

  cfg = config.vim.languages.rust;
in {
  options.vim.languages.rust = {
    enable = mkEnableOption "Rust language support";

    treesitter = {
      enable = mkEnableOption "Rust treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = nvim.types.mkGrammarOption pkgs "rust";
    };

    crates = {
      enable = mkEnableOption "crates-nvim, tools for managing dependencies";
      codeActions = mkOption {
        description = "Enable code actions through none-ls";
        type = types.bool;
        default = true;
      };
    };

    lsp = {
      enable = mkEnableOption "Rust LSP support (rust-analyzer with extra tools)" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "rust-analyzer package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = with types; either package (listOf str);
        default = pkgs.rust-analyzer;
      };

      opts = mkOption {
        description = "Options to pass to rust analyzer";
        type = types.str;
        default = "";
      };
    };

    dap = {
      enable = mkOption {
        description = "Rust Debug Adapter support";
        type = types.bool;
        default = config.vim.languages.enableDAP;
      };
      package = mkOption {
        description = "lldb pacakge";
        type = types.package;
        default = pkgs.lldb;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.crates.enable {
      vim.lsp.none-ls.enable = mkIf cfg.crates.codeActions true;

      vim.startPlugins = ["crates-nvim"];

      vim.autocomplete.sources = {"crates" = "[Crates]";};

      vim.maps.normal = mkMerge [
        (mkBinding "<leader>cf" ":lua require('crates').show_features_popup()<cr>" "[Crates]Show features popup")
        (mkBinding "<leader>cu" ":lua require('crates').update_crate()<cr>" "[Crates]Update crate")
        (mkBinding "<leader>cd" ":lua require('crates').show_dependencies_popup()<cr>" "[Crates]Show deps")
      ];

      vim.luaConfigRC.rust-crates = nvim.dag.entryAnywhere ''
        local crates = require('crates')
        local opts = { silent = true }
        crates.setup {
          null_ls = {
            enabled = ${boolToString cfg.crates.codeActions},
            name = "crates.nvim",
          }
        }
        local function show_documentation()
            local filetype = vim.bo.filetype
            if filetype == "vim" or filetype == "help" then
                vim.cmd('h '..vim.fn.expand('<cword>'))
            elseif filetype == "man" then
                vim.cmd('Man '..vim.fn.expand('<cword>'))
            elseif vim.fn.expand('%:t') == 'Cargo.toml' and require('crates').popup_available() then
                crates.show_popup()
            else
                vim.lsp.buf.hover()
            end
        end
        vim.keymap.set('n', 'K', show_documentation, opts)
      '';
    })
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
    (mkIf (cfg.lsp.enable || cfg.dap.enable) {
      vim.startPlugins =
        (
          # with pkgs.vimPlugins;
          [
            "rustaceanvim"
          ]
        )
        ++ optionals cfg.dap.enable [cfg.dap.package];

      vim.maps.normal = mkMerge [
        (mkBinding "<leader>rm" ":RustLsp expandMacro<CR>" "[Rust]expand_macro")
        (mkBinding "<leader>rd" ":RustLsp debuggables last<CR>" "[Rust]Debuggables")
        (mkBinding "<leader>rr" ":RustLsp runnables last<CR>" "[Rust]Runnables")
        (mkBinding "<leader>rl" ":RustLsp runnables<CR>" "[Rust]Runnables")
        (mkBinding "<leader>rc" ":RustLsp openCargo<CR>" "[Rust]open_cargo_toml")
        (mkBinding "<leader>rg" ":RustLsp crateGraph<CR>" "[Rust]Crate graph")
        (mkBinding "<leader>rp" ":RustLsp rebuildProcMacros<CR>" "[Rust]Rebuild proc macros")
        (mkBinding "<leader>rj" ":RustLsp joinLines<CR>" "[Rust]joinLines")
        (mkBinding "<leader>rs" ":RustLsp syntaxTree<CR>" "[Rust]View Syntax Tree")
        (mkBinding "<leader>rvh" ":RustLsp view hir<CR>" "[Rust]View HIR")
        (mkBinding "<leader>rvm" ":RustLsp view mir<CR>" "[Rust]View MIR")
        (mkBinding "<leader>rn" ":RustLsp renderDiagnostic<CR>" "[Rust]Render diagnostics")
      ];

      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.rust-lsp = ''
                vim.g.cargo_shell_command_runner = '!'

                rust_on_attach = function(client, bufnr)
                  default_on_attach(client, bufnr)
                  vim.lsp.inlay_hint.enable(true, {bufnr})
                  local opts = { noremap=true, silent=true, buffer = bufnr }
                  ${optionalString cfg.dap.enable ''
          vim.keymap.set(
            "n", "${config.vim.debugger.nvim-dap.mappings.continue}",
            function()
              local dap = require("dap")
              if dap.status() == "" then
                vim.cmd "RustDebuggables"
              else
                dap.continue()
              end
            end,
            opts
          )
        ''}
                end

                vim.g.rustaceanvim = {
                  -- Plugin configuration
                  tools = {
                  },
                  -- LSP configuration
                  server = {
                    on_attach = rust_on_attach,
                    cmd = function()
                      return {"${cfg.lsp.package}/bin/rust-analyzer"}
                    end,
                    settings = {
                      -- rust-analyzer language server configuration
                      ['rust-analyzer'] = {

                      },
                    },
                  },
                  -- DAP configuration
                  ${optionalString cfg.dap.enable ''
          dap = {
            adapter = {
              type = "executable",
              command = "${cfg.dap.package}/bin/lldb-vscode",
              name = "rt_lldb",
            },
          },
        ''}
                }
                local rustopts = {
                  tools = {
                    hover_with_actions = false,
                  },
                  server = {
                    capabilities = capabilities,
                    on_attach = rust_on_attach,
                    cmd = ${
          if isList cfg.lsp.package
          then nvim.lua.expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/rust-analyzer"}''
        },
                    settings = {
                      ${cfg.lsp.opts}
                    }
                  },
                }
      '';
    })
    (mkIf config.vim.debugger.nvim-dap.enable {
      vim.luaConfigRC.rustDebug = nvim.dag.entryAfter ["debugger"] ''
        dap.configurations.rust = {
          {

            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},

            initCommands = function()
              -- Find out where to look for the pretty printer Python module
              local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

              local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
              local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

              local commands = {}
              local file = io.open(commands_file, 'r')
              if file then
                for line in file:lines() do
                  table.insert(commands, line)
                end
                file:close()
              end
              table.insert(commands, 1, script_import)

              return commands
            end,
            -- ...,
          }
        }
      '';
    })
  ]);
}
