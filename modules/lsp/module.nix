{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption;
in {
  options.vim.lsp = {
    enable = mkEnableOption "LSP, also enabled automatically through none-ls and lspconfig options";
    formatOnSave = mkEnableOption "format on save";
    mappings = {
      goToDefinition =
        mkMappingOption "Go to definition"
        "gd";
      goToDeclaration =
        mkMappingOption "Go to declaration"
        "gD";
      goToType =
        mkMappingOption "Go to type"
        "<leader>lgt";
      listImplementations =
        mkMappingOption "List implementations"
        "<leader>lgi";
      listReferences =
        mkMappingOption "List references"
        "<leader>lgr";
      nextDiagnostic =
        mkMappingOption "Go to next diagnostic"
        "<leader>lgn";
      previousDiagnostic =
        mkMappingOption "Go to previous diagnostic"
        "<leader>lgp";
      openDiagnosticFloat =
        mkMappingOption "Open diagnostic float"
        "<leader>le";
      documentHighlight =
        mkMappingOption "Document highlight"
        "<leader>lH";
      listDocumentSymbols =
        mkMappingOption "List document symbols"
        "<leader>lS";
      addWorkspaceFolder =
        mkMappingOption "Add workspace folder"
        "<leader>lwa";
      removeWorkspaceFolder =
        mkMappingOption "Remove workspace folder"
        "<leader>lwr";
      listWorkspaceFolders =
        mkMappingOption "List workspace folders"
        "<leader>lwl";
      listWorkspaceSymbols =
        mkMappingOption "List workspace symbols"
        "<leader>lws";
      hover =
        mkMappingOption "Trigger hover"
        "<leader>lh";
      signatureHelp =
        mkMappingOption "Signature help"
        "<leader>ls";
      renameSymbol =
        mkMappingOption "Rename symbol"
        "<leader>ln";
      codeAction =
        mkMappingOption "Code action"
        "<leader>la";
      format =
        mkMappingOption "Format"
        "<leader>lf";
      toggleFormatOnSave =
        mkMappingOption "Toggle format on save"
        "<leader>ltf";
    };
  };
}
