local Remap = require("kenjam.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

local cmp = require("cmp")
local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	path = "[Path]",
}
local lspkind = require("lspkind")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
	}),

	formatting = {
		format = function(entry, vim_item)
			vim_item.kind = lspkind.presets.default[vim_item.kind]
			local menu = source_mapping[entry.source.name]
			vim_item.menu = menu
			return vim_item
		end,
	},

	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		nnoremap("gd", function()
			vim.lsp.buf.definition()
		end)
		nnoremap("K", function()
			vim.lsp.buf.hover()
		end)
		nnoremap("<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end)
		nnoremap("<leader>vd", function()
			vim.diagnostic.open_float()
		end)
		nnoremap("[d", function()
			vim.diagnostic.goto_next()
		end)
		nnoremap("]d", function()
			vim.diagnostic.goto_prev()
		end)
		nnoremap("<leader>ca", function()
			vim.lsp.buf.code_action()
		end)
		nnoremap("<leader>rr", function()
			vim.lsp.buf.references()
		end)
		nnoremap("<leader>rn", function()
			vim.lsp.buf.rename()
		end)
		nnoremap("<leader>fm", function()
			require("conform").format()
		end)
		inoremap("<C-h>", function()
			vim.lsp.buf.signature_help()
		end)
	end,
})

require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		-- Provides the `roslyn` package used by roslyn.nvim (:MasonInstall roslyn)
		"github:Crashdummyy/mason-registry",
	},
})

require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"rust_analyzer",
		"ts_ls",
		"vue_ls",
		"clangd",
		"tailwindcss",
	},
})

vim.lsp.config('*', {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "it", "describe", "before_each", "after_each" },
			},
            workspace = {
                library = {
                    "${3rd}/love2d/library",
                },
            },
		},
	},
})

local vue_plugin_path = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

vim.lsp.config('ts_ls', {
	filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
	init_options = {
		plugins = {
			{
				name = '@vue/typescript-plugin',
				location = vue_plugin_path,
				languages = { 'vue' },
			},
		},
	},
})

vim.lsp.config('vue_ls', {})

vim.lsp.config('ols', {
	init_options = {
		checker_args = "-strict-style",
		collections = {
			{ name = "shared", path = vim.fn.expand("$HOME/odin-lib") },
		},
	},
})

vim.lsp.enable({ 'lua_ls', 'rust_analyzer', 'ts_ls', 'vue_ls', 'clangd', 'tailwindcss', 'ruby_lsp', 'pyright', 'ols' })

vim.diagnostic.config({
	virtual_text = true,
})

require("outline").setup({
	outline_items = {
		highlight_hovered_item = true,
		show_guides = true,
	},
})
