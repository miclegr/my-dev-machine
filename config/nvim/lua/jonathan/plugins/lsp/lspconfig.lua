return {
	"neovim/nvim-lspconfig", -- in-built Neovim LSP
	dependencies = {
		"hrsh7th/cmp-nvim-lsp", -- autocompletion
	},
	config = function()
		-- disable lsp logs ("off") unless needed so it doesn't create a huge file (switch to "debug" if needed)
		vim.lsp.set_log_level("off")

		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		-- enable keybinds when lsp is available
		local on_attach = function(client, bufnr)
			-- keybind options
			local opts = { noremap = true, silent = true, buffer = bufnr }

			-- set keybinds
			keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts) -- show definition, references
			keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- go to declaration
			keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
			keymap.set("n", "gi", "<cmd>Lspsaga incoming_calls<CR>", opts) -- go to incoming calls
			keymap.set("n", "go", "<cmd>Lspsaga outgoing_calls<CR>", opts) -- go to outgoing calls
			keymap.set("n", "<leader>ga", "<cmd>Lspsaga code_action<CR>", opts) -- go to available code actions
			keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename mode=n<CR>", opts) -- smart rename
			keymap.set("n", "<leader>rN", "<cmd>Lspsaga rename ++project<CR>", opts) -- smart rename project wide
			keymap.set("n", "èd", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
			keymap.set("n", "+d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
			keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
		end

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- configure html server
		lspconfig["html"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure cpp server
		lspconfig["clangd"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
      filetypes = {"c", "cpp", "objc", "objcpp", "cuda", "proto", "hpp"}
		})

		-- self-contained ty install (python type checker + LSP from astral-sh/ty)
		local ty_dir = vim.fn.stdpath("data") .. "/ty"
		local ty_bin = ty_dir .. "/ty"

		local function ensure_ty()
			if vim.uv.fs_stat(ty_bin) then
				return ty_bin
			end
			vim.fn.mkdir(ty_dir, "p")
			local url = "https://github.com/astral-sh/ty/releases/latest/download/ty-x86_64-unknown-linux-gnu.tar.gz"
			vim.fn.system({ "sh", "-c", ("curl -LsSf '%s' | tar -xz -C '%s' --strip-components=1"):format(url, ty_dir) })
			if vim.v.shell_error ~= 0 or not vim.uv.fs_stat(ty_bin) then
				vim.notify("ty LSP: failed to install binary", vim.log.levels.ERROR)
				return nil
			end
			return ty_bin
		end

		local ty_bin = ensure_ty()
		if ty_bin then
			local configs = require("lspconfig.configs")
			if not configs.ty then
				configs.ty = {
					default_config = {
						cmd = { ty_bin, "server" },
						filetypes = { "python" },
						root_dir = function(fname)
							return lspconfig.util.root_pattern(
								"ty.toml", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"
							)(fname)
						end,
					},
				}
			end

			-- configure python server
			lspconfig["ty"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "python" },
			})
		end

		-- configure ts server
		lspconfig["ts_ls"].setup({
			init_options = {
				-- relative imports
				preferences = {
					importModuleSpecifierPreference = "relative",
					importModuleSpecifierEnding = "minimal",
				},
				plugins = {},
			},
			filetypes = {
				"javascript",
				"typescript",
				"typescriptreact",
				"javascriptreact",
				"vue",
			},
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure css server
		lspconfig["cssls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure bash server
		lspconfig["bashls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- configure java server

    local function get_jdtls_cache_dir()
      return vim.loop.os_homedir() .. '/.cache/jdtls'
    end

    local function get_jdtls_config_dir()
      return get_jdtls_cache_dir() .. '/config'
    end

    local function get_jdtls_workspace_dir()
      return get_jdtls_cache_dir() .. '/workspace'
    end

		lspconfig["jdtls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
      settings = {
        java = {
          home = vim.fn.expand("$HOME/.sdkman/candidates/java/current"), -- java home
          cmd = {
            'jdtls',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-configuration',
            get_jdtls_config_dir(),
            '-data',
            get_jdtls_workspace_dir(),
          },
          eclipse = {
            downloadSources = true,
          },
          configuration = {
            updateBuildConfiguration = "interactive",
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
          references = {
            includeDecompiledSources = true,
          },
          format = {
            enabled = false, -- format on save (this doesn't seem to work consistently) see https://github.com/mfussenegger/nvim-jdtls/issues/533 for a potential solution
          },
        },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
          },
          importOrder = {
            "java",
            "javax",
            "com",
            "org",
          },
        },
        extendedClientCapabilities = {
          classFileContentsSupport = true,
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
        },
      },
    })

		-- configure lua server
		lspconfig["lua_ls"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			on_init = function(client)
				local path = client.workspace_folders[1].name
				if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
					client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
						Lua = {
							runtime = {
								-- Tell the language server which version of Lua you're using
								-- (most likely LuaJIT in the case of Neovim)
								version = "LuaJIT",
							},
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME .. "/lua",
									"${3rd}/luv/library",
									"${3rd}/busted/library",
								},
								-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
								-- library = vim.api.nvim_get_runtime_file("", true),
							},
							diagnostics = {
								globals = { "vim" },
							},
						},
					})

					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
				end
			end,
		})
	end,
}
