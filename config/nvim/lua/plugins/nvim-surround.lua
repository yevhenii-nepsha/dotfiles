return {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            surrounds = {
                -- Custom surround for markdown links
                -- Usage: Visual select text, press S, then press l, enter URL
                ["l"] = {
                    add = function()
                        local url = vim.fn.input("URL: ")
                        return { { "[" }, { "](" .. url .. ")" } }
                    end,
                },
            },
        })
    end,
}
