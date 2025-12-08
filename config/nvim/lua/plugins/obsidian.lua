local vault_path = vim.fn.fnamemodify("~/Documents/obsidian/nostromo", ":p"):gsub("/$", "")
local home_path = vault_path .. "/home.md"

-- Function to open home if in vault with no file
local function open_home_if_in_vault()
    local cwd = vim.fn.getcwd()
    local no_file = vim.fn.argc() == 0
        or (vim.fn.argc() == 1 and vim.fn.argv(0) == ".")
    if no_file and cwd:find(vault_path, 1, true) then
        vim.schedule(function()
            vim.cmd("edit " .. home_path)
        end)
    end
end

-- Create new note in inbox with proper frontmatter (no # heading)
local function new_inbox_note()
    local title = vim.fn.input("Enter note title: ")
    if title == "" then
        vim.notify("Aborted", vim.log.levels.WARN)
        return
    end

    local client = require("obsidian").get_client()
    local timestamp = os.date("%Y%m%d%H%M%S")
    local vault_path = tostring(client.dir)
    local inbox_dir = vault_path .. "/inbox"
    local file_path = inbox_dir .. "/" .. timestamp .. ".md"

    -- Create frontmatter
    local title_lower = title:lower()
    local content = string.format([[---
title: %s
created: %s
tags: [📥]
aliases:
  - %s
---

]], title_lower, os.date("%Y-%m-%d %H:%M:%S"), title_lower)

    -- Write file
    vim.fn.mkdir(inbox_dir, "p")
    local f = io.open(file_path, "w")
    if f then
        f:write(content)
        f:close()
        vim.cmd("edit " .. vim.fn.fnameescape(file_path))
        -- Move cursor to end of file
        vim.cmd("normal! G")
    else
        vim.notify("Failed to create note", vim.log.levels.ERROR)
    end
end

-- Create new literature note (source)
local function new_literature_note()
    local title = vim.fn.input("Enter source title: ")
    if title == "" then
        vim.notify("Aborted", vim.log.levels.WARN)
        return
    end

    local client = require("obsidian").get_client()
    local vault_path = tostring(client.dir)
    local lit_dir = vault_path .. "/literature notes"
    local file_path = lit_dir .. "/" .. title .. ".md"

    local content = string.format([[---
title: %s
tags: [source/book]
author: 
status: to-do
url: 
---

## Notes

]], title:lower())

    vim.fn.mkdir(lit_dir, "p")
    local f = io.open(file_path, "w")
    if f then
        f:write(content)
        f:close()
        vim.cmd("edit " .. vim.fn.fnameescape(file_path))
        -- Wait for Obsidian to process the file, then reload silently
        vim.defer_fn(function()
            vim.cmd("silent! checktime")
            vim.cmd("normal! G")
        end, 500)
    else
        vim.notify("Failed to create literature note", vim.log.levels.ERROR)
    end
end

-- Create new research note
local function new_research_note()
    local title = vim.fn.input("Enter research title: ")
    if title == "" then
        vim.notify("Aborted", vim.log.levels.WARN)
        return
    end

    local client = require("obsidian").get_client()
    local vault_path = tostring(client.dir)
    local research_dir = vault_path .. "/research"
    local file_path = research_dir .. "/" .. title .. ".md"

    local content = string.format([[---
title: %s
tags: [research]
created: %s
status: to-do
---

## Sources

## Notes

]], title:lower(), os.date("%Y-%m-%d %H:%M"))

    vim.fn.mkdir(research_dir, "p")
    local f = io.open(file_path, "w")
    if f then
        f:write(content)
        f:close()
        vim.cmd("edit " .. vim.fn.fnameescape(file_path))
        -- Wait for Obsidian to process the file, then reload silently
        vim.defer_fn(function()
            vim.cmd("silent! checktime")
            vim.cmd("normal! G")
        end, 500)
    else
        vim.notify("Failed to create research note", vim.log.levels.ERROR)
    end
end

-- Move current note to notes/ directory and update tag
local function move_to_notes()
    local current_file = vim.fn.expand("%:p")
    if not current_file:match("%.md$") then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
    end

    -- Check if already in notes/
    if current_file:match("/notes/") then
        vim.notify("Already in notes/", vim.log.levels.INFO)
        return
    end

    local client = require("obsidian").get_client()
    local vault_path = tostring(client.dir)
    local notes_dir = vault_path .. "/notes"
    local filename = vim.fn.expand("%:t")
    local new_path = notes_dir .. "/" .. filename

    -- Get current note using obsidian.nvim API
    local note = client:current_note()
    if note then
        -- Remove 📥 tag and add 📝 tag
        local new_tags = {}
        for _, tag in ipairs(note.tags or {}) do
            if tag ~= "📥" then
                table.insert(new_tags, tag)
            end
        end
        table.insert(new_tags, "📝")
        note.tags = new_tags

        -- Save updated frontmatter to buffer
        note:save_to_buffer()
    end

    -- Create notes dir if not exists
    vim.fn.mkdir(notes_dir, "p")

    -- Save current buffer
    vim.cmd("write")

    -- Move file
    local ok, err = os.rename(current_file, new_path)
    if ok then
        -- Open new location
        vim.cmd("edit " .. vim.fn.fnameescape(new_path))
        -- Close old buffer
        vim.cmd("bdelete #")
        vim.notify("Moved to notes/", vim.log.levels.INFO)
    else
        vim.notify("Failed to move: " .. (err or "unknown error"), vim.log.levels.ERROR)
    end
end

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    init = open_home_if_in_vault,
    keys = {
        { "<leader>of", "<cmd>ObsidianSearch<cr>", desc = "Find note" },
        { "<leader>on", new_inbox_note, desc = "New note" },
        { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Today's daily note" },
        { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's daily note" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
        { "<leader>ol", "<cmd>ObsidianLink<cr>", mode = "v", desc = "Link selection" },
        { "<leader>oc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
        { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian app" },
        { "<leader>oe", ":ObsidianExtractNote<cr>", mode = "v", desc = "Extract to new note" },
        { "<leader>oi", "<cmd>ObsidianTemplate<cr>", desc = "Insert template" },
        { "<leader>om", move_to_notes, desc = "Move to notes/" },
        { "<leader>oh", "<cmd>edit ~/Documents/obsidian/nostromo/home.md<cr>", desc = "Open home" },
        { "<leader>os", new_literature_note, desc = "New source (literature note)" },
        { "<leader>or", new_research_note, desc = "New research note" },
    },
    opts = {
        workspaces = {
            {
                name = "nostromo",
                path = "~/Documents/obsidian/nostromo",
            },
        },
        daily_notes = {
            folder = "diary/daily",
            template = "daily.md",
        },
        templates = {
            folder = "system/templates",
        },
        -- Disable frontmatter for diary notes, preserve for others
        disable_frontmatter = function(filename)
            return filename:match("diary/") ~= nil
        end,
        note_frontmatter_func = function(note)
            local out = {
                title = note.title and note.title:lower() or nil,
                tags = note.tags,
                aliases = note.aliases,
            }
            -- Preserve all existing metadata fields (like 'created')
            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for k, v in pairs(note.metadata) do
                    out[k] = v
                end
            end
            -- Add 'created' only if it doesn't exist
            if not out.created then
                out.created = os.date("%Y-%m-%d %H:%M:%S")
            end
            return out
        end,

        notes_subdir = "inbox",
        new_notes_location = "notes_subdir",
        -- Zettelkasten: always use timestamp as filename
        ---@return string
        note_id_func = function()
            return os.date("%Y%m%d%H%M%S")
        end,
        -- Use only filename (ID) without path: [[ID|Title]]
        wiki_link_func = function(opts)
            local id = opts.id or opts.path:match("([^/]+)$"):gsub("%.md$", "")
            if opts.label and opts.label ~= id then
                return string.format("[[%s|%s]]", id, opts.label)
            else
                return string.format("[[%s]]", id)
            end
        end,
        picker = {
            name = "telescope.nvim",
            note_mappings = {
                new = "<C-x>",
                insert_link = "<C-l>",
            },
            tag_mappings = {
                tag_note = "<C-x>",
                insert_tag = "<C-l>",
            },
        },
        search = {
            exclude = { "system", "diary" },
        },
        ui = {
            enable = true,
            update_debounce = 100, -- faster UI updates (default 200)
            checkboxes = {
                [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                ["x"] = { char = "✔", hl_group = "ObsidianDone" },
            },
            bullets = { char = "•", hl_group = "ObsidianBullet" },
        },
        -- Open external URLs in default browser
        follow_url_func = function(url)
            vim.fn.jobstart({ "open", url })
        end,
        -- Custom mappings (disable <cr> smart action, keep gf for links)
        mappings = {
            ["gf"] = {
                action = function()
                    return require("obsidian").util.gf_passthrough()
                end,
                opts = { noremap = false, expr = true, buffer = true },
            },
        },
    },
}
