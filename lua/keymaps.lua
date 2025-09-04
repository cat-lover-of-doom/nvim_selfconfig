-- Leader
vim.g.mapleader = " "

-- QoL: do not yank on change/delete
vim.keymap.set({ "n", "x" }, "s", '"_s', { silent = true })
vim.keymap.set({ "n", "x" }, "S", '"_S', { silent = true })
vim.keymap.set({"n", "x"}, "x", '"_x', { silent = true })
vim.keymap.set({"n", "x"}, "X", '"_X', { silent = true })

-- QoL: visual paste swap
vim.keymap.set("x", "p", "P", { silent = true })
vim.keymap.set("x", "P", "p", { silent = true })

-- QoL: navigation/selection
vim.keymap.set("n", "0", "^", { silent = true })
vim.keymap.set("n", "gg", "gg0", { silent = true })
vim.keymap.set("n", "G", "G$", { silent = true })

-- QoL: indent keep selection
vim.keymap.set("x", "<Tab>", ">gv", { silent = true })
vim.keymap.set("x", "<S-Tab>", "<gv", { silent = true })
vim.keymap.set("x", ">", ">gv", { silent = true })
vim.keymap.set("x", "<", "<gv", { silent = true })

-- Clear search with Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { silent = true })

-- -------------------------------------------------------------------
-- Smart helpers for fallbacks (Telescope/Yazi may not be installed)
-- -------------------------------------------------------------------
-- [ADDED]
local function has(mod)
  local ok = pcall(require, mod)
  return ok
end

-- Grep fallback: prompt and run :vimgrep then open quickfix
-- [ADDED]
local function naive_live_grep()
  local input = vim.fn.input("Grep > ")
  if input == nil or input == "" then return end
  vim.cmd("silent vimgrep /" .. input .. "/gj **/*")
  vim.cmd("copen")
end

-- -------------------------------------------------------------------
-- Window/Buffer movement (fallbacks if tmux-navigator missing)
-- -------------------------------------------------------------------
-- [CHANGED] use tmux navigator if present; else use Vim window moves
if vim.fn.exists(":TmuxNavigateLeft") == 2 then
  vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>",  { silent = true })
  vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>",  { silent = true })
  vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>",    { silent = true })
  vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { silent = true })
  vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", { silent = true })
else
  vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
end

-- Buffer navigation
vim.keymap.set("n", "<A-Down>", ":bn<CR>", { silent = true, desc = "Next Buffer" })
vim.keymap.set("n", "<A-Up>",   ":bp<CR>", { silent = true, desc = "Prev Buffer" })

-- Quick close for help/quickfix/man
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "qf", "man" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

-- -------------------------------------------------------------------
-- File explorers
-- -------------------------------------------------------------------
-- <leader>s => Yazi (fallback: netrw :Explore)
vim.keymap.set("n", "<leader>s", function()
  if has("Oil") then
    vim.cmd("Oil")
  else
    vim.cmd("Explore")
  end
end, { silent = true, desc = "File explorer (Yazi | fallback: netrw)" })

-- -------------------------------------------------------------------
-- Telescope core mappings with fallbacks
-- -------------------------------------------------------------------
-- [CHANGED]
vim.keymap.set("n", "<leader>ff", function()
  if has("telescope.builtin") then
    require("telescope.builtin").find_files()
  else
    vim.cmd("Explore")  -- fallback
  end
end, { silent = true, desc = "Find files" })

-- [CHANGED]
vim.keymap.set("n", "<leader>fg", function()
  if has("telescope.builtin") then
    require("telescope.builtin").live_grep()
  else
    naive_live_grep()
  end
end, { silent = true, desc = "Live grep" })

-- [CHANGED]
vim.keymap.set("n", "<leader>fb", function()
  if has("telescope.builtin") then
    require("telescope.builtin").buffers()
  else
    vim.cmd("ls")  -- fallback
  end
end, { silent = true, desc = "Buffers" })

-- Undotree
vim.keymap.set("n", "<leader>z", "<cmd>UndotreeToggle<CR>", { silent = true, desc = "Undotree" })

-- -------------------------------------------------------------------
-- GitSigns (safe if plugin missing)
-- -------------------------------------------------------------------
-- [CHANGED]
do
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    vim.keymap.set("n", "]c", gs.next_hunk, { desc = "Next hunk" })
    vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "Prev hunk" })
    vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
    vim.keymap.set("n", "<leader>gr", gs.reset_hunk,   { desc = "Reset hunk" })
    vim.keymap.set("n", "<leader>gs", gs.stage_hunk,   { desc = "Stage hunk" })
    vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
    vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
    vim.keymap.set("n", "<leader>gd", gs.diffthis, { desc = "Diff against index" })
    vim.keymap.set("v", "<leader>gs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "Stage selection" })
    vim.keymap.set("v", "<leader>gr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "Reset selection" })
  end
end
