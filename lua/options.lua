-- OPTIONS
vim.opt.backup = false                          -- creates a backup file
vim.opt.clipboard = "unnamedplus"               -- allows neovim to access the system clipboard
vim.opt.fileencoding = "utf-8"                  -- the encoding written to a file
vim.opt.ignorecase = false                       -- ignore case in search patterns
vim.opt.smartindent = true                      -- make indenting smarter again
vim.opt.swapfile = false                        -- creates a swapfile
vim.opt.undofile = true                         -- enable persistent undo
vim.opt.writebackup = false                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.opt.expandtab = true                        -- convert tabs to spaces
vim.opt.shiftwidth = 4                          -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4                             -- insert 2 spaces for a tab
vim.opt.number = true                           -- set numbered lines
vim.opt.relativenumber = true                  -- set relative numbered lines
vim.opt.wrap = false                            -- display lines as one long line
vim.opt.scrolloff = 8                           -- is one of my fav
vim.opt.sidescrolloff = 8
vim.opt.hlsearch = false -- not keep shit highlighted
vim.opt.incsearch = true -- see how shit moves
vim.opt.path= vim.opt.path + "**"
vim.opt.wildmenu = true
vim.opt.mouse = ""

vim.opt.laststatus = 2
vim.opt.autoread = true
vim.opt.shiftround = true
vim.opt.expandtab = true

--vimux
vim.g.netrw_list_hide='\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'
vim.g.VimuxOrientation= "h"
vim.g.VimuxHeight = "40"
vim.g.VimuxCloseOnExit= 1

-- Function to set tab width based on file type

local function set_tab_width()
    local filetype = vim.bo.filetype
    if filetype == 'c' then
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
    else
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
    end
end

-- Create an autocommand to run the function when entering a buffer
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = set_tab_width,
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.expand("%") == "" then
            vim.cmd(":Ex")
        end
    end
})

--netrw lines
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

-- italics and shit
vim.opt.termguicolors = true


vim.diagnostic.config({
  virtual_text = true,   -- inline errors
  signs = true,          -- gutter signs
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
-- c header
-- vim.g.c_syntax_for_h = 1
