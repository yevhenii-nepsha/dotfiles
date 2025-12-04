return {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text" },
    init = function()
        vim.g.bullets_enabled_file_types = { "markdown", "text" }
        -- Disable checkbox markers, let obsidian.nvim handle rendering
        vim.g.bullets_checkbox_markers = " X"
        vim.g.bullets_nested_checkboxes = 0
        vim.g.bullets_outline_levels = { "std-", "std*", "std+" }
        -- Only use bullets in insert mode, not normal mode mappings
        vim.g.bullets_set_mappings = 0
        vim.g.bullets_custom_mappings = {
            { "imap", "<cr>", "<Plug>(bullets-newline)" },
            { "inoremap", "<C-cr>", "<cr>" },
        }
    end,
}
