-- Lazy.nvim config file.

-- DESCRIPTION:
-- Use this file to configure the way you get updates.

--    Functions:
--      -> git_clone_lazy                → download lazy from git if necessary.
--      -> after_instaling_plugins_load  → instantly try to load the plugins passed.
--      -> get_lazy_spec                 → load and get the plugins file.
--      -> setup_lazy                    → pass the plugins file to lazy and run setup().
--
local updates_config = {
    channel = "stable",                -- 'nightly', or 'stable'
    snapshot_file = "lazy_snapshot.lua", -- plugins lockfile created by running the command ':DistroFreezePluginVersions' provided by `distroupdate.nvim`.
}

--- Download 'lazy' from its git repository if lazy_dir doesn't exists already.
--- Note: This function should ONLY run the first time you start nvim.
--- @param lazy_dir string Path to clone lazy into. Recommended: `<nvim data dir>/lazy/lazy.nvim`
local function git_clone_lazy(lazy_dir)
    local output = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazy_dir,
    })
    if vim.api.nvim_get_vvar("shell_error") ~= 0 then
        vim.api.nvim_echo(
            { { "Error cloning lazy.nvim repository...\n\n" .. output } },
            true, { err = true }
        )
    end
end

--- This functions creates a one time autocmd to load the plugins passed.
--- This is useful for plugins that will trigger their own update mechanism when loaded.
--- Note: This function should ONLY run the first time you start nvim.
--- @param plugins string[] plugins to load right after lazy end installing all.
local function after_installing_plugins_load(plugins)
    local oldcmdheight = vim.opt.cmdheight:get()
    vim.opt.cmdheight = 1
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyInstall",
        once = true,
        callback = function()
            vim.cmd.bw()
            vim.opt.cmdheight = oldcmdheight
            vim.tbl_map(function(module) pcall(require, module) end, plugins)
            -- Note: Loading mason and treesitter will trigger updates there too if necessary.
        end,
        desc = "Load Mason and Treesitter after Lazy installs plugins",
    })
end


--- load `<config_dir>/lua/lazy_snapshot.lua` and return it as table.
--- @return table spec A table you can pass to the `spec` option of lazy.
local function get_lazy_spec()
    local snapshot_filename = vim.fn.fnamemodify(updates_config.snapshot_file, ":t:r")
    local pin_plugins = updates_config.channel == "stable"
    local snapshot_file_exists = vim.uv.fs_stat(
        vim.fn.stdpath("config")
        .. "/lua/"
        .. snapshot_filename
        .. ".lua"
    )
    local spec = pin_plugins
        and snapshot_file_exists
        and { { import = snapshot_filename } }
        or {}
    vim.list_extend(spec, { { import = "plugins" } })

    return spec
end

--- Require lazy and pass the spec.
--- @param lazy_dir string used to specify neovim where to find the lazy_dir.
local function setup_lazy(lazy_dir)
    local spec = get_lazy_spec()

    vim.opt.rtp:prepend(lazy_dir)
    require("lazy").setup({
        spec = spec,
        defaults = { lazy = true },
        performance = {
            rtp = { -- Disable unnecessary nvim features to speed up startup.
                disabled_plugins = {
                    "tohtml",
                    "gzip",
                    "zipPlugin",
                    "tarPlugin",
                },
            },
        },
        -- Enable luarocks if installed.
        rocks = { enabled = vim.fn.executable("luarocks") == 1 },
        -- We don't use this, so create it in a disposable place.
        lockfile = vim.fn.stdpath("cache") .. "/lazy-lock.json",
    })
end

local lazy_dir = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local is_first_startup = not vim.uv.fs_stat(lazy_dir)

-- Call the functions defined above.
if is_first_startup then
    git_clone_lazy(lazy_dir)
    after_installing_plugins_load({ "nvim-treesitter", "mason" })
    vim.notify("Please wait while plugins are installed...")
end

-- PLUGINS
vim.opt.rtp:prepend(lazy_dir)
require("lazy").setup({
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
    {
        "preservim/vimux"
    },
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
        lazy = false,
    },
    "mbbill/undotree",
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "catppuccin/nvim", name = "catppuccin", priority = 1000
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        config = function()
            vim.api.nvim_create_autocmd({ "VimEnter" }, { command = "TSEnable highlight" })
            highlight = { enable = true }
        end,
    },
    "williamboman/mason-lspconfig.nvim",
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup {
                ensure_installed = {
                    "clangd",
                    "gopls",
                    "pylsp",
                    "lua_ls",
                    "cssls",
                    "eslint",
                    "html",
                },
            }
        end,
    },
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            'saadparwaiz1/cmp_luasnip',
            "rafamadriz/friendly-snippets",
        }
    },
    "tpope/vim-commentary",
})
