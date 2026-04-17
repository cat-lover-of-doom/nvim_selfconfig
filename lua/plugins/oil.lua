return {
    {
        "stevearc/oil.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function(_, opts)
            require("oil").setup(opts)
            vim.keymap.set("n", "<leader>s", "<cmd>Oil<CR>", { desc = "Files: explorer" })
        end,
        opts = {
            default_file_explorer = true,
            skip_confirm_for_simple_edits = true,
            delete_to_trah = true,
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
    },
}
