return {
    -- Surround Editing
    {
        'kylechui/nvim-surround',
        config = function()
            require('nvim-surround').setup()
        end
    },
    -- Autopairs
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        opts = {},
    },
}
