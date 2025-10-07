return {
	-- 🌳 Treesitter (core)
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				indent = { enable = true },
				ensure_installed = {
					"html",
					"css",
					"javascript",
					"typescript",
					"tsx",
					"lua",
					"bash",
					"json",
					"yaml",
					"markdown",
					"vim",
					"query",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-c>",
						node_incremental = "<C-c>",
						scope_incremental = false,
					},
				},
				additional_vim_regex_highlighting = false,
			})
		end,
	},

	-- 🏷️ Auto close + rename HTML/JSX tags
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		ft = { "html", "xml", "javascriptreact", "typescriptreact", "svelte", "vue" },
		config = function()
			require("nvim-ts-autotag").setup({
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			})
		end,
	},

	-- 📏 VS Code–like indent guides / tag connections
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
				highlight = "Function",
			},
		},
		config = function(_, opts)
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
			require("ibl").setup(opts)
