local obsidian_ok, obsidian = pcall(require, 'obsidian')
if not obsidian_ok then
  print("Obsidian integration plugin is missing")
  return
end

obsidian.setup({
  workspaces = {
    {
      name = "main",
      path = "~/notes/",
    }
  },
  picker = {
    name = "fzf-lua",
    note_mappings = {
      -- Create a new note from your query.
      new = "<C-x>",
      -- Insert a link to the selected note.
      insert_link = "<C-l>",
    },
    tag_mappings = {
      -- Add tag(s) to current note.
      tag_note = "<C-x>",
      -- Insert a tag at the current location.
      insert_tag = "<C-l>",
    },
    open_notes_in = "vsplit",
  }
})
