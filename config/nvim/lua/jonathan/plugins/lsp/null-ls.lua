return {
	"nvimtools/none-ls.nvim", -- configure formatters & linters
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "mason.nvim" },
	config = function()
		local null_ls = require("null-ls")

		local formatting = null_ls.builtins.formatting -- to setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- to setup linters

		-- format on save (from null_ls docs)
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		-- configure null_ls
		null_ls.setup({
			-- setup formatters & linters
			debug = false,
			sources = {
				--  to disable file types use
				--  "formatting.prettier.with({disabled_filetypes = {}})" (see null-ls docs)
				formatting.black, -- python
				formatting.sql_formatter.with({ -- install with npm -g (see https://github.com/sql-formatter-org/sql-formatter#readme)
					extra_args = { "--config", '{"language": "postgresql", "tabWidth": 2, "keywordCase": "upper"}' },
				}),
				formatting.prettier, -- js/ts/apex formatter
				formatting.stylua, -- lua formatter
        formatting.clang_format,
			},
			-- configure format on save
			on_attach = function(current_client, bufnr)
				if current_client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								filter = function(client)
									--  only use null-ls for formatting instead of lsp server
									return client.name == "null-ls"
								end,
								bufnr = bufnr,
								timeout_ms = 3000, -- add because apex prettier formatting is slow
							})
						end,
					})
				end
			end,
		})
	end,
}
