{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  inherit (lib.nvim.binds) pushDownDefault mkKeymap;
  #   cfg = config.vim.utility.aerial;
in {
  config =
    # mkIf (cfg.enable)
    {
      vim.startPlugins = [
      ];

      vim.lazy.plugins."aerial.nvim" = {
        package = pkgs.vimPlugins.aerial-nvim;
        setupModule = "aerial";
        before = optionalString config.vim.lazy.enable "require('lz.n').trigger_load('telescope')";
        after = ''
              require("aerial").setup({
          -- optionally use on_attach to set keymaps when aerial has attached to a buffer
          on_attach = function(bufnr)
            -- Jump forwards/backwards with '{' and '}'
            vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
            vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
          end,
          })
          -- You probably also want to set a keymap to toggle aerial
          vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
            require("telescope").load_extension("aerial")
        '';
        keys = [];
        # binds.whichKey.register = pushDownDefault {};
      };
    };
}
