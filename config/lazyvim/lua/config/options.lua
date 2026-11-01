-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Clipboard: yank goes both to the Mac clipboard (pbcopy) and via OSC 52 to
-- whichever terminal is attached, so copying works over SSH + Zellij too.
-- Paste reads the Mac clipboard, which always holds the last yank.
local osc52 = require("vim.ui.clipboard.osc52")
local function copy(reg)
  local send = osc52.copy(reg)
  return function(lines, regtype)
    vim.fn.system("pbcopy", table.concat(lines, "\n"))
    send(lines, regtype)
  end
end
local function paste()
  return vim.split(vim.fn.system("pbpaste"), "\n")
end
vim.g.clipboard = {
  name = "osc52+pbcopy",
  copy = { ["+"] = copy("+"), ["*"] = copy("*") },
  paste = { ["+"] = paste, ["*"] = paste },
}
vim.opt.clipboard = "unnamedplus"
