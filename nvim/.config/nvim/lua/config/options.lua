local set = {
    nu = true,
    cursorline = true,

    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,

    smartindent = true,

    wrap = false,

    swapfile = false,
    backup = false,
    undodir = os.getenv("HOME") .. "/.vim/undodir",
    undofile = true,

    hlsearch = false,
    incsearch = true,

    termguicolors = true,

    scrolloff = 8,
    fixendofline = false,
}

for key, value in pairs(set) do
    vim.opt[key] = value
end

