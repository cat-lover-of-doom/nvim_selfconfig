-- lua/autocmds.lua
-- Define Vimux helpers globally, once, on startup

local command_file = vim.fn.stdpath("data") .. "/stored_command.txt"

local term_state = { buf = nil, win = nil, job = nil }

_G.VimuxWriteCommand = function()
  local cmd = vim.fn.input("Enter command: ")
  if cmd == "" then
    print("No command entered.")
    return
  end
  local f = io.open(command_file, "w")
  if not f then
    print("Cannot write command file.")
    return
  end
  f:write(cmd)
  f:close()
  print("Stored:", cmd)
end

_G.VimuxExecCommand = function()
  local f = io.open(command_file, "r")
  if not f then
    print("No stored command. Use <leader>ts first.")
    return
  end
  local cmd = f:read("*all") or ""
  f:close()
  if cmd == "" then
    print("Stored command is empty.")
    return
  end
  open_floating_term(cmd)
end

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end

})

_G.VimuxToggleTerm = function()
  if term_state.win and vim.api.nvim_win_is_valid(term_state.win) then
    vim.api.nvim_win_close(term_state.win, true) -- hides buffer; job keeps running
    term_state.win = nil
  else
    -- Re-open window for existing buffer (if any)
    open_floating_term(nil, true) -- no command, just show
  end
end

local function close_term_win()
  if term_state and term_state.win and vim.api.nvim_win_is_valid(term_state.win) then
    vim.api.nvim_win_close(term_state.win, true) -- hide window; buffer/job persist
    term_state.win = nil
  end
end

-- helper to open command in new tmux window
local function send_to_tmux(cmd)
  if cmd == "" then return end
  -- "new-window" makes a fresh tmux window and runs the command
  vim.fn.system({ "tmux", "new-window", cmd })
  print("Opened in tmux window: " .. cmd)
end

open_floating_term = function(cmd, just_show)
  -- ensure persistent buffer
  if not (term_state.buf and vim.api.nvim_buf_is_valid(term_state.buf)) then
    term_state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "hide", { buf = term_state.buf })
  end

  -- (re)open window
  if not (term_state.win and vim.api.nvim_win_is_valid(term_state.win)) then
    local width  = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row    = math.floor((vim.o.lines - height) / 2)
    local col    = math.floor((vim.o.columns - width) / 2)
    term_state.win = vim.api.nvim_open_win(term_state.buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })
  else
    vim.api.nvim_set_current_win(term_state.win)
  end

  -- start terminal job if needed
  local job_alive = term_state.job and vim.fn.jobwait({ term_state.job }, 0)[1] == -1
  if not job_alive then
    vim.api.nvim_buf_call(term_state.buf, function()
      vim.cmd("terminal")
      term_state.job = vim.b.terminal_job_id
    end)
  end

  -- send command (optional)
  if cmd and cmd ~= "" and term_state.job then
    vim.api.nvim_chan_send(term_state.job, cmd .. "\n")
  end

  -- back to Normal mode
  vim.cmd("stopinsert")

  -- --- buffer-local keymaps (NORMAL MODE) ---
  -- ESC: hide window (previously `q`)
  vim.keymap.set("n", "<Esc>", close_term_win, { buffer = term_state.buf, nowait = true, silent = true })
  vim.keymap.set("n", "q", close_term_win, { buffer = term_state.buf, nowait = true, silent = true })

  vim.keymap.set("n", "|", function()
    -- grab last stored command
    local f = io.open(command_file, "r")
    local c = f and (f:read("*a") or "") or ""
    if f then f:close() end
    c = c:gsub("^%s+", ""):gsub("%s+$", "")
    if c ~= "" then
      send_to_tmux(c)
    else
      print("No stored command to send to tmux.")
    end
  end, { buffer = term_state.buf, silent = true, desc = "Run in tmux window" })
end

vim.keymap.set("n", "<leader>ts", _G.VimuxWriteCommand, { desc = "Store command" })
vim.keymap.set("n", "<leader>tr", _G.VimuxExecCommand,   { desc = "Run stored command in persistent float term" })
vim.keymap.set("n", "<leader>tt", _G.VimuxToggleTerm,    { desc = "Toggle persistent float terminal" })

-- lua/qf_make.lua

-- ========= Quickfix UX =========
local function qf_toggle()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.getwininfo(win)[1].quickfix == 1 then
      vim.cmd("cclose"); return
    end
  end
  if #vim.fn.getqflist() > 0 then vim.cmd("copen") else print("Quickfix empty") end
end

local function run_make()
  vim.cmd("silent make!")
  local qf = vim.fn.getqflist()
  if #qf > 0 then vim.cmd("copen") else print("✔ build/test passed") end
end

-- Global quickfix mappings
vim.keymap.set("n", "]q", "<cmd>cnext<CR>",  { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>",  { desc = "Prev quickfix" })
vim.keymap.set("n", "<leader>qo", qf_toggle, { desc = "Toggle quickfix" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
vim.keymap.set("n", "<leader>qq", function() vim.fn.setqflist({}); vim.cmd("cclose") end,
  { desc = "Clear quickfix" })

