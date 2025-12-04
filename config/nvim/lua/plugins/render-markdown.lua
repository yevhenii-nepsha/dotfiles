return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ft = { "markdown" },
    opts = {
        -- Only render tables and code blocks, disable everything else
        heading = { enabled = false },
        paragraph = { enabled = false },
        code = { enabled = true },
        dash = { enabled = false },
        bullet = { enabled = false },
        checkbox = { enabled = false },
        quote = { enabled = false },
        pipe_table = { enabled = true },
        callout = {},
        link = { enabled = false },
        sign = { enabled = false },
        indent = { enabled = false },
        -- Don't change conceallevel, let obsidian.nvim handle it
        win_options = {
            conceallevel = {
                default = 1,
                rendered = 1,
            },
        },
    },
}
