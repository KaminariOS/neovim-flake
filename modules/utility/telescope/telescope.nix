{lib, ...}: let
  inherit (lib) mkMappingOption mkEnableOption;
in {
  options.vim.telescope = {
    mappings = {
      findProjects = mkMappingOption "Find files [Telescope]" "<leader>fp";

      findFiles = mkMappingOption "Find files [Telescope]" "<leader>ff";
      liveGrep = mkMappingOption "Live grep [Telescope]" "<leader>fg";
      buffers = mkMappingOption "Buffers [Telescope]" "<leader>fb";
      helpTags = mkMappingOption "Help tags [Telescope]" "<leader>fh";
      open = mkMappingOption "Open [Telescope]" "<leader>ft";

      gitCommits = mkMappingOption "Git commits [Telescope]" "<leader>fvcw";
      gitBufferCommits = mkMappingOption "Git buffer commits [Telescope]" "<leader>fvcb";
      gitBranches = mkMappingOption "Git branches [Telescope]" "<leader>fvb";
      gitStatus = mkMappingOption "Git status [Telescope]" "<leader>fvs";
      gitStash = mkMappingOption "Git stash [Telescope]" "<leader>fvx";

      lspDocumentSymbols = mkMappingOption "LSP Document Symbols [Telescope]" "<leader>flsb";
      lspWorkspaceSymbols = mkMappingOption "LSP Workspace Symbols [Telescope]" "<leader>flsw";
      lspReferences = mkMappingOption "LSP References [Telescope]" "<leader>rr";
      lspImplementations = mkMappingOption "LSP Implementations [Telescope]" "<leader>fli";
      lspDefinitions = mkMappingOption "LSP Definitions [Telescope]" "<leader>flD";
      lspTypeDefinitions = mkMappingOption "LSP Type Definitions [Telescope]" "<leader>flt";
      diagnostics = mkMappingOption "Diagnostics [Telescope]" "<leader>dd";

      treesitter = mkMappingOption "Treesitter [Telescope]" "<leader>fs";

      dapCommands = mkMappingOption "Dap commands[Telescope]" "<leader>dc";
      dapConfigurations = mkMappingOption "Dap commands[Telescope]" "<leader>do";
      dapListBreakpoints = mkMappingOption "Dap breakpoints[Telescope]" "<leader>dl"; 
      dapListVariables = mkMappingOption "Dap variables[Telescope]" "<leader>dv"; 
      dapListFrames = mkMappingOption "Dap frames[Telescope]" "<leader>df"; 
    };

    enable = mkEnableOption "telescope.nvim: multi-purpose search and picker utility";
  };
}
