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

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Paste from system clipboard
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste after from clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from clipboard" })


-- QoL: navigation/selection
vim.keymap.set("n", "0", "^", { silent = true })
vim.keymap.set("n", "gg", "gg0", { silent = true })
vim.keymap.set("n", "G", "G$", { silent = true })
vim.keymap.set("n", "<C-a>", "gg0vG$", { silent = true, desc = "Select all" })

-- QoL: indent keep selection
vim.keymap.set("x", "<Tab>", ">gv", { silent = true })
vim.keymap.set("x", "<S-Tab>", "<gv", { silent = true })
vim.keymap.set("x", ">", ">gv", { silent = true })
vim.keymap.set("x", "<", "<gv", { silent = true })

-- Clear search with Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { silent = true })

-- Window movement/resizing (fallbacks)
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<CR>", { silent = true })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { silent = true })

-- Quick close for help/quickfix/man
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "qf", "man" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

-- Plugins -------------------------------------------------------------

-- Oil
vim.keymap.set("n", "<leader>s", "<CMD>Oil<CR>", { silent = true, desc = "File browser (Oil)" })

-- Undotree
vim.keymap.set("n", "<leader>z", "<cmd>UndotreeToggle<CR>", { silent = true, desc = "Undotree" })

-- Vimux (no custom helpers; use built-ins)
vim.keymap.set("n", "<leader>tt",
  function()
    if vim.g.VimuxRunnerIndex == nil then
      vim.cmd("VimuxOpenRunner")
    else
      vim.cmd("VimuxTogglePane")
    end
  end,
  { silent = true, desc = "Vimux toggle" })
vim.keymap.set("n", "<leader>tp", "<cmd>VimuxPromptCommand<CR>", { silent = true, desc = "Vimux prompt" })
vim.keymap.set("n", "<leader>t;", "<cmd>VimuxRunLastCommand<CR>", { silent = true, desc = "Vimux last" })
-- TODO consider using the VIM :make command
vim.keymap.set("n", "<leader>tm", "<cmd>VimuxRunCommand make<CR>", { silent = true, desc = "Vimux make" })
vim.keymap.set("n", "<leader>ts", "<cmd>lua VimuxWriteCommand()<CR>", { silent = true, desc = "Vimux make" })
vim.keymap.set("n", "<leader>tr", "<cmd>lua VimuxExecCommand()<CR>", { silent = true, desc = "Vimux make" })
-- Orientation/height are global options; if you still want a toggle, keep this simple variant:
vim.keymap.set("n", "<leader>to", function()
  if vim.g.VimuxOrientation == "v" then
    vim.g.VimuxOrientation = "h"; vim.g.VimuxHeight = "40%"
  else
    vim.g.VimuxOrientation = "v"; vim.g.VimuxHeight = "20%"
  end
end, { silent = true, desc = "Vimux toggle orientation" })

-- mini.pick nvim 
vim.keymap.set("n", "<leader>ff", function() require("mini.pick").builtin.files() end, { silent = true, desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() require("mini.pick").builtin.grep_live() end, { silent = true, desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function() require("mini.pick").builtin.buffers() end, { silent = true, desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function() require("mini.pick").builtin.help() end, { silent = true, desc = "Help tags" })


-- Gitsigns (global keymaps)
local gs = require("gitsigns")

-- Navigation
vim.keymap.set("n", "]c", gs.next_hunk, { desc = "Next hunk" })
vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "Prev hunk" })

-- Actions
vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
vim.keymap.set("n", "<leader>gd", gs.diffthis, { desc = "Diff against index" })

-- Visual mode: stage/reset selection
vim.keymap.set("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
  { desc = "Stage selection" })
vim.keymap.set("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
  { desc = "Reset selection" })

-- Buffer navigation
vim.keymap.set("n", "<A-Down>", ":bn<CR>", {silent = true, desc = "Next Buffer"})
vim.keymap.set("n", "<A-Up>", ":bp<CR>", {silent = true, desc = "Next Buffer"})
