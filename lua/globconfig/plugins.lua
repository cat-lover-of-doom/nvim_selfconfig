-- PLUGINS
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {modes = { search = {enabled = false}, char = {enabled = true, autohide = true, jump_labels = true,}}}
    },
    "mbbill/undotree",
    { 
    {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    "catppuccin/nvim", name = "catppuccin", priority = 1000 
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        config = function()
        vim.api.nvim_create_autocmd({"VimEnter"}, {command = "TSEnable highlight"})

        highlight = {enable = true} 
        end,
    },
    "williamboman/mason-lspconfig.nvim",
    {"williamboman/mason.nvim",  
        config = function()
        require("mason").setup()
        require("mason-lspconfig").setup{
                ensure_installed = { "clangd", "gopls", "pylsp",},
        }
        end,
        },
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp", 
    "hrsh7th/cmp-nvim-lsp",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
})
