return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
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
      providers = {
        copilot = {
          disabled = true,
        },
        github_models = {
          disabled = true,
        },
        github_embeddings = {
          disabled = true,
        },
        gemini = {

          prepare_input = function(inputs, opts)
            return require('CopilotChat.config.providers').copilot.prepare_input(inputs, opts)
          end,

          prepare_output = function(output)
            return require('CopilotChat.config.providers').copilot.prepare_output(output)
          end,

          get_headers = function ()
            local gemini_key = os.getenv("GEMINI_API_KEY")
            return {
              ["Authorization"] = 'Bearer ' .. gemini_key,
            }, nil
          end,

          get_models = function(headers)
            local response, err = require('CopilotChat.utils').curl_get('https://generativelanguage.googleapis.com/v1beta/openai/models', {
                headers = headers,
                json_response = true,
            })

            if err then
                error(err)
            end

            return vim.tbl_map(function(model)
                return {
                    id = model.id,
                    name = model.id,
                }
            end, response.body.data)
          end,

          embed = function(inputs, headers)
            local response, err = require('CopilotChat.utils').curl_post('https://generativelanguage.googleapis.com/v1beta/openai/embeddings', {
                headers = headers,
                json_request = true,
                json_response = true,
                body = {
                    input = inputs,
                    model = 'text-embedding-004',
                },
            })

            if err then
                error(err)
            end

            local data = {}
            for i, embed in ipairs(response.body.data) do
              table.insert(data, {
                    index = i - 1,
                    embedding = embed.embedding,
                    object = embed.object,
                })
            end

            return data

          end,

          get_url = function()
            return 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions'
          end,
          },
      },
      model = 'models/gemini-1.5-pro',
    },
  },
}
