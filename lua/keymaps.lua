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

-- ── Buffers ──────────────────────────────────────────────────────────────────
vim.keymap.set("n", "<A-Down>", ":bn<CR>", { silent = true, desc = "Buffer: next" })
vim.keymap.set("n", "<C-Up>", ":bp<CR>", { silent = true, desc = "Buffer: previous" })

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
vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "undotree toggle" })
vim.keymap.set("n", "<leader>h", ":WhichKey<CR>", { desc = "Show help" })
vim.keymap.set("i", "<C-d>", "<Del>", { noremap = true })     -- forward delete
vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true })     -- forward delete
vim.keymap.set("n", "|", "q", { noremap = true })
vim.keymap.set("n", "q", "@", { noremap = true })

vim.keymap.set('n', '<leader><leader>', ":bp<CR>")
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, function()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    if bufs[i] then
      vim.cmd('buffer ' .. bufs[i].bufnr)
    end
  end, { desc = 'Go to buffer ' .. i })
end

vim.keymap.set('n', '<leader>0', function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 0 then
    vim.cmd('buffer ' .. bufs[#bufs].bufnr)
  end
end, { desc = 'Go to last buffer' })

-- ── Files (Oil → fallback to netrw) ─────────────────────────────────────────
local function has(mod) return pcall(require, mod) end
vim.keymap.set("n", "<leader>s", function()
    if has("oil") then vim.cmd("Oil") else vim.cmd("Explore") end
end, { desc = "Files: explorer" })

-- ── Search (Telescope with sane fallbacks) ───────────────────────────────────
local function naive_live_grep()
    local q = vim.fn.input("Grep > "); if q == "" then return end
    vim.cmd("silent vimgrep /" .. q .. "/gj **/*"); vim.cmd("copen")
end
vim.keymap.set("n", "<leader>ff", function()
    if has("telescope.builtin") then require("telescope.builtin").find_files({ hidden = false }) else vim.cmd("Explore") end
end, { desc = "Search: files" })
vim.keymap.set("n", "<leader>fF", function()
    if has("telescope.builtin") then require("telescope.builtin").find_files({ hidden = true }) else vim.cmd("Explore") end
end, { desc = "Search: files (hidden)" })
vim.keymap.set("n", "<leader>fg", function()
    if has("telescope.builtin") then require("telescope.builtin").live_grep() else naive_live_grep() end
end, { desc = "Search: live grep" })
vim.keymap.set("n", "<leader>fb", function()
    if has("telescope.builtin") then require("telescope.builtin").buffers() else vim.cmd("ls") end
end, { desc = "Search: buffers" })

-- ── GitSigns (only if available) ────────────────────────────────────────────
local ok_gs, gs = pcall(require, "gitsigns")
if ok_gs then
    vim.keymap.set("n", "]c", gs.next_hunk, { desc = "Git: next hunk" })
    vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "Git: prev hunk" })
    vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Git: preview hunk" })
    vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Git: reset hunk" })
    vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Git: stage hunk" })
    vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Git: undo stage" })
    vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Git: toggle blame" })
    vim.keymap.set("n", "<leader>gd", gs.diffthis, { desc = "Git: diff vs index" })
end

-- ── LSP buffer-local maps (set on attach) ────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    callback = function(ev)
        local o = { buffer = ev.buf, silent = true }
        -- diagnostics
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end,
            { buffer = ev.buf, silent = true, desc = "Prev diagnostic" })
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,
            { buffer = ev.buf, silent = true, desc = "Next diagnostic" })
        vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { buffer = ev.buf, silent = true, desc = "Lsp expand error" })
        vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>", { buffer = ev.buf, silent = true, desc = "Lsp Info" })
        -- actions
        vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { buffer = ev.buf, silent = true, desc = "Lsp code actions" })
        vim.keymap.set({ "n", "v" }, "<leader>lf", function() vim.lsp.buf.format({ async = false }) end,
            { buffer = ev.buf, silent = true, desc = "Lsp format" })
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = ev.buf, silent = true, desc = "Lsp rename" })
        -- goto / help
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, silent = true, desc = "Go definition" })
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, silent = true, desc = "Go declaration" })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, silent = true, desc = "Show references" })
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, silent = true, desc = "Go implementation" })
        vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = ev.buf, silent = true, desc = "Go type_definition" })
        vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = ev.buf, silent = true, desc = "Get hover info" })
        vim.keymap.set("n", "gH", vim.lsp.buf.signature_help, { buffer = ev.buf, silent = true, desc = "Get signature_help" })
    end,
})
