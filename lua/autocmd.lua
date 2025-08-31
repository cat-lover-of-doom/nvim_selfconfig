-- lua/autocmds.lua
-- Define Vimux helpers globally, once, on startup

local command_file = vim.fn.stdpath("data") .. "/stored_command.txt"

_G.VimuxWriteCommand = function()
  local cmd = vim.fn.input("Enter command: ")
  if cmd == "" then
    print("No command entered.")
    return
  end
  local f = io.open(command_file, "w")
  if not f then
    print("Cannot write command file.")
    return
  end
  f:write(cmd)
  f:close()
  print("Stored:", cmd)
end

_G.VimuxExecCommand = function()
  local f = io.open(command_file, "r")
  if not f then
    print("No stored command. Use <leader>ts first.")
    return
  end
  local cmd = f:read("*all") or ""
  f:close()
  if cmd == "" then
    print("Stored command is empty.")
    return
  end
  vim.cmd("VimuxRunCommand " .. vim.fn.shellescape(cmd))
end
