require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("i", "<C-l>", function()
  vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
end, { desc = "Copilot Accept", noremap = true, silent = true })

map("n", "<leader>tt", function()
  require("base46").toggle_transparency()
end, { desc = "Toggle transparency" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
