return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ft = { "markdown" },
    opts = {
        heading = { enabled = true },
        paragraph = { enabled = false },
        code = { enabled = true },
        dash = { enabled = true },
        bullet = { enabled = false },  -- obsidian.nvim handles this
        checkbox = { enabled = false }, -- obsidian.nvim handles this
        quote = { enabled = true },
        pipe_table = { enabled = true },
        callout = {},
        link = { enabled = true },
        sign = { enabled = false },
        indent = { enabled = true },
        inline_highlight = { enabled = true },
        -- Don't change conceallevel, let obsidian.nvim handle it
        win_options = {
            conceallevel = {
                default = 1,
                rendered = 1,
            },
        },
    },
}
