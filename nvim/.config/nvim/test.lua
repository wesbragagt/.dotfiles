-- use this file to print and debug lua things
-- luafile %
-- print(vim.lsp.get_active_clients()[1].config.root_dir)
--
--
function print_table(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    formatting = string.rep(" ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      print_table(v, indent + 2)
    else
      print(formatting .. tostring(v))
    end
  end
end

local function setup_vscode_launch_json()
  local root_dir = require("utils").get_git_root()
  local path = vim.fn.expand(root_dir) .. "/.vscode/launch.json"
  local launch_file_exists = vim.fn.filereadable(path)
  if launch_file_exists then
    local launch_configs = vim.fn.readfile(path)
    local launch_config = vim.fn.json_decode(launch_configs)
    local configurations = launch_config["configurations"]
    require("utils").print_table(configurations)
    -- for _, language in ipairs({ "typescript", "javascript" }) do
    -- 	dap.configurations[language] = configurations
    -- end
  end
end

local clients = vim.lsp.buf_get_clients()

-- print(print_table(clients))
--

print_table(vim.lsp.util.text_document_completion_list_to_complete_items(vim.lsp.buf.completion()))



