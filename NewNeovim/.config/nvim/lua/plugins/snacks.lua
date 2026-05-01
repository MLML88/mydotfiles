return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            quickfile = {
                enabled = true,
                exclude = { "latex" },
            },
            -- HACK: read picker docs @ https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
            picker = {
                exclude = {
                    ".git",
                    "node_modules",
                    "dist",
                    "build",
                },
                formatters = {
                    file = {
                        filename_first = true,
                        filename_only = false,
                        icon_width = 2,
                    },
                },
                layout = {
                    -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
                    -- override picker layout in keymaps function as a param below
                    preset = "telescope", -- defaults to this layout unless overidden
                    cycle = false,
                },
                layouts = {
                    select = {
                        preview = false,
                        layout = {
                            backdrop = false,
                            width = 0.6,
                            min_width = 80,
                            height = 0.4,
                            min_height = 10,
                            box = "vertical",
                            border = "rounded",
                            title = "{title}",
                            title_pos = "center",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                            { win = "preview", title = "{preview}", width = 0.6, height = 0.4, border = "top" },
                        }
                    },
                    telescope = {
                        reverse = true, -- set to false for search bar to be on top 
                        layout = {
                            box = "horizontal",
                            backdrop = false,
                            width = 0.8,
                            height = 0.9,
                            border = "none",
                            {
                                box = "vertical",
                                { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
                                { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
                            },
                            {
                                win = "preview",
                                title = "{preview:Preview}",
                                width = 0.50,
                                border = "rounded",
                                title_pos = "center",
                            },
                        },
                    },
                    ivy = {
                        layout = {
                            box = "vertical",
                            backdrop = false,
                            width = 0,
                            height = 0.4,
                            position = "bottom",
                            border = "top",
                            title = " {title} {live} {flags}",
                            title_pos = "left",
                            { win = "input", height = 1, border = "bottom" },
                            {
                                box = "horizontal",
                                { win = "list", border = "none" },
                                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
                            },
                        },
                    },
                },
            },
        },

        keys = {
            {"<leader>lg", function() require("snacks").lazygit() end, desc = "Lazygit"},
            {"<leader>gl", function() require("snacks").lazygit.log() end, desc = "Lazygit Logs"},
            {"<leader>es", function() require("snacks").explorer() end, desc = "Opens Snacks Explorer"},
            {"<leader>rN", function() require("snacks").rename.rename_file() end, desc = "Fast Rename Current File"},
            {"<leader>dB", function() require("snacks").bufdelete() end, desc = "Delete/Close Buffer (confirm)"},

            --Snack Picker
            {"<leader>pf", function() require("snacks").picker.files() end, desc = "Find files"},
            {"<leader>pc", function() require("snacks").picker.files({cwd = vim.fn.stdpath("config")}) end, desc = "Find config files"},
            {"<leader>ps", function() require("snacks").picker.grep() end, desc = "Grep word"},
            {"<leader>pws", function() require("snacks").picker.grep_word() end, desc = "Grep selected word", mode = {"n", "x"}},
            {"<leader>pk", function() require("snacks").picker.keymaps({layout = "ivy"}) end, desc = "Search keymaps"},

            {"<leader>gbr", function() require("snacks").picker.git_branches({layout = "select"}) end, desc = "Pick and switch git branches"},
            {"<leader>th", function() require("snacks").picker.colorschemes({layout = "ivy"}) end, desc = "Pick colorschemes"},
            {"<leader>vh", function() require("snacks").picker.help() end, desc = "Help page"},
        }
    }
}
