return {
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
    {
        "preservim/vimux"
    },
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
        lazy = false,
    },
    "mbbill/undotree",
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "catppuccin/nvim", name = "catppuccin", priority = 1000
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        config = function()
            vim.api.nvim_create_autocmd({ "VimEnter" }, { command = "TSEnable highlight" })
            highlight = { enable = true }
        end,
    },
    "williamboman/mason-lspconfig.nvim",
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup {
                ensure_installed = {
                    "clangd",
                    "gopls",
                    "pylsp",
                    "lua_ls",
                    "cssls",
                    "eslint",
                    "html",
                },
            }
        end,
        lazy=false,
    },
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            'saadparwaiz1/cmp_luasnip',
            "rafamadriz/friendly-snippets",
        }
    },
    "tpope/vim-commentary",
}
