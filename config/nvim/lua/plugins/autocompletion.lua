return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
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
                "rafamadriz/friendly-snippets",
            },
        },
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        -- Load snippets from friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Track autocomplete state
        vim.g.cmp_autocomplete_enabled = false

        -- Toggle function
        local function toggle_autocomplete()
            vim.g.cmp_autocomplete_enabled = not vim.g.cmp_autocomplete_enabled
            if vim.g.cmp_autocomplete_enabled then
                cmp.setup({ completion = { autocomplete = { cmp.TriggerEvent.TextChanged } } })
                vim.notify("Autocomplete: AUTO", vim.log.levels.INFO)
            else
                cmp.setup({ completion = { autocomplete = false } })
                vim.notify("Autocomplete: MANUAL (Tab)", vim.log.levels.INFO)
            end
        end

        -- Keymap to toggle: <leader>ta (toggle autocomplete)
        vim.keymap.set("n", "<leader>ta", toggle_autocomplete, { desc = "Toggle autocomplete" })

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            completion = {
                completeopt = "menu,menuone,noinsert",
                autocomplete = false, -- disable auto popup, trigger manually with <C-Space>
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<Tab>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),

            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
            }, {
                { name = "buffer" },
            }),
        })
    end,
}
