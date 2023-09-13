local telescope_ok, telescope = pcall(require, "telescope")
if not telescope_ok then
	return
end

local git_worktrees_ok, git_worktrees = pcall(require, "git_worktrees")

if not git_worktrees_ok then
  return
end

git_worktrees.setup()
telescope.load_extension("git_worktree")

-- mappings
local nnoremap = require("utils").nnoremap

-- Switch worktrees
-- <Enter> - switches to that worktree
-- <c-d> - deletes that worktree
-- <c-f> - toggles forcing of the next deletion
nnoremap('<leader>wg', telescope.extensions.git_worktree.git_worktrees)

-- New worktrees 
nnoremap('<leader>wn', telescope.extensions.git_worktree.create_git_worktree)

-- op = Operations.Switch, Operations.Create, Operations.Delete
-- metadata = table of useful values (structure dependent on op)
--      Switch
--          path = path you switched to
--          prev_path = previous worktree path
--      Create
--          path = path where worktree created
--          branch = branch name
--          upstream = upstream remote name
--      Delete
--          path = path where worktree deleted
-- Worktree hooks
git_worktrees.on_tree_change(function(op, metadata)
  if op == git_worktrees.Operations.Switch then
    print("Switched from " .. metadata.prev_path .. " to " .. metadata.path)
  end
end)
