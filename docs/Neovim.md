# Neovim Configuration Guide

## Quick Reference

### Core Information
- **Plugin Manager**: lazy.nvim
- **Version**: Neovim 0.11.4
- **Leader Key**: `<Space>`
- **File Manager**: yazi.nvim
- **LSP Manager**: Mason

---

## Essential Keybindings

### General
- `<Space>` - Leader key
- `<M-s>` (Cmd+S) - Save file in all modes
- `<leader>sn` - Save without auto-formatting
- `<C-q>` - Quit file
- `x` - Delete character (without copying to register)

### Navigation
- `<C-d>` / `<C-u>` - Scroll down/up and center
- `n` / `N` - Next/previous search result (centered)
- `<C-h/j/k/l>` - Navigate between splits
- `<Tab>` / `<S-Tab>` - Next/previous buffer
- `<leader>x` - Close current buffer
- `<leader>b` - New buffer

### Window Management
- `<leader>v` - Split window vertically
- `<leader>h` - Split window horizontally
- `<leader>se` - Make splits equal size
- `<leader>xs` - Close current split
- `<Up/Down/Left/Right>` - Resize windows

### Tab Management
- `<leader>to` - Open new tab
- `<leader>tx` - Close current tab
- `<leader>tn` - Next tab
- `<leader>tp` - Previous tab

### File Manager (Yazi)
- `<leader>-` - Open yazi at current file
- `<leader>cw` - Open yazi in working directory
- `<Ctrl-Up>` - Resume last yazi session

### Telescope (Fuzzy Finder)
- `<leader>sf` - Search files
- `<leader>sg` - Search by grep (live grep)
- `<leader>sw` - Search current word
- `<leader>sh` - Search help
- `<leader>sk` - Search keymaps
- `<leader>sd` - Search diagnostics
- `<leader>sr` - Resume last search
- `<leader>s.` - Search recent files
- `<leader><leader>` - Find existing buffers
- `<leader>/` - Fuzzy search in current buffer
- `<leader>s/` - Live grep in open files

**Telescope Navigation** (in insert mode):
- `<C-n>` - Next item
- `<C-p>` - Previous item
- `<CR>` - Select item

### LSP (Language Server)
- `grd` - Go to definition
- `grD` - Go to declaration
- `gri` - Go to implementation
- `grr` - Go to references
- `grt` - Go to type definition
- `grn` - Rename symbol
- `gra` - Code action
- `gO` - Document symbols
- `gW` - Workspace symbols
- `<leader>th` - Toggle inlay hints

### Diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>d` - Open diagnostic float
- `<leader>q` - Open diagnostics list

### Text Editing
- `<` / `>` (visual mode) - Indent/unindent (stays in visual mode)
- `p` (visual mode) - Paste without yanking deleted text
- `<leader>lw` - Toggle line wrapping
- `<leader>mb` (visual mode) - Wrap selection in **bold**
- `<leader>mi` (visual mode) - Wrap selection in *italic*

### Markdown Lists (visual mode)
- `<leader>lu` - Toggle unordered list (- item)
- `<leader>lo` - Toggle ordered list (1. 2. 3.)

### Obsidian
- `<leader>of` - Find note (search content)
- `<leader>oa` - Find note by title
- `<leader>on` - New note in inbox
- `<leader>ot` - Today's daily note
- `<leader>oy` - Yesterday's daily note
- `<leader>ob` - Backlinks
- `<leader>ol` (visual) - Link selection
- `<leader>oc` - Toggle checkbox
- `<leader>oo` - Open in Obsidian app
- `<leader>oe` (visual) - Extract to new note
- `<leader>oi` - Insert template
- `<leader>om` - Move to notes/
- `<leader>oh` - Open home
- `<leader>os` - New source (literature note)
- `<leader>or` - New research note

### Surround (nvim-surround)
In visual mode, select text then press `S` + character:
- `S` + `"` - Wrap in double quotes
- `S` + `'` - Wrap in single quotes
- `S` + `(` or `)` - Wrap in parentheses
- `S` + `{` or `}` - Wrap in braces
- `S` + `[` or `]` - Wrap in brackets
- `S` + `l` - Wrap as markdown link (prompts for URL)

---

## Installed Plugins

### Core Plugins

#### Plugin Manager
- **lazy.nvim** - Modern plugin manager with lazy loading

#### LSP & Completion
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - LSP/tool installer
- **mason-lspconfig.nvim** - Bridge between Mason and lspconfig
- **mason-tool-installer.nvim** - Auto-install tools
- **nvim-cmp** - Completion engine
- **cmp-nvim-lsp** - LSP source for nvim-cmp
- **LuaSnip** - Snippet engine
- **friendly-snippets** - Collection of snippets
- **lazydev.nvim** - Lua development support
- **fidget.nvim** - LSP progress notifications

#### Syntax & Highlighting
- **nvim-treesitter** - Advanced syntax highlighting

#### Formatting & Linting
- **none-ls.nvim** - Formatting and diagnostics
- **none-ls-extras.nvim** - Extra sources for none-ls
- **mason-null-ls.nvim** - Bridge between Mason and none-ls

#### File Navigation
- **yazi.nvim** - Modern file manager
- **telescope.nvim** - Fuzzy finder
- **telescope-fzf-native.nvim** - FZF sorter for telescope
- **telescope-ui-select.nvim** - Use telescope for vim.ui.select

#### Git Integration
- **gitsigns.nvim** - Git decorations
- **vim-fugitive** - Git commands
- **vim-rhubarb** - GitHub integration

#### UI Enhancements
- **lualine.nvim** - Statusline
- **noice.nvim** - UI improvements for messages/cmdline/popups
- **nvim-notify** - Notification manager
- **nui.nvim** - UI component library
- **indent-blankline.nvim** - Indent guides
- **which-key.nvim** - Keybinding hints

#### Editing Enhancements
- **nvim-autopairs** - Auto-close brackets/quotes
- **nvim-surround** - Surround text objects
- **todo-comments.nvim** - Highlight TODO comments
- **nvim-colorizer.lua** - Color highlighter
- **mini.nvim** - Collection of minimal plugins
- **vim-sleuth** - Auto-detect indentation

#### Utilities
- **vim-tmux-navigator** - Seamless tmux/vim navigation
- **plenary.nvim** - Lua utility library
- **nvim-web-devicons** - File icons

#### Language-Specific
- **rustaceanvim** - Rust development tools
- **uv.nvim** - Python uv integration

#### Themes
- **moonfly** - Color scheme

---

## Configuration Structure

```
~/.dotfiles/config/nvim/
├── init.lua                    # Entry point
├── lazy-lock.json             # Plugin versions lock file
├── lua/
│   ├── core/
│   │   ├── options.lua        # Vim options
│   │   └── keymaps.lua        # General keymaps
│   └── plugins/
│       ├── lsp.lua            # LSP configuration
│       ├── autocompletion.lua # Completion setup
│       ├── autoformatting.lua # Formatters/linters
│       ├── telescope.lua      # Fuzzy finder
│       ├── treesitter.lua     # Syntax highlighting
│       ├── gitsigns.lua       # Git decorations
│       ├── lualine.lua        # Statusline
│       ├── yazi.lua           # File manager
│       ├── colortheme.lua     # Color scheme
│       ├── rustaceanvim.lua   # Rust tools
│       ├── uv.lua             # Python uv
│       ├── noice.lua          # UI improvements
│       ├── nvim-surround.lua  # Surround plugin
│       ├── indent-blankline.lua
│       ├── mini.lua           # Mini plugins
│       └── misc.lua           # Simple plugins
└── README.md                  # This file
```

---

## How to Add New Plugins

### Method 1: Create New Plugin File (Recommended)

1. Create a new file in `lua/plugins/`:
   ```bash
   touch ~/.dotfiles/config/nvim/lua/plugins/my-plugin.lua
   ```

2. Add plugin configuration:
   ```lua
   return {
       "author/plugin-name",
       event = { "BufReadPre", "BufNewFile" }, -- lazy load on file open
       dependencies = {
           "dependency-author/dependency-name",
       },
       config = function()
           require("plugin-name").setup({
               -- plugin options here
           })
       end,
   }
   ```

3. Plugin will be auto-loaded by lazy.nvim on next restart

### Method 2: Add to Existing File

Add to `lua/plugins/misc.lua` for simple plugins:

```lua
{
    "author/plugin-name",
    event = "VimEnter",
    opts = {},
}
```

### Common Lazy Loading Events

- `event = "VimEnter"` - Load when Neovim starts
- `event = { "BufReadPre", "BufNewFile" }` - Load when opening a file
- `event = { "BufReadPost", "BufNewFile" }` - Load after file is read
- `event = "InsertEnter"` - Load when entering insert mode
- `cmd = "CommandName"` - Load when running command
- `keys = "<leader>x"` - Load when pressing key
- `ft = "python"` - Load for specific filetype
- `lazy = false` - Load immediately (not recommended)

### Plugin Configuration Examples

#### Simple Plugin (no configuration)
```lua
return {
    "author/simple-plugin",
    event = "VimEnter",
}
```

#### Plugin with Options
```lua
return {
    "author/plugin-name",
    event = "VimEnter",
    opts = {
        option1 = true,
        option2 = "value",
    },
}
```

#### Plugin with Custom Setup
```lua
return {
    "author/plugin-name",
    event = "BufReadPre",
    config = function()
        require("plugin-name").setup({
            -- options
        })

        -- custom keymaps
        vim.keymap.set("n", "<leader>p", "<cmd>PluginCommand<cr>")
    end,
}
```

#### Plugin with Dependencies
```lua
return {
    "author/main-plugin",
    dependencies = {
        "author/dependency1",
        { "author/dependency2", opts = {} },
    },
    config = function()
        require("main-plugin").setup()
    end,
}
```

---

## Managing Plugins

### Install/Update Plugins
```vim
:Lazy
```
Then press:
- `I` - Install missing plugins
- `U` - Update plugins
- `S` - Sync (clean + install + update)
- `X` - Clean (remove unused plugins)
- `C` - Check for updates
- `L` - View plugin logs
- `P` - Profile startup time

### Lock Plugin Versions
Plugin versions are locked in `lazy-lock.json`. To update:
1. `:Lazy update` - Update all plugins
2. Git commit `lazy-lock.json` to track versions

### Remove Plugin
1. Delete plugin file from `lua/plugins/` or remove from `misc.lua`
2. Run `:Lazy clean`
3. Restart Neovim

---

## LSP Configuration

### Installed Language Servers

Current servers in `lua/plugins/lsp.lua`:
- **pyright** - Python
- **ts_ls** - TypeScript/JavaScript
- **cssls** - CSS
- **tailwindcss** - Tailwind CSS
- **dockerls** - Docker
- **sqlls** - SQL
- **terraformls** - Terraform
- **jsonls** - JSON
- **yamlls** - YAML
- **lua_ls** - Lua

### Add New LSP Server

1. Open `lua/plugins/lsp.lua`
2. Add to `servers` table:
   ```lua
   local servers = {
       pyright = {},
       ts_ls = {},
       -- Add your server here:
       gopls = {},  -- example: Go language server
   }
   ```
3. Restart Neovim - Mason will auto-install

### Custom LSP Settings

```lua
local servers = {
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" }
                }
            }
        }
    }
}
```

### Check LSP Status
```vim
:LspInfo          " Show attached LSP clients
:Mason            " Manage LSP servers/tools
:checkhealth      " Diagnose issues
```

---

## Formatters & Linters

### Installed Tools

Configured in `lua/plugins/autoformatting.lua`:
- **prettier** - JS/TS/HTML/CSS/JSON/YAML/Markdown
- **stylua** - Lua
- **eslint_d** - JS/TS linting
- **shfmt** - Shell scripts
- **checkmake** - Makefile linting
- **ruff** - Python formatting + linting

### Add New Formatter/Linter

1. Open `lua/plugins/autoformatting.lua`
2. Add to `ensure_installed`:
   ```lua
   ensure_installed = {
       "prettier",
       "stylua",
       "your-tool-name",  -- add here
   }
   ```
3. Add to `sources`:
   ```lua
   local sources = {
       formatting.your_formatter,
       diagnostics.your_linter,
   }
   ```

### Disable Auto-Format on Save

In `lua/plugins/autoformatting.lua`, comment out the `on_attach` function.

---

## Treesitter Configuration

### Installed Parsers

Configured in `lua/plugins/treesitter.lua`:
- lua, python, javascript, typescript, tsx
- vimdoc, vim, regex
- terraform, sql, dockerfile, toml, json
- java, groovy, go
- gitignore, graphql, yaml
- make, cmake
- markdown, markdown_inline
- bash, css, html

### Add New Parser

1. Open `lua/plugins/treesitter.lua`
2. Add language to `ensure_installed`:
   ```lua
   ensure_installed = {
       "lua",
       "python",
       "rust",  -- add here
   }
   ```
3. Restart Neovim - will auto-install

Or install manually:
```vim
:TSInstall rust
```

---

## Customization Tips

### Change Color Scheme

Edit `lua/plugins/colortheme.lua`:
```lua
return {
    "new-theme/name",
    priority = 1000,
    config = function()
        vim.cmd("colorscheme theme-name")
    end,
}
```

### Add Custom Keymaps

Edit `lua/core/keymaps.lua`:
```lua
vim.keymap.set("n", "<leader>cc", "<cmd>YourCommand<cr>",
    { desc = "Description" })
```

### Change Editor Options

Edit `lua/core/options.lua`:
```lua
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
```

### Disable Signature Help

In `lua/plugins/autocompletion.lua`:
```lua
signature = { enabled = false },
```

### Change Update Time

In `lua/core/options.lua`:
```lua
vim.o.updatetime = 100  -- milliseconds
```

---

## Troubleshooting

### Plugin Not Loading
1. Check `:Lazy` for errors
2. Run `:checkhealth lazy`
3. Ensure lazy loading event is correct

### LSP Not Working
1. `:LspInfo` - Check if LSP attached
2. `:Mason` - Ensure server installed
3. `:checkhealth lsp`

### Slow Startup
1. `:Lazy profile` - See startup time
2. Add `event` to plugins for lazy loading
3. Use `:Lazy` to check plugin count

### Formatting Not Working
1. Check `:Mason` for installed formatters
2. `:checkhealth null-ls`
3. Verify `autoformatting.lua` sources

### Restore Default Config
```bash
cd ~/.dotfiles/config/nvim
git restore .
```

---

## Performance Optimizations

Current optimizations:
- ✅ Lazy loading for LSP, Treesitter, Gitsigns
- ✅ Fast update time (100ms)
- ✅ Optimized completion (nvim-cmp)
- ✅ Minimal plugin count (33 active plugins)

### Check Performance
```vim
:Lazy profile    " Plugin startup times
:checkhealth     " Overall health
```

---

## Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim Guide](https://github.com/folke/lazy.nvim)
- [Mason Registry](https://mason-registry.dev/)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [LSP Config](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)

---

## Maintenance Commands

```vim
:Lazy sync              " Update all plugins
:Mason                  " Manage LSP/tools
:TSUpdate               " Update parsers
:checkhealth            " Check config health
:Telescope keymaps      " Search all keymaps
```

---

**Last Updated**: 2025-12-09
**Config Version**: Optimized v1.1
