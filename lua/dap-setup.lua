local dap = require("dap")
local dapui = require("dapui")

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
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
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

-- Debug-mode keymaps: remap single keys during active session
local debug_keys = { "n", "s", "r", "c", "b" }
local saved_maps = {}

local function set_debug_maps()
    saved_maps = {}
    for _, key in ipairs(debug_keys) do
        for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
            if m.lhs == key then
                saved_maps[key] = m
                break
            end
        end
    end
    vim.keymap.set("n", "n", dap.step_over, { desc = "Debug: step over" })
    vim.keymap.set("n", "s", dap.step_into, { desc = "Debug: step into" })
    vim.keymap.set("n", "r", dap.restart, { desc = "Debug: restart" })
    vim.keymap.set("n", "c", dap.continue, { desc = "Debug: continue" })
    vim.keymap.set("n", "b", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
    vim.keymap.set("n", "o", function() dap.step_out() end, { desc = "Debug: step out" })
    vim.keymap.set("n", "t", function() dap.terminate() end, { desc = "Debug: terminate" })
    vim.keymap.set("n", "u", function() dapui.toggle() end, { desc = "Debug: toggle UI" })
    vim.keymap.set("n", "e", function() dapui.eval() end, { desc = "Debug: eval under cursor" })
    vim.keymap.set("v", "e", function() dapui.eval() end, { desc = "Debug: eval selection" })
    vim.keymap.set("n", "k", function() dap.up() end, { desc = "Debug: frame up" })
    vim.keymap.set("n", "j", function() dap.down() end, { desc = "Debug: frame down" })
end

local function restore_maps()
    for _, key in ipairs(debug_keys) do
        local m = saved_maps[key]
        if m then
            vim.keymap.set(m.mode, m.lhs, m.rhs or m.callback, {
                desc = m.desc,
                silent = m.silent == 1,
                noremap = m.noremap == 1,
                expr = m.expr == 1,
            })
        else
            pcall(vim.keymap.del, "n", key)
        end
    end
    saved_maps = {}
end

-- auto open/close UI + remap keys on debug session
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
    set_debug_maps()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
    restore_maps()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
    restore_maps()
end
