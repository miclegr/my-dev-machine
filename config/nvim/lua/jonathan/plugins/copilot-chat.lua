return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.vim" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      contexts = {
        file = {
          input = function(callback)
            local telescope = require("telescope.builtin")
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            telescope.find_files({
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  callback(selection[1])
                end)
                return true
              end,
            })
          end,
        },
      },
    },
  },
}
