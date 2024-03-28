local dap_ok, dap = pcall(require, "dap")
local nnoremap = require("utils").nnoremap

if not dap_ok then
  return
end

local dapui_ok, dapui = pcall(require, "dapui")

if not dapui_ok then
  return
end

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7"),
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        "breakpoints",
        "watches",
      },
      size = 0.20,
      position = "left",
    },
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        "console",
      },
      size = 0.50,
      position = "right",
    },
  },
  floating = {
    max_height = nil,  -- These can be integers or a float between 0 and 1.
    max_width = nil,   -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
  },
})

local dap_virtual_text_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")

if not dap_virtual_text_ok then
  return
end

dap_virtual_text.setup({})

local dap_vscode_js_ok, dap_vscode_js = pcall(require, "dap-vscode-js")

if not dap_vscode_js_ok then
  return
end

dap.adapters.python = {
  type = 'executable',
  command = os.getenv("VIRTUAL_ENV") .. "/bin/python",
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch',
    name = "Launch file",
    cwd = "${workspaceFolder}", --python is executed from this directory
    env = {
      PYTHONPATH = "${workspaceFolder}"
    },

    program = "${file}", -- This configuration will launch the current file if used.
    console = "integratedTerminal",
    restart = true,

    pythonPath = function()
      -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
      -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
      -- use the .git root
      local utils = require('utils')
      local cwd = utils.get_git_root_with_fallback()

      if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
      elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
      else
        return vim.fn.exepath('python')
      end
    end,
  },
  {
    type = 'python',
    request = 'attach',
    name = "Attach to process",
    cwd = "${workspaceFolder}",
    env = {
      PYTHONPATH = "${workspaceFolder}"
    },
    pid = require('dap.utils').pick_process,
  }
}

dap_vscode_js.setup({
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
})

for _, language in ipairs({ "typescript", "javascript" }) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      cwd = "${workspaceFolder}",
      request = "launch",
      name = "Node run",
      runtimeExecutable = "node",
      runtimeArgs = {
        "--inspect-brk",
        "${file}",
      },
      console = "integratedTerminal",
      restart = true,
      protocol = "auto",
      port = 9229,
      autoAttachChildProcesses = true
    },
    {
      type = "pwa-node",
      cwd = "${workspaceFolder}",
      request = "launch",
      name = "Nest Debug",
      runtimeExecutable = "bun",
      runtimeArgs = {
        "start:debug",
        "--",
        "--inspect-brk",
      },
      console = "integratedTerminal",
      restart = true,
      protocol = "auto",
      port = 9229,
      autoAttachChildProcesses = true,
    },
    {
      name = "Debug Jest Tests",
      type = "pwa-node",
      request = "launch",
      cwd = "${workspaceFolder}",
      sourceMaps = "inline",
      skipFiles = { "<node_internals>/**" },
      runtimeExecutable = "bun",
      runtimeArgs = {
        "--inspect-brk",
        "jest",
        "--runInBand",
        "--no-cache",
        "--no-collect-coverage",
        "--test-timeout=0",
        "--force-exit",
        "--findRelatedTests",
        "${file}",
      },
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
    {
      name = "Debug Mocha Tests",
      type = "pwa-node",
      request = "launch",
      cwd = "${workspaceFolder}",
      sourceMaps = "inline",
      skipFiles = { "<node_internals>/**" },
      runtimeExecutable = "bun",
      runtimeArgs = {
        "--inspect-brk",
        "mocha",
        "${file}",
        "--no-cache"
      },
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require 'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    }
  }
end

vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🔵", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "⏸️", texthl = "", linehl = "", numhl = "" })

dap.set_log_level("DEBUG")

-- maps
nnoremap("<leader>9", function()
  dap.toggle_breakpoint()
end)
nnoremap("<leader>0", function()
  dap.continue()
end)
nnoremap("<leader>du", function()
  dapui.toggle({})
end)
nnoremap("<leader>[", function()
  require("dap.breakpoints").clear()
end)

nnoremap("H", function()
  dapui.eval()
end)

local function setup_vscode_launch_json()
  local root_dir = require("utils").get_git_root()
  local path = vim.fn.expand(root_dir) .. "/.vscode/launch.json"
  local launch_file_exists = vim.fn.filereadable(path)
  if launch_file_exists then
    local launch_configs = vim.fn.readfile(path)
    local launch_config = vim.fn.json_decode(launch_configs)
    if launch_config then
      local configurations = launch_config["configurations"]
      require("utils").print_table(configurations)
      -- figure out why path fails here
      for _, language in ipairs({ "typescript", "javascript" }) do
        dap.configurations[language] = configurations
      end
    end
  end
end

nnoremap("<leader>djo", setup_vscode_launch_json)
