return {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    -- dependencies = {
    --     "rafamadriz/friendly-snippets",
    -- },
    config = function()
        local ls = require("luasnip")

        -- require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load({paths = "~/.config/nvim/snippets"})

        -- Keymaps for snippet navigation
        -- vim.keymap.set({"i"}, "<C-k>", function()
        --     if ls.expand_or_jumpable() then
        --         ls.expand_or_jump()
        --     end
        -- end, { silent = true, desc = "Expand or jump to next snippet node" })
        --
        -- vim.keymap.set({"i", "s"}, "<C-j>", function()
        --     if ls.jumpable(-1) then
        --         ls.jump(-1)
        --     end
        -- end, { silent = true, desc = "Jump to previous snippet node" })
        --
        -- vim.keymap.set("i", "<C-l>", function()
        --     if ls.choice_active() then
        --         ls.change_choice(1)
        --     end
        -- end, { silent = true, desc = "Cycle through choice nodes" })
    end
}
