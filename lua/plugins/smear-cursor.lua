return {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    config = function(_, opts)
        require("smear_cursor").setup(opts)
        require("smear_cursor").toggle() -- start disabled

        vim.keymap.set("n", "<leader>oc", function()
            local sc = require("smear_cursor")
            -- cycle: fast -> fire -> off -> fast ...
            local mode = vim.g.smear_cursor_mode or "off"
            if mode == "fast" then
                sc.setup({
                    cursor_color = "#ff4000",
                    particles_enabled = true,
                    stiffness = 0.5,
                    trailing_stiffness = 0.2,
                    trailing_exponent = 5,
                    damping = 0.6,
                    gradient_exponent = 0,
                    gamma = 1,
                    never_draw_over_target = true,
                    hide_target_hack = true,
                    particle_spread = 1,
                    particles_per_second = 500,
                    particles_per_length = 50,
                    particle_max_lifetime = 800,
                    particle_max_initial_velocity = 20,
                    particle_velocity_from_cursor = 0.5,
                    particle_damping = 0.15,
                    particle_gravity = -50,
                    min_distance_emit_particles = 0,
                })
                if not sc.enabled then sc.toggle() end
                vim.g.smear_cursor_mode = "fire"
                vim.notify("Smear cursor: FIRE")
            elseif mode == "fire" then
                if sc.enabled then sc.toggle() end
                vim.g.smear_cursor_mode = "off"
                vim.notify("Smear cursor: OFF")
            else
                sc.setup({
                    cursor_color = false,
                    particles_enabled = false,
                    stiffness = 0.8,
                    trailing_stiffness = 0.6,
                    stiffness_insert_mode = 0.7,
                    trailing_stiffness_insert_mode = 0.7,
                    damping = 0.95,
                    damping_insert_mode = 0.95,
                    distance_stop_animating = 0.5,
                })
                if not sc.enabled then sc.toggle() end
                vim.g.smear_cursor_mode = "fast"
                vim.notify("Smear cursor: FAST")
            end
        end, { desc = "Option: cycle smear cursor (fast/fire/off)" })
    end,
    opts = {
        -- Default  Range
        stiffness = 0.8,                      -- 0.6      [0, 1]
        trailing_stiffness = 0.6,             -- 0.45     [0, 1]
        stiffness_insert_mode = 0.7,          -- 0.5      [0, 1]
        trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
        damping = 0.95,                       -- 0.85     [0, 1]
        damping_insert_mode = 0.95,           -- 0.9      [0, 1]
        distance_stop_animating = 0.5,        -- 0.1      > 0
    },
}
