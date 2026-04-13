-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins
require("lazy").setup({
  'tpope/vim-commentary',
  'tpope/vim-fugitive',
  'tpope/vim-surround',
  'ciaranm/inkpot',
  'drmikehenry/vim-fontsize',
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls" }
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf, remap = false }

          vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
          vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
          vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
          vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)

          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      })

      vim.lsp.config('gopls', {})
      vim.lsp.enable('gopls')
    end
  },
})

-- Neovide: disable animations, they're distracting
vim.g.neovide_position_animation_length = 0
vim.g.neovide_cursor_animation_length = 0.00
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_scroll_animation_far_lines = 0
vim.g.neovide_scroll_animation_length = 0.00

--------------------
-- Creature comforts
--------------------

-- j and k go to the position directly above or below them if possible, not up
-- or down one line. Useful when wrapping is on and dealing with very long
-- lines.
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Fix typos when I'm working too fast
-- List of common shift-key typos
local typos = { "W", "Q", "Wq", "WQ", "Qall", "QAll", "QA" }

for _, name in ipairs(typos) do
  vim.api.nvim_create_user_command(name, function(opts)
    local cmd_base = name:lower()
    if opts.bang then
      vim.cmd(cmd_base .. "!")
    else
      vim.cmd(cmd_base)
    end
  end, { bang = true, desc = "Fix typo for " .. name:lower() })
end

-- Save a file as root (useful in cases where I opened a file that root owns)
vim.api.nvim_create_user_command('Wsudo', function()
  local file = vim.fn.expand('%')
  vim.cmd('write !sudo tee ' .. file .. ' > /dev/null')
  vim.cmd('edit!')
end, { desc = 'Save current file as sudo' })

-- Sed commands default to /g, which means it will replace multiple times on the
-- same line.
vim.opt.gdefault = true
-- Put a marker one past my normal line limit
vim.opt.colorcolumn = "81"
-- Allow modelines
vim.opt.modeline = true
-- Check 2 lines from top or bottom
vim.opt.modelines = 2
-- Scroll nicely with scroll wheel when there are long, wrapping lines
vim.opt.smoothscroll = true
-- When shifting width (<< / >>), round to the nearest tab width
vim.opt.shiftround = true
-- Always keep a buffer of 3 lines between the cursor and top / bottom
vim.opt.scrolloff=3
-- Search in a case-insensitive manner...
vim.opt.ignorecase = true
-- ...unless some uppercase characters are typed
vim.opt.smartcase = true
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-------------
-- Default On
-------------
-- Ported from vim, but noted as "default on".
-- I'm not sure how often these are "default on" -- if it's just the
-- implementation that I'm using or a global Neovim standard. So I'm leaving
-- these here, but commented out, so that I can readd them if needed.

-- Show row,column in the statusline
-- vim.opt.ruler = true
-- When there's a subset of the amount of spaces for a tab, increase to the
-- nearest spot that would have been a tab.
-- vim.opt.smarttab = true
-- See search matches while you type.
-- vim.opt.incsearch = true
-- Keep searches highlighted after hitting enter
-- vim.opt.hlsearch = true

---------------------
-- Mapleader bindings
---------------------
vim.g.mapleader = ","

-- Clear highlighting after a search
vim.keymap.set('n', '<leader><space>', ':nohlsearch<CR>', { silent = true })

-- Toggle "list" characters - trailing whitespace / newlines showing up
vim.opt.list = true
vim.opt.listchars = { nbsp = "␣", trail = ".", tab = ">-" }
local showTabs = true

local function toggle_list_chars()
  if vim.opt.listchars:get().eol == "↲" then
    vim.opt.listchars = { nbsp = "␣", trail = "."}

  else
    vim.opt.listchars = { nbsp = "␣", eol = "↲" }
  end
  if showTabs then
    vim.opt.listchars[tab] = ">-"
  end
end

-- <Leader>l to cycle through character types
vim.keymap.set('n', '<leader>l', toggle_list_chars, { desc = "Toggle listchars style" })

-- <Leader>L to toggle visibility on/off
vim.keymap.set('n', '<leader>L', ':set list!<CR>', { desc = "Toggle list on/off" })

-- Strip trailing whitespaces on save / on demand
local function strip_trailing_whitespace()
  local view = vim.fn.winsaveview()
  vim.cmd([[keepjumps silent! %s/\s\+$//e]])
  vim.fn.winrestview(view)
end

vim.keymap.set('n', '<leader>W', strip_trailing_whitespace, { desc = 'Strip trailing whitespace' })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = strip_trailing_whitespace,
})

-- Insert literal tabs
vim.keymap.set('n', '<leader><Tab>', function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local new_line = line:sub(1, col) .. "\t" .. line:sub(col + 1)

  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, { row, col + 1 })
end, { desc = 'Insert literal tab via API' })

----------------
-- User commands
----------------

-- Allow the user to set all the options related to tabbing
-- Example: `:Tabs 4` sets hard tabs that are 4 characters wide
vim.api.nvim_create_user_command(
  'Tabs',
  function(opts)
    vim.opt.tabstop = opts.count
    vim.opt.softtabstop = 0
    vim.opt.shiftwidth = opts.count
    vim.opt.expandtab = false

    -- Don't show tabs in listchars
    showTabs = false
    local current = vim.opt.listchars:get()
    current.tab = "  "
    vim.opt_local.listchars = current
  end,
  {
    bar = true,
    count = 8,
    desc = "Set global indentation to use hard tabs of the given size, defaulting to 8",
  }
)

vim.api.nvim_create_user_command(
  'Spaces',
  function(opts)
    vim.opt.tabstop = 8
    vim.opt.softtabstop = opts.count
    vim.opt.shiftwidth = opts.count
    vim.opt.expandtab = true

    -- Show tabs in listchars
    showTabs = true
    local current = vim.opt.listchars:get()
    current.tab = ">-"
    vim.opt_local.listchars = current
  end,
  {
    bar = true,
    count = 4,
    desc = "Set global indentation to use soft tabs of the given size, defaulting to 4",
  }
)

-- Use :T to open a terminal in a new tab. If arguments are provided, run the command in the terminal.
-- The "!" command is a built-in Ex command and cannot be overwritten or shadowed with a user command.
vim.api.nvim_create_user_command("T", function(opts)
  if #opts.fargs == 0 then
    vim.cmd("tabnew | startinsert | terminal")
  else
    local cmd = table.concat(opts.fargs, " ")
    vim.cmd("tabnew | terminal " .. cmd)
  end
end, { nargs = "*", desc = "Run shell command in new tab terminal" })
-- By default, `<Esc>` kills the tab when the Terminal has exited in Terminal mode.
-- This remap makes it more like normal `<Esc>` behavior, where it just exits Terminal mode and leaves the terminal buffer open.
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

---------------------------
-- Filetype-specific config
---------------------------

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.cmd("Tabs 4")
  end,
})

---------------------
-- OS-specific config
---------------------

local os_name = jit.os

if os_name == "Windows" then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

------------------------
-- Local-specific config
------------------------
local local_lua = vim.fn.stdpath("config") .. "/init-local.lua"
if vim.loop.fs_stat(local_lua) then
  dofile(local_lua)
end

-- vim: et sts=2 ts=2 sw=2:
