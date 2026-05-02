vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opts = {noremap = true, silent = true}
local set = vim.keymap.set

-- set("n", "<leader>cd", vim.cmd.Ex)

set("v", "J", ":m '>+1<CR>gv=gv", {desc = "Moves lines down"})
set("v", "K", ":m '<-2<CR>gv=gv", {desc = "Moves lines up"})

set("n", "<C-d>", "<C-d>zz", {desc = "Moves down half page and cursor centered"})
set("n", "<C-u>", "<C-u>zz", {desc = "Moves up half page and cursor centered"})

set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")

set("v", "<", "<gv", opts)
set("v", ">", ">gv", opts)

--Clipboard keybinds
set("x", "<leader>p", [["_dP"]])
set("v", "p", '"_dP', opts)
set({"n", "v"}, "<leader>d", [["_dP"]])

set("n", "<C-c>", ":nohl<CR>", {desc = "Clear search hl", silent = true})

set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {desc = "Replace word globally"})

--Tabs
set("n", "<leader>to", "<cmd>tabnew<CR>")
set("n", "<leader>tx", "<cmd>tabclose<CR>")
set("n", "<leader>tn", "<cmd>tabn<CR>")
set("n", "<leader>tp", "<cmd>tabp<CR>")
set("n", "<leader>tf", "<cmd>tabnew %<CR>")

--Splits
set("n", "<leader>sv", "<C-w>v", {desc = "Split window vertically"})
set("n", "<leader>sh", "<C-w>s", {desc = "Split window horizontally"})
set("n", "<leader>se", "<C-w>=", {desc = "Make splits equally size"})
set("n", "<leader>sx", "<cmd>close<CR>", {desc = "Close current split"})
