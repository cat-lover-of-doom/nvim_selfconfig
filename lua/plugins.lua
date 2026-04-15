return {
    ---------------------------------------------------------------------------
    -- UI/theme
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
        opts = function() return require("plugins.oil") end,
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
    },

    ---------------------------------------------------------------------------
    -- LSP stack
    ---------------------------------------------------------------------------
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
        config = function() require("plugins.lsp") end,
    },

    ---------------------------------------------------------------------------
    -- Completion
    ---------------------------------------------------------------------------
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
        },
        config = function() require("plugins.cmp") end,
    },

    ---------------------------------------------------------------------------
    -- Treesitter
    ---------------------------------------------------------------------------
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        config = function() require("plugins.treesitter") end,
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
    -- Telescope
    ---------------------------------------------------------------------------
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope",
        event = "BufReadPre",
        config = function() require("plugins.telescope") end,
    },

    ---------------------------------------------------------------------------
    -- Git
    ---------------------------------------------------------------------------
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        opts = {},
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

    ---------------------------------------------------------------------------
    -- DAP (Debug Adapter Protocol)
    ---------------------------------------------------------------------------
    {
        "mfussenegger/nvim-dap",
        lazy = true,
        dependencies = {
            "jay-babu/mason-nvim-dap.nvim",
            "williamboman/mason.nvim",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require("plugins.dap")
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "codelldb" },
            automatic_installation = true,
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
    },

    ---------------------------------------------------------------------------
    -- Which-key
    ---------------------------------------------------------------------------
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
    },
}
