local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- General
	"nvim-lua/plenary.nvim",
	"nvim-lua/popup.nvim",
	"nvim-telescope/telescope.nvim",
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Mason / LSP
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",

	-- Completion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"onsails/lspkind-nvim",
	"saadparwaiz1/cmp_luasnip",
	"L3MON4D3/LuaSnip",

	-- Editing
	"windwp/nvim-autopairs",
	"windwp/nvim-ts-autotag",
	"numToStr/Comment.nvim",
	"JoosepAlviste/nvim-ts-context-commentstring",
	"hedyhli/outline.nvim",
	"mbbill/undotree",
	"stevearc/conform.nvim",
	"lukas-reineke/lsp-format.nvim",

	-- Git
	"lewis6991/gitsigns.nvim",
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree" },
			{ "<leader>gb", "<cmd>DiffviewOpen dev...HEAD<cr>", desc = "Diff branch vs dev" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
			{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
		},
	},

	-- C# (Roslyn, same server as VS Code C# Dev Kit; installed via the Crashdummyy Mason registry)
	{ "seblyng/roslyn.nvim", ft = { "cs", "razor" }, opts = {} },

	-- Claude Code: shares the current file/selection and shows Claude's edits as diffs here
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = true,
		keys = {
			{ "<leader>ic", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>if", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ir", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>ib", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
			{ "<leader>is", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
			{ "<leader>ia", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
			{ "<leader>id", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude diff" },
		},
	},

	-- Colorschemes
	{ "catppuccin/nvim", name = "catppuccin" },
	"folke/tokyonight.nvim",
	"neanias/everforest-nvim",
	{ "alljokecake/naysayer-theme.nvim", name = "naysayer" },

	-- Treesitter
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"romgrk/nvim-treesitter-context",

	-- Copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				-- Windows uses nvm4w's node; elsewhere node comes from PATH (mise).
				copilot_node_command = vim.fn.has("win32") == 1 and "C:\\nvm4w\\nodejs\\node.exe" or "node",
				suggestion = {
					auto_trigger = true,
					keymap = {
						accept = "<Tab>",
						next = "<C-n>",
						prev = "<C-p>",
						dismiss = "<C-]>",
					},
				},
				logger = {
					file_log_level = vim.log.levels.DEBUG,
					log_lsp_messages = true,
				},
			})
		end,
	},
})
