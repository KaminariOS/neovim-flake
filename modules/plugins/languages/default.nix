{lib, ...}: let
  inherit (lib.nvim.languages) mkEnable;
in {
  imports = [
    ./asm.nix
    ./astro.nix
    ./bash.nix
    ./dart.nix
    ./clang.nix
    ./css.nix
    ./elixir.nix
    ./gleam.nix
    ./go.nix
    ./hcl.nix
    ./kotlin.nix
    ./html.nix
    ./haskell.nix
    ./java.nix
    ./lua.nix
    ./markdown.nix
    ./nim.nix
    ./vala.nix
    ./nix.nix
    ./ocaml.nix
    ./php.nix
    ./python.nix
    ./r.nix
    ./rust.nix
    ./scala.nix
    ./sql.nix
    ./ts.nix
    ./zig.nix
    ./html.nix
    ./tex.nix
    ./toml.nix
    ./svelte.nix
    ./tailwind.nix
    ./json.nix
    ./yaml.nix
    ./cmake.nix
    ./java.nix
    ./lua.nix
    ./php.nix
    ./terraform.nix
    ./ts.nix
    ./typst.nix
    ./zig.nix
    ./csharp.nix
    ./julia.nix
    ./nu.nix
    ./odin.nix
    ./vim.nix
    ./neodev.nix
    ./lua.nix
    ./vue.nix
  ];

  options.vim.languages = {
    enableLSP = mkEnable "LSP";
    enableDAP = mkEnable "Debug Adapter";
    enableTreesitter = mkEnable "Treesitter";
    enableFormat = mkEnable "Formatting";
    enableExtraDiagnostics = mkEnable "extra diagnostics";
  };
}
