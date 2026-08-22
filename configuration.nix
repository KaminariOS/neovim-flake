# This is the sample configuration for nvf, aiming to give you a feel of the default options
# while certain plugins are enabled. While it may partially act as one, this is *not* quite
# an overview of nvf's module options. To find a complete and curated list of nvf module
# options, examples, instruction tutorials and more; please visit the online manual.
# https://notashelf.github.io/nvf/options.html
isMaximal: {
  config.vim = {
    viAlias = true;
    vimAlias = true;
    undoFile.enable = true;
    luaConfigRC.custom = builtins.readFile ./init.lua;
    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    extraPackages = [];
    extraPlugins = {};
    preventJunkFiles = true;
    diagnostics = {
      enable = true;
      config = {
        virtual_text = true;
        virtual_lines = true;
      };
    };
    debugMode = {
      enable = false;
      level = 16;
      logFile = "/tmp/nvim.log";
    };

    # vim.opts and vim.options are aliased
    opts.expandtab = true;

    spellcheck = {
      enable = true;
      programmingWordlist.enable = true;
    };

    lsp = {
      # This must be enabled for the language modules to hook into
      # the LSP API.
      enable = true;

      formatOnSave = false;
      lspkind.enable = true;
      lightbulb.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
      lspSignature.enable = !isMaximal;
      otter-nvim.enable = true;
      nvim-docs-view.enable = true;
      presets.harper.enable = isMaximal;
      mappings = {
        goToDefinition = "gd";
        nextDiagnostic = "gn";
        previousDiagnostic = "gp";
      };
    };

    debugger = {
      nvim-dap = {
        enable = true;
        ui.enable = true;
      };
    };

    # This section does not include a comprehensive list of available language modules.
    # To list all available language module options, please visit the nvf manual.
    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      # Languages that will be supported in default and maximal configurations.
      nix.enable = true;
      html = {
        enable = true;
        treesitter.autotagHtml = true;
      };
      markdown.enable = true;

      # Languages that are enabled in the maximal configuration.
      bash.enable = true;
      clang.enable = isMaximal;
      cmake.enable = isMaximal;
      css.enable = isMaximal;
      scss.enable = isMaximal;
      json.enable = isMaximal;
      sql.enable = isMaximal;
      java = {
        enable = true;
        # jdt-language-server wraps an OpenJDK; drop it from the closure
        lsp.enable = false;
      };
      kotlin = {
        enable = true;
        # kotlin-language-server depends on an OpenJDK
        lsp.enable = false;
        # ktlint is a JVM tool that pulls an OpenJDK
        extraDiagnostics.enable = false;
      };
      typescript.enable = true;
      go.enable = true;
      lua.enable = isMaximal;
      zig.enable = isMaximal;
      python.enable = true;
      typst.enable = isMaximal;
      rust = {
        enable = true;
        # Can only be enabled if lsp.enable = false
        extensions.rustaceanvim.enable = false;
        extensions.crates-nvim.enable = true;
      };
      toml.enable = isMaximal;
      xml = {
        enable = isMaximal;
        # lemminx wraps an OpenJDK JRE; drop it from the closure
        lsp.enable = false;
      };
      tex.enable = isMaximal;
      docker.enable = true;
      env.enable = isMaximal;

      # Language modules that are not as common.
      arduino.enable = false;
      assembly.enable = false;
      astro.enable = false;
      awk.enable = false;
      beancount.enable = false;
      csharp.enable = false;
      dart.enable = false;
      elixir.enable = false;
      fish.enable = false;
      fluent.enable = false;
      fsharp.enable = false;
      gettext.enable = false;
      gleam.enable = false;
      glsl.enable = false;
      haskell.enable = false;
      hcl.enable = false;
      jinja.enable = false;
      jq.enable = false;
      julia.enable = false;
      just.enable = false;
      liquid.enable = false;
      lisp.enable = false;
      make.enable = false;
      nu.enable = false;
      ocaml.enable = false;
      openscad.enable = false;
      pug.enable = false;
      qml.enable = false;
      r.enable = false;
      ruby.enable = false;
      scala.enable = false;
      standard-ml.enable = false;
      svelte.enable = false;
      tera.enable = false;
      tsx.enable = false;
      twig.enable = false;
      vala.enable = false;
      vue.enable = false;
      zsh.enable = false;
      http.enable = false;

      # Nim LSP is broken on Darwin and therefore
      # should be disabled by default. Users may still enable
      # `vim.languages.nim` to enable it, this does not restrict
      # that.
      # See: <https://github.com/PMunch/nimlsp/issues/178#issue-2128106096>
      nim.enable = false;
    };

    visuals = {
      nvim-scrollbar.enable = isMaximal;
      satellite-nvim.enable = false;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      cinnamon-nvim.enable = true;
      fidget-nvim.enable = false;

      highlight-undo.enable = true;
      blink-indent.enable = true;
      indent-blankline = {
        enable = true;
        setupOpts.scope.highlight = ["Function" "Label"];
      };

      # Fun
      cellular-automaton.enable = false;
    };

    statusline = {
      lualine = {
        enable = true;
        theme = "catppuccin";

        integrations.breadcrumbs = {
          vanilla.enable = !isMaximal;
          nvim-navic.enable = isMaximal;
          navbuddy.enable = isMaximal;
          lspsaga.enable = false;
        };
      };
    };

    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = true;
    };

    autopairs.nvim-autopairs.enable = true;

    # nvf provides various autocomplete options. The tried and tested nvim-cmp
    # is enabled in default package, because it does not trigger a build. We
    # enable blink-cmp in maximal because it needs to build its rust fuzzy
    autocomplete = {
      nvim-cmp.enable = !isMaximal;
      blink-cmp = {
        enable = isMaximal;
        setupOpts.signature.enabled = isMaximal;
      };
    };

    snippets.luasnip.enable = true;

    filetree = {
      neo-tree = {
        enable = true;
        setupOpts = {
          hide_root_node = true;
          filesystem.hijack_netrw_behavior = "open_current";
        };
      };
    };

    tabline = {
      nvimBufferline.enable = true;
    };

    treesitter.context.enable = true;

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    telescope = {
      enable = true;
      mappings = {
        diagnostics = "<leader>fd";
        lspDefinitions = "<leader>gd";
        lspImplementations = "<leader>gi";
        lspReferences = "<leader>gr";
      };
    };

    git = {
      enable = true;
      gitsigns.enable = true;
      gitsigns.codeActions.enable = false; # throws an annoying debug message
      neogit.enable = isMaximal;
      gitsigns.setupOpts = {
        current_line_blame = true;
      };
    };

    minimap = {
      minimap-vim.enable = isMaximal;
    };

    dashboard = {
      dashboard-nvim.enable = true;
      alpha.enable = isMaximal;
    };

    notify = {
      nvim-notify.enable = false;
    };

    projects = {
      project-nvim.enable = isMaximal;
    };

    utility = {
      ccc.enable = false;
      vim-wakatime.enable = false;
      diffview-nvim.enable = true;
      yanky-nvim.enable = false;
      qmk-nvim.enable = false; # requires hardware specific options
      icon-picker.enable = isMaximal;
      surround.enable = isMaximal;
      leetcode-nvim.enable = isMaximal;
      multicursors.enable = isMaximal;
      smart-splits.enable = isMaximal;
      undotree.enable = isMaximal;
      nvim-biscuits.enable = isMaximal;
      grug-far-nvim.enable = isMaximal;
      outline.aerial-nvim = {
        enable = true;
        mappings.toggle = "<leader>a";
      };

      motion = {
        hop.enable = true;
        leap.enable = true;
        precognition.enable = isMaximal;
      };
      images = {
        image-nvim.enable = false;
        img-clip.enable = isMaximal;
      };
      preview.markdownPreview = {
        enable = true;
        autoStart = true;
      };
    };

    notes = {
      neorg.enable = false;
      orgmode.enable = false;
      todo-comments.enable = true;
    };

    terminal = {
      toggleterm = {
        enable = true;
        lazygit.enable = true;
        mappings.open = "<c-\\>";
      };
    };

    ui = {
      borders.enable = true;
      dropbar-nvim.enable = false;
      noice.enable = true;
      colorizer.enable = true;
      modes-nvim.enable = false; # the theme looks terrible with catppuccin
      illuminate.enable = true;
      smartcolumn = {
        enable = false;
        setupOpts.custom_colorcolumn = {
          # this is a freeform module, it's `buftype = int;` for configuring column position
          nix = "110";
          ruby = "120";
          java = "130";
          go = ["90" "130"];
        };
      };
      fastaction.enable = true;
    };

    assistant = {
      chatgpt.enable = false;
      copilot = {
        enable = false;
        cmp.enable = isMaximal;
      };
      codecompanion-nvim.enable = false;
      avante-nvim.enable = isMaximal;
    };

    session = {
      nvim-session-manager.enable = false;
    };

    gestures = {
      gesture-nvim.enable = false;
    };

    comments = {
      comment-nvim.enable = true;
    };

    presence = {
      neocord.enable = false;
      cord-nvim.enable = false;
    };
  };
}
