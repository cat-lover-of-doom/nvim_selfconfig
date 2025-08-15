-- Initialize counters for the keys
local key_counts = { h = 0, j = 0, k = 0, l = 0 }
local max_count = 3

-- Function to reset all key counters
local function reset_counts()
    key_counts.h = 0
    key_counts.j = 0
    key_counts.k = 0
    key_counts.l = 0
end

-- Function to check and update key usage
local function handle_key(key)
    key_counts[key] = key_counts[key] + 1
    if key_counts[key] > max_count then
        print("Key " .. key .. " usage limit exceeded!")
        return ""
    end
    return key
end

-- Reset the key counts on entering insert mode, using other keys, or using counts
vim.cmd [[
    augroup ResetKeyCounts
        autocmd!
        autocmd InsertEnter * lua reset_counts()
        autocmd BufEnter * lua reset_counts()
    augroup END
]]

-- Function to handle counts
local function handle_count(count, key)
    if count > 1 then
    return key
    end
    return handle_key(key)
end

-- Remap keys with count handling
vim.api.nvim_set_keymap('n', 'h', 'v:lua.handle_count(v:count1, "h")', { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('n', 'j', 'v:lua.handle_count(v:count1, "j")', { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('n', 'k', 'v:lua.handle_count(v:count1, "k")', { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('n', 'l', 'v:lua.handle_count(v:count1, "l")', { noremap = true, silent = true, expr = true })
_G.handle_count = handle_count
_G.reset_counts = reset_counts
_G.handle_key = handle_key
