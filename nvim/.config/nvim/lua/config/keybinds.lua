vim.g.mapleader = " "
vim.g.maplocalleader = ","

local set = vim.keymap.set

set("n", "<leader>cd", vim.cmd.Ex)

set('v', 'J', ":m '>+1<CR>gv=gv")
set('v', 'K', ":m '<-2<CR>gv=gv")
