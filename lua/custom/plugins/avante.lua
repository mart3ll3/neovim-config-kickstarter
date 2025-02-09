return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    -- provider = "openai",
    -- vendors = {
    -- ---@type AvanteProvider
    -- openai = {
    -- ["local"] = true,
    -- endpoint = "http://localhost:11434/v1",
    -- model = "deepseek-r1-distill-qwen-32b",
    -- parse_curl_args = function(opts, code_opts)
    -- return {
    -- url = opts.endpoint .. "/chat/completions",
    -- headers = {
    -- ["Accept"] = "application/json",
    -- ["Content-Type"] = "application/json",
    -- },
    -- body = {
    -- model = opts.model,
    -- messages = require("avante.providers").copilot.parse_message(code_opts),    -- you can make your own message, but this is very advanced
    -- max_tokens = 2048,
    -- stream = true,
    -- },
    -- }
    -- end,
    -- parse_response_data = function(data_stream, event_state, opts)
    -- require("avante.providers").openai.parse_response(data_stream, event_state, opts)
    -- end,
    -- },
    -- },
    provider = "lmstudio",
    vendors = {
      lmstudio = {
        __inherited_from = "openai",
        api_key_name = "",
        endpoint = "http://127.0.0.1:11434/v1",
        model = "deepseek-r1-distill-qwen-32b@iq3_xs",
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
