return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "c",
                "make",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "python",
                "go",
                "gomod",
                "gosum",
                "html",
                "css",
                "javascript",
                "json",
                "sql",
                "csv",
                "bash",
            },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}
