return {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
            version = "2.*",
            build = (function()
                if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                    return
                end
                return "make install_jsregexp"
            end)(),
            dependencies = {
                {
                    "rafamadriz/friendly-snippets",
                    config = function()
                        require("luasnip.loaders.from_vscode").lazy_load()
                    end,
                },
            },
            opts = {},
        },
        "folke/lazydev.nvim",
    },
    opts = {
        keymap = {
            preset = "super-tab",
            ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        },

        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 300 },
        },

        sources = {
            default = { "lsp", "path", "snippets", "lazydev" },
            providers = {
                lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
            },
            -- Enable completion from all sources for markdown
            per_filetype = {
                markdown = { "lsp", "path", "snippets", "buffer" },
            },
        },

        snippets = { preset = "luasnip" },
        fuzzy = { implementation = "lua" },
        signature = {
            enabled = true,
            trigger = { enabled = false },
            window = { show_documentation = true },
        },
    },
}
