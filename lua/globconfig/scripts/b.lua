-- Define the file where the command will be stored
local command_file = vim.fn.stdpath('data') .. '/stored_command.txt'

-- Function to write a command to the file
function WriteCommand()
  local command = vim.fn.input('Enter command: ')
  local file = io.open(command_file, 'w')
  if file then
    file:write(command)
    file:close()
    print('Command stored.')
  else
    print('Error: Unable to write to file.')
  end
end

-- Function to read and execute the command in Vimux
function ExecCommand()
  local file = io.open(command_file, 'r')
  if file then
    local command = file:read('*all')
    file:close()
    if command ~= '' then
      -- Use Vimux to run the command in a tmux pane
      vim.cmd('VimuxRunCommand(' .. vim.fn.json_encode(command) .. ')')
      print('Executed command in Vimux: ' .. command)
    else
      print('No command found in the file.')
    end
  else
    print('Error: Unable to read from file.')
  end
end

-- Set key bindings for the functions
