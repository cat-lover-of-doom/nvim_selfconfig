local utils = require("utils")
local utils_lsp = require("utils.lsp")
return {
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
        config = function()
            require("oil").setup({
                default_file_explorer = true,
                delete_to_trash = true,
                skip_confirm_for_simple_edits = true,
                view_options = {
                    -- Show files and directories that start with "."
                    show_hidden = true,
                    natural_order = true,
                    is_always_hidden = function(name, bufnr)
                        return name == ".." or name == ".git" or name == ".DS_Store"
                    end,
                    win_options = {
                        wrap = true,
                        signcolumn = "yes",
                    }
                },
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<CR>"] = "actions.select",
                    ["|"] = { "actions.select", opts = { vertical = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = { "actions.close", mode = "n" },
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = { "actions.parent", mode = "n" },
                    ["_"] = { "actions.open_cwd", mode = "n" },
                    ["`"] = { "actions.cd", mode = "n" },
                    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                    ["gs"] = { "actions.change_sort", mode = "n" },
                    ["gx"] = "actions.open_external",
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["g\\"] = { "actions.toggle_trash", mode = "n" },
                },
                -- Set to false to disable all of the above keymaps
                use_default_keymaps = false,
            })
        end
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
        -- No opts or config needed! Works automatically
    },
    {
        "chrishrb/gx.nvim",
        keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
        cmd = { "Browse" },
        init = function()
            vim.g.netrw_nogx = 1                    -- disable netrw gx
        end,
        dependencies = { "nvim-lua/plenary.nvim" }, -- Required for Neovim < 0.10.0
        config = true,                              -- default settings
        submodules = false,                         -- not needed, submodules are required only for tests
    },

    -- project.nvim [project search + auto cd]
    -- https://github.com/ahmedkhalf/project.nvim
    {
        "zeioth/project.nvim",
        event = "User defered",
        cmd = "ProjectRoot",
        opts = {
            -- How to find root directory
            patterns = {
                ".git",
                "_darcs",
                ".hg",
                ".bzr",
                ".svn",
                "Makefile",
                "package.json",
                ".solution",
                ".solution.toml"
            },
            -- Don't list the next projects
            exclude_dirs = {
                "~/"
            },
            silent_chdir = true,
            manual_mode = false,

            -- Don't chdir for certain buffers
            exclude_chdir = {
                filetype = { "", "OverseerList", "alpha" },
                buftype = { "nofile", "terminal" },
            },

            --ignore_lsp = { "lua_ls" },
        },
        config = function(_, opts) require("project_nvim").setup(opts) end,
    },

    -- trim.nvim [auto trim spaces]
    -- https://github.com/cappyzawa/trim.nvim
    {
        "cappyzawa/trim.nvim",
        event = "BufWrite",
        opts = {
            trim_on_write = true,
            trim_trailing = true,
            trim_last_line = false,
            trim_first_line = false,
            -- ft_blocklist = { "markdown", "text", "org", "tex", "asciidoc", "rst" },
            -- patterns = {[[%s/\(\n\n\)\n\+/\1/]]}, -- Only one consecutive bl
        },
    },

    -- stickybuf.nvim [lock special buffers]
    -- https://github.com/arnamak/stay-centered.nvim
    -- By default it support neovim/aerial and others.
    {
        "stevearc/stickybuf.nvim",
        event = "User efered",
        config = function() require("stickybuf").setup() end
    },

    --  smart-splits [move and resize buffers]
    --  https://github.com/mrjones2014/smart-splits.nvim
    {
        "mrjones2014/smart-splits.nvim",
        event = "User ile",
        opts = {
            ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
            ignored_buftypes = { "nofile" },
        },
    },

    -- session-manager [session]
    -- https://github.com/Shatur/neovim-session-manager
    {
        "Shatur/neovim-session-manager",
        event = "User efered",
        cmd = "SessionManager",
        opts = function()
            local config = require('session_manager.config')
            return {
                autoload_mode = config.AutoloadMode.Disabled,
                autosave_last_session = false,
                autosave_only_in_session = false,
            }
        end,
        config = function(_, opts)
            local session_manager = require('session_manager')
            session_manager.setup(opts)

            -- Auto save session
            -- BUG: This feature will auto-close anything nofile before saving.
            --      This include neotree, aerial, mergetool, among others.
            --      Consider commenting the next block if this is important for you.
            --
            --      This won't be necessary once neovim fixes:
            --      https://github.com/neovim/neovim/issues/12242
            -- vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
            --   callback = function ()
            --     session_manager.save_current_session()
            --   end
            -- })
        end
    },

    -- spectre.nvim [search and replace in project]
    -- https://github.com/nvim-pack/nvim-spectre
    -- INSTRUCTIONS:
    -- To see the instructions press '?'
    -- To start the search press <ESC>.
    -- It doesn't have ctrl-z so please always commit before using it.
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        opts = {
            default = {
                find = {
                    -- pick one of item in find_engine [ fd, rg ]
                    cmd = "fd",
                    options = {}
                },
                replace = {
                    -- pick one of item in [ sed, oxi ]
                    cmd = "sed"
                },
            },
            is_insert_mode = true,    -- start open panel on is_insert_mode
            is_block_ui_break = true, -- prevent the UI from breaking
            mapping = {
                ["toggle_line"] = {
                    map = "d",
                    cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
                    desc = "toggle item.",
                },
                ["enter_file"] = {
                    map = "<cr>",
                    cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
                    desc = "open file.",
                },
                ["send_to_qf"] = {
                    map = "sqf",
                    cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                    desc = "send all items to quickfix.",
                },
                ["replace_cmd"] = {
                    map = "src",
                    cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
                    desc = "replace command.",
                },
                ["show_option_menu"] = {
                    map = "so",
                    cmd = "<cmd>lua require('spectre').show_options()<CR>",
                    desc = "show options.",
                },
                ["run_current_replace"] = {
                    map = "c",
                    cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
                    desc = "confirm item.",
                },
                ["run_replace"] = {
                    map = "R",
                    cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
                    desc = "replace all.",
                },
                ["change_view_mode"] = {
                    map = "sv",
                    cmd = "<cmd>lua require('spectre').change_view()<CR>",
                    desc = "results view mode.",
                },
                ["change_replace_sed"] = {
                    map = "srs",
                    cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
                    desc = "use sed to replace.",
                },
                ["change_replace_oxi"] = {
                    map = "sro",
                    cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
                    desc = "use oxi to replace.",
                },
                ["toggle_live_update"] = {
                    map = "sar",
                    cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
                    desc = "auto refresh changes when nvim writes a file.",
                },
                ["resume_last_search"] = {
                    map = "sl",
                    cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
                    desc = "repeat last search.",
                },
                ["insert_qwerty"] = {
                    map = "i",
                    cmd = "<cmd>startinsert<CR>",
                    desc = "insert (qwerty).",
                },
                ["insert_colemak"] = {
                    map = "o",
                    cmd = "<cmd>startinsert<CR>",
                    desc = "insert (colemak).",
                },
                ["quit"] = {
                    map = "q",
                    cmd = "<cmd>lua require('spectre').close()<CR>",
                    desc = "quit.",
                },
            },
        },
    },

    -- [neotree]
    -- https://github.com/nvim-neo-tree/neo-tree.nvim
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = "MunifTanjim/nui.nvim",
        cmd = "Neotree",
        opts = function()
            vim.g.neo_tree_remove_legacy_commands = true
            local get_icon = utils.get_icon
            return {
                auto_clean_after_session_restore = true,
                close_if_last_window = true,
                buffers = {
                    show_unloaded = true
                },
                sources = { "filesystem", "buffers", "git_status" },
                source_selector = {
                    winbar = true,
                    content_layout = "center",
                    sources = {
                        {
                            source = "filesystem",
                            display_name = get_icon("FolderClosed", true) .. " File",
                        },
                        {
                            source = "buffers",
                            display_name = get_icon("DefaultFile", true) .. " Bufs",
                        },
                        {
                            source = "git_status",
                            display_name = get_icon("Git", true) .. " Git",
                        },
                        {
                            source = "diagnostics",
                            display_name = get_icon("Diagnostic", true) .. " Diagnostic",
                        },
                    },
                },
                default_component_configs = {
                    indent = { padding = 0 },
                    icon = {
                        folder_closed = get_icon("FolderClosed"),
                        folder_open = get_icon("FolderOpen"),
                        folder_empty = get_icon("FolderEmpty"),
                        folder_empty_open = get_icon("FolderEmpty"),
                        default = get_icon("DefaultFile"),
                    },
                    modified = { symbol = get_icon("FileModified") },
                    git_status = {
                        symbols = {
                            added = get_icon("GitAdd"),
                            deleted = get_icon("GitDelete"),
                            modified = get_icon("GitChange"),
                            renamed = get_icon("GitRenamed"),
                            untracked = get_icon("GitUntracked"),
                            ignored = get_icon("GitIgnored"),
                            unstaged = get_icon("GitUnstaged"),
                            staged = get_icon("GitStaged"),
                            conflict = get_icon("GitConflict"),
                        },
                    },
                },
                -- A command is a function that we can assign to a mapping (below)
                commands = {
                    system_open = function(state)
                        require("utils").open_with_program(state.tree:get_node():get_id())
                    end,
                    parent_or_close = function(state)
                        local node = state.tree:get_node()
                        if
                            (node.type == "directory" or node:has_children())
                            and node:is_expanded()
                        then
                            state.commands.toggle_node(state)
                        else
                            require("neo-tree.ui.renderer").focus_node(
                                state,
                                node:get_parent_id()
                            )
                        end
                    end,
                    child_or_open = function(state)
                        local node = state.tree:get_node()
                        if node.type == "directory" or node:has_children() then
                            if not node:is_expanded() then -- if unexpanded, expand
                                state.commands.toggle_node(state)
                            else                           -- if expanded and has children, seleect the next child
                                require("neo-tree.ui.renderer").focus_node(
                                    state,
                                    node:get_child_ids()[1]
                                )
                            end
                        else -- if not a directory just open it
                            state.commands.open(state)
                        end
                    end,
                    copy_selector = function(state)
                        local node = state.tree:get_node()
                        local filepath = node:get_id()
                        local filename = node.name
                        local modify = vim.fn.fnamemodify

                        local results = {
                            e = { val = modify(filename, ":e"), msg = "Extension only" },
                            f = { val = filename, msg = "Filename" },
                            F = {
                                val = modify(filename, ":r"),
                                msg = "Filename w/o extension",
                            },
                            h = {
                                val = modify(filepath, ":~"),
                                msg = "Path relative to Home",
                            },
                            p = {
                                val = modify(filepath, ":."),
                                msg = "Path relative to CWD",
                            },
                            P = { val = filepath, msg = "Absolute path" },
                        }

                        local messages = {
                            { "\nChoose to copy to clipboard:\n", "Normal" },
                        }
                        for i, result in pairs(results) do
                            if result.val and result.val ~= "" then
                                vim.list_extend(messages, {
                                    { ("%s."):format(i),           "Identifier" },
                                    { (" %s: "):format(result.msg) },
                                    { result.val,                  "String" },
                                    { "\n" },
                                })
                            end
                        end
                        vim.api.nvim_echo(messages, false, {})
                        local result = results[vim.fn.getcharstr()]
                        if result and result.val and result.val ~= "" then
                            vim.notify("Copied: " .. result.val)
                            vim.fn.setreg("+", result.val)
                        end
                    end,
                    find_in_dir = function(state)
                        local node = state.tree:get_node()
                        local path = node:get_id()
                        require("telescope.builtin").find_files {
                            cwd = node.type == "directory" and path
                                or vim.fn.fnamemodify(path, ":h"),
                        }
                    end,
                },
                window = {
                    width = 30,
                    mappings = {
                        ["<space>"] = false,
                        ["<S-CR>"] = "system_open",
                        ["[b"] = "prev_source",
                        ["]b"] = "next_source",
                        F = "find_in_dir",
                        O = "system_open",
                        Y = "copy_selector",
                        h = "parent_or_close",
                        l = "child_or_open",
                    },
                },
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                    },
                    use_libuv_file_watcher = true,
                },
                event_handlers = {
                    {
                        event = "neo_tree_buffer_enter",
                        handler = function(_)
                            vim.opt_local.signcolumn = "auto"
                            vim.cmd [[setlocal relativenumber]]
                        end,
                    },
                },
            }
        end,
    },

    --  code [folding mod] + [promise-asyn] dependency
    --  https://github.com/kevinhwang91/nvim-ufo
    --  https://github.com/kevinhwang91/promise-async
    {
        "kevinhwang91/nvim-ufo",
        event = { "User ile" },
        dependencies = { "kevinhwang91/promise-async" },
        opts = {
            preview = {
                mappings = {
                    scrollB = "<C-b>",
                    scrollF = "<C-f>",
                    scrollU = "<C-u>",
                    scrollD = "<C-d>",
                },
            },
            provider_selector = function(_, filetype, buftype)
                local function handleFallbackException(bufnr, err, providerName)
                    if type(err) == "string" and err:match "UfoFallbackException" then
                        return require("ufo").getFolds(bufnr, providerName)
                    else
                        return require("promise").reject(err)
                    end
                end

                -- only use indent until a file is opened
                return (filetype == "" or buftype == "nofile") and "indent"
                    or function(bufnr)
                        return require("ufo")
                            .getFolds(bufnr, "lsp")
                            :catch(
                                function(err)
                                    return handleFallbackException(bufnr, err, "treesitter")
                                end
                            )
                            :catch(
                                function(err)
                                    return handleFallbackException(bufnr, err, "indent")
                                end
                            )
                    end
            end,
        },
    },

    --  nvim-neoclip [nvim clipboard]
    --  https://github.com/AckslD/nvim-neoclip.lua
    --  Read their docs to enable cross-session history.
    {
        "AckslD/nvim-neoclip.lua",
        requires = 'nvim-telescope/telescope.nvim',
        event = "User ile",
        opts = {}
    },

    --  vim-matchup [improved % motion]
    --  https://github.com/andymass/vim-matchup
    {
        "andymass/vim-matchup",
        event = "User ile",
        config = function()
            vim.g.matchup_matchparen_deferred = 1   -- work async
            vim.g.matchup_matchparen_offscreen = {} -- disable status bar icon
        end,
    },

    --  hop.nvim [go to word visually]
    --  https://github.com/smoka7/hop.nvim
    {
        "smoka7/hop.nvim",
        cmd = { "HopWord" },
        opts = { keys = "etovxqpdygfblzhckisuran" }
    },

    --  nvim-autopairs [auto close brackets]
    --  https://github.com/windwp/nvim-autopairs
    --  It's disabled by default, you can enable it with <space>ua
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        dependencies = "windwp/nvim-ts-autotag",
        opts = {
            check_ts = true,
            ts_config = { java = false },
            fast_wrap = {
                map = "<M-e>",
                chars = { "{", "[", "(", '"', "'" },
                pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
                offset = 0,
                end_key = "$",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma = true,
                highlight = "PmenuSel",
                highlight_grey = "LineNr",
            },
        },
        config = function(_, opts)
            local npairs = require("nvim-autopairs")
            npairs.setup(opts)
            if not vim.g.autopairs_enabled then npairs.disable() end

            local is_cmp_loaded, cmp = pcall(require, "cmp")
            if is_cmp_loaded then
                cmp.event:on(
                    "confirm_done",
                    require("nvim-autopairs.completion.cmp").on_confirm_done {
                        tex = false }
                )
            end
        end
    },

    -- nvim-ts-autotag [auto close html tags]
    -- https://github.com/windwp/nvim-ts-autotag
    -- Adds support for HTML tags to the plugin nvim-autopairs.
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "windwp/nvim-autopairs"
        },
        opts = {}
    },

    -- lsp_signature.nvim [auto params help]
    -- https://github.com/ray-x/lsp_signature.nvim
    {
        "ray-x/lsp_signature.nvim",
        event = "User ile",
        opts = function()
            -- Apply globals from 1-options.lua
            local is_enabled = vim.g.lsp_signature_enabled
            local round_borders = {}
            if vim.g.lsp_round_borders_enabled then
                round_borders = { border = 'rounded' }
            end
            return {
                -- Window mode
                floating_window = is_enabled, -- Display it as floating window.
                hi_parameter = "IncSearch",   -- Color to highlight floating window.
                handler_opts = round_borders, -- Window style

                -- Hint mode
                hint_enable = false, -- Display it as hint.
                hint_prefix = "👈 ",

                -- Additionally, you can use <space>uH to toggle inlay hints.
                toggle_key_flip_floatwin_setting = is_enabled
            }
        end,
        config = function(_, opts) require('lsp_signature').setup(opts) end
    },

    -- nvim-lightbulb [lightbulb for code actions]
    -- https://github.com/kosayoda/nvim-lightbulb
    -- Show a lightbulb where a code action is available
    {
        'kosayoda/nvim-lightbulb',
        enabled = vim.g.codeactions_enabled,
        event = "User ile",
        opts = {
            action_kinds = { -- show only for relevant code actions.
                "quickfix",
            },
            ignore = {
                ft = { "lua", "markdown" }, -- ignore filetypes with bad code actions.
            },
            autocmd = {
                enabled = true,
                updatetime = 100,
            },
            sign = { enabled = false },
            virtual_text = {
                enabled = true,
                text = require("utils").get_icon("Lightbulb")
            }
        },
        config = function(_, opts) require("nvim-lightbulb").setup(opts) end
    },

    --- 222222222222222222222222
    --  tokyonight [theme]
    --  https://github.com/folke/tokyonight.nvim
    {
        "folke/tokyonight.nvim",
        event = "User LoadColorSchemes",
        opts = {
            dim_inactive = false,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
            },
        }
    },

    --  astrotheme [theme]
    --  https://github.com/AstroNvim/astrotheme
    {
        "AstroNvim/astrotheme",
        event = "User LoadColorSchemes",
        opts = {
            palette = "astrodark",
            plugins = { ["dashboard-nvim"] = true },
        },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "auto", -- latte, frappe, macchiato, mocha
            transparent_background = true, -- disables setting the background color.
            float = {
                transparent = true,        -- enable transparent floating windows
            },
            styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { "italic" },    -- Change the style of comments
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = { "bold" },
                operators = {},
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
        end,
    },
    --  morta [theme]
    --  https://github.com/ssstba/morta.nvim
    {
        "philosofonusus/morta.nvim",
        event = "User LoadColorSchemes",
        opts = {}
    },

    --  eldritch [theme]
    --  https://github.com/eldritch-theme/eldritch.nvim
    {
        "eldritch-theme/eldritch.nvim",
        event = "User LoadColorSchemes",
        opts = {}
    },

    --  alpha-nvim [greeter]
    --  https://github.com/goolord/alpha-nvim
    {
        "goolord/alpha-nvim",
        cmd = "Alpha",
        -- setup header and buttonts
        opts = function()
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                [[888b      88                                                           88]],
                [[8888b     88                                                           88]],
                [[88 `8b    88                                                           88]],
                [[88  `8b   88   ,adPPYba,   8b,dPPYba,  88,dPYba,,adPYba,   ,adPPYYba,  88]],
                [[88   `8b  88  a8"     "8a  88P'   "Y8  88P'   "88"    "8a  ""     `Y8  88]],
                [[88    `8b 88  8b       d8  88          88      88      88  ,adPPPPP88  88]],
                [[88     `8888  "8a,   ,a8"  88          88      88      88  88,    ,88  88]],
                [[88      `888   `"YbbdP"'   88          88      88      88  `"8bbdP"Y8  88]],
                [[                                                    ]],
                [[                       .------.------.------.------.]],
                [[                       |C.--. |L.--. |O.--. |D.--. |]],
                [[                       | :/\: | : .: | :/\: | :. : |]],
                [[                       | :\/: | :. : | :\/: | : .: |]],
                [[                       | '--'C| '--'L| '--'O| '--'D|]],
                [[                       `------`------`------`------']],
            }


            local get_icon = require("utils").get_icon

            dashboard.section.header.opts.hl = "DashboardHeader"
            vim.cmd("highlight DashboardHeader guifg=#F7778F")

            -- Buttons
            dashboard.section.buttons.val = {
                dashboard.button("n",
                    get_icon("GreeterNew") .. "  New",
                    "<cmd>ene<CR>"),
                dashboard.button("r",
                    get_icon("GreeterRecent") .. "  Recent  ",
                    "<cmd>Telescope oldfiles<CR>"),
                dashboard.button("s",
                    get_icon("GreeterOil") .. "  Oil",
                    "<cmd>Oil<CR><CMD>Neotree action=show<CR>"),
                dashboard.button("c",
                    get_icon("GreeterSessions") .. "  Sessions",
                    "<cmd>SessionManager! load_session<CR>"
                ),
                dashboard.button("p",
                    get_icon("GreeterProjects") .. "  Projects",
                    "<cmd>Telescope projects<CR>"),
                dashboard.button("", ""),
                dashboard.button("q", "   Quit", "<cmd>exit<CR>"),
            }

            -- Vertical margins
            dashboard.config.layout[1].val =
                vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.10) } -- Above header
            dashboard.config.layout[3].val =
                vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.10) } -- Above buttons

            -- Disable autocmd and return
            dashboard.config.opts.noautocmd = true
            return dashboard
        end,
        config = function(_, opts)
            -- Footer
            require("alpha").setup(opts.config)
            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                desc = "Add Alpha dashboard footer",
                once = true,
                callback = function()
                    local footer_icon = require("utils").get_icon("GreeterPlug")
                    local stats = require("lazy").stats()
                    stats.real_cputime = true
                    local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
                    opts.section.footer.val = {
                        " ",
                        " ",
                        " ",
                        "Loaded " .. stats.loaded .. " plugins " .. footer_icon .. " in " .. ms .. "ms",
                        ".............................",
                    }
                    opts.section.footer.opts.hl = "DashboardFooter"
                    vim.cmd("highlight DashboardFooter guifg=#D29B68")
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },

    --  [notifications]
    --  https://github.com/rcarriga/nvim-notify
    {
        "rcarriga/nvim-notify",
        event = "User BaseDefered",
        opts = function()
            return {
                background_colour = "#000000",
                timeout = 2500,
                fps = 60,
                max_height = function() return math.floor(vim.o.lines * 0.75) end,
                max_width = function() return math.floor(vim.o.columns * 0.75) end,
                on_open = function(win)
                    -- enable markdown support on notifications
                    vim.api.nvim_win_set_config(win, { zindex = 175 })
                    if not vim.g.notifications_enabled then
                        vim.api.nvim_win_close(win, true)
                    end
                    if not package.loaded["nvim-treesitter"] then
                        pcall(require, "nvim-treesitter")
                    end
                    vim.wo[win].conceallevel = 3
                    local buf = vim.api.nvim_win_get_buf(win)
                    if not pcall(vim.treesitter.start, buf, "markdown") then
                        vim.bo[buf].syntax = "markdown"
                    end
                    vim.wo[win].spell = false
                end,
            }
        end,
        config = function(_, opts)
            local notify = require("notify")
            notify.setup(opts)
            vim.notify = notify
        end,
    },

    --  mini.indentscope [guides]
    --  https://github.com/echasnovski/mini.indentscope
    {
        "echasnovski/mini.indentscope",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            draw = { delay = 0, animation = function() return 0 end },
            options = { border = "top", try_as_border = true },
            symbol = "▏",
        },
        config = function(_, opts)
            require("mini.indentscope").setup(opts)

            -- Disable for certain filetypes
            vim.api.nvim_create_autocmd({ "FileType" }, {
                desc = "Disable indentscope for certain filetypes",
                callback = function()
                    local ignored_filetypes = {
                        "aerial",
                        "dashboard",
                        "help",
                        "lazy",
                        "leetcode.nvim",
                        "mason",
                        "neo-tree",
                        "NvimTree",
                        "neogitstatus",
                        "notify",
                        "startify",
                        "toggleterm",
                        "Trouble",
                        "calltree",
                        "coverage"
                    }
                    if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
                        vim.b.miniindentscope_disable = true
                    end
                end,
            })
        end
    },

    -- heirline-components.nvim [ui components]
    -- https://github.com/zeioth/heirline-components.nvim
    -- Collection of components to use on your heirline config.
    {
        "zeioth/heirline-components.nvim",
        opts = function()
            -- return different items depending of the value of `vim.g.fallback_icons_enabled`
            local function get_icons()
                if vim.g.fallback_icons_enabled then
                    return require("icons.fallback_icons")
                else
                    return require("icons.icons")
                end
            end

            -- opts
            return {
                icons = get_icons(),
            }
        end
    },

    --  heirline [ui components]
    --  https://github.com/rebelot/heirline.nvim
    --  Use it to customize the components of your user interface,
    --  Including tabline, winbar, statuscolumn, statusline.
    --  Be aware some components are positional. Read heirline documentation.
    {
        "rebelot/heirline.nvim",
        dependencies = { "zeioth/heirline-components.nvim" },
        event = "User BaseDefered",
        opts = function()
            local lib = require("heirline-components.all")
            return {
                opts = {
                    disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
                        local is_disabled = not require("heirline-components.buffer").is_valid(args.buf) or
                            lib.condition.buffer_matches({
                                buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                                filetype = {
                                    "NvimTree",
                                    "neo%-tree",
                                    "dashboard",
                                    "Outline",
                                    "aerial",
                                    "rnvimr",
                                },
                            }, args.buf)
                        return is_disabled
                    end,
                },
                tabline = { -- UI upper bar
                    lib.component.tabline_conditional_padding(),
                    lib.component.tabline_buffers(),
                    lib.component.fill { hl = { bg = "tabline_bg" } },
                    lib.component.tabline_tabpages()
                },
                statuscolumn = { -- UI left column
                    init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
                    lib.component.foldcolumn(),
                    lib.component.numbercolumn(),
                    lib.component.signcolumn(),
                } or nil,
                statusline = { -- UI statusbar
                    hl = { fg = "fg", bg = "bg" },
                    lib.component.mode(),
                    lib.component.git_branch(),
                    lib.component.file_info(),
                    lib.component.git_diff(),
                    lib.component.diagnostics(),
                    lib.component.fill(),
                    lib.component.cmd_info(),
                    lib.component.fill(),
                    lib.component.lsp(),
                    lib.component.compiler_state(),
                    lib.component.virtual_env(),
                    lib.component.nav(),
                    lib.component.mode { surround = { separator = "right" } },
                },
            }
        end,
        config = function(_, opts)
            local heirline = require("heirline")
            local heirline_components = require "heirline-components.all"

            -- Setup
            heirline_components.init.subscribe_to_events()
            heirline.load_colors(heirline_components.hl.get_colors())
            heirline.setup(opts)
        end,
    },

    --  Telescope [search] + [search backend] dependency
    --  https://github.com/nvim-telescope/telescope.nvim
    --  https://github.com/nvim-telescope/telescope-fzf-native.nvim
    --  https://github.com/debugloop/telescope-undo.nvim
    --  NOTE: Normally, plugins that depend on Telescope are defined separately.
    --  But its Telescope extension is added in the Telescope 'config' section.
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                enabled = vim.fn.executable("make") == 1,
                build = "make",
            },
        },
        cmd = "Telescope",
        opts = function()
            local get_icon = require("utils").get_icon
            local actions = require("telescope.actions")
            local mappings = {
                i = {
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                    ["<ESC>"] = actions.close,
                    ["<C-c>"] = false,
                },
                n = { ["q"] = actions.close },
            }
            return {
                defaults = {
                    prompt_prefix = get_icon("PromptPrefix") .. " ",
                    selection_caret = get_icon("PromptPrefix") .. " ",
                    multi_icon = get_icon("PromptPrefix") .. " ",
                    path_display = { "truncate" },
                    sorting_strategy = "ascending",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.50,
                        },
                        vertical = {
                            mirror = false,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    mappings = mappings,
                },
            }
        end,
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            -- Here we define the Telescope extension for all plugins.
            -- If you delete a plugin, you can also delete its Telescope extension.
            telescope.load_extension("notify")
            telescope.load_extension("fzf")
            telescope.load_extension("projects")
            telescope.load_extension("luasnip")
            telescope.load_extension("aerial")
            --- neoclip extensions
            telescope.load_extension("neoclip")
            telescope.load_extension("macroscope")
        end,
    },

    --  [better ui elements]
    --  https://github.com/stevearc/dressing.nvim
    {
        "stevearc/dressing.nvim",
        event = "User BaseDefered",
        opts = {
            input = { default_prompt = "➤ " },
            select = { backend = { "telescope", "builtin" } },
        }
    },

    --  Noice.nvim [better cmd/search line]
    --  https://github.com/folke/noice.nvim
    --  We use it for:
    --  * cmdline: Display treesitter for :
    --  * search: Display a magnifier instead of /
    --
    --  We don't use it for:
    --  * LSP status: We use a heirline component for this.
    --  * Search results: We use a heirline component for this.
    {
        "folke/noice.nvim",
        event = "User BaseDefered",
        opts = function()
            local enable_conceal = false            -- Hide command text if true
            return {
                presets = { bottom_search = true }, -- The kind of popup used for /
                cmdline = {
                    view = "cmdline",               -- The kind of popup used for :
                    format = {
                        cmdline = { conceal = enable_conceal },
                        search_down = { conceal = enable_conceal },
                        search_up = { conceal = enable_conceal },
                        filter = { conceal = enable_conceal },
                        lua = { conceal = enable_conceal },
                        help = { conceal = enable_conceal },
                        input = { conceal = enable_conceal },
                    }
                },

                -- Disable every other noice feature
                messages = { enabled = false },
                lsp = {
                    hover = { enabled = false },
                    signature = { enabled = false },
                    progress = { enabled = false },
                    message = { enabled = false },
                    smart_move = { enabled = false },
                },
            }
        end
    },

    --  UI icons [icons - ui]
    --  https://github.com/nvim-tree/nvim-web-devicons
    {
        "nvim-tree/nvim-web-devicons",
        enabled = not vim.g.fallback_icons_enabled,
        event = "User BaseDefered",
        opts = {
            override = {
                default_icon = {
                    icon = require("utils").get_icon("DefaultFile")
                },
            },
        },
    },

    --  LSP icons [icons | lsp]
    --  https://github.com/onsails/lspkind.nvim
    {
        "onsails/lspkind.nvim",
        enabled = not vim.g.fallback_icons_enabled,
        opts = {
            mode = "symbol",
            symbol_map = {
                Array = "󰅪",
                Boolean = "⊨",
                Class = "󰌗",
                Constructor = "",
                Copilot = "",
                Key = "󰌆",
                Namespace = "󰅪",
                Null = "NULL",
                Number = "#",
                Object = "󰀚",
                Package = "󰏗",
                Property = "",
                Reference = "",
                Snippet = "",
                String = "󰀬",
                TypeParameter = "󰊄",
                Unit = "",
            },
            menu = {},
        },
        config = function(_, opts)
            require("lspkind").init(opts)
        end,
    },

    --  nvim-scrollbar [scrollbar]
    --  https://github.com/petertriho/nvim-scrollbar
    {
        "petertriho/nvim-scrollbar",
        event = "User BaseFile",
        opts = {
            handlers = {
                gitsigns = true, -- gitsigns integration (display hunks)
                ale = true,      -- lsp integration (display errors/warnings)
                search = false,  -- hlslens integration (display search result)
            },
            excluded_filetypes = {
                "cmp_docs",
                "cmp_menu",
                "noice",
                "prompt",
                "TelescopePrompt",
                "alpha"
            },
        },
    },

    --  mini.animate [animations]
    --  https://github.com/echasnovski/mini.animate
    --  HINT: if one of your personal keymappings fail due to mini.animate, try to
    --        disable it during the keybinding using vim.g.minianimate_disable = true
    {
        "echasnovski/mini.animate",
        event = "User BaseFile",
        enabled = true,
        opts = function()
            -- don't use animate when scrolling with the mouse
            local mouse_scrolled = false
            for _, scroll in ipairs { "Up", "Down" } do
                local key = "<ScrollWheel" .. scroll .. ">"
                vim.keymap.set({ "", "i" }, key, function()
                    mouse_scrolled = true
                    return key
                end, { expr = true })
            end

            local animate = require("mini.animate")
            return {
                open = { enable = false }, -- true causes issues on nvim-spectre
                resize = {
                    timing = animate.gen_timing.linear { duration = 33, unit = "total" },
                },
                scroll = {
                    timing = animate.gen_timing.linear { duration = 50, unit = "total" },
                    subscroll = animate.gen_subscroll.equal {
                        predicate = function(total_scroll)
                            if mouse_scrolled then
                                mouse_scrolled = false
                                return false
                            end
                            return total_scroll > 1
                        end,
                    },
                },
                cursor = {
                    enable = false, -- We don't want cursor ghosting
                    timing = animate.gen_timing.linear { duration = 26, unit = "total" },
                },
            }
        end,
    },

    --  highlight-undo
    --  https://github.com/tzachar/highlight-undo.nvim
    --  This plugin only flases on undo/redo.
    --  But we also have a autocmd to flash on yank.
    {
        "tzachar/highlight-undo.nvim",
        event = "User BaseDefered",
        opts = {
            duration = 150,
            hlgroup = "IncSearch",
        },
        config = function(_, opts)
            require("highlight-undo").setup(opts)

            -- Also flash on yank.
            vim.api.nvim_create_autocmd("TextYankPost", {
                desc = "Highlight yanked text",
                pattern = "*",
                callback = function()
                    (vim.hl or vim.highlight).on_yank()
                end,
            })
        end,
    },

    --  which-key.nvim [on-screen keybindings]
    --  https://github.com/folke/which-key.nvim
    {
        "folke/which-key.nvim",
        event = "User BaseDefered",

        opts_extend = { "disable.ft", "disable.bt" },
        opts = {
            preset = "modern", -- "classic", "modern", or "helix"
            icons = {
                group = (vim.g.fallback_icons_enabled and "+") or "",
                rules = false,
                separator = "-",
            },
        },
        config = function(_, opts)
            require("which-key").setup(opts)
            require("utils").which_key_register()
        end,
    },
    -- 333333333333333333333333333333333
    --
    --  TREE SITTER ---------------------------------------------------------
    --  [syntax highlight]
    --  https://github.com/nvim-treesitter/nvim-treesitter
    --  https://github.com/windwp/nvim-treesitter-textobjects
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        event = "User BaseDefered",
        cmd = {
            "TSBufDisable",
            "TSBufEnable",
            "TSBufToggle",
            "TSDisable",
            "TSEnable",
            "TSToggle",
            "TSInstall",
            "TSInstallInfo",
            "TSInstallSync",
            "TSModuleInfo",
            "TSUninstall",
            "TSUpdate",
            "TSUpdateSync",
        },
        build = ":TSUpdate",
        opts = {
            auto_install = true, -- Currently bugged. Use [:TSInstall all] and [:TSUpdate all]
            ensure_installed = {
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "python",
                "go",
                "html",
                "css",
                "javascript",
            },

            highlight = {
                enable = true,
                disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
            },
            matchup = {
                enable = true,
                enable_quotes = true,
                disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
            },
            incremental_selection = { enable = true },
            indent = { enable = true },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["ak"] = { query = "@block.outer", desc = "around block" },
                        ["ik"] = { query = "@block.inner", desc = "inside block" },
                        ["ac"] = { query = "@class.outer", desc = "around class" },
                        ["ic"] = { query = "@class.inner", desc = "inside class" },
                        ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
                        ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
                        ["af"] = { query = "@function.outer", desc = "around function " },
                        ["if"] = { query = "@function.inner", desc = "inside function " },
                        ["al"] = { query = "@loop.outer", desc = "around loop" },
                        ["il"] = { query = "@loop.inner", desc = "inside loop" },
                        ["aa"] = { query = "@parameter.outer", desc = "around argument" },
                        ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]k"] = { query = "@block.outer", desc = "Next block start" },
                        ["]f"] = { query = "@function.outer", desc = "Next function start" },
                        ["]a"] = { query = "@parameter.inner", desc = "Next parameter start" },
                    },
                    goto_next_end = {
                        ["]K"] = { query = "@block.outer", desc = "Next block end" },
                        ["]F"] = { query = "@function.outer", desc = "Next function end" },
                        ["]A"] = { query = "@parameter.inner", desc = "Next parameter end" },
                    },
                    goto_previous_start = {
                        ["[k"] = { query = "@block.outer", desc = "Previous block start" },
                        ["[f"] = { query = "@function.outer", desc = "Previous function start" },
                        ["[a"] = { query = "@parameter.inner", desc = "Previous parameter start" },
                    },
                    goto_previous_end = {
                        ["[K"] = { query = "@block.outer", desc = "Previous block end" },
                        ["[F"] = { query = "@function.outer", desc = "Previous function end" },
                        ["[A"] = { query = "@parameter.inner", desc = "Previous parameter end" },
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        [">K"] = { query = "@block.outer", desc = "Swap next block" },
                        [">F"] = { query = "@function.outer", desc = "Swap next function" },
                        [">A"] = { query = "@parameter.inner", desc = "Swap next parameter" },
                    },
                    swap_previous = {
                        ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
                        ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
                        ["<A"] = { query = "@parameter.inner", desc = "Swap previous parameter" },
                    },
                },
            },
        },
        config = function(_, opts)
            -- calling setup() here is necessary to enable conceal and some features.
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    --  render-markdown.nvim [normal mode markdown]
    --  https://github.com/MeanderingProgrammer/render-markdown.nvim
    --  While on normal mode, markdown files will display highlights.
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { "markdown" },
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        opts = {
            heading = {
                sign = false,
                icons = require("utils").get_icon("RenderMarkdown"),
                width = "block",
            },
            code = {
                sign = false,
                width = 'block', -- use 'language' if colorcolumn is important for you.
                right_pad = 1,
            },
            dash = {
                width = 79
            },
            pipe_table = {
                style = 'full', -- use 'normal' if colorcolumn is important for you.
            },
        },
    },

    --  [hex colors]
    --  https://github.com/brenoprata10/nvim-highlight-colors
    {
        "brenoprata10/nvim-highlight-colors",
        event = "User BaseFile",
        cmd = { "HighlightColors" }, -- followed by 'On' / 'Off' / 'Toggle'
        opts = { enabled_named_colors = false },
    },

    --  LSP -------------------------------------------------------------------

    --  nvim-lspconfig [lsp configs]
    --  https://github.com/neovim/nvim-lspconfig
    --  This plugin provide default configs for the lsp servers available on mason.
    {
        "neovim/nvim-lspconfig",
        event = "User BaseFile",
    },

    -- mason-lspconfig [auto start lsp]
    -- https://github.com/mason-org/mason-lspconfig.nvim
    -- This plugin auto starts the lsp servers installed by Mason
    -- every time Neovim trigger the event FileType.
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        opts = {
            automatic_installation = true,
            ensure_installed = {
                "clangd",
                "gopls",
                "pylsp",
                "lua_ls",
                "cssls",
                "eslint",
                "html",
            }
        },
        -- event = "BufReadPre",
        -- depends on automcds.lua
        event = "User BaseDefered",
        config = function(_, opts)
            require("mason-lspconfig").setup(opts)
            utils_lsp.apply_default_lsp_settings() -- Apply our default lsp settings.
            -- if shit hits the fan needed for the keymaps
            utils.trigger_event("FileType")
            utils_lsp.setup("lua_ls")
            utils_lsp.setup("clangd")
            utils_lsp.setup("gopls")
            utils_lsp.setup("pylsp")
            utils_lsp.setup("eslint")
            utils_lsp.setup("html")
            utils_lsp.setup("cssls")
        end,
    },

    --  mason [lsp package manager]
    --  https://github.com/mason-org/mason.nvim
    --  https://github.com/zeioth/mason-extra-cmds
    {
        "mason-org/mason.nvim",
        dependencies = { "zeioth/mason-extra-cmds", opts = {} },
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
            "MasonUpdate",
            "MasonUpdateAll", -- this cmd is provided by mason-extra-cmds
        },
        opts = {
            registries = {
                "github:nvim-java/mason-registry",
                "github:mason-org/mason-registry",
            },
            ui = {
                icons = {
                    package_installed = require("utils").get_icon("MasonInstalled"),
                    package_uninstalled = require("utils").get_icon("MasonUninstalled"),
                    package_pending = require("utils").get_icon("MasonPending"),
                },
            },
        }

    },

    --  Schema Store [mason extra schemas]
    --  https://github.com/b0o/SchemaStore.nvim
    --  We use this plugin in ../base/utils/lsp.lua
    "b0o/SchemaStore.nvim",

    -- none-ls-autoload.nvim [mason package loader]
    -- https://github.com/zeioth/mason-none-ls.nvim
    -- This plugin auto starts the packages installed by Mason
    -- every time Neovim trigger the event FileType ().
    -- By default it will use none-ls builtin sources.
    -- But you can add external sources if a mason package has no builtin support.
    {
        "zeioth/none-ls-autoload.nvim",
        event = "User BaseFile",
        dependencies = {
            "mason-org/mason.nvim",
            "zeioth/none-ls-external-sources.nvim"
        },
        opts = {
            -- Here you can add support for sources not oficially suppored by none-ls.
            external_sources = {
                -- diagnostics
                'none-ls-external-sources.diagnostics.cpplint',
                'none-ls-external-sources.diagnostics.eslint',
                'none-ls-external-sources.diagnostics.eslint_d',
                'none-ls-external-sources.diagnostics.flake8',
                'none-ls-external-sources.diagnostics.luacheck',
                'none-ls-external-sources.diagnostics.psalm',
                'none-ls-external-sources.diagnostics.yamllint',

                -- formatting
                'none-ls-external-sources.formatting.autopep8',
                'none-ls-external-sources.formatting.beautysh',
                'none-ls-external-sources.formatting.easy-coding-standard',
                'none-ls-external-sources.formatting.eslint',
                'none-ls-external-sources.formatting.eslint_d',
                'none-ls-external-sources.formatting.jq',
                'none-ls-external-sources.formatting.latexindent',
                'none-ls-external-sources.formatting.reformat_gherkin',
                'none-ls-external-sources.formatting.rustfmt',
                'none-ls-external-sources.formatting.standardrb',
                'none-ls-external-sources.formatting.yq',
            },
        },
    },

    -- none-ls [lsp code formatting]
    -- https://github.com/nvimtools/none-ls.nvim
    {
        "nvimtools/none-ls.nvim",
        event = "User BaseFile",
        opts = function()
            local builtin_sources = require("null-ls").builtins

            -- You can customize your 'builtin sources' and 'external sources' here.
            builtin_sources.formatting.shfmt.with({
                command = "shfmt",
                args = { "-i", "2", "-filename", "$FILENAME" },
            })

            -- Attach the user lsp mappings to every none-ls client.
            return { on_attach = utils_lsp.apply_user_lsp_mappings }
        end
    },

    --  garbage-day.nvim [lsp garbage collector]
    --  https://github.com/zeioth/garbage-day.nvim
    {
        "zeioth/garbage-day.nvim",
        event = "User BaseFile",
        opts = {
            aggressive_mode = false,
            excluded_lsp_clients = {
                "null-ls", "jdtls", "marksman", "lua_ls"
            },
            grace_period = (60 * 15),
            wakeup_delay = 3000,
            notifications = false,
            retries = 3,
            timeout = 1000,
        }
    },

    --  lazy.nvim [lua lsp for nvim plugins]
    --  https://github.com/folke/lazydev.nvim
    {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = function(_, opts)
            opts.library = {
                -- Any plugin you wanna have LSP autocompletion for, add it here.
                -- in 'path', write the name of the plugin directory.
                -- in 'mods', write the word you use to require the module.
                -- in 'words' write words that trigger loading a lazydev path (optionally).
                { path = "lazy.nvim",                   mods = { "lazy" } },
                { path = "project.nvim",                mods = { "project_nvim", "telescope" } },
                { path = "trim.nvim",                   mods = { "trim" } },
                { path = "stickybuf.nvim",              mods = { "stickybuf" } },
                { path = "mini.bufremove",              mods = { "mini.bufremove" } },
                { path = "smart-splits.nvim",           mods = { "smart-splits" } },
                { path = "toggleterm.nvim",             mods = { "toggleterm" } },
                { path = "neovim-session-manager.nvim", mods = { "session_manager" } },
                { path = "nvim-spectre",                mods = { "spectre" } },
                { path = "neo-tree.nvim",               mods = { "neo-tree" } },
                { path = "nui.nvim",                    mods = { "nui" } },
                { path = "nvim-ufo",                    mods = { "ufo" } },
                { path = "promise-async",               mods = { "promise-async" } },
                { path = "nvim-neoclip.lua",            mods = { "neoclip", "telescope" } },
                { path = "zen-mode.nvim",               mods = { "zen-mode" } },
                { path = "vim-suda",                    mods = { "suda" } },                                      -- has vimscript
                { path = "vim-matchup",                 mods = { "matchup", "match-up", "treesitter-matchup" } }, -- has vimscript
                { path = "hop.nvim",                    mods = { "hop", "hop-treesitter", "hop-yank" } },
                { path = "nvim-autopairs",              mods = { "nvim-autopairs" } },
                { path = "lsp_signature",               mods = { "lsp_signature" } },
                { path = "nvim-lightbulb",              mods = { "nvim-lightbulb" } },

                { path = "tokyonight.nvim",             mods = { "tokyonight" } },
                { path = "astrotheme",                  mods = { "astrotheme" } },
                { path = "alpha-nvim",                  mods = { "alpha" } },
                { path = "nvim-notify",                 mods = { "notify" } },
                { path = "mini.indentscope",            mods = { "mini.indentscope" } },
                { path = "heirline-components.nvim",    mods = { "heirline-components" } },
                { path = "telescope.nvim",              mods = { "telescope" } },
                { path = "telescope-fzf-native.nvim",   mods = { "telescope", "fzf_lib" } },
                { path = "dressing.nvim",               mods = { "dressing" } },
                { path = "noice.nvim",                  mods = { "noice", "telescope" } },
                { path = "nvim-web-devicons",           mods = { "nvim-web-devicons" } },
                { path = "lspkind.nvim",                mods = { "lspkind" } },
                { path = "nvim-scrollbar",              mods = { "scrollbar" } },
                { path = "mini.animate",                mods = { "mini.animate" } },
                { path = "highlight-undo.nvim",         mods = { "highlight-undo" } },
                { path = "which-key.nvim",              mods = { "which-key" } },

                { path = "nvim-treesitter",             mods = { "nvim-treesitter" } },
                { path = "nvim-ts-autotag",             mods = { "nvim-ts-autotag" } },
                { path = "nvim-treesitter-textobjects", mods = { "nvim-treesitter", "nvim-treesitter-textobjects" } },
                { path = "markdown.nvim",               mods = { "render-markdown" } },
                { path = "nvim-highlight-colors",       mods = { "nvim-highlight-colors" } },
                { path = "nvim-java",                   mods = { "java" } },
                { path = "nvim-lspconfig",              mods = { "lspconfig" } },
                { path = "mason-lspconfig.nvim",        mods = { "mason-lspconfig" } },
                { path = "mason.nvim",                  mods = { "mason", "mason-core", "mason-registry", "mason-vendor" } },
                { path = "mason-extra-cmds",            mods = { "masonextracmds" } },
                { path = "SchemaStore.nvim",            mods = { "schemastore" } },
                { path = "none-ls-autoload.nvim",       mods = { "none-ls-autoload" } },
                { path = "none-ls.nvim",                mods = { "null-ls" } },
                { path = "lazydev.nvim",                mods = { "" } },
                { path = "garbage-day.nvim",            mods = { "garbage-day" } },
                { path = "nvim-cmp",                    mods = { "cmp" } },
                { path = "cmp_luasnip",                 mods = { "cmp_luasnip" } },
                { path = "cmp-buffer",                  mods = { "cmp_buffer" } },
                { path = "cmp-path",                    mods = { "cmp_path" } },
                { path = "cmp-nvim-lsp",                mods = { "cmp_nvim_lsp" } },

                { path = "LuaSnip",                     mods = { "luasnip" } },
                { path = "friendly-snippets",           mods = { "snippets" } }, -- has vimscript
                { path = "NormalSnippets",              mods = { "snippets" } }, -- has vimscript
                { path = "telescope-luasnip.nvim",      mods = { "telescop" } },
                { path = "gitsigns.nvim",               mods = { "gitsigns" } },
                { path = "vim-fugitive",                mods = { "fugitive" } }, -- has vimscript
                { path = "aerial.nvim",                 mods = { "aerial", "telescope", "lualine", "resession" } },
                { path = "litee.nvim",                  mods = { "litee" } },
                { path = "litee-calltree.nvim",         mods = { "litee" } },
                { path = "dooku.nvim",                  mods = { "dooku" } },
                { path = "markdown-preview.nvim",       mods = { "mkdp" } }, -- has vimscript
                { path = "markmap.nvim",                mods = { "markmap" } },
                { path = "neural",                      mods = { "neural" } },
                { path = "copilot",                     mods = { "copilot" } },
                { path = "guess-indent.nvim",           mods = { "guess-indent" } },
                { path = "overseer.nvim",               mods = { "overseer", "lualine", "neotest", "resession", "cmp_overseer" } },
                { path = "nvim-dap",                    mods = { "dap" } },
                { path = "nvim-nio",                    mods = { "nio" } },
                { path = "nvim-dap-ui",                 mods = { "dapui" } },
                { path = "cmp-dap",                     mods = { "cmp_dap" } },
                { path = "cmp-copilot",                 mods = { "cmp_copilot" } },
                { path = "mason-nvim-dap.nvim",         mods = { "mason-nvim-dap" } },

                { path = "one-small-step-for-vimkind",  mods = { "osv" } },
                { path = "neotest-dart",                mods = { "neotest-dart" } },
                { path = "neotest-dotnet",              mods = { "neotest-dotnet" } },
                { path = "neotest-elixir",              mods = { "neotest-elixir" } },
                { path = "neotest-golang",              mods = { "neotest-golang" } },
                { path = "neotest-java",                mods = { "neotest-java" } },
                { path = "neotest-jest",                mods = { "neotest-jest" } },
                { path = "neotest-phpunit",             mods = { "neotest-phpunit" } },
                { path = "neotest-python",              mods = { "neotest-python" } },
                { path = "neotest-rust",                mods = { "neotest-rust" } },
                { path = "neotest-zig",                 mods = { "neotest-zig" } },
                { path = "nvim-coverage.nvim",          mods = { "coverage" } },
                { path = "gutentags_plus",              mods = { "gutentags_plus" } }, -- has vimscript
                { path = "vim-gutentags",               mods = { "vim-gutentags" } },  -- has vimscript

                -- To make it work exactly like neodev, you can add all plugins
                -- without conditions instead like this but it will load slower
                -- on startup and consume ~1 Gb RAM:
                -- vim.fn.stdpath "data" .. "/lazy",

                -- You can also add libs.
                { path = "luvit-meta/library",          mods = { "vim%.uv" } },
            }
        end,
        specs = { { "Bilal2453/luvit-meta", lazy = true } },
    },

    --  AUTO COMPLETION --------------------------------------------------------
    --  Auto completion engine [autocompletion engine]
    --  https://github.com/hrsh7th/nvim-cmp
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "saadparwaiz1/cmp_luasnip" },
            { "zbirenbaum/copilot-cmp",  opts = {} },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "onsails/lspkind.nvim" },
        },
        event = "InsertEnter",
        opts = function()
            -- ensure dependencies exist
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind_loaded, lspkind = pcall(require, "lspkind")

            -- border opts
            local border_opts = {
                border = "rounded",
                winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            }
            local cmp_config_window = (
                vim.g.lsp_round_borders_enabled and cmp.config.window.bordered(border_opts)
            ) or cmp.config.window

            -- helper
            local function has_words_before()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
            end

            return {
                enabled = function() -- disable in certain cases on dap.
                    local is_prompt = vim.bo.buftype == "prompt"
                    local is_dap_prompt = vim.tbl_contains(
                        { "dap-repl", "dapui_watches", "dapui_hover" }, vim.bo.filetype)
                    if is_prompt and not is_dap_prompt then
                        return false
                    else
                        return vim.g.cmp_enabled
                    end
                end,
                preselect = cmp.PreselectMode.None,
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = (lspkind_loaded and lspkind.cmp_format(utils.get_plugin_opts("lspkind.nvim"))) or nil
                },
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                duplicates = {
                    nvim_lsp = 1,
                    lazydev = 1,
                    luasnip = 1,
                    cmp_tabnine = 1,
                    buffer = 1,
                    path = 1,
                },
                confirm_opts = {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                },
                window = {
                    completion = cmp_config_window,
                    documentation = cmp_config_window,
                },
                mapping = {
                    ["<Up>"] = cmp.mapping.select_prev_item {
                        behavior = cmp.SelectBehavior.Select,
                    },
                    ["<Down>"] = cmp.mapping.select_next_item {
                        behavior = cmp.SelectBehavior.Select,
                    },
                    ["<C-k>"] = cmp.mapping.select_prev_item {
                        behavior = cmp.SelectBehavior.Insert,
                    },
                    ["<C-j>"] = cmp.mapping.select_next_item {
                        behavior = cmp.SelectBehavior.Insert,
                    },
                    ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                    ["<C-y>"] = cmp.config.disable,
                    ["<C-s>"] = cmp.mapping {
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    },
                    ["<CR>"] = cmp.mapping.confirm { select = false },
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = cmp.config.sources {
                    -- Note: Priority decides the order items appear.
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "lazydev",  priority = 850 },
                    { name = "luasnip",  priority = 750 },
                    { name = "copilot",  priority = 600 },
                    { name = "buffer",   priority = 500 },
                    { name = "path",     priority = 250 },
                },
            }
        end,
    },

    -- 444444444444444444444

    --  SNIPPETS ----------------------------------------------------------------
    --  Vim Snippets engine  [snippet engine] + [snippet templates]
    --  https://github.com/L3MON4D3/LuaSnip
    --  https://github.com/rafamadriz/friendly-snippets
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "zeioth/NormalSnippets",
            "benfowler/telescope-luasnip.nvim",
        },
        event = "User BaseFile",
        opts = {
            history = true,
            delete_check_events = "TextChanged",
            region_check_events = "CursorMoved",
        },
        config = function(_, opts)
            if opts then require("luasnip").config.setup(opts) end
            vim.tbl_map(
                function(type) require("luasnip.loaders.from_" .. type).lazy_load() end,
                { "vscode", "snipmate", "lua" }
            )
            -- friendly-snippets - enable standardized comments snippets
            require("luasnip").filetype_extend("typescript", { "tsdoc" })
            require("luasnip").filetype_extend("javascript", { "jsdoc" })
            require("luasnip").filetype_extend("lua", { "luadoc" })
            require("luasnip").filetype_extend("python", { "pydoc" })
            require("luasnip").filetype_extend("rust", { "rustdoc" })
            require("luasnip").filetype_extend("cs", { "csharpdoc" })
            require("luasnip").filetype_extend("java", { "javadoc" })
            require("luasnip").filetype_extend("c", { "cdoc" })
            require("luasnip").filetype_extend("cpp", { "cppdoc" })
            require("luasnip").filetype_extend("php", { "phpdoc" })
            require("luasnip").filetype_extend("kotlin", { "kdoc" })
            require("luasnip").filetype_extend("ruby", { "rdoc" })
            require("luasnip").filetype_extend("sh", { "shelldoc" })
        end,
    },

    --  GIT ---------------------------------------------------------------------
    --  Git signs [git hunks]
    --  https://github.com/lewis6991/gitsigns.nvim
    {
        "lewis6991/gitsigns.nvim",
        enabled = vim.fn.executable("git") == 1,
        event = "User BaseGitFile",
        opts = function()
            local get_icon = require("utils").get_icon
            return {
                max_file_length = vim.g.big_file.lines,
                signs = {
                    add = { text = get_icon("GitSign") },
                    change = { text = get_icon("GitSign") },
                    delete = { text = get_icon("GitSign") },
                    topdelete = { text = get_icon("GitSign") },
                    changedelete = { text = get_icon("GitSign") },
                    untracked = { text = get_icon("GitSign") },
                },
            }
        end
    },

    --  Git fugitive mergetool + [git commands]
    --  https://github.com/lewis6991/gitsigns.nvim
    --  PR needed: Setup keymappings to move quickly when using this feature.
    --
    --  We only want this plugin to use it as mergetool like "git mergetool".
    --  To enable this feature, add this  to your global .gitconfig:
    --
    --  [mergetool "fugitive"]
    --  	cmd = nvim -c \"Gvdiffsplit!\" \"$MERGED\"
    --  [merge]
    --  	tool = fugitive
    --  [mergetool]
    --  	keepBackup = false
    {
        "tpope/vim-fugitive",
        enabled = vim.fn.executable("git") == 1,
        dependencies = { "tpope/vim-rhubarb" },
        cmd = {
            "Gvdiffsplit",
            "Gdiffsplit",
            "Gedit",
            "Gsplit",
            "Gread",
            "Gwrite",
            "Ggrep",
            "GMove",
            "GRename",
            "GDelete",
            "GRemove",
            "GBrowse",
            "Git",
            "Gstatus",
        },
        config = function()
            -- NOTE: On vim plugins we use config instead of opts.
            vim.g.fugitive_no_maps = 1
        end,
    },

    --  ANALYZER ----------------------------------------------------------------
    --  [symbols tree]
    --  https://github.com/stevearc/aerial.nvim
    {
        "stevearc/aerial.nvim",
        event = "User BaseFile",
        opts = {
            filter_kind = { -- Symbols that will appear on the tree
                -- "Class",
                "Constructor",
                "Enum",
                "Function",
                "Interface",
                -- "Module",
                "Method",
                -- "Struct",
            },
            open_automatic = false, -- Open if the buffer is compatible
            nerd_font = (vim.g.fallback_icons_enabled and false) or true,
            autojump = true,
            link_folds_to_tree = false,
            link_tree_to_folds = false,
            attach_mode = "global",
            backends = { "lsp", "treesitter", "markdown", "man" },
            disable_max_lines = vim.g.big_file.lines,
            disable_max_size = vim.g.big_file.size,
            layout = {
                min_width = 28,
                default_direction = "right",
                placement = "edge",
            },
            show_guides = true,
            guides = {
                mid_item = "├ ",
                last_item = "└ ",
                nested_top = "│ ",
                whitespace = "  ",
            },
            keymaps = {
                ["[y"] = "actions.prev",
                ["]y"] = "actions.next",
                ["[Y"] = "actions.prev_up",
                ["]Y"] = "actions.next_up",
                ["{"] = false,
                ["}"] = false,
                ["[["] = false,
                ["]]"] = false,
            },
        },
        config = function(_, opts)
            require("aerial").setup(opts)
            -- HACK: The first time you open aerial on a session, close all folds.
            vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
                desc = "Aerial: When aerial is opened, close all its folds.",
                callback = function()
                    local is_aerial = vim.bo.filetype == "aerial"
                    if is_aerial and vim.b.new_aerial_session == nil then
                        vim.b.new_aerial_session = false
                        require("aerial").tree_set_collapse_level(0, 0)
                    end
                end,
            })
        end
    },

    -- Litee calltree [calltree]
    -- https://github.com/ldelossa/litee.nvim
    -- https://github.com/ldelossa/litee-calltree.nvim
    -- press ? inside the panel to show help.
    {
        'ldelossa/litee.nvim',
        event = "User BaseFile",
        opts = {
            notify = { enabled = false },
            tree = {
                icon_set = "default" -- "nerd", "codicons", "default", "simple"
            },
            panel = {
                orientation = "bottom",
                panel_size = 10,
            },
        },
        config = function(_, opts)
            require('litee.lib').setup(opts)
        end
    },
    {
        'ldelossa/litee-calltree.nvim',
        dependencies = 'ldelossa/litee.nvim',
        event = "User BaseFile",
        opts = {
            on_open = "panel", -- or popout
            map_resize_keys = false,
            keymaps = {
                expand = "<CR>",
                collapse = "c",
                collapse_all = "C",
                jump = "<C-CR>"
            },
        },
        config = function(_, opts)
            require('litee.calltree').setup(opts)

            -- Highlight only while on calltree
            vim.api.nvim_create_autocmd({ "WinEnter" }, {
                desc = "Clear highlights when leaving calltree + UX improvements.",
                callback = function()
                    vim.defer_fn(function()
                        if vim.bo.filetype == "calltree" then
                            vim.wo.colorcolumn = "0"
                            vim.wo.foldcolumn = "0"
                            vim.cmd("silent! PinBuffer") -- stickybuf.nvim
                            vim.cmd(
                                "silent! hi LTSymbolJump ctermfg=015 ctermbg=110 cterm=italic,bold,underline guifg=#464646 guibg=#87afd7 gui=italic,bold")
                            vim.cmd(
                                "silent! hi LTSymbolJumpRefs ctermfg=015 ctermbg=110 cterm=italic,bold,underline guifg=#464646 guibg=#87afd7 gui=italic,bold")
                        else
                            vim.cmd("silent! highlight clear LTSymbolJump")
                            vim.cmd("silent! highlight clear LTSymbolJumpRefs")
                        end
                    end, 100)
                end
            })
        end
    },

    --  CODE DOCUMENTATION ------------------------------------------------------
    --  dooku.nvim [html doc generator]
    --  https://github.com/zeioth/dooku.nvim
    {
        "zeioth/dooku.nvim",
        cmd = {
            "DookuGenerate",
            "DookuOpen",
            "DookuAutoSetup"
        },
        opts = {},
    },

    --  [markdown previewer]
    --  https://github.com/iamcco/markdown-preview.nvim
    --  Note: If you change the build command, wipe ~/.local/data/nvim/lazy
    {
        "iamcco/markdown-preview.nvim",
        build = function(plugin)
            -- guard clauses
            local yarn = (vim.fn.executable("yarn") and "yarn")
                or (vim.fn.executable("npx") and "npx -y yarn")
                or nil
            if not yarn then error("Missing `yarn` or `npx` in the PATH") end

            -- run cmd
            local cd_cmd = "!cd " .. plugin.dir .. " && cd app"
            local yarn_install_cmd = "COREPACK_ENABLE_AUTO_PIN=0 " .. yarn .. " install --frozen-lockfile"
            vim.cmd(cd_cmd .. " && " .. yarn_install_cmd)
        end,
        init = function()
            local plugin = require("lazy.core.config").spec.plugins["markdown-preview.nvim"]
            vim.g.mkdp_filetypes = require("lazy.core.plugin").values(plugin, "ft", true)
        end,
        ft = { "markdown", "markdown.mdx" },
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    },

    --  [markdown markmap]
    --  https://github.com/zeioth/markmap.nvim
    --  Important: Make sure you have yarn in your PATH before running markmap.
    {
        "zeioth/markmap.nvim",
        build = "yarn global add markmap-cli",
        cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
        config = function(_, opts) require("markmap").setup(opts) end,
    },

    --  DEBUGGER ----------------------------------------------------------------
    --  Debugger alternative to vim-inspector [debugger]
    --  https://github.com/mfussenegger/nvim-dap
    --  Here we configure the adapter+config of every debugger.
    --  Debuggers don't have system dependencies, you just install them with mason.
    --  We currently ship most of them with nvim.
    {
        "mfussenegger/nvim-dap",
        enabled = vim.fn.has "win32" == 0,
        event = "User BaseFile",
        config = function()
            local dap = require("dap")

            -- C#
            dap.adapters.coreclr = {
                type = 'executable',
                command = vim.fn.stdpath('data') .. '/mason/bin/netcoredbg',
                args = { '--interpreter=vscode' }
            }
            dap.configurations.cs = {
                {
                    type = "coreclr",
                    name = "launch - netcoredbg",
                    request = "launch",
                    program = function() -- Ask the user what executable wants to debug
                        return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Program.exe', 'file')
                    end,
                },
            }

            -- F#
            dap.configurations.fsharp = dap.configurations.cs

            -- Visual basic dotnet
            dap.configurations.vb = dap.configurations.cs

            -- Java
            -- Note: The java debugger jdtls is automatically spawned and configured
            -- by the plugin 'nvim-java' in './3-dev-core.lua'.

            -- Python
            dap.adapters.python = {
                type = 'executable',
                command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
                args = { '-m', 'debugpy.adapter' },
            }
            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}", -- This configuration will launch the current file if used.
                },
            }

            -- Lua
            dap.adapters.nlua = function(callback, config)
                callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
            end
            dap.configurations.lua = {
                {
                    type = 'nlua',
                    request = 'attach',
                    name = "Attach to running Neovim instance",
                    program = function() pcall(require "osv".launch({ port = 8086 })) end,
                }
            }

            -- C
            dap.adapters.codelldb = {
                type = 'server',
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
                    args = { "--port", "${port}" },
                    detached = true,
                }
            }
            dap.configurations.c = {
                {
                    name = 'Launch',
                    type = 'codelldb',
                    request = 'launch',
                    program = function() -- Ask the user what executable wants to debug
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/bin/program', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                },
            }

            -- C++
            dap.configurations.cpp = dap.configurations.c

            -- Rust
            dap.configurations.rust = {
                {
                    name = 'Launch',
                    type = 'codelldb',
                    request = 'launch',
                    program = function() -- Ask the user what executable wants to debug
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/bin/program', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                    initCommands = function() -- add rust types support (optional)
                        -- Find out where to look for the pretty printer Python module
                        local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

                        local script_import = 'command script import "' ..
                            rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                        local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                        local commands = {}
                        local file = io.open(commands_file, 'r')
                        if file then
                            for line in file:lines() do
                                table.insert(commands, line)
                            end
                            file:close()
                        end
                        table.insert(commands, 1, script_import)

                        return commands
                    end,
                }
            }

            -- Go
            -- Requires:
            -- * You have initialized your module with 'go mod init module_name'.
            -- * You :cd your project before running DAP.
            dap.adapters.delve = {
                type = 'server',
                port = '${port}',
                executable = {
                    command = vim.fn.stdpath('data') .. '/mason/packages/delve/dlv',
                    args = { 'dap', '-l', '127.0.0.1:${port}' },
                }
            }
            dap.configurations.go = {
                {
                    type = "delve",
                    name = "Compile module and debug this file",
                    request = "launch",
                    program = "./${relativeFileDirname}",
                },
                {
                    type = "delve",
                    name = "Compile module and debug this file (test)",
                    request = "launch",
                    mode = "test",
                    program = "./${relativeFileDirname}"
                },
            }

            -- Dart / Flutter
            dap.adapters.dart = {
                type = 'executable',
                command = vim.fn.stdpath('data') .. '/mason/bin/dart-debug-adapter',
                args = { 'dart' }
            }
            dap.adapters.flutter = {
                type = 'executable',
                command = vim.fn.stdpath('data') .. '/mason/bin/dart-debug-adapter',
                args = { 'flutter' }
            }
            dap.configurations.dart = {
                {
                    type = "dart",
                    request = "launch",
                    name = "Launch dart",
                    dartSdkPath = "/opt/flutter/bin/cache/dart-sdk/", -- ensure this is correct
                    flutterSdkPath = "/opt/flutter",                  -- ensure this is correct
                    program = "${workspaceFolder}/lib/main.dart",     -- ensure this is correct
                    cwd = "${workspaceFolder}",
                },
                {
                    type = "flutter",
                    request = "launch",
                    name = "Launch flutter",
                    dartSdkPath = "/opt/flutter/bin/cache/dart-sdk/", -- ensure this is correct
                    flutterSdkPath = "/opt/flutter",                  -- ensure this is correct
                    program = "${workspaceFolder}/lib/main.dart",     -- ensure this is correct
                    cwd = "${workspaceFolder}",
                }
            }

            -- Kotlin
            -- Kotlin projects have very weak project structure conventions.
            -- You must manually specify what the project root and main class are.
            dap.adapters.kotlin = {
                type = 'executable',
                command = vim.fn.stdpath('data') .. '/mason/bin/kotlin-debug-adapter',
            }
            dap.configurations.kotlin = {
                {
                    type = 'kotlin',
                    request = 'launch',
                    name = 'Launch kotlin program',
                    projectRoot = "${workspaceFolder}/app", -- ensure this is correct
                    mainClass = "AppKt",                    -- ensure this is correct
                },
            }

            -- Javascript / Typescript (firefox)
            dap.adapters.firefox = {
                type = 'executable',
                command = vim.fn.stdpath('data') .. '/mason/bin/firefox-debug-adapter',
            }
            dap.configurations.typescript = {
                {
                    name = 'Debug with Firefox',
                    type = 'firefox',
                    request = 'launch',
                    reAttach = true,
                    url = 'http://localhost:4200', -- Write the actual URL of your project.
                    webRoot = '${workspaceFolder}',
                    firefoxExecutable = '/usr/bin/firefox'
                }
            }
            dap.configurations.javascript = dap.configurations.typescript
            dap.configurations.javascriptreact = dap.configurations.typescript
            dap.configurations.typescriptreact = dap.configurations.typescript

            -- Javascript / Typescript (chromium)
            -- If you prefer to use this adapter, comment the firefox one.
            -- But to use this adapter, you must manually run one of these two, first:
            -- * chromium --remote-debugging-port=9222 --user-data-dir=remote-profile
            -- * google-chrome-stable --remote-debugging-port=9222 --user-data-dir=remote-profile
            -- After starting the debugger, you must manually reload page to get all features.
            -- dap.adapters.chrome = {
            --  type = 'executable',
            --  command = vim.fn.stdpath('data')..'/mason/bin/chrome-debug-adapter',
            -- }
            -- dap.configurations.typescript = {
            --  {
            --   name = 'Debug with Chromium',
            --   type = "chrome",
            --   request = "attach",
            --   program = "${file}",
            --   cwd = vim.fn.getcwd(),
            --   sourceMaps = true,
            --   protocol = "inspector",
            --   port = 9222,
            --   webRoot = "${workspaceFolder}"
            --  }
            -- }
            -- dap.configurations.javascript = dap.configurations.typescript
            -- dap.configurations.javascriptreact = dap.configurations.typescript
            -- dap.configurations.typescriptreact = dap.configurations.typescript

            -- PHP
            dap.adapters.php = {
                type = 'executable',
                command = vim.fn.stdpath("data") .. '/mason/bin/php-debug-adapter',
            }
            dap.configurations.php = {
                {
                    type = 'php',
                    request = 'launch',
                    name = 'Listen for Xdebug',
                    port = 9000
                }
            }

            -- Shell
            dap.adapters.bashdb = {
                type = 'executable',
                command = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/bash-debug-adapter',
                name = 'bashdb',
            }
            dap.configurations.sh = {
                {
                    type = 'bashdb',
                    request = 'launch',
                    name = "Launch file",
                    showDebugOutput = true,
                    pathBashdb = vim.fn.stdpath("data") ..
                        '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
                    pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
                    trace = true,
                    file = "${file}",
                    program = "${file}",
                    cwd = '${workspaceFolder}',
                    pathCat = "cat",
                    pathBash = "/bin/bash",
                    pathMkfifo = "mkfifo",
                    pathPkill = "pkill",
                    args = {},
                    env = {},
                    terminalKind = "integrated",
                }
            }

            -- Elixir
            dap.adapters.mix_task = {
                type = 'executable',
                command = vim.fn.stdpath("data") .. '/mason/bin/elixir-ls-debugger',
                args = {}
            }
            dap.configurations.elixir = {
                {
                    type = "mix_task",
                    name = "mix test",
                    task = 'test',
                    taskArgs = { "--trace" },
                    request = "launch",
                    startApps = true, -- for Phoenix projects
                    projectDir = "${workspaceFolder}",
                    requireFiles = {
                        "test/**/test_helper.exs",
                        "test/**/*_test.exs"
                    }
                },
            }
        end, -- of dap config
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "rcarriga/cmp-dap",
            "jay-babu/mason-nvim-dap.nvim",
            "jbyuki/one-small-step-for-vimkind",
            "nvim-java/nvim-java",
        },
    },

    -- nvim-dap-ui [dap ui]
    -- https://github.com/mfussenegger/nvim-dap-ui
    -- user interface for the debugger dap
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = { floating = { border = "rounded" } },
        config = function(_, opts)
            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function(
            )
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function(
            )
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            dapui.setup(opts)
        end,
    },

    -- cmp-dap [dap autocomplete]
    -- https://github.com/mfussenegger/cmp-dap
    -- Enables autocomplete for the debugger dap.
    {
        "rcarriga/cmp-dap",
        dependencies = { "nvim-cmp" },
        config = function()
            require("cmp").setup.filetype(
                { "dap-repl", "dapui_watches", "dapui_hover" },
                {
                    sources = {
                        { name = "dap" },
                    },
                }
            )
        end,
    },

    --  TESTING -----------------------------------------------------------------
    --  Run tests inside of nvim [unit testing]
    --  https://github.com/nvim-neotest/neotest
    --
    --
    --  MANUAL:
    --  -- Unit testing:
    --  To tun an unit test you can run any of these commands:
    --
    --    :Neotest run      -- Runs the nearest test to the cursor.
    --    :Neotest stop     -- Stop the nearest test to the cursor.
    --    :Neotest run file -- Run all tests in the file.
    --
    --  -- E2e and Test Suite
    --  Normally you will prefer to open your e2e framework GUI outside of nvim.
    --  But you have the next commands in ../base/3-autocmds.lua:
    --
    --    :TestNodejs    -- Run all tests for this nodejs project.
    --    :TestNodejsE2e -- Run the e2e tests/suite for this nodejs project.
    {
        "nvim-neotest/neotest",
        cmd = { "Neotest" },
        dependencies = {
            "sidlatau/neotest-dart",
            "Issafalcon/neotest-dotnet",
            "jfpedroza/neotest-elixir",
            "fredrikaverpil/neotest-golang",
            "rcasia/neotest-java",
            "nvim-neotest/neotest-jest",
            "olimorris/neotest-phpunit",
            "nvim-neotest/neotest-python",
            "rouge8/neotest-rust",
            "lawrence-laz/neotest-zig",
        },
        opts = function()
            return {
                -- your neotest config here
                adapters = {
                    require("neotest-dart"),
                    require("neotest-dotnet"),
                    require("neotest-elixir"),
                    require("neotest-golang"),
                    require("neotest-java"),
                    require("neotest-jest"),
                    require("neotest-phpunit"),
                    require("neotest-python"),
                    require("neotest-rust"),
                    require("neotest-zig"),
                },
            }
        end,
        config = function(_, opts)
            -- get neotest namespace (api call creates or returns namespace)
            local neotest_ns = vim.api.nvim_create_namespace "neotest"
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+",
                            "")
                        return message
                    end,
                },
            }, neotest_ns)
            require("neotest").setup(opts)
        end,
    },

    --  Shows a float panel with the [code coverage]
    --  https://github.com/andythigpen/nvim-coverage
    --
    --  Your project must generate coverage/lcov.info for this to work.
    --
    --  On jest, make sure your packages.json file has this:
    --  "tests": "jest --coverage"
    --
    --  If you use other framework or language, refer to nvim-coverage docs:
    --  https://github.com/andythigpen/nvim-coverage/blob/main/doc/nvim-coverage.txt
    {
        "andythigpen/nvim-coverage",
        cmd = {
            "Coverage",
            "CoverageLoad",
            "CoverageLoadLcov",
            "CoverageShow",
            "CoverageHide",
            "CoverageToggle",
            "CoverageClear",
            "CoverageSummary",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            summary = {
                min_coverage = 80.0, -- passes if higher than
            },
        },
        config = function(_, opts) require("coverage").setup(opts) end,
    },

    -- LANGUAGE IMPROVEMENTS ----------------------------------------------------
    -- guttentags_plus [auto generate C/C++ tags]
    -- https://github.com/skywind3000/gutentags_plus
    -- This plugin is necessary for using <C-]> (go to ctag).
    {
        "skywind3000/gutentags_plus",
        ft = { "c", "cpp", "lisp" },
        dependencies = { "ludovicchabant/vim-gutentags" },
        config = function()
            -- NOTE: On vimplugins we use config instead of opts.
            vim.g.gutentags_plus_nomap = 1
            vim.g.gutentags_resolve_symlinks = 1
            vim.g.gutentags_cache_dir = vim.fn.stdpath "cache" .. "/tags"
            vim.api.nvim_create_autocmd("FileType", {
                desc = "Auto generate C/C++ tags",
                callback = function()
                    local is_c = vim.bo.filetype == "c" or vim.bo.filetype == "cpp"
                    if is_c then
                        vim.g.gutentags_enabled = 1
                    else
                        vim.g.gutentags_enabled = 0
                    end
                end,
            })
        end,
    },
    {
        "akinsho/toggleterm.nvim",
        cmd = { "ToggleTerm", "TermExec" },
        opts = {
            highlights = {
                Normal = { link = "Normal" },
                NormalNC = { link = "NormalNC" },
                NormalFloat = { link = "Normal" },
                FloatBorder = { link = "FloatBorder" },
                StatusLine = { link = "StatusLine" },
                StatusLineNC = { link = "StatusLineNC" },
                WinBar = { link = "WinBar" },
                WinBarNC = { link = "WinBarNC" },
            },
            size = 10,
            open_mapping = [[<F7>]],
            shading_factor = 2,
            direction = "float",
            float_opts = {
                border = "rounded",
                highlights = { border = "Normal", background = "Normal" },
            },
        },
    },

    --- 999999999999999999999999999
    "mbbill/undotree",
}
