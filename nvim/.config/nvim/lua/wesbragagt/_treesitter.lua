local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end
treesitter.setup {
  indenting = {
    enable = true
  },
  highlight = {
    enable = true
  },
  incremental_selection = {
    enable = true
  },
  textobjects = {
    enable = true
  }
}
