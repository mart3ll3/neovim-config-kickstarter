# kickstart.nvim

### Prerequisities
Neovim
[git](https://cli.github.com/)
[make](https://www.gnu.org/software/make/)
[pip](https://pypi.org/project/pip/)
[python](https://www.python.org/)
[npm](https://npmjs.com/)
[node](https://nodejs.org/)
[cargo](https://www.rust-lang.org/tools/install)
[ripgrep](https://github.com/BurntSushi/ripgrep)
[fd](https://github.com/sharkdp/fd) 

lazygit (optional)
[NERD font](https://www.nerdfonts.com/) -- one is enough, for example "JetBrainsMono Nerd Font"

### Installation
Overwrite nvim config folder
Location

### Commands
:Lazy - update plugins

:Mason - install/update/remove language servers, formaters, linters
  i - install
  u - update
  X - remove

:MasonInstall - install specific version
  for example :MasonInstall omnisharp@v1.39.8

:e! - force reload language server

:mes - show history of messages

### Shortcuts
escape or double escape or q - close modal windows
C means control with some key after dash (for exmample C-u means control with key u) 
S means shift with some key after dash (for exmample S-h means control with key h) 

<leader> - is set to key space atm
jk - go to normal mode

"<leader>qq" - force close all buffers and close neovim
<leader>bd - close buffer
<leader>wd - close window
S-h - go to left buffer
S-l - go to right buffer
C-h - go to left window
C-l - go to right window
C-j - go to window below
C-k - go to window up

Jump to location on shown text - plugin [Flash](https://github.com/folke/flash.nvim)
s + 1 or 2 chars of positionand confirmation by another letter will jump to that position

Surround text - plugin [nvim-surround](https://github.com/kylechui/nvim-surround)
Examples of usage:
    Old text                    Command         New text
--------------------------------------------------------------------------------
    surr*ound_words             ysiw)           (surround_words)
    *make strings               ys$"            "make strings"
    [delete ar*ound me!]        ds]             delete around me!
    remove <b>HTML t*ags</b>    dst             remove HTML tags
    'change quot*es'            cs'"            "change quotes"
    <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
    delete(functi*on calls)     dsf             function calls



<leader>sf - fuzzy find file by file name 
<leader>sg - fuzzy find string

<leader>e - toggle file tree view
<leader>fu - make smaller tree view
<leader>fi - enlarge tree view

<leader>u - toggle undotree (local history of changes on document)

<leader>o - toggle outline
} - next symbol from outline
{ - previous symbol from outline

Harpoon - quick switching between up to 4 files
<leader>a - Harpoon add file 
C-e - toggle Harpoon quick menu
C-p - Harpoon file #1
C-t - Harpoon file #2
C-n - Harpoon file #3
C-s - Harpoon file #4

<leader>sj - show jump list
C-o - jump to previous position 
C-i - jump forward in position history
C-; - next buffer in jump list
C-g - previous buffer in jump list

<leader>cf - show file path

<leader>J - toggle wrap parameters, text in element etc


### Code view/manipulation shortcuts

<leader>gs - Lazygit
<leader>dt - show diagnostics for whole folder

,c - toggle comment line or visualized block
<leader>cc - comment line

<leader>ff - format document

gd - go to definition
gr - go to references
gI - go to implementation
<leader>ca - code action
K - hover documentation (another K jumps into that window)
gD - go to declaration
C-n - next option in intellisense
C-p - previous option in intellisense
Tab - confirm select or 1st option in intellisense

Keymaps for objects from treesitter (parser)
This could be used either when text is visually selected or by some vim motion
Shortcuts here are inside appostrophes, this is just copy/paste from lua config

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
        ["<leader>n:"] = "@property.outer", -- swap object property with next
        ["<leader>nm"] = "@function.outer", -- swap function with next
      },
      swap_previous = {
        ["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
        ["<leader>p:"] = "@property.outer", -- swap object property with prev
        ["<leader>pm"] = "@function.outer", -- swap function with previous
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




