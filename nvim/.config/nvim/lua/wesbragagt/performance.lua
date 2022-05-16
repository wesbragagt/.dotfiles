-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1
local status_ok, impatient = pcall(require, "impatient")
if not status_ok then
  return
end

local status_ok, filetype = pcall(require, "filetype")
if not status_ok then
  return
end

filetype.setup {
  overrides = {
    extensions = {
      tf = "terraform",
      tfvars = "terraform",
      tfstate = "json"
    }
  }
}
