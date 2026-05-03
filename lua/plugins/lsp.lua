return {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup({ ui = { border = "rounded" } })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lspconfig = require("lspconfig")

            local caps = vim.lsp.protocol.make_client_capabilities()
            pcall(function()
                caps = require("cmp_nvim_lsp").default_capabilities(caps)
            end)

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
                callback = function(ev)
                    -- diagnostics
                    vim.keymap.set("n", "<leader>lN", function() vim.diagnostic.jump({ count = -1 }) end,
                        { buffer = ev.buf, silent = true, desc = "Prev diagnostic" })
                    vim.keymap.set("n", "<leader>ln", function() vim.diagnostic.jump({ count = 1 }) end,
                        { buffer = ev.buf, silent = true, desc = "Next diagnostic" })
                    vim.keymap.set("n", "<leader>le", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
                        { buffer = ev.buf, silent = true, desc = "Next error" })
                    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { buffer = ev.buf, silent = true, desc = "Lsp expand error" })
                    vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>", { buffer = ev.buf, silent = true, desc = "Lsp Info" })
                    -- actions
                    vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { buffer = ev.buf, silent = true, desc = "Lsp code actions" })
                    vim.keymap.set({ "n", "v" }, "<leader>lf", function() vim.lsp.buf.format({ async = false }) end,
                        { buffer = ev.buf, silent = true, desc = "Lsp format" })
                    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = ev.buf, silent = true, desc = "Lsp rename" })
                    -- goto / help
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, silent = true, desc = "Go definition" })
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, silent = true, desc = "Go declaration" })
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, silent = true, desc = "Show references" })
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, silent = true, desc = "Go implementation" })
                    vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = ev.buf, silent = true, desc = "Go type definition" })
                    vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = ev.buf, silent = true, desc = "Get hover info" })
                    vim.keymap.set("n", "gH", vim.lsp.buf.signature_help, { buffer = ev.buf, silent = true, desc = "Get signature_help" })
                    -- Header/Source toggle (clangd)
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    if client and client.name == "clangd" then
                        vim.keymap.set("n", "gh", function()
                            vim.lsp.buf_request(0, "textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(0) }, function(err, result)
                                if not err and result then
                                    vim.cmd("edit " .. vim.uri_to_fname(result))
                                end
                            end)
                        end, { buffer = ev.buf, desc = "Toggle header/source (clangd)" })
                    end
                end,
            })

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pylsp", "clangd", "gopls", },
                automatic_installation = true,
                handlers = {
                    function(server)
                        lspconfig[server].setup({ capabilities = caps })
                    end,
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup({
                            capabilities = caps,
                            settings = { Lua = { diagnostics = { globals = { "vim" } } } },
                        })
                    end,
                    ["cmakelang"] = function()
                        lspconfig.lua_ls.setup({
                            capabilities = caps,
                            Pattern = { "CMakeLists.txt", "*.cmake" },
                        })
                    end,
                },
            })
        end,
    },
}
