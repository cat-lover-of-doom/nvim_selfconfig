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

vim.keymap.set("n", "<leader>dc", tracked(function() dap.continue() end), { desc = "Debug: continue" })
vim.keymap.set("n", "<leader>dn", tracked(function() dap.step_over() end), { desc = "Debug: step over" })
vim.keymap.set("n", "<leader>di", tracked(function() dap.step_into() end), { desc = "Debug: step into" })
vim.keymap.set("n", "<leader>do", tracked(function() dap.step_out() end), { desc = "Debug: step out" })
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Debug: toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, { desc = "Debug: conditional breakpoint" })
vim.keymap.set("n", "<leader>dt", function() dap.terminate() end, { desc = "Debug: terminate" })
vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, { desc = "Debug: toggle UI" })
vim.keymap.set("n", "<leader>de", function() dapui.eval() end, { desc = "Debug: eval under cursor" })
vim.keymap.set("v", "<leader>de", function() dapui.eval() end, { desc = "Debug: eval selection" })
vim.keymap.set("n", "<leader>dk", tracked(function() dap.up() end), { desc = "Debug: frame up" })
vim.keymap.set("n", "<leader>dj", tracked(function() dap.down() end), { desc = "Debug: frame down" })
vim.keymap.set("n", "<leader>dR", function() dap.restart() end, { desc = "Debug: restart" })

vim.keymap.set("n", "<leader>dr", function()
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
end, { desc = "Debug: relaunch binary" })

vim.keymap.set("n", "<leader>dd", function()
    if _last_dap_action then
        _last_dap_action()
    else
        vim.notify("No debug action to repeat", vim.log.levels.WARN)
    end
end, { desc = "Debug: repeat last action" })
