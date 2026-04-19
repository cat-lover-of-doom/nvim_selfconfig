return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function(_, opts)
        require("which-key").setup(opts)
        vim.keymap.set("n", "<leader>h", ":WhichKey<CR>", { desc = "Show help" })
    end,
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
        spec = {
            { "<leader>f", group = "Find", icon = "󰈞 " },
            { "<leader>g", group = "Git", icon = "󰊢 " },
            { "<leader>l", group = "LSP", icon = " " },
            { "<leader>b", group = "Build", icon = " " },
            { "<leader>d", group = "Debug", icon = " " },
            { "<leader>q", group = "Quickfix", icon = "󰁨 " },
            { "<leader>t", group = "Terminal", icon = " " },
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
