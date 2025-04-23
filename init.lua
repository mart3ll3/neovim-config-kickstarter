--[[
vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })
--
--
--aasdk

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require "base.utils"
-- require("custom.plugins.dotnet-commands").setup()
local windows = vim.fn.has('win32') == 1           -- true if on windows
local android = vim.fn.isdirectory('/system') == 1 -- true if on android

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  {
    'tpope/vim-fugitive',
    event = "VeryLazy",
  },
  {
    'tpope/vim-rhubarb',
    event = "VeryLazy",
  },

  -- Detect tabstop and shiftwidth automatically
  -- {'tpope/vim-sleuth', lazy = true},
  -- {
    -- 'mbbill/undotree',
    -- event = "VeryLazy",
  -- },
  {
    'RishabhRD/popfix',
    event = "VeryLazy",
  },
  -- {
    -- 'RishabhRD/nvim-cheat.sh',
    -- event = "VeryLazy",
  -- },
  {
    'nvim-lua/plenary.nvim',
    event = "VeryLazy",
  },
  {
    'nvim-pack/nvim-spectre',
    lazy = true,
  },
  {
    'ThePrimeagen/harpoon',
    lazy = true,
  },
  -- 'prichrd/netrw.nvim',
  -- {
    -- 'nvim-tree/nvim-tree.lua',
    -- event = "VeryLazy",
  -- },
  -- 'm4xshen/autoclose.nvim',
  {
    'windwp/nvim-autopairs',
    event = "VeryLazy",
  },
  {
    'windwp/nvim-ts-autotag',
    event = "VeryLazy",
  },
  {
    "smoka7/hop.nvim",
    lazy = true,
    cmd = { "HopWord" },
    opts = { keys = "etovxqpdygfblzhckisuran" }
  },
  {
      "gbprod/substitute.nvim",
      event = "InsertEnter",
      opts = {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
      },
      config = function(_, opts)
        require("substitute").setup(opts)
      end,
  },
  -- {
    -- "folke/flash.nvim",
    -- event = "VeryLazy",
    -- ---@type Flash.Config
    -- opts = {},
    -- -- stylua: ignore
    -- keys = {
      -- { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end,       desc = "Flash" },
      -- { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
      -- {
        -- "R",
        -- mode = { "o", "x" },
        -- function() require("flash").treesitter_search() end,
        -- desc =
        -- "Treesitter Search"
      -- },
      -- {
        -- "<c-s>",
        -- mode = { "c" },
        -- function() require("flash").toggle() end,
        -- desc =
        -- "Toggle Flash Search"
      -- },
    -- },
  -- },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    init = function()
      require("base.utils").load_plugin_with_func("nvim-notify", vim, "notify")
    end,
    opts = {
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 175 })
        if not vim.g.notifications_enabled then
          vim.api.nvim_win_close(win, true)
        end
        if not package.loaded["nvim-treesitter"] then
          pcall(require, "nvim-treesitter")
        end
        vim.wo[win].conceallevel = 3
        local buf = vim.api.nvim_win_get_buf(win)
        if not pcall(vim.treesitter.start, buf, "markdown") then
          vim.bo[buf].syntax = "markdown"
        end
        vim.wo[win].spell = false
      end,
    },
    config = function(_, opts)
      local notify = require "notify"
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    opts = {
      handlers = {
        gitsigns = true, -- gitsigns integration (display hunks)
        ale = true,      -- lsp integration (display errors/warnings)
        search = false,  -- hlslens integration (display search result)
      },
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "noice",
        "prompt",
        "TelescopePrompt",
        "alpha",
      },
    },
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function()
      local enable_conceal = false          -- Hide command text if true
      return {
        presets = { bottom_search = true }, -- The kind of popup used for /
        cmdline = {
          view = "cmdline",                 -- The kind of popup used for :
          format = {
            cmdline = { conceal = enable_conceal },
            search_down = { conceal = enable_conceal },
            search_up = { conceal = enable_conceal },
            filter = { conceal = enable_conceal },
            lua = { conceal = enable_conceal },
            help = { conceal = enable_conceal },
            input = { conceal = enable_conceal },
          }
        },

        -- Disable every other noice feature
        messages = { enabled = false },
        lsp = {
          hover = { enabled = false },
          signature = { enabled = false },
          progress = { enabled = false },
          message = { enabled = false },
          smart_move = { enabled = false },
        },
      }
    end
  },

  -- {
    -- "mfussenegger/nvim-dap",
    -- lazy = true,
    -- config = function()
      -- local dap, dapui = require "dap", require "dapui"
      -- dap.set_log_level "TRACE"

      -- dap.listeners.after.event_initialized.dapui_config = function()
        -- dapui.open()
        -- vim.cmd("colorscheme " .. vim.g.colors_name)
      -- end
      -- dap.listeners.before.launch.dapui_config = function()
        -- dapui.open()
      -- end
      -- dap.listeners.before.event_terminated.dapui_config = function()
        -- dapui.close()
      -- end
      -- dap.listeners.before.event_exited.dapui_config = function()
        -- dapui.close()
      -- end

      -- vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "DapBreakpoint", numhl = "" })
      -- vim.fn.sign_define("DapStopped", { text = "󰳟", texthl = "", linehl = "DapStopped", numhl = "" })

      -- require("custom.plugins.netcore").register_net_dap()
    -- end,
    -- keys = {
      -- -- stylua: ignore start
      -- {"<leader>dc", function() require("dap").continue() end, noremap = true, silent = true, desc = "continue",},
      -- {"<leader>do", function() require("dap").step_over() end, noremap = true, silent = true, desc = "step over",},
      -- {"<leader>di", function() require("dap").step_into() end, noremap = true, silent = true, desc = "step into",},
      -- {"<leader>du", function() require("dap").step_out() end, noremap = true, silent = true, desc = "step out",},
      -- {"<leader>dr", function() require("dap").restart() end, noremap = true, silent = true, desc = "restart",},
      -- {"<leader>dt", function() require("dap").terminate() end, noremap = true, silent = true, desc = "terminate",},
      -- {"<leader>db", function() require("dap").toggle_breakpoint() end, noremap = true, silent = true, desc = "toggle breakpoint",},
      -- -- stylua: ignore end
    -- },
    -- dependencies = {
      -- { "jbyuki/one-small-step-for-vimkind" },
      -- { "nvim-neotest/nvim-nio" },
      -- {
        -- "rcarriga/nvim-dap-ui",
        -- config = function()
          -- require("dapui").setup {
            -- icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
            -- mappings = { expand = { "<CR>" }, open = "o", remove = "d", edit = "e", repl = "r", toggle = "t" },
            -- element_mappings = {},
            -- expand_lines = true,
            -- force_buffers = true,
            -- layouts = {
              -- {
                -- elements = { { id = "scopes", size = 0.33 }, { id = "repl", size = 0.66 } },
                -- size = 10,
                -- position = "bottom",
              -- },
              -- {
                -- elements = { "breakpoints", "console", "stacks", "watches" },
                -- size = 45,
                -- position = "right",
              -- },
            -- },
            -- floating = {
              -- max_height = nil,
              -- max_width = nil,
              -- border = "single",
              -- mappings = { ["close"] = { "q", "<Esc>" } },
            -- },
            -- controls = {
              -- enabled = vim.fn.exists "+winbar" == 1,
              -- element = "repl",
              -- icons = {
                -- pause = "",
                -- play = "",
                -- step_into = "",
                -- step_over = "",
                -- step_out = "",
                -- step_back = "",
                -- run_last = "",
                -- terminate = "",
                -- disconnect = "",
              -- },
            -- },
            -- render = { max_type_length = nil, max_value_lines = 100, indent = 1 },
          -- }
        -- end,
      -- },
    -- },
  -- },

  -- {
    -- "GustavEikaas/easy-dotnet.nvim",
    -- dependencies = { "nvim-lua/plenary.nvim" },
    -- ft = { "cs", "vb", "csproj", "sln", "slnx", "props", "csx", "targets" },
    -- lazy = true,
    -- cmd = "Dotnet",
    -- opts = {
      -- terminal = function(path, action)
        -- local commands = {
          -- run = function()
            -- return "dotnet run --project " .. path
          -- end,
          -- test = function()
            -- return "dotnet test " .. path
          -- end,
          -- restore = function()
            -- return "dotnet restore " .. path
          -- end,
          -- build = function()
            -- return "dotnet build " .. path
          -- end,
        -- }
        -- local cmd = commands[action]() .. "\r"
        -- Snacks.terminal.open(cmd)
      -- end,
      -- test_runner = {
        -- viewmode = "float",
        -- icons = {
          -- project = "󰗀",
        -- },
      -- },
    -- },
    -- keys = {
      -- -- stylua: ignore start 
      -- -- { "<leader>nb", function() require("easy-dotnet").build_default_quickfix() end, desc = "build" },
      -- { "<leader>nB", function() require("easy-dotnet").build_quickfix() end, desc = "build solution" },
      -- { "<leader>nr", function() require("easy-dotnet").run_default() end, desc = "run" },
      -- { "<leader>nR", function() require("easy-dotnet").run_solution() end, desc = "run solution" },
      -- { "<leader>nx", function() require("easy-dotnet").clean() end, desc = "clean solution" },
      -- { "<leader>na", "<cmd>Dotnet new<cr>", desc = "new item" },
      -- { "<leader>nt", "<cmd>Dotnet testrunner<cr>", desc = "open test runner" },
      -- -- stylua: ignore end
    -- },
  -- },
  {
    'leoluz/nvim-dap-go',
    lazy = true,
    -- event = "VeryLazy",
  },


  {
    'akinsho/toggleterm.nvim',
    lazy = true,
    version = "*",
    -- opts = {[> things you want to change go here<]},
    -- event = "VeryLazy",
  },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    -- event = "VeryLazy",
    opts = {}
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = "VeryLazy",
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        -- add = { text = '+' },
        -- change = { text = '~' },
        -- delete = { text = '_' },
        -- topdelete = { text = '‾' },
        -- changedelete = { text = '~' },
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▎' },
        topdelete = { text = '▎' },
        changedelete = { text = '▎' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']h', function()
          if vim.wo.diff then return ']h' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
        vim.keymap.set({ 'n', 'v' }, '[h', function()
          if vim.wo.diff then return '[h' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
      end,
    },
  },

  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  --   config = function()
  --     vim.cmd.colorscheme 'tokyonight'
  --   end,
  -- },
  {
    "catppuccin/nvim",
    event = "VeryLazy",
    name = "catppuccin",
    priority = 1000
  },
{ "Mofiqul/dracula.nvim",
  event = "VeryLazy"},
{ "EdenEast/nightfox.nvim",
  event = "VeryLazy"}, 
{
  "vague2k/vague.nvim",
    event = "VeryLazy",
  config = function()
    -- NOTE: you do not need to call setup if you don't want to.
    require("vague").setup({
      -- optional configuration here
    })
  end
},
  {
    "rebelot/kanagawa.nvim",
    event = "VeryLazy",
  },
  {
    "ellisonleao/gruvbox.nvim",
    event = "VeryLazy",
    priority = 100,
    config = true,
    opts = ...
  },
  {
    "folke/tokyonight.nvim",
    event = "VeryLazy",
    priority = 200,
    opts = {},
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    event = "VeryLazy",
  },
  {
    'rose-pine/neovim',
    event = "VeryLazy",
    name = 'rose-pine'
  },
  {
    "zaldih/themery.nvim",
    event = "VeryLazy",
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
        path = 1,
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    lazy = true,
    opts = {}
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
  },

  {
    "rrethy/vim-illuminate",
    event = "VeryLazy",
  },
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
  },
  {
    "Wansmer/treesj",
    lazy = true,
    -- event = "VeryLazy",
  },
  -- {"simrat39/symbols-outline.nvim"},
  -- {
  -- "stevearc/aerial.nvim",
  -- event = "VeryLazy",
  -- },
  {
    "godlygeek/tabular",
    lazy = true,
    -- event = "VeryLazy",
  },
  {
    "kdheepak/lazygit.nvim",
    event = "VeryLazy",
  },
  -- {
  -- "LunarVim/bigfile.nvim",
  -- event = "VeryLazy",
  -- },
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    -- lazy = true,
    opts = {
      merge_tool = {
            -- Config for conflicted files in diff views during a merge or rebase.
            layout = "diff3_mixed",
          },
    },
    config = function(_, opts)
      require("diffview").setup(opts)
    end,
  },


  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons', opt = true }
  },

  -- "gc" to comment visual regions/lines
  -- {'numToStr/Comment.nvim', opts = {} },
  {
    "preservim/nerdcommenter",
    event = "VeryLazy",
  },
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
  },
  {
    "ray-x/go.nvim",
    event = "VeryLazy",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
  -- {
    -- 'Exafunction/codeium.vim',
    -- event = "VeryLazy",
    -- -- event = 'BufEnter'
  -- },
  {
    "max397574/better-escape.nvim",
    event = "VeryLazy",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    'mart3ll3/vim-bbye',
    event = "VeryLazy",
  },
{
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = true,
},

  {
    "epwalsh/obsidian.nvim",
    version = "*",  -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
{
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
},

{
    "aaronhallaert/advanced-git-search.nvim",
    lazy = true,
    cmd = { "AdvancedGitSearch" },
    config = function()
        -- optional: setup telescope before loading the extension
        require("telescope").setup{
            -- move this to the place where you call the telescope setup function
            extensions = {
                advanced_git_search = {
                        -- See Config

                    }
            }
        }

        require("telescope").load_extension("advanced_git_search")
    end,
    dependencies = {
       "nvim-telescope/telescope.nvim",
          -- to show diff splits and open commits in browser
          "tpope/vim-fugitive",
          -- to open commits in browser with fugitive
          "tpope/vim-rhubarb",       --- See dependencies
    },
},


{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
        suggestion = {
            enabled = true,
            auto_trigger = true,
            hide_during_completion = true,
            debounce = 75,
            trigger_on_accept = true,
            keymap = {
              accept = "<C-y>",
              accept_word = false,
              accept_line = false,
              next = false, --"<M-]>",
              prev = false, --"<M-[>",
              dismiss = false, --"<C-]>",
            },
          },
      })
  end,
},


  {
    "zeioth/compiler.nvim",
    lazy = true,
    cmd = {
      "CompilerOpen",
      "CompilerToggleResults",
      "CompilerRedo",
      "CompilerStop"
    },
    dependencies = { "stevearc/overseer.nvim" },
    opts = {},
  },

  {
    "stevearc/overseer.nvim",
    lazy = true,
    cmd = {
      "CompilerOpen", 
      "CompilerToggleResults", 
      "CompilerRedo",
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerInfo",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache"
    },
    opts = {
     task_list = { -- the window that shows the results.
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
      -- component_aliases = {
      --   default = {
      --     -- Behaviors that will apply to all tasks.
      --     "on_exit_set_status",                   -- don't delete this one.
      --     "on_output_summarize",                  -- show last line on the list.
      --     "display_duration",                     -- display duration.
      --     "on_complete_notify",                   -- notify on task start.
      --     "open_output",                          -- focus last executed task.
      --     { "on_complete_dispose", timeout=300 }, -- dispose old tasks.
      --   },
      -- },
    },
  },
{
  "stevearc/conform.nvim",
  cond = not vim.g.vscode,
  lazy = true,
  event = { "BufWritePre" },
  config = function()
    require("conform").setup {
      quiet = true,
      lsp_fallback = true,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier", "eslint", stop_after_first = true },
        typescript = { "prettier", "eslint", stop_after_first = true },
        javascriptreact = { "prettier", "rustywind" },
        typescriptreact = { "prettier", "rustywind" },
        svelte = { "prettier", "rustywind" },
        html = { "prettier", "rustywind" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        mdx = { "prettier" },
        graphql = { "prettier" },
        go = { "gofmt"},
        cs = { "csharpier" },
        xml = { "xmlformat" },
        svg = { "xmlformat" },
        rust = { "rustfmt" },
      },
      formatters = {
        xmlformat = {
          cmd = { "xmlformat" },
          args = { "--selfclose", "-" },
        },
        injected = { options = { ignore_errors = false } },
      },
    }
  end,
},


  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    -- event = "User BaseFile",
    opts = function()
      -- Apply globals from 1-options.lua
      local is_enabled = vim.g.lsp_signature_enabled
      local round_borders = {}
      if vim.g.lsp_round_borders_enabled then
        round_borders = { border = 'rounded' }
      end
      return {
        -- Window mode
        floating_window = is_enabled, -- Display it as floating window.
        hi_parameter = "IncSearch",   -- Color to highlight floating window.
        handler_opts = round_borders, -- Window style

        -- Hint mode
        hint_enable = false, -- Display it as hint.
        hint_prefix = "👈 ",

        -- Additionally, you can use <space>ui to toggle inlay hints.
        toggle_key_flip_floatwin_setting = is_enabled
      }
    end,
    config = function(_, opts) require('lsp_signature').setup(opts) end
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    -- event = "VeryLazy",
    cmd = { "Neotest" },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "sidlatau/neotest-dart",
      "Issafalcon/neotest-dotnet",
      "jfpedroza/neotest-elixir",
      "nvim-neotest/neotest-go",
      "rcasia/neotest-java",
      "nvim-neotest/neotest-jest",
      "olimorris/neotest-phpunit",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
      "lawrence-laz/neotest-zig",
    },
    opts = function()
      return {
        -- your neotest config here
        adapters = {
          require("neotest-dart"),
          require("neotest-dotnet"),
          require("neotest-elixir"),
          require("neotest-go"),
          require("neotest-java"),
          require("neotest-jest"),
          require("neotest-phpunit"),
          require("neotest-python"),
          require("neotest-rust"),
          require("neotest-zig"),
        },
      }
    end,
    config = function(_, opts)
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace "neotest"
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)
      require("neotest").setup(opts)
    end,
  },
  -- { 'echasnovski/mini.animate', version = '*' },

  -- Fuzzy Finder (files, lsp, etc)
  -- {
    -- 'nvim-telescope/telescope.nvim',
    -- event = "VeryLazy",
    -- branch = '0.1.x',
    -- dependencies = {
      -- 'nvim-lua/plenary.nvim',
      -- -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- -- Only load if `make` is available. Make sure you have the system
      -- -- requirements installed.
      -- {
        -- 'nvim-telescope/telescope-fzf-native.nvim',
        -- -- NOTE: If you are having trouble with this installation,
        -- --       refer to the README for telescope-fzf-native for more instructions.
        -- build = 'make',
        -- cond = function()
          -- return vim.fn.executable 'make' == 1
        -- end,
      -- },
    -- },
  -- },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "debugloop/telescope-undo.nvim",
        cmd = "Telescope",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        enabled = vim.fn.executable("make") == 1,
        build = "make",
      },
    },
    cmd = "Telescope",
    opts = function()
      local get_icon = require("base.utils").get_icon
      local actions = require("telescope.actions")
      local mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<ESC>"] = actions.close,
          ["<C-c>"] = false,
        },
        n = { ["q"] = actions.close },
      }
      return {
        defaults = {
          prompt_prefix = get_icon("PromptPrefix") .. " ",
          -- selection_caret = get_icon("PromptPrefix") .. " ",
          multi_icon = get_icon("PromptPrefix") .. " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.50,
            },
            vertical = {
              mirror = false,
            },
            width = 0.99,
            height = 0.99,
            preview_cutoff = 120,
          },
          mappings = mappings,
        },
        extensions = {
          undo = {
            use_delta = true,
            side_by_side = true,
            vim_diff_opts = { ctxlen = 0 },
            entry_format = "󰣜 #$ID, $STAT, $TIME",
            layout_strategy = "horizontal",
            layout_config = {
              preview_width = 0.65,
            },
            mappings = {
              i = {
                ["<cr>"] = require("telescope-undo.actions").yank_additions,
                ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                ["<C-cr>"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- Here we define the Telescope extension for all plugins.
      -- If you delete a plugin, you can also delete its Telescope extension.
      if utils.is_available("nvim-notify") then telescope.load_extension("notify") end
      if utils.is_available("telescope-fzf-native.nvim") then telescope.load_extension("fzf") end
      if utils.is_available("telescope-undo.nvim") then telescope.load_extension("undo") end
      if utils.is_available("project.nvim") then telescope.load_extension("projects") end
      if utils.is_available("LuaSnip") then telescope.load_extension("luasnip") end
      if utils.is_available("aerial.nvim") then telescope.load_extension("aerial") end
      if utils.is_available("nvim-neoclip.lua") then
        telescope.load_extension("neoclip")
        telescope.load_extension("macroscope")
      end
    end,
  },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = "VeryLazy",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    'akinsho/bufferline.nvim',
    event = "VeryLazy",
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons'
  },

  {
    'nvimdev/lspsaga.nvim',
    event = "VeryLazy",
    -- config = function()
    -- require('lspsaga').setup({})
    -- end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    }
  },
  {
    "nvim-java/nvim-java",
    event = "VeryLazy",
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/nvim-java-refactor",
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "nvim-java/nvim-java-dap",
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      {
        "williamboman/mason.nvim",
        opts = {
          registries = {
            "github:nvim-java/mason-registry",
            "github:mason-org/mason-registry",
          },
        },
      },
      {
        "williamboman/mason-lspconfig.nvim",
        -- opts = {
          -- handlers = {
            -- ["jdtls"] = function()
              -- require("java").setup()
            -- end,
          -- },
        -- },
      },
    },
    opts = {},
  },
{
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    file_types = { "markdown", "Avante" },
  },
  ft = { "markdown", "Avante" },
},
  
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  --
  { import = 'custom.plugins.avante' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true
vim.opt.incsearch = true
vim.wo.relativenumber = true

-- Make line numbers default
vim.wo.number = true

-- Joshua Morony settings
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.showmatch = true
vim.opt.synmaxcol = 300
vim.opt.laststatus = 3 -- always show statusline

-- Sidebar
vim.opt.numberwidth = 3
vim.opt.showcmd = true
vim.opt.cmdheight = 0

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50

vim.opt.colorcolumn = "120"
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'

-- Enable mouse mode
vim.o.mouse = 'a'


-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = ''

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true
vim.o.guifont = "JetBrainsMono Nerd Font:h12"
vim.o.lines = 999
vim.o.columns = 999
vim.o.cursorline = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- vim.cmd.colorscheme "catppuccin"
-- vim.g.codeium_disable_bindings = 1
-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set("i", "jk", "<Esc>")

--primeagean mappiings
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-d>", "<Cmd>lua vim.cmd('normal! <C-d>'); MiniAnimate.execute_after('scroll', 'normal! zz')<CR>")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- vim.keymap.set("n", "<C-u>", "<Cmd>lua vim.cmd('normal! <C-u>'); MiniAnimate.execute_after('scroll', 'normal! zz')<CR>")

vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true })
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>dd", [["_d]])
-- vim.keymap.set("n", "<leader>ff", vim.lsp.buf.format, { desc = "[F]ormat Document" })

 vim.keymap.set("n", "<leader>ff", function() require("conform").format() end, { desc = "[F]ormat Document" })
 vim.keymap.set("v", "<leader>ff", function() require("conform").format() end, { desc = "[F]ormat Selection" })

-- vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { desc = "Show Nvim Tree" })
vim.keymap.set("n", "<leader>fu", ":NvimTreeResize -10<cr>", { desc = "Make smaller Nvim Tree" })
vim.keymap.set("n", "<leader>fi", ":NvimTreeResize +10<cr>", { desc = "Enlarge Nvim Tree" })
vim.keymap.set("n", "<leader>fs", vim.cmd.NvimTreeFindFile)
vim.keymap.set("n", "<leader>fd", vim.cmd.NvimTreeCollapse)

-- vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Show UndoTree" })
vim.keymap.set("n", "<leader>u", function() require("telescope").extensions.undo.undo() end, { desc = "Show UndoTree" })
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")



vim.keymap.set("n", "<C-a>", vim.cmd("normal! gg0vG$"), { desc = "Visually select all" })


vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go Window to the left" })
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Go Window to the left" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Go Window to the down" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Go Window to the up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go Window to the right" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Go Window to the right" })
-- Resize with arrows
vim.keymap.set("n", "<C-k>", ":horizontal resize +2<CR>")
vim.keymap.set("n", "<C-j>", ":horizontal resize -2<CR>")
-- vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>")
-- vim.keymap.set("n", "<C-m>", ":vertical resize +2<CR>")
-- vim.keymap.set("n", "<C-,>", ":horizontal resize +2<CR>")
-- vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-/>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-.>", ":horizontal resize -2<CR>")
-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-Right>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true })
vim.keymap.set("n", "<S-Left>", ":bprevious<CR>", { silent = true })
-- Clear highlights
vim.keymap.set("n", "<leader>hh", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
-- Close buffers
vim.keymap.set("n", "<leader>bd", "<cmd>Bdelete!<CR>", { desc = "[B]uffer Force [D]elete" })
vim.keymap.set("n", "<C-q>", "<cmd>Bdelete!<CR>", { desc = "[B]uffer Force [D]elete" })
vim.keymap.set("n", "<leader>ba", "<cmd>bufdo Bwipeout<cr>", { desc = "[B]uffers Close [A]ll" })
-- vim.keymap.set("n", "<leader>ba", "<cmd>Bdeleteall<cr>", { desc = "[B]uffers Close [A]ll" })
-- vim.keymap.set("n", "<leader>bu", "<cmd>%bd|e#<CR>", { desc = "[B]uffers Close All B[u]t This" })
vim.keymap.set("n", "<leader>bu", "<cmd>Bdeleteexcept<CR>", { desc = "[B]uffers Close All B[u]t This" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "[B]uffer [N]ew " })

vim.keymap.set("n", "<leader>bw", "<C-W>c", { desc = "Buffer Force Close" })
-- vim.keymap.set("n", "<leader>ww", "<cmd>set wrap!<CR>", { desc = "Toggle [Wrap] lines" })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Vertically" })

vim.keymap.set("n", "<leader>th", "<cmd>Themery<CR>", { desc = "Change [Th]eme" })
vim.keymap.set("n", "<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", { desc = "Run Closes Test" })
vim.keymap.set("n", "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", { desc = "Run All Tests in File" })
vim.keymap.set("n", "<leader>ta", "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<cr>", { desc = "Run All Tests" })
vim.keymap.set("n", "<leader>to", "<cmd>lua require('neotest').summary.toggle()<cr>", { desc = "Tests Toggle" })
--
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Harpoon shortcuts
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")


vim.keymap.set("x", "<leader>re", ":Refactor extract ")
vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ")

vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ")

vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var")

vim.keymap.set("n", "<leader>rI", ":Refactor inline_func")

vim.keymap.set("n", "<leader>re", ":Refactor extract_block")
vim.keymap.set("n", "<leader>rf", ":Refactor extract_block_to_file")

-- Outline
-- vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Show Outline for current buffer" })
-- require("aerial").setup({
-- on_attach = function(bufnr)
-- -- Jump forwards/backwards with '{' and '}'
-- vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
-- vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
-- end,
-- })

vim.keymap.set("n", "<leader>ae", mark.add_file, { desc = "Harpoon Add File" })
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Harpoon Toggle Quick menu" })

vim.keymap.set("n", "<C-f>", function() ui.nav_file(1) end, { desc = "Harpoon File #1" })
vim.keymap.set("n", "<C-p>", function() ui.nav_file(2) end, { desc = "Harpoon File #2" })
vim.keymap.set("n", "<C-s>", function() ui.nav_file(3) end, { desc = "Harpoon File #3" })
vim.keymap.set("n", "<C-n>", function() ui.nav_file(4) end, { desc = "Harpoon File #4" })

-- Fugitive shortcuts
-- vim.keymap.set("n", "<leader>gg", "<cmd>G<CR>", { desc = "Git Status" })
-- vim.keymap.set("n", "<leader>gf", "<cmd>Gdiff<CR>", { desc = "Git Diff" })
vim.keymap.set("n", "<leader>gd", vim.cmd.DiffviewOpen, { desc = "Git Diffview plugin" })
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { desc = "Git Diffview Close" })
vim.keymap.set("n", "<leader>gg", "<cmd>DiffviewToggleFiles<CR>", { desc = "Git Diffview Toggle Files" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
vim.keymap.set("n", "<leader>gP", "<cmd>Git push<CR>", { desc = "Git Push" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<CR>", { desc = "Git Pull" })
vim.keymap.set("n", "<leader>gl", "<cmd>Gclog<CR>", { desc = "Git Log File" })
vim.keymap.set("n", "<leader>gL", "<cmd>Gclog --<CR>", { desc = "Git All File" })
vim.keymap.set("n", "<leader>gu", "<cmd>GitBlameOpenCommitURL<CR>", { desc = "Git Open Commit Url" })
vim.keymap.set("n", "<leader>gU", "<cmd>GitBlameOpenFileURL<CR>", { desc = "Git Open File Url" })

-- lazygit
vim.keymap.set("n", "<leader>gs", vim.cmd.LazyGit)
-- advanced git search
vim.keymap.set("n", "<leader>gf", "<cmd>AdvancedGitSearch search_log_content_file<CR>", { desc = "AdvancedGitSearch file" })
vim.keymap.set("n", "<leader>ga", "<cmd>AdvancedGitSearch search_log_content<CR>", { desc = "AdvancedGitSearch repo" })

vim.keymap.set("n", "<leader>gm", vim.cmd.GitBlameOpenCommitURL, { desc = "Git Open Commit Url" })
vim.keymap.set("n", "<leader>gM", vim.cmd.GitBlameOpenFileURL, { desc = "Git Open File Url" })

vim.api.nvim_set_var("NERDSpaceDelims", 1);
-- shortcuts to toggle
vim.api.nvim_set_keymap("n", ",c", ":call nerdcommenter#Comment(0, 'toggle')<CR>", { noremap = true, silent = true });
vim.api.nvim_set_keymap("v", ",c", ":call nerdcommenter#Comment(0, 'toggle')<CR>", { noremap = true, silent = true });
vim.api.nvim_set_keymap("n", "<leader>/", ":call nerdcommenter#Comment(0, 'toggle')<CR>", { noremap = true, silent = true });
vim.api.nvim_set_keymap("v", "<leader>/", ":call nerdcommenter#Comment(0, 'toggle')<CR>", { noremap = true, silent = true });


vim.keymap.set("n", "<leader>cf", "0<c-g>", { desc = "Show full file path" })

vim.keymap.set("n", "<C-t>", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
vim.keymap.set("t", "<C-t>", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })

vim.keymap.set("n", "s", function() require("hop") vim.cmd("silent! HopWord") end, { desc = "Hop to word" })
vim.keymap.set("x", "s", function() require("hop") vim.cmd("silent! HopWord") end, { desc = "Hop to word" })

vim.keymap.set("n", "m", require('substitute').operator, { noremap = true })
vim.keymap.set("n", "mm", require('substitute').line, { noremap = true })
vim.keymap.set("n", "M", require('substitute').eol, { noremap = true })
vim.keymap.set("x", "m", require('substitute').visual, { noremap = true })

      -- Open parent directory in current window
      -- vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })

      -- Open parent directory in floating window
      vim.keymap.set("n", "<space>e", require("oil").toggle_float)

-- jump list + buffer
function jumps_fileCO(direction)
  -- Default to jumping backward if no direction is specified
  direction = direction or "backward"

  local current_buffer = vim.fn.bufnr()
  local last_file = vim.fn.bufname()

  local jump_command = ""
  if direction == "backward" then
    jump_command = "normal! <c-o>"
  elseif direction == "forward" then
    jump_command = "normal! 1<c-i>"
  end

  while true do
    vim.cmd(vim.api.nvim_replace_termcodes(jump_command, true, true, true))
    if vim.fn.bufnr() == current_buffer then
      if vim.fn.bufname() == last_file then
        break
      else
        last_file = vim.fn.bufname()
      end
    else
      break
    end
  end
end

-- vim.keymap.set("n", "<c-;>", "<cmd>lua jumps_fileCO('forward')<cr>", { desc = "Next buffer in jump list" })
vim.keymap.set("n", "<c-g>", "<cmd>lua jumps_fileCO()<cr>", { desc = "Prev buffer in jump list" })

vim.keymap.set("n", "<leader>ad", "<cmd>AvanteClear<cr>", { desc = "Avante Clear" })

vim.keymap.set("n", "<leader>mm", function() vim.cmd("CompilerOpen") end, { desc = "Open compiler" })
vim.keymap.set("n", "<leader>mr", function() vim.cmd("CompilerRedo") end, { desc = "Compiler redo" })
vim.keymap.set("n", "<leader>mt", function() vim.cmd("CompilerToggleResults") end, { desc = "Compiler results" })


-- vim.keymap.set('i', '<C-y>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
-- vim.keymap.set('i', '<C-;>', function() return vim.fn['codeium#CycleCompletions'](1) end)
-- vim.keymap.set('i', '<C-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end)
-- vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
-- require('telescope').setup {
  -- defaults = {
    -- -- mappings = {
      -- -- i = {
        -- -- ['<C-u>'] = false,
        -- -- ['<C-d>'] = false,
      -- -- },
    -- -- },
    -- layout_strategy = 'vertical',
    -- layout_config = {
      -- vertical = {
        -- preview_cutoff = 1,
        -- prompt_position = "bottom",
        -- height = 0.98,
        -- preview_height = 0.65
      -- }
    -- }
  -- },
-- }

-- Enable telescope fzf native, if installed
-- pcall(require('telescope').load_extension, 'fzf')

-- configure Bufferline
vim.opt.termguicolors = true
require("bufferline").setup {}

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sW', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sR', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>sR', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set("n", "<leader>sj", require("telescope.builtin").jumplist, { desc = "[J]ump [L]ist" })
vim.keymap.set('n', '<leader>sr', '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
  { desc = "Search current word Spectre" })
vim.keymap.set('n', '<leader>J', require('treesj').toggle)

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'lua',
    'python',
    'tsx',
    'javascript',
    'typescript',
    'vimdoc',
    'vim',
    'yaml',
    'json',
    'html',
    'css',
    'markdown',
    'markdown_inline',
    'graphql',
    'bash',
    'dockerfile',
    'gitignore',
    'xml',
    'c_sharp',
    'java',
    -- 'norg',
    -- 'norg_meta'
  },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
        ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
        ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
        ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

        -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
        ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
        ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
        ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
        ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },

        ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
        ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

        ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
        ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

        ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
        ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

        ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
        ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

        ["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
        ["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

        ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
        ["<leader>n:"] = "@property.outer",  -- swap object property with next
        ["<leader>nm"] = "@function.outer",  -- swap function with next
      },
      swap_previous = {
        ["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
        ["<leader>p:"] = "@property.outer",  -- swap object property with prev
        ["<leader>pm"] = "@function.outer",  -- swap function with previous
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = { query = "@call.outer", desc = "Next function call start" },
        ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
        ["]c"] = { query = "@class.outer", desc = "Next class start" },
        ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
        ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]F"] = { query = "@call.outer", desc = "Next function call end" },
        ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
        ["]C"] = { query = "@class.outer", desc = "Next class end" },
        ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
        ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
        ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
        ["[c"] = { query = "@class.outer", desc = "Prev class start" },
        ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
        ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
      },
      goto_previous_end = {
        ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
        ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
        ["[C"] = { query = "@class.outer", desc = "Prev class end" },
        ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
        ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set("n", "<leader>dt", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>qq", ":qa!<CR>")

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  -- nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  -- nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  -- nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- nmap('<leader>K', vim.lsp.buf.signature_help, 'Signature Documentation')

  local optsSaga = { noremap = true, silent = true }
  vim.keymap.set('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', optsSaga)
  -- vim.keymap.set('i', '<leader>K', '<Cmd>Lspsaga signature_help<CR>', optsSaga)
  vim.keymap.set('n', '<leader>kp', '<Cmd>Lspsaga peek_definition<CR>', optsSaga)
  vim.keymap.set('n', '<leader>kd', '<cmd>Lspsaga finder<CR>')

  vim.keymap.set('n', '<leader>kj', '<Cmd>Lspsaga diagnostic_jump_next<CR>', optsSaga)
  vim.keymap.set('n', '<leader>rn', '<Cmd>Lspsaga rename<CR>', optsSaga)
  vim.keymap.set('n', '<leader>o', '<Cmd>Lspsaga outline<CR>', optsSaga)

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  -- nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  -- nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  -- nmap('<leader>wl', function()
    -- print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  csharp_ls = {
    filetypes = { 'cs' }
  },

}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip').filetype_extend("javascript", { "javascriptreact" })
require('luasnip').filetype_extend("javascript", { "html" })
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<Tab>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_locally_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.locally_jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer',  keyword_length = 3 },
  },
}

-- require("ibl").setup({
-- scope = { enabled = false },
-- })

local highlight = {
  "RainbowRed",
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
  vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
  vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
  vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
  vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
  vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
  vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

vim.g.rainbow_delimiters = { highlight = highlight }
require("ibl").setup { scope = { highlight = highlight } }

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)


-- require("noice").setup({
-- lsp = {
-- -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
-- override = {
-- ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
-- ["vim.lsp.util.stylize_markdown"] = true,
-- ["cmp.entry.get_documentation"] = true,
-- },
-- },
-- -- you can enable a preset for easier configuration
-- presets = {
-- bottom_search = true,         -- use a classic bottom cmdline for search
-- command_palette = true,       -- position the cmdline and popupmenu together
-- long_message_to_split = true, -- long messages will be sent to a split
-- inc_rename = false,           -- enables an input dialog for inc-rename.nvim
-- lsp_doc_border = false,       -- add a border to hover docs and signature help
-- },
-- routes = {
-- {
-- filter = {
-- event = "msg_show",
-- kind = "",
-- find = "written",
-- },
-- opts = { skip = true },
-- },
-- },
-- })

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
-- neo-tree


require("nvim-surround")
-- require("flash").toggle(false)
-- require'netrw'.setup{
--   -- Put your configuration here, or leave the object empty to take the default
--   -- configuration.
--   icons = {
--     symlink = '', -- Symlink icon (directory and file)
--     directory = '', -- Directory icon
--     file = '', -- File icon
--   },
--   use_devicons = true, -- Uses nvim-web-devicons if true, otherwise use the file icon specified above
--   mappings = {}, -- Custom key mappings
-- }
-- require("nvim-tree").setup({
  -- view = {
    -- width = 40,
  -- },
-- })

local bufferline = require('bufferline')
bufferline.setup {
  options = {

    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
        separator = true
      }
    },
    indicator = {
      style = "underline",
    },
  }
}


-- require("autoclose").setup()
require('treesj').setup({ --[[ your config ]] })

local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

-- vim way: ; goes to the direction you were moving.
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- require("symbols-outline").setup()
-- require("aerial").setup()
require("nvim-autopairs").setup({
  disable_filetype = { 'TelescopePrompt', 'vim' }
})

require("nvim-ts-autotag").setup()
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
--
-- require("bigfile").setup {
-- -- filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
-- pattern = function(bufnr, filesize_mib)
-- -- you can't use `nvim_buf_line_count` because this runs on BufReadPre
-- local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
-- local file_length = #file_contents
-- local filetype = vim.filetype.match({ buf = bufnr })
-- if file_length > 5000 and filetype == "cs" then
-- return true
-- end
-- end,
-- features = { -- features to disable
-- "indent_blankline",
-- "illuminate",
-- -- "lsp",
-- -- "treesitter",
-- -- "syntax",
-- -- "matchparen",
-- -- "vimopts",
-- -- "filetype",
-- },
-- }

-- Using before and after.
require("themery").setup({
  themes = {
    {
      name = "Gruvbox light",
      colorscheme = "gruvbox",
      before = [[
      vim.opt.background = "light"
    ]],
      after = [[-- Same as before, but after if you need it]]
    },
    {
      name = "Kanagawa Lotus",
      colorscheme = "kanagawa-lotus",
    },
    {
      name = "Tokyo Day",
      colorscheme = "tokyonight-day",
    },
    {
      name = "Catppuccin Latte",
      colorscheme = "catppuccin-latte",
    },
    {
      name = "Oxocarbon Light",
      colorscheme = "oxocarbon",
      before = [[
        -- All this block will be executed before apply "set colorscheme"
        vim.opt.background = "light"
      ]],
    },
    {
      name = "Rosepine Dawn",
      colorscheme = "rose-pine",
      before = [[
        -- All this block will be executed before apply "set colorscheme"
        vim.opt.background = "light"
      ]],
    },
    {
      name = "Dayfox",
      colorscheme = "dayfox",
    },
    {
      name = "Dawnfox",
      colorscheme = "dawnfox",
    },
    {
      name = "Gruvbox dark",
      colorscheme = "gruvbox",
      before = [[
        -- All this block will be executed before apply "set colorscheme"
        vim.opt.background = "dark"
      ]],
    },
    {
      name = "Kanagawa Dragon",
      colorscheme = "kanagawa-dragon",
    },
    {
      name = "Kanagawa Wave",
      colorscheme = "kanagawa-wave",
    },
    {
      name = "Tokyo Night",
      colorscheme = "tokyonight-night",
    },
    {
      name = "Tokyo Storm",
      colorscheme = "tokyonight-storm",
    },
    {
      name = "Tokyo Moon",
      colorscheme = "tokyonight-moon",
    },
    {
      name = "Catppuccin Frappe",
      colorscheme = "catppuccin-frappe",
    },
    {
      name = "Catppuccin Macchiato",
      colorscheme = "catppuccin-macchiato",
    },
    {
      name = "Catppuccin Mocha",
      colorscheme = "catppuccin-mocha",
    },
    {
      name = "Oxocarbon Dark",
      colorscheme = "oxocarbon",
      before = [[
        -- All this block will be executed before apply "set colorscheme"
        vim.opt.background = "dark"
      ]],
    },
    {
      name = "Rosepine Main",
      colorscheme = "rose-pine",
      before = [[
        -- All this block will be executed before apply "set colorscheme"
        vim.opt.background = "dark"
      ]],
    },
    {
      name = "Dracula",
      colorscheme = "dracula",
    },
    {
      name = "Vague",
      colorscheme = "vague",
    },
    {
      name = "Nightfox",
      colorscheme = "nightfox",
    },
    {
      name = "Duskfox",
      colorscheme = "duskfox",
    },
    {
      name = "Nordfox",
      colorscheme = "nordfox",
    },
    {
      name = "Terafox",
      colorscheme = "terafox",
    },
    {
      name = "Carbonfox",
      colorscheme = "carbonfox",
    },
  },
  -- themeConfigFile = "~/.config/nvim/lua/custom/plugins/theme.lua", -- Described below
  livePreview = true,                                              -- Apply theme while browsing. Default to true.
})
require('rose-pine').setup({
  dark_variant = 'moon'
})

-- local animate = require('mini.animate')
-- animate.setup({
-- scroll = {
-- -- Animate for 200 milliseconds with linear easing
-- timing = animate.gen_timing.linear({ duration = 20, unit = 'total' }),

-- -- Animate equally but with at most 120 steps instead of default 60
-- subscroll = animate.gen_subscroll.equal({ max_output_steps = 120 }),
-- }
-- })

require("custom.plugins.theme")
-- require("custom.plugins.avante")

require("toggleterm").setup()

require('refactoring').setup()

require("lspsaga").setup({
  symbols_in_winbar = {
    enable = false
  },
  lightbulb = {
    enable = false,
    enable_in_insert = false,
  },
})
require('go').setup()
require('scrollbar').setup()

local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require('go.format').goimports()
  end,
  group = format_sync_grp,
})

require("better_escape").setup {
    mapping = {"jk", "jj"}, -- a table with mappings to use
    timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
    clear_empty_lines = false, -- clear line after escaping if there is only whitespace
    keys = "<Esc>", -- keys used for escaping, if it is a function will use the result everytime
    -- example(recommended)
    -- keys = function()
    --   return vim.api.nvim_win_get_cursor(0)[2] > 1 and '<esc>l' or '<esc>'
    -- end,
}
-- 
local cfg = {
  debug = false,                                              -- set to true to enable debug logging
  log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
  -- default is  ~/.cache/nvim/lsp_signature.log
  verbose = false,                                            -- show debug line number

  bind = true,                                                -- This is mandatory, otherwise border config won't get registered.
  -- If you want to hook lspsaga or other signature handler, pls set to false
  doc_lines = 10,                                             -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
  -- set to 0 if you DO NOT want any API comments be shown
  -- This setting only take effect in insert mode, it does not affect signature help in normal
  -- mode, 10 by default

  max_height = 12,                       -- max height of signature floating_window
  max_width = 80,                        -- max_width of signature floating_window, line will be wrapped if exceed max_width
  -- the value need >= 40
  wrap = true,                           -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
  floating_window = true,                -- show hint in a floating window, set to false for virtual text only mode

  floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
  -- will set to true when fully tested, set to false will use whichever side has more space
  -- this setting will be helpful if you do not want the PUM and floating win overlap

  floating_window_off_x = 1, -- adjust float windows x position.
  -- can be either a number or function
  floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
  -- can be either number or function, see examples

  close_timeout = 4000, -- close floating window after ms when laster parameter is entered
  fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
  hint_enable = true, -- virtual hint enable
  hint_prefix = "🐼 ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
  hint_scheme = "String",
  hint_inline = function() return false end, -- should the hint be inline(nvim 0.10 only)?  default false
  -- return true | 'inline' to show hint inline, return 'eol' to show hint at end of line, return false to disable
  -- return 'right_align' to display hint right aligned in the current line
  hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
  handler_opts = {
    border = "rounded"                          -- double, rounded, single, shadow, none, or a table of borders
  },

  always_trigger = false,                   -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

  auto_close_after = nil,                   -- autoclose signature float win after x sec, disabled if nil.
  extra_trigger_chars = {},                 -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
  zindex = 200,                             -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

  padding = '',                             -- character to pad on left and right of signature can be ' ', or '|'  etc

  transparency = nil,                       -- disabled by default, allow floating win transparent value 1~100
  shadow_blend = 36,                        -- if you using shadow as border use this set the opacity
  shadow_guibg = 'Black',                   -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
  timer_interval = 200,                     -- default timer check interval set to lower value if you want to reduce latency
  toggle_key = nil,                         -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
  toggle_key_flip_floatwin_setting = false, -- true: toggle floating_windows: true|false setting after toggle key pressed
  -- false: floating_windows setup will not change, toggle_key will pop up signature helper, but signature
  -- may not popup when typing depends on floating_window setting

  select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
  move_cursor_key = nil,      -- imap, use nvim_set_current_win to move cursor between current win and floating window
  -- e.g. move_cursor_key = '<M-p>',
  -- once moved to floating window, you can use <M-d>, <M-u> to move cursor up and down
  keymaps = {} -- relate to move_cursor_key; the keymaps inside floating window
  -- e.g. keymaps = { 'j', '<C-o>j' } this map j to <C-o>j in floating window
  -- <M-d> and <M-u> are default keymaps to move cursor up and down
}

-- recommended:
require 'lsp_signature'.setup(cfg)

      require("oil").setup {
        columns = { "icon" },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
          ["<C-k>"] = false,
          ["<C-j>"] = false,
           ["<BS>"] = { "actions.parent", mode = "n" },
          -- ["<M-h>"] = "actions.select_split",
        },
        -- win_options = {
          -- winbar = "%{v:lua.CustomOilBar()}",
        -- },
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name, _)
            local folder_skip = { "dev-tools.locks", "dune.lock", "_build" }
            return vim.tbl_contains(folder_skip, name)
          end,
        },
      }

require("obsidian").setup({
  workspaces = {
    {
      name = "Notes",
      -- path = "/Users/omerxx/Obsidian/Notes",
      path = "~/Documents/Projects",
    },
  },
  ui = { enable = false },
})

require('render-markdown').setup({})

MiniIcons.mock_nvim_web_devicons()
-- require("custom.plugins.debug")
