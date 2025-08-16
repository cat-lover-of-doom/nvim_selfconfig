-- General usage autocmds.

-- DESCRIPTION:
-- All autocmds are defined here.

--    Sections:
--       ## EXTRA LOGIC
--       -> 1. Events to load plugins faster.
--       -> 2. Save/restore window layout when possible.
--       -> 3. Launch alpha greeter on startup.
--       -> 4. Update neotree when closing the git client.
--       -> 5. Create parent directories when saving a file.
--
--       ## COOL HACKS
--       -> 6. Effect: URL underline.
--       -> 7. Customize right click contextual menu.
--       -> 8. Unlist quickfix buffers if the filetype changes.
--       -> 9. Close all notifications on BufWritePre.
--
--       ## COMMANDS
--       -> 11. Open Neotree when opening Oil
--       -> 12. Handle Locking and unlocking neovim
--       -> 13. user command to manually unlock neotree
--       ->     Extra commands.
--
--       ## BUILD COMMANDS
--       -> 14. Function to write a command to the file
--       -> 15. Function to read and execute the command in Vimux
--
--       ## REGULATE HJKL KEYS
--       -> 16. Function to check and update key usage
--       -> 17. Reset the key counts on entering insert mode, using other keys, or using counts
--       -> 18. Function to handle counts

local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.api.nvim_create_user_command
local utils = require("utils")
-- local is_available = utils.is_available

-- ## EXTRA LOGIC -----------------------------------------------------------
-- 1. Events to load plugins faster → 'BaseFile'/'BaseGitFile'/'BaseDefered':
--    this is pretty much the same thing as the event 'BufEnter',
--    but without increasing the startup time displayed in the greeter.
autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
    desc = "Nvim user events for file detection (BaseFile and BaseGitFile)",
    callback = function(args)
        local empty_buffer = vim.fn.resolve(vim.fn.expand "%") == ""
        local greeter = vim.api.nvim_get_option_value("filetype", { buf = args.buf }) == "alpha"
        local git_repo = vim.fn.executable("git") == 1 and utils.run_cmd(
            { "git", "-C", vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand "%"), ":p:h"), "rev-parse" }, false)

        -- For any file exept empty buffer, or the greeter (alpha)
        if not (empty_buffer or greeter) then
            utils.trigger_event("User BaseFile")

            -- Is the buffer part of a git repo?
            if git_repo then
                utils.trigger_event("User BaseGitFile")
            end
        end
    end,
})

autocmd({ "VimEnter" }, {
    desc = "Nvim user event that trigger a few ms after nvim starts",
    callback = function()
        -- If nvim is opened passing a filename, trigger the event inmediatelly.
        if #vim.fn.argv() >= 1 then
            -- In order to avoid visual glitches.
            utils.trigger_event("User BaseDefered", true)
            utils.trigger_event("BufEnter", true) -- also, initialize tabline_buffers.
        else                                -- Wait some ms before triggering the event.
            vim.defer_fn(function()
                utils.trigger_event("User BaseDefered")
            end, 70)
        end
    end,
})

-- 2. Save/restore window layout when possible.
autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
    desc = "Save view with mkview for real files",
    callback = function(args)
        if vim.b[args.buf].view_activated then
            vim.cmd.mkview { mods = { emsg_silent = true } }
        end
    end,
})
autocmd("BufWinEnter", {
    desc = "Try to load file view if available and enable view saving for real files",
    callback = function(args)
        if not vim.b[args.buf].view_activated then
            local filetype =
                vim.api.nvim_get_option_value("filetype", { buf = args.buf })
            local buftype =
                vim.api.nvim_get_option_value("buftype", { buf = args.buf })
            local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
            if
                buftype == ""
                and filetype
                and filetype ~= ""
                and not vim.tbl_contains(ignore_filetypes, filetype)
            then
                vim.b[args.buf].view_activated = true
                vim.cmd.loadview { mods = { emsg_silent = true } }
            end
        end
    end,
})

-- 3. Launch alpha greeter on startup
autocmd({ "User", "BufEnter" }, {
    desc = "Disable status and tablines for alpha",
    callback = function(args)
        local is_filetype_alpha = vim.api.nvim_get_option_value(
            "filetype", { buf = 0 }) == "alpha"
        local is_empty_file = vim.api.nvim_get_option_value(
            "buftype", { buf = 0 }) == "nofile"
        if ((args.event == "User" and args.file == "AlphaReady") or
                (args.event == "BufEnter" and is_filetype_alpha)) and
            not vim.g.before_alpha
        then
            vim.g.before_alpha = {
                showtabline = vim.opt.showtabline:get(),
                laststatus = vim.opt.laststatus:get()
            }
            vim.opt.showtabline, vim.opt.laststatus = 0, 0
        elseif
            vim.g.before_alpha
            and args.event == "BufEnter"
            and not is_empty_file
        then
            vim.opt.laststatus = vim.g.before_alpha.laststatus
            vim.opt.showtabline = vim.g.before_alpha.showtabline
            vim.g.before_alpha = nil
        end
    end,
})
autocmd("VimEnter", {
    desc = "Start Alpha only when nvim is opened with no arguments",
    callback = function()
        -- Precalculate conditions.
        local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
        local buf_not_empty = vim.fn.argc() > 0
            or #lines > 1
            or (#lines == 1 and lines[1]:len() > 0)
        local buflist_not_empty = #vim.tbl_filter(
            function(bufnr) return vim.bo[bufnr].buflisted end,
            vim.api.nvim_list_bufs()
        ) > 1
        local buf_not_modifiable = not vim.o.modifiable

        -- Return instead of opening alpha if any of these conditions occur.
        if buf_not_modifiable or buf_not_empty or buflist_not_empty then
            return
        end
        for _, arg in pairs(vim.v.argv) do
            if arg == "-b"
                or arg == "-c"
                or vim.startswith(arg, "+")
                or arg == "-S"
            then
                return
            end
        end

        -- All good? Show alpha.
        require("alpha").start(true, require("alpha").default_config)
        vim.schedule(function() vim.cmd.doautocmd "FileType" end)
    end,
})

-- 4. Update neotree when closing the git client.
autocmd("TermClose", {
    pattern = { "*lazygit", "*gitui" },
    desc = "Refresh Neo-Tree git when closing lazygit/gitui",
    callback = function()
        local manager_avail, manager = pcall(require, "neo-tree.sources.manager")
        if manager_avail then
            for _, source in ipairs {
                "filesystem",
                "git_status",
                "document_symbols",
            } do
                local module = "neo-tree.sources." .. source
                if package.loaded[module] then
                    manager.refresh(require(module).name)
                end
            end
        end
    end,
})

-- 5. Create parent directories when saving a file.
autocmd("BufWritePre", {
    desc = "Automatically create parent directories if they don't exist when saving a file",
    callback = function(args)
        local buf_is_valid_and_listed = vim.api.nvim_buf_is_valid(args.buf)
            and vim.bo[args.buf].buflisted

        if buf_is_valid_and_listed then
            vim.fn.mkdir(vim.fn.fnamemodify(
                vim.uv.fs_realpath(args.match) or args.match, ":p:h"), "p")
        end
    end,
})

-- ## COOL HACKS ------------------------------------------------------------
-- 6. Effect: URL underline.
vim.api.nvim_set_hl(0, 'HighlightURL', { underline = true })
-- autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
--     desc = "URL Highlighting",
--     callback = function() utils.set_url_effect() end,
-- })


-- 8. Unlist quickfix buffers if the filetype changes.
autocmd("FileType", {
    desc = "Unlist quickfist buffers",
    pattern = "qf",
    callback = function() vim.opt_local.buflisted = false end,
})

-- 9. Close all notifications on BufWritePre.
autocmd("BufWritePre", {
    desc = "Close all notifications on BufWritePre",
    callback = function()
        require("notify").dismiss({ pending = true, silent = true })
    end,
})

-- ## COMMANDS --------------------------------------------------------------

-- 10. Testing commands
-- Aditional commands to the ones implemented in neotest.
-------------------------------------------------------------------

-- Customize this command to work as you like
cmd("TestNodejs", function()
    -- You can generate code coverage by adding this to your project's packages.json
    -- "tests": "jest --coverage"
    vim.cmd(":ProjectRoot")                 -- cd the project root (requires project.nvim)
    vim.cmd(":TermExec cmd='npm run test'") -- convention to run tests on nodejs
end, { desc = "Run all unit tests for the current nodejs project" })

-- Customize this command to work as you like
cmd("TestNodejsE2e", function()
    vim.cmd(":ProjectRoot")                -- cd the project root (requires project.nvim)
    vim.cmd(":TermExec cmd='npm run e2e'") -- Conventional way to call e2e in nodejs (requires ToggleTerm)
end, { desc = "Run e2e tests for the current nodejs project" })

-- Extra commands
----------------------------------------------

-- Change working directory
cmd("Cwd", function()
    vim.cmd(":cd %:p:h")
    vim.cmd(":pwd")
end, { desc = "cd current file's directory" })

-- Set working directory (alias)
cmd("Swd", function()
    vim.cmd(":cd %:p:h")
    vim.cmd(":pwd")
end, { desc = "cd current file's directory" })

-- Write all buffers
cmd("WriteAllBuffers", function()
    vim.cmd("wa")
end, { desc = "Write all changed buffers" })

-- Close all notifications
cmd("CloseNotifications", function()
    require("notify").dismiss({ pending = true, silent = true })
end, { desc = "Dismiss all notifications" })

-- Lazy fingers
vim.api.nvim_create_user_command(
    'W',           -- :Name of the command
    function(opts) -- callback (Lua)
        -- vim.cmd("w")
        vim.cmd('write')
    end,
    {
        nargs = '?',                     -- 0 or 1 arg
        bang = true,                     -- allow !
        desc = 'I have lazy fingers :(', -- :help :Greet
        -- complete = function(_, _, _)              -- custom completion
        --   return { 'Alice', 'Bob', 'Carol' }
        -- end,
    }
)

-- ## Neotree --------------------------------------------------------------
--
-- 11. Open Neotree when opening Oil
autocmd("BufEnter", {
  desc = "Open Neotree when entering Oil buffer",
  callback = function(args)
    if vim.bo[args.buf].filetype == "oil" then
            vim.cmd("Neotree action=show")
    end
  end,
})

-- 12. Handle Locking and unlocking neovim
Neotree_is_locked = false
autocmd({ "BufEnter" }, {
    desc = "Prevent user from entering neotree when its locked",
    callback = function(args)
        local is_filetype_neotree = vim.api.nvim_get_option_value(
            "filetype", { buf = 0 }) == "neo-tree"
        if (args.event == "BufEnter" and is_filetype_neotree) then
            if Neotree_is_locked then
                require("smart-splits").move_cursor_right()
            else
                Neotree_is_locked = true
            end
        end
    end,
})

-- 13. user command to manually unlock neotree
vim.api.nvim_create_user_command(
    'UnlockNT', -- :Name of the command
    function(opts)         -- callback (Lua)
        Neotree_is_locked = false
    end,
    {
        nargs = '?',                    -- 0 or 1 arg
        bang = true,                    -- allow !
        desc = 'i must control myself', -- :help :Greet
        -- complete = function(_, _, _)              -- custom completion
        --   return { 'Alice', 'Bob', 'Carol' }
        -- end,
    }
)

-- ## BUILD COMMANDS --------------------------------------------------------------
-- Define the file where the command will be stored
local command_file = vim.fn.stdpath('data') .. '/stored_command.txt'

-- 14. Function to write a command to the file
function WriteCommand()
  local command = vim.fn.input('Enter command: ')
  local file = io.open(command_file, 'w')
  if file then
    file:write(command)
    file:close()
  else
    print('Error: Unable to write to file.')
  end
end

-- 15. Function to read and execute the command in Vimux
function ExecCommand()
  local file = io.open(command_file, 'r')
  if file then
    local command = file:read('*all')
    file:close()
    if command ~= '' then
      -- Use Vimux to run the command in a tmux pane
      vim.cmd('VimuxRunCommand(' .. vim.fn.json_encode(command) .. ')')
    else
      print('No command found in the file.')
    end
  else
    print('Error: Unable to read from file.')
  end
end

-- ## REGULATE HJKL KEYS --------------------------------------------------------------
-- Initialize counters for the keys
local key_counts = { h = 0, j = 0, k = 0, l = 0 }
local max_count = 3

-- Function to reset all key counters
local function reset_counts()
    key_counts.h = 0
    key_counts.j = 0
    key_counts.k = 0
    key_counts.l = 0
end

-- 16. Function to check and update key usage
local function handle_key(key)
    key_counts[key] = key_counts[key] + 1
    if key_counts[key] > max_count then
        print("Key " .. key .. " usage limit exceeded!")
        return ""
    end
    return key
end

-- 17. Reset the key counts on entering insert mode, using other keys, or using counts
vim.cmd [[
    augroup ResetKeyCounts
        autocmd!
        autocmd InsertEnter * lua reset_counts()
        autocmd BufEnter * lua reset_counts()
    augroup END
]]

-- 18. Function to handle counts
local function handle_count(count, key)
    if count > 1 then
    return key
    end
    return handle_key(key)
end

-- Remap keys with count handling
vim.api.nvim_set_keymap('n', 'h', 'v:lua.handle_count(v:count1, "h")', { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('n', 'j', 'v:lua.handle_count(v:count1, "j")', { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('n', 'k', 'v:lua.handle_count(v:count1, "k")', { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('n', 'l', 'v:lua.handle_count(v:count1, "l")', { noremap = true, silent = true, expr = true })
_G.handle_count = handle_count
_G.reset_counts = reset_counts
_G.handle_key = handle_key
