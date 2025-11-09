return {
  'nvim-mini/mini.nvim',
  version = false,
  config = function()
    -- ============================================================================
    -- MINI.FILES - File explorer with Miller columns
    -- ============================================================================
    require('mini.files').setup({
      -- Content options
      content = {
        filter = nil, -- Predicate for which file system entries to show
        prefix = nil, -- What prefix to show to the left of file system entry
        sort = nil,   -- In what order to show file system entries
      },

      -- Module mappings (inside mini.files buffer)
      mappings = {
        close       = 'q',
        go_in       = 'l',
        go_in_plus  = 'L',
        go_out      = 'h',
        go_out_plus = 'H',
        reset       = '<BS>',
        reveal_cwd  = '@',
        show_help   = 'g?',
        synchronize = '=',
        trim_left   = '<',
        trim_right  = '>',
      },

      -- General options
      options = {
        permanent_delete = true, -- Delete files permanently or to trash
        use_as_default_explorer = true, -- Replace netrw
      },

      -- Window display
      windows = {
        max_number = math.huge, -- Maximum number of windows to show side by side
        preview = false,        -- Whether to show preview of file/directory under cursor
        width_focus = 50,       -- Width of focused window
        width_nofocus = 15,     -- Width of non-focused window
        width_preview = 25,     -- Width of preview window
      },
    })

    -- Keybinding to open mini.files (like vim-vinegar)
    vim.keymap.set('n', '-', function()
      require('mini.files').open(vim.api.nvim_buf_get_name(0))
    end, { desc = 'Open parent directory in mini.files' })

    -- ============================================================================
    -- MINI.AI - Extended and created text objects
    -- ============================================================================
    local ai = require('mini.ai')
    require('mini.ai').setup({
      -- Better text objects: function, argument, bracket, quote, etc.
      -- Examples:
      -- - dib: delete in brackets
      -- - dia: delete in argument
      -- - dif: delete in function (uses treesitter)
      -- - din: delete in next text object
      -- - dil: delete in last text object
      n_lines = 500, -- Number of lines within which to search

      custom_textobjects = {
        -- Use treesitter for function text object
        f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
        -- Use treesitter for class text object
        c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
        -- Use treesitter for conditional
        o = ai.gen_spec.treesitter({
          a = { '@conditional.outer', '@loop.outer' },
          i = { '@conditional.inner', '@loop.inner' },
        }, {}),
      },
    })

    -- ============================================================================
    -- MINI.COMMENT - Comment lines
    -- ============================================================================
    require('mini.comment').setup({
      -- Comment with gcc in normal mode, gc in visual mode
      options = {
        custom_commentstring = nil, -- Use default commentstring from filetype
        ignore_blank_line = false,
        start_of_line = false,
        pad_comment_parts = true,
      },
      mappings = {
        comment = 'gc',
        comment_line = 'gcc',
        comment_visual = 'gc',
        textobject = 'gc',
      },
    })

    -- ============================================================================
    -- MINI.PAIRS - Autopairs
    -- ============================================================================
    require('mini.pairs').setup({
      -- Automatically pair brackets, quotes, etc.
      modes = { insert = true, command = false, terminal = false },
      mappings = {
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
        [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
        [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
        ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
      },
    })

    -- ============================================================================
    -- MINI.BUFREMOVE - Remove buffers without breaking layout
    -- ============================================================================
    require('mini.bufremove').setup()

    -- Replace default buffer delete with mini.bufremove
    vim.keymap.set('n', '<leader>bd', function()
      require('mini.bufremove').delete(0, false)
    end, { desc = 'Delete buffer (preserve layout)' })

    -- Force delete buffer
    vim.keymap.set('n', '<leader>bD', function()
      require('mini.bufremove').delete(0, true)
    end, { desc = 'Delete buffer (force)' })

    -- ============================================================================
    -- MINI.INDENTSCOPE - Visualize and work with indent scope
    -- ============================================================================
    require('mini.indentscope').setup({
      -- Show vertical line for current scope
      draw = {
        delay = 100,
        animation = require('mini.indentscope').gen_animation.none(),
      },
      mappings = {
        object_scope = 'ii',
        object_scope_with_border = 'ai',
        goto_top = '[i',
        goto_bottom = ']i',
      },
      options = {
        border = 'both',
        indent_at_cursor = true,
        try_as_border = false,
      },
      symbol = '│',
    })
  end,
}
