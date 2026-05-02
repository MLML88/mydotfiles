return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
        "saghen/blink.cmp",
    },
    opts = {
        servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = {"vim"},
                        },
                    },
                },
            },
            ts_ls = {},
            eslint = {},
            tailwindcss = {},
            pyright = {},
        },
    },
    config = function(_, opts)
        require("mason").setup()

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "eslint",
                "tailwindcss",
                "pyright",
            },
        })

        local capabilities = require("blink.cmp").get_lsp_capabilities()

        for server, config in pairs(opts.servers) do
            config.capabilities = capabilities
            vim.lsp.config(server, config)
            vim.lsp.enable(server)
        end

    end
}
