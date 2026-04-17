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
            { "<leader>0", desc = "[0-9] Switch buffer", icon = "󰯬", hidden = false },
            { "<leader>1", hidden = true },
            { "<leader>2", hidden = true },
            { "<leader>3", hidden = true },
            { "<leader>4", hidden = true },
            { "<leader>5", hidden = true },
            { "<leader>6", hidden = true },
            { "<leader>7", hidden = true },
            { "<leader>8", hidden = true },
            { "<leader>9", hidden = true },
            { "<leader>f", group = "Find", icon = " " },
            { "<leader>g", group = "Git", icon = "󰊢 " },
            { "<leader>l", group = "LSP", icon = " " },
            { "<leader>b", group = "Build", icon = " " },
            { "<leader>d", group = "Debug", icon = " " },
            { "<leader>q", group = "Quickfix", icon = " " },
            { "<leader>t", group = "Terminal", icon = " " },
            { "<leader>o", group = "Options", icon = " " },
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
