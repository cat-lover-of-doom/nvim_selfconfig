-- Lazy.nvim config file.

-- DESCRIPTION:
-- Use this file to configure the way you get updates.

--    Functions:
--      -> git_clone_lazy                → download lazy from git if necessary.
--      -> after_instaling_plugins_load  → instantly try to load the plugins passed.



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

local lazy_dir = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local is_first_startup = not vim.uv.fs_stat(lazy_dir)

-- Call the functions defined above.
if is_first_startup then
    git_clone_lazy(lazy_dir)
    after_installing_plugins_load({ "nvim-treesitter", "mason" })
    vim.notify("Please wait while plugins are installed...")
end

vim.opt.rtp:prepend(lazy_dir)
require("lazy").setup({
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
    spec = { { import = "4-plugins" } },
})
