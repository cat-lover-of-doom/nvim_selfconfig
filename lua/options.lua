local o = vim.opt
o.number = true
o.relativenumber = true
o.termguicolors = true
o.signcolumn = "yes"
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.mouse = "a"
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.updatetime = 300
o.wrap = false
o.expandtab = true
o.termguicolors = true
o.scrolloff = 1000
o.clipboard = "unnamedplus"
vim.opt.encoding = "utf-8"

vim.opt.langmap = table.concat({
  [[1234567890;!"#$%&/()=]],
  [[!"#$%&/()=;1234567890]],
}, ",")
