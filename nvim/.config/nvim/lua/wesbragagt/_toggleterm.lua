local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
  return
end

toggleterm.setup {
  open_mapping = [[<c-\>]],
  start_in_insert = true,
  insert_mappings = true,
  direction = "horizontal",
  size = 25,
  shell = vim.o.shell
}
