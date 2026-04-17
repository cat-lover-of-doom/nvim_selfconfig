return {
    {
        "echasnovski/mini.pairs",
        version = false,
        event = "InsertEnter",
        opts = {},
        config = function(_, opts)
            require("mini.pairs").setup(opts)
            vim.keymap.set("n", "<leader>op", function()
                vim.g.minipairs_disable = not vim.g.minipairs_disable
                vim.notify("Autopairs: " .. (vim.g.minipairs_disable and "OFF" or "ON"))
            end, { desc = "Option: toggle autopairs" })
        end,
    },
    {
        "echasnovski/mini.surround",
        version = false,
        event = "VeryLazy",
        opts = {
            mappings = {
                add = "<C-s>a",
                delete = "<C-s>d",
                find = "<C-s>f",
                find_left = "<C-s>F",
                highlight = "<C-s>h",
                replace = "<C-s>r",
                update_n_lines = "<C-s>n",
            },
        },
    },
}
