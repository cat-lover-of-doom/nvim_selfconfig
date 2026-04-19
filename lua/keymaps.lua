-- Leader
vim.g.mapleader = " "

-- ── Floating terminal utilities (provided by autocmd.lua) ────────────────────
-- Safe require: if the module isn't there, the mappings no-op gracefully.
local term_ok, term = pcall(require, "autocmd")
if term_ok then
    vim.keymap.set("n", "<leader>tt", term.toggle, { desc = "Terminal: toggle floating" })
    vim.keymap.set("n", "<leader>ts", term.store, { desc = "Terminal: store command" })
    vim.keymap.set("n", "<leader>tr", term.run_stored, { desc = "Terminal: run stored" })
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Terminal: exit insert" })
end

local function map_nav(lhs, rhs, label)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = label })
    vim.keymap.set("t", lhs, [[<C-\><C-n>]] .. rhs, { silent = true, desc = label })
end
map_nav("<C-h>", "<C-w>h", "Window: left")
map_nav("<C-j>", "<C-w>j", "Window: down")
map_nav("<C-k>", "<C-w>k", "Window: up")
map_nav("<C-l>", "<C-w>l", "Window: right")


-- ── Editing QoL ──────────────────────────────────────────────────────────────
vim.keymap.set({ "n", "x" }, "s", '"_s', { desc = "Edit: subst (blackhole)" })
vim.keymap.set({ "n", "x" }, "S", '"_S', { desc = "Edit: S (blackhole)" })
vim.keymap.set({ "n", "x" }, "x", '"_x', { desc = "Edit: x (blackhole)" })
vim.keymap.set({ "n", "x" }, "X", '"_X', { desc = "Edit: X (blackhole)" })
vim.keymap.set("x", "p", "P", { desc = "Edit: keep default reg" })
vim.keymap.set("x", "P", "p", { desc = "Edit: swap paste" })
vim.keymap.set("n", "0", "^", { desc = "Move: smart line start" })
vim.keymap.set("n", "gg", "gg0", { desc = "Move: file top" })
vim.keymap.set("n", "G", "G$", { desc = "Move: file bottom" })
vim.keymap.set("x", "<Tab>", ">gv", { desc = "Indent: right" })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Indent: left" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent: right" })
vim.keymap.set("x", "<", "<gv", { desc = "Indent: left" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Search: clear highlights" })
vim.keymap.set("i", "<C-d>", "<Del>", { noremap = true })     -- forward delete
vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true })     -- forward delete

-- ── Buffers ──────────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>n", ":bn<CR>", { silent = true, desc = "Buffer: next" })
vim.keymap.set("n", "<leader>N", ":bp<CR>", { silent = true, desc = "Buffer: previous" })
vim.keymap.set('n', "<leader><Tab>", "<C-^>", { desc = "Switch to previous buffer" })

-- ── Quickfix ─────────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>qt", function()
    local wins = vim.fn.getwininfo()
    for _, w in ipairs(wins) do
        if w.quickfix == 1 then vim.cmd("cclose"); return end
    end
    vim.cmd("copen")
end, { silent = true, desc = "Quickfix: toggle" })
vim.keymap.set("n", "<leader>qn", "<cmd>cnext<CR>",  { silent = true, desc = "Quickfix: next" })
vim.keymap.set("n", "<leader>qN", "<cmd>cprev<CR>",  { silent = true, desc = "Quickfix: prev" })

-- ── Build ───────────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>bm", "<cmd>make<CR>", { desc = "Build: make" })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "c",
    callback = function()
        vim.keymap.set("n", "<leader>bf", function()
            vim.cmd("!gcc -Wall -Wextra -o " .. vim.fn.expand("%:r") .. " " .. vim.fn.expand("%"))
        end, { buffer = true, desc = "Build: gcc current file" })
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.keymap.set("n", "<leader>bf", function()
            vim.cmd("!g++ -Wall -Wextra -o " .. vim.fn.expand("%:r") .. " " .. vim.fn.expand("%"))
        end, { buffer = true, desc = "Build: g++ current file" })
    end,
})
