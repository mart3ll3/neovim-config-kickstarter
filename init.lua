--[[
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
local windows = vim.fn.has('win32') == 1             -- true if on windows
local android = vim.fn.isdirectory('/system') == 1   -- true if on android

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
    {
        'mbbill/undotree',
        event = "VeryLazy",
    },
    {
        'RishabhRD/popfix',
        event = "VeryLazy",
    },
    {
        'RishabhRD/nvim-cheat.sh',
        event = "VeryLazy",
    },
    {
        'nvim-lua/plenary.nvim',
        event = "VeryLazy",
    },
    {
        'nvim-pack/nvim-spectre',
        event = "VeryLazy",
    },
    {
        'ThePrimeagen/harpoon',
        event = "VeryLazy",
    },
    -- 'prichrd/netrw.nvim',
    {
        'nvim-tree/nvim-tree.lua',
        event = "VeryLazy",
    },
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
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end,       desc = "Flash" },
            { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
            {
                "R",
                mode = { "o", "x" },
                function() require("flash").treesitter_search() end,
                desc =
                "Treesitter Search"
            },
            {
                "<c-s>",
                mode = { "c" },
                function() require("flash").toggle() end,
                desc =
                "Toggle Flash Search"
            },
        },
    },

  {
    "rcarriga/nvim-notify",
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
    event = "User BaseFile",
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
          format= {
            cmdline =     { conceal = enable_conceal },
            search_down = { conceal = enable_conceal },
            search_up =   { conceal = enable_conceal },
            filter =      { conceal = enable_conceal },
            lua =         { conceal = enable_conceal },
            help =        { conceal = enable_conceal },
            input =       { conceal = enable_conceal },
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
    {
        'mfussenegger/nvim-dap',
        event = "VeryLazy",
    },
    {
        'rcarriga/nvim-dap-ui',
        event = "VeryLazy",
    },
    {
        'leoluz/nvim-dap-go',
        event = "VeryLazy",
    },

    {
        'akinsho/toggleterm.nvim',
        version = "*",
        -- opts = {[> things you want to change go here<]},
        event = "VeryLazy",
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
        event = "VeryLazy",
        opts = {}
    },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        event = "VeryLazy",
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
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
        event = "VeryLazy",
    },
    -- {"simrat39/symbols-outline.nvim"},
    -- {
    -- "stevearc/aerial.nvim",
    -- event = "VeryLazy",
    -- },
    {
        "godlygeek/tabular",
        event = "VeryLazy",
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
    {
        'Exafunction/codeium.vim',
        event = 'BufEnter'
    },
    -- {
    -- "ray-x/lsp_signature.nvim",
    -- event = "VeryLazy",
    -- opts = {},
    -- config = function(_, opts) require 'lsp_signature'.setup(opts) end
    -- },
    -- { 'echasnovski/mini.animate', version = '*' },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        event = "VeryLazy",
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
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
                opts = {
                    handlers = {
                        ["jdtls"] = function()
                            require("java").setup()
                        end,
                    },
                },
            },
        },
        opts = {},
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
    -- { import = 'custom.plugins' },
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
vim.opt.laststatus = 2 -- always show statusline

-- Sidebar
vim.opt.numberwidth = 3
vim.opt.showcmd = true
vim.opt.cmdheight = 0

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50

vim.opt.colorcolumn = "120"

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
vim.o.guifont = "JetBrainsMono Nerd Font:h9"
vim.o.lines = 999
vim.o.columns = 999
vim.o.cursorline = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- vim.cmd.colorscheme "catppuccin"
vim.g.codeium_disable_bindings = 1
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

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>dd", [["_d]])
vim.keymap.set("n", "<leader>ff", vim.lsp.buf.format, { desc = "[F]ormat Document" })
vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { desc = "Show Nvim Tree" })
vim.keymap.set("n", "<leader>fu", ":NvimTreeResize -10<cr>", { desc = "Make smaller Nvim Tree" })
vim.keymap.set("n", "<leader>fi", ":NvimTreeResize +10<cr>", { desc = "Enlarge Nvim Tree" })
vim.keymap.set("n", "<leader>fs", vim.cmd.NvimTreeFindFile)
vim.keymap.set("n", "<leader>fd", vim.cmd.NvimTreeCollapse)

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Show UndoTree" })
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")



vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go Window to the left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go Window to the down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go Window to the up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go Window to the right" })
-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":horizontal resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":horizontal resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>")
-- vim.keymap.set("n", "<C-m>", ":vertical resize +2<CR>")
-- vim.keymap.set("n", "<C-,>", ":horizontal resize +2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-/>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-.>", ":horizontal resize -2<CR>")
-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true })
-- Clear highlights
vim.keymap.set("n", "<leader>hh", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })
-- Close buffers
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete!<CR>", { desc = "[B]uffer Force [D]elete" })
vim.keymap.set("n", "<leader>ba", "<cmd>bufdo bwipeout<cr>", { desc = "[B]uffers Close [A]ll" })
vim.keymap.set("n", "<leader>bu", "<cmd>%bd|e#<CR>", { desc = "[B]uffers Close All B[u]t This" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "[B]uffer [N]ew " })

vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Buffer Force Close" })
vim.keymap.set("n", "<leader>ww", "<cmd>set wrap!<CR>", { desc = "Toggle [Wrap] lines" })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Vertically" })

vim.keymap.set("n", "<leader>th", "<cmd>Themery<CR>", { desc = "Change [Th]eme" })

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

vim.keymap.set("n", "<leader>rb", ":Refactor extract_block")
vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file")

-- Outline
-- vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Show Outline for current buffer" })
-- require("aerial").setup({
-- on_attach = function(bufnr)
-- -- Jump forwards/backwards with '{' and '}'
-- vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
-- vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
-- end,
-- })

vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon Add File" })
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Harpoon Toggle Quick menu" })

vim.keymap.set("n", "<C-f>", function() ui.nav_file(1) end, { desc = "Harpoon File #1" })
vim.keymap.set("n", "<C-p>", function() ui.nav_file(2) end, { desc = "Harpoon File #2" })
vim.keymap.set("n", "<C-s>", function() ui.nav_file(3) end, { desc = "Harpoon File #3" })
vim.keymap.set("n", "<C-n>", function() ui.nav_file(4) end, { desc = "Harpoon File #4" })

-- Fugitive shortcuts
vim.keymap.set("n", "<leader>gg", "<cmd>G<CR>", { desc = "Git Status" })
vim.keymap.set("n", "<leader>gf", "<cmd>Gdiff<CR>", { desc = "Git Diff" })
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Git Diffview plugin" })
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { desc = "Git Diffview Close" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
vim.keymap.set("n", "<leader>gP", "<cmd>Git push<CR>", { desc = "Git Push" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<CR>", { desc = "Git Pull" })
vim.keymap.set("n", "<leader>gl", "<cmd>Gclog<CR>", { desc = "Git Log File" })
vim.keymap.set("n", "<leader>gL", "<cmd>Gclog --<CR>", { desc = "Git All File" })
vim.keymap.set("n", "<leader>gu", "<cmd>GitBlameOpenCommitURL<CR>", { desc = "Git Open Commit Url" })
vim.keymap.set("n", "<leader>gU", "<cmd>GitBlameOpenFileURL<CR>", { desc = "Git Open File Url" })

-- lazygit
vim.keymap.set("n", "<leader>gs", vim.cmd.LazyGit)

vim.api.nvim_set_var("NERDSpaceDelims", 1);
-- shortcuts to toggle
vim.api.nvim_set_keymap("n", ",c", ":call nerdcommenter#Comment(0, 'toggle')<CR>", { noremap = true, silent = true });
vim.api.nvim_set_keymap("v", ",c", ":call nerdcommenter#Comment(0, 'toggle')<CR>", { noremap = true, silent = true });

vim.keymap.set("n", "<leader>cf", "0<c-g>", { desc = "Show full file path" })

vim.keymap.set("n", "<C-t>", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
vim.keymap.set("t", "<C-t>", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })

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

vim.keymap.set('i', '<C-y>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
vim.keymap.set('i', '<C-;>', function() return vim.fn['codeium#CycleCompletions'](1) end)
vim.keymap.set('i', '<C-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end)
vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })

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
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

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
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    -- nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    -- nmap('<leader>K', vim.lsp.buf.signature_help, 'Signature Documentation')

    local optsSaga = { noremap = true, silent = true }
    vim.keymap.set('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', optsSaga)
    vim.keymap.set('i', '<leader>K', '<Cmd>Lspsaga signature_help<CR>', optsSaga)
    vim.keymap.set('n', '<leader>kp', '<Cmd>Lspsaga peek_definition<CR>', optsSaga)
    vim.keymap.set('n', '<leader>kd', '<cmd>Lspsaga finder<CR>')

    vim.keymap.set('n', '<leader>kj', '<Cmd>Lspsaga diagnostic_jump_next<CR>', optsSaga)
    vim.keymap.set('n', '<leader>rn', '<Cmd>Lspsaga rename<CR>', optsSaga)
    vim.keymap.set('n', '<leader>o', '<Cmd>Lspsaga outline<CR>', optsSaga)

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

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
require("flash").toggle(false)
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
require("nvim-tree").setup({
    view = {
        width = 40,
    },
})

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
    },
    themeConfigFile = "~/.config/nvim/lua/custom/plugins/theme.lua", -- Described below
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


-- require("custom.plugins.debug")
