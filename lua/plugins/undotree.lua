return {
    "mbbill/undotree",
    event = "BufEnter",
    init = function()
        vim.g.undotree_SetFocusWhenToggle = 1
        vim.g.undotree_WindowLayout = 2
        vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "undotree toggle" })
    end,
}
