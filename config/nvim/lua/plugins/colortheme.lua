return {
    -- Moonfly theme
    {
        "bluz71/vim-moonfly-colors",
        name = "moonfly",
        lazy = false,
        priority = 1000,
        config = function()
            -- Moonfly configuration
            vim.g.moonflyCursorColor = true
            vim.g.moonflyItalics = false
            vim.g.moonflyNormalFloat = true
            vim.g.moonflyTerminalColors = true
            vim.g.moonflyTransparent = true
            vim.g.moonflyUndercurls = true
            vim.g.moonflyUnderlineMatchParen = false
            vim.g.moonflyVirtualTextColor = true

            -- Set colorscheme
            vim.cmd([[colorscheme moonfly]])
        end,
    },
}
