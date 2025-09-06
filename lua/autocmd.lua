-- utils/floaterm & helpers (no global keymaps here)
local M = {}
local state = { buf = nil, win = nil, job = nil }
local cmdfile = vim.fn.stdpath("data") .. "/stored_command.txt"

local function center(size, total) return math.floor((total - size) / 2) end

local function open_win()
  if state.win and vim.api.nvim_win_is_valid(state.win) then return end
  state.buf = state.buf or vim.api.nvim_create_buf(false, true)
  local w = math.floor(vim.o.columns * 0.8)
  local h = math.floor(vim.o.lines * 0.8)
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = w,
    height = h,
    row = center(h, vim.o.lines),
    col = center(w, vim.o.columns),
    style = "minimal",
    border = "rounded",
  })
end

local function ensure_shell()
  if state.job and vim.fn.jobwait({ state.job }, 0)[1] == -1 then return end
  vim.api.nvim_buf_call(state.buf, function()
    vim.cmd("terminal")
    state.job = vim.b.terminal_job_id
  end)
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
    return
  end
  open_win()
  ensure_shell()
  vim.cmd("stopinsert")
  -- Local buffer-only quit bindings
  vim.keymap.set("n", "<Esc>", M.toggle, { buffer = state.buf, nowait = true, silent = true, desc = "Close floating terminal" })
  vim.keymap.set("n", "q",     M.toggle, { buffer = state.buf, nowait = true, silent = true, desc = "Close floating terminal" })
end

function M.store()
  local c = vim.fn.input("Command: ")
  if c == "" then return end
  local f = io.open(cmdfile, "w"); if not f then return end
  f:write(c); f:close()
  print("Stored:", c)
end

function M.run_stored()
  local f = io.open(cmdfile, "r"); if not f then return print("No stored command") end
  local c = (f:read("*a") or ""):gsub("^%s+", ""):gsub("%s+$", ""); f:close()
  if c == "" then return print("Stored command is empty") end
  M.toggle()
  ensure_shell()
  vim.api.nvim_chan_send(state.job, c .. "\n")
end

function M.send_to_tmux()
  local f = io.open(cmdfile, "r"); if not f then return print("No stored command") end
  local c = (f:read("*a") or ""):gsub("^%s+", ""):gsub("%s+$", ""); f:close()
  if c == "" then return print("Stored command is empty") end
  vim.fn.system({ "tmux", "new-window", c })
  vim.notify("Sent to tmux: " .. c)
end

return M
