require("config.lazy")

vim.o.termguicolors = true
vim.cmd.colorscheme("catppuccin")
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

require("config.lsp")
require("config.keymaps")

