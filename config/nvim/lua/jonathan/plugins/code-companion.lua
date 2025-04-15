return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "zbirenbaum/copilot.vim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.diff",
    "Davidyz/VectorCode",
  },
  opts = {
    log_level = 'TRACE',
    strategies = {
      chat = {
        slash_commands = {
          codebase = require("vectorcode.integrations").codecompanion.chat.make_slash_command(),
        },
        tools = {
          vectorcode = {
            description = "Run VectorCode to retrieve the project context.",
            callback = require("vectorcode.integrations").codecompanion.chat.make_tool(),
          },
        },
      },
    },
    display = {
      diff = {
        provider = "mini_diff",
      },
    chat = {
      window = {
        width = 0.35,
      }
    },
    },
  },
}
