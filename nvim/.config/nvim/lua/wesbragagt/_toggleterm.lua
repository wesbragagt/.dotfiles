local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
  return
end

toggleterm.setup {
  open_mapping = [[<c-\>]],
  start_in_insert = false,
  insert_mappings = true,
  direction = "float",
  shell = vim.o.shell
}