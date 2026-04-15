local lspconfig = require("lspconfig")

local caps = vim.lsp.protocol.make_client_capabilities()
pcall(function()
    caps = require("cmp_nvim_lsp").default_capabilities(caps)
end)

local on_attach = function(_, bufnr)
    local o = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, o)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, o)
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, o)
    vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>", o)
    vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, o)
    vim.keymap.set({ "n", "v" }, "<leader>lf", function() vim.lsp.buf.format({ async = false }) end, o)
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, o)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
    vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, o)
    vim.keymap.set("n", "gh", vim.lsp.buf.hover, o)
    vim.keymap.set("n", "gH", vim.lsp.buf.signature_help, o)
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    callback = function(ev)
        on_attach(nil, ev.buf)
    end,
})

require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pylsp", "clangd", "gopls", },
    automatic_installation = true,
    handlers = {
        function(server)
            lspconfig[server].setup({ on_attach = on_attach, capabilities = caps })
        end,
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
                on_attach = on_attach,
                capabilities = caps,
                settings = { Lua = { diagnostics = { globals = { "vim" } } } },
            })
        end,
        ["cmakelang"] = function()
            lspconfig.lua_ls.setup({
                on_attach = on_attach,
                capabilities = caps,
                Pattern = { "CMakeLists.txt", "*.cmake" },
            })
        end,
    },
})
