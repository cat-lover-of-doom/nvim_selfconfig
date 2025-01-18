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
set("t","<Esc>", "<C-\\><C-n>")
set("n","¿", "@")
set("n","<leader>n", ":bp<CR>")
-- lsp
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>q', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.setloclist)
-- build
vim.keymap.set('n', '<leader>t', ":VimuxPromptCommand<CR>")
-- telescope
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})

vim.api.nvim_set_keymap('n', '<leader><S-b>', ':lua WriteCommand()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', ':lua ExecCommand()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', ' ', "")
