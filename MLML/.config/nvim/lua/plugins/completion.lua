return {
    'saghen/blink.cmp',
    dependencies = { 'L3MON4D3/LuaSnip' },

    version = '1.*',

    opts = {
        keymap = {
            preset = 'default',

            ['<Tab>'] = { 'snippet_forward', 'fallback' },
            ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        },

        snippets = {
            preset = 'luasnip',

            expand = function(snippet)
                require('luasnip').lsp_expand(snippet)
            end,

            active = function(filter)
                if filter and filter.direction then
                    return require('luasnip').jumpable(filter.direction)
                end
                return require('luasnip').in_snippet()
            end,

            jump = function(direction)
                require('luasnip').jump(direction)
            end,
        },

        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono'
        },

        completion = {documentation = {auto_show = true}},

        sources = {
            default = {"lsp", "path", "snippets", "buffer"},
        },

        signature = { enabled = true },
        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = {"sources.default"}
}
