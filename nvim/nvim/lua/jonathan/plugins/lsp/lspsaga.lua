return {
	"nvimdev/lspsaga.nvim",
	config = function()
		-- import lspsaga safely
		local saga = require("lspsaga")

		saga.setup({
			-- keybinds for navigation in lspsaga window
			scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },
			-- use enter to open file with definition preview
			lightbulb = {
				debounce = 500, -- particularly needed for Java since there are code actions on every line
			},
			definition = {
				keys = {
					edit = "<CR>",
				},
			},
			finder = {
				keys = {
					edit = "<CR>",
				},
			},
			ui = {
				colors = {
					normal_bg = "#022746",
				},
			},
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- optional
		"nvim-tree/nvim-web-devicons", -- optional
	},
} -- enhanced UI for LSPs
