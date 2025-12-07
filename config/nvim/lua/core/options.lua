-- Disable netrw (use mini.files instead with '-' key)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.wo.number = true -- Make line numbers default (default: false)
vim.o.relativenumber = true -- Set relative numbered lines (default: false)
-- Note: clipboard configuration moved to core/clipboard.lua for OSC 52 support
vim.o.wrap = false -- Display lines as one long line (default: true)
vim.o.linebreak = true -- Companion to wrap, dont split words (defalt: false)
vim.o.mouse = "a" -- Enable mouse mode (default: '')
vim.o.autoindent = true -- Copy indent from current line when starting new one (default: true)
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search (default: false)
vim.o.smartcase = true -- Smart case (default: false)
vim.o.shiftwidth = 4 -- The number of spaces inserted for each indentation (default: 8)
vim.o.tabstop = 4 -- Insert n spaces for a tab (default: 8)
vim.o.softtabstop = 4 -- Number of spaces that a tab counts for while performing editing operations (default: 0)
vim.o.expandtab = true -- Convert tabs to spaces (default: false)
vim.o.scrolloff = 4 -- Minimal number of screen lines to keep above and below the cursor (default: 0)
vim.o.sidescrolloff = 8 -- Minimal number of screen columns either side of cursor if wrap is `false` (default: 0)
vim.o.cursorline = true -- Highlight the current line (default: false)
vim.o.colorcolumn = "88" -- Show vertical line at column 88
vim.o.splitbelow = true -- Force all horizontal splits go to below current window (default: false)
vim.o.splitright = true -- Force all vertical splits to go to the right of current window (default: false)
vim.o.hlsearch = false -- Set highlight on search (default: true)
vim.o.showmode = false -- We don't need to see things like -- INSERT -- anymore (default: true)
vim.opt.termguicolors = true -- Set termguicolors to enable highlight grous (default: true)
vim.o.whichwrap = "bs<>[]hl" -- Which "horizontal" keys are allowd to travel to prev/next line (default: b,s)
vim.o.numberwidth = 2 -- Set number column width to 4 (default: 4)
vim.o.swapfile = false -- Creates a swapfile (default: true)
vim.o.smartindent = true -- Make indenting smarter again (default: false)
vim.o.showtabline = 2 -- Always show tabs (default: 1)
vim.o.backspace = "indent,eol,start" -- Allow backspace on (default: 'indent,eol,start')
vim.o.pumheight = 10 -- Pop up menu height (default: 0)
vim.o.conceallevel = 1 -- Enable basic concealing for markdown rendering (required for obsidian.nvim UI)
vim.wo.signcolumn = "yes" -- Keep signcolumn on by default (default: auto)
vim.o.encoding = "utf-8" -- Internal character encoding
vim.o.fileencoding = "utf-8" -- The encoding written to a file (default: 'utf-8')
vim.o.fileencodings = "utf-8,ucs-bom,default,latin1" -- List of character encodings to try when reading a file
vim.o.cmdheight = 1 -- More space in the Neovim command line for displaying messages (default: 1)
vim.o.breakindent = true -- Enable break indent (default: false)
vim.o.updatetime = 100 -- Decrease update time (default: 4000)
vim.o.timeoutlen = 300 -- Time to wait for a mapped sequence to complete (in milliseconds) (default: 1000)
vim.o.backup = false -- Creates a backup file (default: false)
vim.o.writebackup = false -- If a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited (default: true)
vim.o.undofile = true -- Save undo history (default: false)
vim.o.autoread = true -- Auto reload file if changed outside vim (default: false)

-- Ignore external file changes when buffer has unsaved modifications
-- Prevents Obsidian sync conflicts from overwriting your work
vim.api.nvim_create_autocmd("FileChangedShell", {
    pattern = "*",
    callback = function()
        -- Keep our version if buffer is modified, otherwise reload
        if vim.bo.modified then
            vim.v.fcs_choice = ""  -- ignore the change
        else
            vim.v.fcs_choice = "reload"
        end
    end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    pattern = "*",
    command = "silent! checktime",
})

-- Enable word wrap for markdown files at colorcolumn width
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.textwidth = 88
        vim.opt_local.colorcolumn = ""  -- hide line since we wrap at this width
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
    end,
})
vim.o.completeopt = "menuone,noselect" -- Set completeopt to have a better completion experience (default: 'menu,preview')
vim.o.list = true -- Show invisible characters (default: false)
vim.opt.listchars = { space = '·', tab = '→ ', trail = '•', nbsp = '␣' } -- Characters to show for whitespace
vim.opt.shortmess:append("c") -- Don't give |ins-completion-menu| messages (default: does not include 'c')
vim.opt.iskeyword:append("-") -- Hyphenated words recognized by searches (default: does not include '-')
vim.opt.formatoptions:remove({ "c", "r", "o" }) -- Don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode. (default: 'croql')
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles") -- Separate Vim plugins from Neovim in case Vim still in use (default: includes this path if Vim is installed)
