local mocha = require("catppuccin.palettes").get_palette "mocha"
require("catppuccin").setup({
    flavour = "mocha",             -- latte, frappe, macchiato, mocha
    transparent_background = true, -- disables setting the background color.
    show_end_of_buffer = false,    -- shows the '~' characters after the end of buffers

    term_colors = true,            -- sets terminal colors (e.g. `g:terminal_color_0`)
    integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        styles = {                   -- Handles the styles of general hi groups (see `:h highlight-args`):
            comments = { "italic" }, -- Change the style of comments
            conditionals = { "italic" },
            loops = {},
            functions = { "italic" },
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = { "italic" },
            types = {},
            operators = {},
            -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
    },
    custom_highlights = function(colors)
        return {
            LineNr = { fg = colors.text, style = {"italic"} },
        }
    end
})
vim.cmd.colorscheme "catppuccin"

-- -- Define the highlight group
-- vim.api.nvim_set_hl(0, "CustomType", { fg = "#ff9e64", italic = true, bold = true })

-- -- Link the Tree-sitter highlight group to your custom group
-- vim.cmd [[
--   highlight! link @property CustomType
-- ]]
