return {
	-- note: you can lazy load plugins on certain keybinds too with the "keys" property (see :h lazy.nvim)
	{
		"nvim-lua/plenary.nvim",
	}, -- Lua functions that many other plugins depend on
	-- {
	-- 	"LunarVim/bigfile.nvim", -- Could be useful for large files
	-- },
	{ "echasnovski/mini.nvim", version = "*" },
	{
		"tpope/vim-repeat",
		event = { "BufReadPre", "BufNewFile" },
	},
	{
		"folke/trouble.nvim",
    opts={},
		dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble"
	},
	{
		"folke/which-key.nvim", -- displays a popup with possible key bindings of the command you started typing
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},
	{ "sindrets/diffview.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
	{ "christoomey/vim-tmux-navigator", lazy = false },
	{
		"mg979/vim-visual-multi",
		config = function()
			vim.keymap.set("n", "<C-m>", "<Plug>(VM-Find-Under)")
		end,
	},
	"mbbill/undotree",
	"tpope/vim-fugitive",
	-- makes resolving merge conflicts easy ([x maps to next conflict)
	{ "metakirby5/codi.vim", event = { "BufReadPre", "BufNewFile" } },
	{
		"rcarriga/cmp-dap",
		event = { "BufReadPre", "BufNewFile" },
	},
	-- markdown preview
	{
		"iamcco/markdown-preview.nvim",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	{
		"tweekmonster/startuptime.vim"
	},
  {
    'ojroques/nvim-osc52',
		config = function()
      require('osc52').setup {
        max_len = 0,
        silent = false,
        trim = false,
        tmux_passthrough = true,
      }
      vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
      vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
      vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)
    end
  },
  {
  'stevearc/aerial.nvim',
	config = function()
    require('aerial').setup {
    }
    vim.keymap.set('n', '<leader>fo', "<cmd>AerialToggle!<CR>")
  end,
  dependencies = {
     "nvim-treesitter/nvim-treesitter",
     "nvim-tree/nvim-web-devicons"
   },
  },
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        source = diff.gen_source.none(),
        view = {
          style = 'sign',
        }
      })
    end,
  },
  {
    "Davidyz/VectorCode",
     version = "*",
     build = "pipx upgrade vectorcode",
     dependencies = { "nvim-lua/plenary.nvim" },
  },
}
