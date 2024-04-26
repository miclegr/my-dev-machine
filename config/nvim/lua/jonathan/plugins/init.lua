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
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/which-key.nvim", -- displays a popup with possible key bindings of the command you started typing
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		-- opts = {}, -- uncomment to enable which-key
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
	-- java
	{ "mfussenegger/nvim-jdtls" },
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
}