-- OSC 52 clipboard provider for SSH sessions
-- Allows copying from remote nvim to local system clipboard

-- Maximum size for OSC 52 clipboard (100KB before base64 encoding)
-- After base64 encoding (~33% increase), this becomes ~133KB
-- Most terminals support up to 100KB-1MB, but we play it safe
local MAX_CLIPBOARD_SIZE = 100 * 1024

local function copy(lines, _)
  -- Join lines and encode to base64
  local text = table.concat(lines, '\n')

  -- Check size limit
  local text_size = #text
  if text_size > MAX_CLIPBOARD_SIZE then
    vim.notify(
      string.format(
        'Text too large for OSC 52 clipboard: %d KB (max: %d KB)\nTry selecting less text or use file transfer.',
        math.floor(text_size / 1024),
        math.floor(MAX_CLIPBOARD_SIZE / 1024)
      ),
      vim.log.levels.WARN
    )
    return
  end

  local base64 = vim.fn.system('base64', text):gsub('\n', '')

  -- Debug: show size for large selections
  if text_size > 10 * 1024 then -- Show info for selections > 10KB
    vim.notify(
      string.format('Copying %d KB via OSC 52...', math.floor(text_size / 1024)),
      vim.log.levels.INFO
    )
  end

  -- Send OSC 52 escape sequence
  -- Format: ESC ] 52 ; c ; <base64> BEL
  local osc52 = string.format('\027]52;c;%s\007', base64)
  io.write(osc52)
  io.flush()
end

local function paste()
  -- OSC 52 doesn't support paste, use default
  return vim.fn.getreg('"')
end

-- Detect if running over SSH or in tmux
local function is_remote()
  return os.getenv('SSH_CONNECTION') ~= nil or os.getenv('TMUX') ~= nil
end

-- Configure clipboard provider
if is_remote() then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = copy,
      ['*'] = copy,
    },
    paste = {
      ['+'] = paste,
      ['*'] = paste,
    },
    cache_enabled = false,
  }
  vim.o.clipboard = 'unnamedplus'
else
  -- Use system clipboard on local machine
  vim.o.clipboard = 'unnamedplus'
end
