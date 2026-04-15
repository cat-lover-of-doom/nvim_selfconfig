local actions = require("telescope.actions")
local t = require("telescope")
t.setup({
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
