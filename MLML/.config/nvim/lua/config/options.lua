local set = {
    nu = true,
    relativenumber = true,
    cursorline = true,

    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    autoindent = true,
    smartindent = true,
    wrap = false,

    clipboard = "unnamedplus",
    mouse = "a",

    swapfile = false,
    backup = false,
    undodir = os.getenv("HOME") .. "/.vim/undodir",
    undofile = true,

    incsearch = true,
    inccommand = "split",
    ignorecase = true,
    smartcase = true,
    hlsearch = true,

    termguicolors = true,

    scrolloff = 8,
    fixendofline = false,

    backspace = {"start", "eol", "indent"},

    splitright = true,
    splitbelow = true,

    updatetime = 50,
}

for key, value in pairs(set) do
    vim.opt[key] = value
end

-- Windows Only
-- vim.g.clipboard = {
--     name = "win32yank.wsl",
--     copy = {
--         ["+"] = "win32yank.exe -i --crlf",
--         ["*"] = "win32yank.exe -i --crlf",
--     },
--     paste = {
--         ["+"] = "win32yank.exe -o --lf",
--         ["*"] = "win32yank.exe -o --lf",
--     },
--     cache_enabled = 0,
-- }

vim.g.editorconfig = true
