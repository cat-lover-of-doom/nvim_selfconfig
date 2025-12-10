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
    vim.keymap.set("n", "<Esc>", M.toggle,
        { buffer = state.buf, nowait = true, silent = true, desc = "Close floating terminal" })
    vim.keymap.set("n", "q", M.toggle,
        { buffer = state.buf, nowait = true, silent = true, desc = "Close floating terminal" })
end

local function read_stored()
    local f = io.open(cmdfile, "r")
    if not f then return "" end
    local c = (f:read("*a") or ""):gsub("^%s+", ""):gsub("%s+$", "")
    f:close()
    return c
end

local function write_stored(c)
    local f = io.open(cmdfile, "w")
    if not f then return false end
    f:write(c)
    f:close()
    return true
end

function M.store()
    local prev = read_stored()
    -- Pre-fill with existing command; user can edit in-place
    local c = vim.fn.input("Command: ", prev)
    if not c then return end
    c = c:gsub("^%s+", ""):gsub("%s+$", "")

    if c == "" then
        if prev == "" then
            print("Nothing to store.")
        else
            print("Unchanged.")
        end
        return
    end
    if c == prev then
        print("Unchanged.")
        return
    end
    if write_stored(c) then
        print("Stored:", c)
    end
end

function M.run_stored()
    local f = io.open(cmdfile, "r"); if not f then return print("No stored command") end
    local c = (f:read("*a") or ""):gsub("^%s+", ""):gsub("%s+$", ""); f:close()
    if c == "" then return print("Stored command is empty") end
    M.toggle()
    ensure_shell()
    vim.api.nvim_chan_send(state.job, c .. "\n")
end

-- Sets colors to line numbers Above, Current and Below  in this order
function M.VisualTweaks()
    vim.api.nvim_set_hl(0, 'LineNrAbove', { fg = '#a6adc8', bold = false })
    vim.api.nvim_set_hl(0, 'LineNr', { fg = '#cdd6f4', bold = true })
    vim.api.nvim_set_hl(0, 'LineNrBelow', { fg = '#a6adc8', bold = false })
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
    callback = function()
        M.VisualTweaks()
    end,
})

local grp = vim.api.nvim_create_augroup("remember_folds", { clear = true })

local function is_text_buffer(buf)
    return vim.api.nvim_buf_get_option(buf, "buftype") == ""
        and vim.api.nvim_buf_get_option(buf, "filetype") ~= ""
end

vim.api.nvim_create_autocmd("BufWinLeave", {
    group = grp,
    callback = function(args)
        if is_text_buffer(args.buf) then
            vim.cmd("mkview")
        end
    end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = grp,
    callback = function(args)
        if is_text_buffer(args.buf) then
            vim.cmd("silent! loadview")
        end
    end,
})

return M
