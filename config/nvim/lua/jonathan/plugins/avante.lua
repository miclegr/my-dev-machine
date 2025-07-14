return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "gemini",
    providers = {
        gemini = {
        model = "gemini-2.5-flash",
      },
      copilot = {
        hide_in_model_selector = true
      }
    },
    windows = {
      width = 35,
      sidebar_header = {
        enabled = true
      },
      input = {
        height = 15
      }
    }
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  },
}
