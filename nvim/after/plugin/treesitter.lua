require("nvim-treesitter").setup()

local languages = {
	"lua",
	"vim",
	"vimdoc",
	"javascript",
	"typescript",
	"vue",
	"html",
	"css",
	"json",
	"rust",
	"c",
	"python",
	"go",
	"markdown",
	"odin",
	"c_sharp",
}

require("nvim-treesitter").install(languages)

-- nvim-treesitter no longer auto-enables highlighting; start it per buffer.
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
