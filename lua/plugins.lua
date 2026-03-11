return {
    ---------------------------------------------------------------------------
    -- UI/theme (optional)
    ---------------------------------------------------------------------------
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({ transparent_background = true })
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    ---------------------------------------------------------------------------
    -- File explorer (Oil)
    ---------------------------------------------------------------------------
    {
        "stevearc/oil.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            default_file_explorer = true,
            -- works if you have a trash utility installed
            skip_confirm_for_simple_edits = true,
            delete_to_trah = true,
            -- more options
            view_options = { show_hidden = true },
            use_default_keymaps = false,
            keymaps = {
                ["q"] = "actions.close",
                ["g?"] = { "actions.show_help", mode = "n" },
                ["<CR>"] = "actions.select",
                ["|"] = { "actions.select", opts = { vertical = true } },
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = { "actions.close", mode = "n" },
                ["<C-r>"] = "actions.refresh",
                ["-"] = { "actions.parent", mode = "n" },
                ["_"] = { "actions.open_cwd", mode = "n" },
                ["`"] = { "actions.cd", mode = "n" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gx"] = "actions.open_external",
                ["g."] = { "actions.toggle_hidden", mode = "n" },
                ["g\\"] = { "actions.toggle_trash", mode = "n" },
            },
        },
    },
    {
        "JezerM/oil-lsp-diagnostics.nvim",
        dependencies = { "stevearc/oil.nvim" },
        opts = {},
        lazy = false,
    },
    {
        "benomahony/oil-git.nvim",
        dependencies = { "stevearc/oil.nvim" },
        lazy = false,
        -- No opts or config needed! Works automatically
    },

    ---------------------------------------------------------------------------
    -- LSP stack: mason + mason-lspconfig + lspconfig + cmp (no LuaSnip)
    ---------------------------------------------------------------------------
    -- In your plugins.lua return list, add/replace these entries:

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
            "hrsh7th/cmp-nvim-lsp", -- optional, for capabilities
        },
        config = function()
            local lspconfig = require("lspconfig")

            -- caps (nvim-cmp optional)
            local caps = vim.lsp.protocol.make_client_capabilities()
            pcall(function()
                caps = require("cmp_nvim_lsp").default_capabilities(caps)
            end)

            -- LSP buffer-local mappings (+ <leader>ts/<leader>tr to call helpers)
            local on_attach = function(_, bufnr)
                local o = { buffer = bufnr, silent = true }
                -- diagnostics
                vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, o)
                vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, o)
                vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, o)
                vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>", o)
                -- actions
                vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, o)
                vim.keymap.set({ "n", "v" }, "<leader>lf", function() vim.lsp.buf.format({ async = false }) end, o)
                vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, o)
                -- goto / help
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
                vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, o)
                vim.keymap.set("n", "gh", vim.lsp.buf.hover, o)
                vim.keymap.set("n", "gH", vim.lsp.buf.signature_help, o)
            end

            -- Safety net: apply the same maps whenever any LSP attaches
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
                callback = function(ev)
                    -- If on_attach already ran, this is redundant but harmless.
                    on_attach(nil, ev.buf)
                end,
            })

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pylsp", "clangd", "gopls", },
                automatic_installation = true,
                handlers = {
                    -- default for all servers
                    function(server)
                        lspconfig[server].setup({ on_attach = on_attach, capabilities = caps })
                    end,
                    -- override: lua
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
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-s>"] = cmp.mapping {
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    },
                    ["<CR>"] = cmp.mapping.confirm { select = false },
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "buffer",  keyword_length = 3 },
                },
                experimental = { ghost_text = false },
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Treesitter (syntax/indent)
    ---------------------------------------------------------------------------
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "c",
                    "make",
                    "lua",
                    "vim",
                    "vimdoc",
                    "query",
                    "markdown",
                    "python",
                    "go",
                    "gomod",
                    "gosum",
                    "html",
                    "css",
                    "javascript",
                    "json",
                    "sql",
                    "csv",
                    "bash",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Undotree
    ---------------------------------------------------------------------------
    {
        "mbbill/undotree",
        event = "BufEnter",
        init = function()
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_WindowLayout = 2
        end,
    },

    ---------------------------------------------------------------------------
    -- Vimux
    ---------------------------------------------------------------------------
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope",
        event = "BufReadPre",
        config = function()
            local t = require("telescope")
            t.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = require("telescope.actions").move_selection_next,
                            ["<C-k>"] = require("telescope.actions").move_selection_previous,
                            ["<C-s>"] = require("telescope.actions").close,
                        },
                    },
                },
                pickers = {
                    find_files = { hidden = true },
                },
            })
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            numhl = false,
            signcolumn = true,
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            triggers = {
                { "<auto>", mode = "nixsotc" },
            },
            win = {
                wo = {
                    winblend = 0,
                },
            },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    }
}
