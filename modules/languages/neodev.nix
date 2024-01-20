{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.python;
in {
  vim.startPlugins = [pkgs.vimPlugins.neodev-nvim];
  vim.luaConfigRC.neodev = nvim.dag.entryBefore ["lspconfig"] ''
    -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
    require("neodev").setup({
      -- add any options here, or leave empty to use the default settings
      ${
      if config.vim.debugger.nvim-dap.enable
      then "library = { plugins = { 'nvim-dap-ui' }, types = true },"
      else ""
    }
    })
  '';
}
