return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    event = "BufReadPre",
    config = function()
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-s>"] = actions.close,
                        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
                    },
                    n = {
                        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
                    },
                },
            },
            pickers = {
                find_files = { hidden = true },
            },
        })

        local function naive_live_grep()
            local q = vim.fn.input("Grep > "); if q == "" then return end
            vim.cmd("silent vimgrep /" .. q .. "/gj **/*"); vim.cmd("copen")
        end

        vim.keymap.set("n", "<leader>fj", function() builtin.find_files({ hidden = false, file_ignore_patterns = { "%.o$" } }) end, { desc = "Search: files" })
        vim.keymap.set("n", "<leader>fF", function() builtin.find_files({ hidden = true }) end, { desc = "Search: files (hidden)" })
        vim.keymap.set("n", "<leader>fg", function() builtin.live_grep() end, { desc = "Search: live grep" })
        vim.keymap.set("n", "<leader>fb", function() builtin.buffers() end, { desc = "Search: buffers" })
        vim.keymap.set("n", "<leader>fr", function() builtin.resume() end, { desc = "Search: resume last" })
        vim.keymap.set("n", "<leader>fw", function() builtin.grep_string() end, { desc = "Search: word under cursor" })
        vim.keymap.set("n", "<leader>f/", function() builtin.current_buffer_fuzzy_find() end, { desc = "Search: current buffer" })
        vim.keymap.set("n", "<leader>fo", function() builtin.oldfiles() end, { desc = "Search: recent files" })
        vim.keymap.set("n", "<leader>fk", function() builtin.keymaps() end, { desc = "Search: keymaps" })
        vim.keymap.set("n", "<leader>fh", function() builtin.help_tags() end, { desc = "Search: help tags" })
        vim.keymap.set("n", "<leader>fm", function() builtin.marks() end, { desc = "Search: marks" })
        vim.keymap.set("n", "<leader>f\"", function() builtin.registers() end, { desc = "Search: registers" })
        vim.keymap.set("n", "<leader>gc", function() builtin.git_commits() end, { desc = "Git: commits" })
        vim.keymap.set("n", "<leader>gC", function() builtin.git_bcommits() end, { desc = "Git: buffer commits" })
        vim.keymap.set("n", "<leader>gS", function() builtin.git_status() end, { desc = "Git: status" })
    end,
}
