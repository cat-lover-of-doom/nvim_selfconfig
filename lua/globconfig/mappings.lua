-- MAPPINGS
vim.g.mapleader = ' '
local set = vim.keymap.set


--fix
set("n", "<C-d>", "<C-d>zz" )
set("n", "<C-u>", "<C-u>zz" )
set("n", "n", "nzz" )
set("n", "N", "nzz" )
set("n", ".", ":" )
set("n", "<leader>s", ":Ex<CR>" )
set("n", "<leader>u", ":UndotreeToggle<CR>")
-- lsp
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
-- build
    vim.keymap.set('n', '<space>b', ":!make<CR>")

