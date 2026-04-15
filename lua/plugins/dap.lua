local dap = require("dap")
local dapui = require("dapui")

local last_program = nil

-- codelldb adapter (installed by mason-nvim-dap)
dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
    },
}

-- C / C++ configurations
local c_cpp_config = {
    {
        name = "Launch executable",
        type = "codelldb",
        request = "launch",
        program = function()
            local path = vim.fn.input("Path to executable: ", last_program or (vim.fn.getcwd() .. "/"), "file")
            last_program = path
            return path
        end,
        cwd = function()
            return vim.fn.getcwd()
        end,
        stopOnEntry = false,
        sourceLanguages = { "c", "cpp" },
        sourceMap = {
            ["."] = "${workspaceFolder}",
        },
    },
    {
        name = "Attach to process",
        type = "codelldb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
    },
}
dap.configurations.c = c_cpp_config
dap.configurations.cpp = c_cpp_config

-- Signs
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

-- DAP UI
dapui.setup({
    layouts = {
        {
            elements = {
                { id = "scopes", size = 0.6 },
                { id = "stacks", size = 0.4 },
            },
            size = 40,
            position = "left",
        },
        {
            elements = {
                { id = "repl",    size = 0.5 },
                { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
        },
    },
})

-- Auto open/close UI on debug session
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-- ── Keymaps (<leader>d*) ────────────────────────────────────────────────────
local _last_dap_action = nil
local function tracked(fn)
    return function()
        _last_dap_action = fn
        fn()
    end
end

-- Action table: { lhs_suffix, fn, desc, mode }
local function relaunch_fn()
    if not last_program or last_program == "" then
        vim.notify("No executable cached — launch first", vim.log.levels.WARN)
        dap.continue()
        return
    end
    local function relaunch()
        dap.run({
            name = "Launch executable",
            type = "codelldb",
            request = "launch",
            program = last_program,
            cwd = vim.fn.getcwd(),
            stopOnEntry = false,
            sourceLanguages = { "c", "cpp" },
            sourceMap = { ["."] = "${workspaceFolder}" },
        })
    end
    if dap.session() then
        dap.terminate(nil, nil, function() vim.defer_fn(relaunch, 150) end)
    else
        relaunch()
    end
end

local dap_actions = {
    { "c", tracked(function() dap.continue() end),                              "Debug: continue",               "n" },
    { "n", tracked(function() dap.step_over() end),                             "Debug: step over",              "n" },
    { "i", tracked(function() dap.step_into() end),                             "Debug: step into",              "n" },
    { "o", tracked(function() dap.step_out() end),                              "Debug: step out",               "n" },
    { "b", function() dap.toggle_breakpoint() end,                              "Debug: toggle breakpoint",      "n" },
    { "B", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end,      "Debug: conditional breakpoint", "n" },
    { "t", function() dap.terminate() end,                                      "Debug: terminate",              "n" },
    { "u", function() dapui.toggle() end,                                       "Debug: toggle UI",              "n" },
    { "e", function() dapui.eval() end,                                         "Debug: eval under cursor",      "n" },
    { "e", function() dapui.eval() end,                                         "Debug: eval selection",         "v" },
    { "k", tracked(function() dap.up() end),                                    "Debug: frame up",               "n" },
    { "j", tracked(function() dap.down() end),                                  "Debug: frame down",             "n" },
    { "R", function() dap.restart() end,                                        "Debug: restart",                "n" },
    { "r", relaunch_fn,                                                         "Debug: relaunch binary",        "n" },
    { "d", function()
        if _last_dap_action then _last_dap_action() else vim.notify("No debug action to repeat", vim.log.levels.WARN) end
    end, "Debug: repeat last action", "n" },
}

-- Always register <leader>d* keymaps
for _, a in ipairs(dap_actions) do
    vim.keymap.set(a[4], "<leader>d" .. a[1], a[2], { desc = a[3] })
end

-- ── Short-key toggle (single-letter keymaps while debugging) ────────────────
local _short_keys_active = false
local _saved_maps = {}

local function set_short_keys()
    if _short_keys_active then return end
    _saved_maps = {}
    for _, a in ipairs(dap_actions) do
        -- Save any existing mapping on this key so we can restore it
        local existing = vim.fn.maparg(a[1], a[4], false, true)
        if existing and existing.lhs then
            table.insert(_saved_maps, existing)
        end
        vim.keymap.set(a[4], a[1], a[2], { desc = a[3], nowait = true })
    end
    _short_keys_active = true
    vim.notify("DAP short keys ON", vim.log.levels.INFO)
end

local function del_short_keys()
    if not _short_keys_active then return end
    for _, a in ipairs(dap_actions) do
        pcall(vim.keymap.del, a[4], a[1])
    end
    -- Restore any mappings that existed before
    for _, m in ipairs(_saved_maps) do
        local rhs = m.callback or m.rhs
        if rhs then
            vim.keymap.set(m.mode or "n", m.lhs, rhs, {
                silent = m.silent == 1,
                noremap = m.noremap == 1,
                expr = m.expr == 1,
                desc = m.desc,
            })
        end
    end
    _saved_maps = {}
    _short_keys_active = false
    vim.notify("DAP short keys OFF", vim.log.levels.INFO)
end

local function toggle_short_keys()
    if _short_keys_active then
        del_short_keys()
    else
        set_short_keys()
    end
end

vim.keymap.set("n", "|", toggle_short_keys, { desc = "Debug: toggle short keymaps" })

-- Auto-enable short keys when debugger starts, auto-disable when it stops
dap.listeners.after.event_initialized["dap_short_keys"] = function()
    set_short_keys()
end
dap.listeners.before.event_terminated["dap_short_keys"] = function()
    del_short_keys()
end
dap.listeners.before.event_exited["dap_short_keys"] = function()
    del_short_keys()
end
