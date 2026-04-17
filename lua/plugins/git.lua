return {
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        opts = {},
        init = function()
            vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen<CR>", { desc = "Git: diffview open" })
            vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", { desc = "Git: file history" })
            vim.keymap.set("n", "<leader>gF", "<cmd>DiffviewFileHistory<CR>", { desc = "Git: branch history" })
            vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<CR>", { desc = "Git: diffview close" })
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
            local gs = require("gitsigns")
            gs.setup(opts)
            vim.keymap.set("n", "<leader>gn", gs.next_hunk, { desc = "Git: next hunk" })
            vim.keymap.set("n", "<leader>gN", gs.prev_hunk, { desc = "Git: prev hunk" })
            vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Git: preview hunk" })
            vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Git: reset hunk" })
            vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Git: stage hunk" })
            vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Git: undo stage" })
            vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Git: toggle blame" })
        end,
    },
}
