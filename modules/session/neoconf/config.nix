{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.session.neoconf;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [
      neoconf-nvim
    ];
    vim.luaConfigRC.neoconf = nvim.dag.entryBefore ["lspconfig"] ''
      require("neoconf").setup({
        -- override any of the default settings here
      })
    '';
  };
}
