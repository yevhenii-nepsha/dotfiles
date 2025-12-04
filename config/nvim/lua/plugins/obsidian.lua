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

-- Move current note to notes/ directory and update tag
local function move_to_notes()
    local current_file = vim.fn.expand("%:p")
    if not current_file:match("%.md$") then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
    end

    local client = require("obsidian").get_client()
    local vault_path = tostring(client.dir)
    local notes_dir = vault_path .. "/notes"

    -- Get filename
    local filename = vim.fn.expand("%:t")
    local new_path = notes_dir .. "/" .. filename

    -- Check if already in notes/
    if current_file:match("/notes/") then
        vim.notify("Already in notes/", vim.log.levels.INFO)
        return
    end

    -- Change tag from 📥 to 📝 in current buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local in_frontmatter = false
    for i, line in ipairs(lines) do
        if i == 1 and line == "---" then
            in_frontmatter = true
        elseif in_frontmatter and line == "---" then
            break -- End of frontmatter, stop searching
        elseif in_frontmatter and line:find("tags:", 1, true) then
            -- Use plain string find/replace to avoid Unicode issues
            local new_line = line:gsub("\u{1F4E5}", "\u{1F4DD}") -- 📥 → 📝
            if new_line ~= line then
                lines[i] = new_line
                vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
                break
            end
        end
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
        -- Preserve existing frontmatter fields (like 'created')
        disable_frontmatter = false,
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
        ui = {
            enable = true,
            update_debounce = 100, -- faster UI updates (default 200)
            checkboxes = {
                [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                ["x"] = { char = "✔", hl_group = "ObsidianDone" },
            },
            bullets = { char = "•", hl_group = "ObsidianBullet" },
        },
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
