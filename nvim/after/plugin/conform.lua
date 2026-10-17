require("conform").setup({
	format_on_save = false,
	default_format_opts = {
		timeout_ms = 5000,
	},
	formatters = {
		odinfmt = {
			command = "odinfmt",
			args = { "-stdin" },
			stdin = true,
		},
	},
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		html = { "prettierd" },
		javascript = { "eslint_d", "prettierd" },
		javascriptreact = { "eslint_d", "prettierd" },
		markdown = { "prettierd" },
		typescript = { "eslint_d", "prettierd" },
		typescriptreact = { "eslint_d", "prettierd" },
		vue = { "eslint_d", "prettierd" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		go = { "gofmt" },
		odin = { "odinfmt" },
		["*"] = { "trim_whitespace" },
	},
})
