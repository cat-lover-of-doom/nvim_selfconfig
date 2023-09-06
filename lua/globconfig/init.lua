-- OPTIONS
vim.opt.backup = false                          -- creates a backup file
vim.opt.clipboard = "unnamedplus"               -- allows neovim to access the system clipboard
vim.opt.fileencoding = "utf-8"                  -- the encoding written to a file
vim.opt.ignorecase = true                       -- ignore case in search patterns
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



require("globconfig.plugins")
require("globconfig.mappings")
require("globconfig.plugconf.lspconfig")
require("globconfig.plugconf.catpuccin")


