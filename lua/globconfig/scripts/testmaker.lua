-- Function to pass yank register value to a shell application and store the output back into the yank register
function GenTest()
  -- Get the value of the yank register
  local yank_value = vim.fn.getreg('"')

  -- Pass the yank value to the sheg application
  local handle = io.popen("~/.config/nvim/lua/globconfig/scripts/gotestmaker/gotestmaker " .. vim.fn.shellescape(yank_value))
  local result = handle:read("*a")
  handle:close()

  -- Remove trailing newline from the result
  result = result:gsub("%s+$", "")

  -- Store the result back into the yank register
  vim.fn.setreg('"', result)
end

-- Example usage: Replace 'your_shell_command' with the desired shell command
-- process_yank_register('your_shell_command')
_G.GenTest = GenTest
