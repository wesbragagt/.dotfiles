local dap_ok, dap = pcall(require, "dap")
local nnoremap = require("utils").nnoremap

if not dap_ok then
  return
end

dap.defaults.fallback.external_terminal = {
  command = "tmux",
  args = {
    "split-window",
    "-h",
    "-p",
    "50",
  }
}

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
      position = "bottom",
    },
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        "console",
      },
      size = 0.30,
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
dap_vscode_js.setup({
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
  node_path = vim.fn.exepath("node"),
})


local dap_python_ok, dap_python = pcall(require, "dap-python")
if not dap_python_ok then
  return
end

--  dap_python.setup('~/.virtualenvs/debugpy/bin/python')
-- local function get_python_path()
--   if os.getenv("VIRTUAL_ENV") then
--     local path = os.getenv("VIRTUAL_ENV") .. "/bin/python"
--
--     print("Using virtualenv python path: " .. path)
--
--     return path
--   end
--
--   local path = vim.fn.exepath("python")
--
--   print("Using system python path: " .. path)
--
--   return path
-- end

dap.adapters.python = {
  type = "executable",
  command = "python",
  args = { "-m", "debugpy.adapter" },
  pythonPath = function()
    -- prioritize virtualenv python path
    if os.getenv("VIRTUAL_ENV") then
      return os.getenv("VIRTUAL_ENV") .. "/bin/python"
    end
    -- execute which python and return its path
    return vim.fn.exepath("python")
  end
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
  }
}

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
      request = "attach",
      name = "Attach",
      processId = require 'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    }
    -- {
    --   type = "pwa-node",
    --   cwd = "${workspaceFolder}",
    --   request = "launch",
    --   name = "Nest Debug",
    --   runtimeExecutable = "bun",
    --   runtimeArgs = {
    --     "start:debug",
    --     "--",
    --     "--inspect-brk",
    --   },
    --   console = "integratedTerminal",
    --   restart = true,
    --   protocol = "auto",
    --   port = 9229,
    --   autoAttachChildProcesses = true,
    -- },
    -- {
    --   type = "pwa-node",
    --   request = "launch",
    --   name = "Debug Jest Tests",
    --   -- trace = true, -- include debugger info
    --   cwd = "${workspaceFolder}",
    --   sourceMaps = "inline",
    --   skipFiles = { "<node_internals>/**" },
    --
    --   runtimeExecutable = "bun",
    --   runtimeArgs = {
    --     "--inspect-brk",
    --     "jest",
    --     "${file}",
    --     "--runInBand",
    --     "--no-cache",
    --     "--detectOpenHandles",
    --   },
    --   console = "integratedTerminal",
    --   internalConsoleOptions = "neverOpen",
    -- },
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

function load_launchjson()
  local path_to_launch_json = require('utils').get_git_root() .. "/.vscode/launch.json"
  print("Path to launch.json:", path_to_launch_json)

  local is_launch_json_readable = vim.fn.filereadable(path_to_launch_json) == 1

  if is_launch_json_readable then
    print("Before loading dap.configurations", vim.inspect(dap.configurations))
    require('dap.ext.vscode').load_launchjs(path_to_launch_json, {
      ["pwa-node"] = { "typescript", "javascript" }
    })
    print("Loaded launch.json")
  end
end

nnoremap("<leader>0", function()
  load_launchjson()
  -- if already debugging skip the launch.json setup

  dap.continue()
  -- after that constantly check to see if the dap session is active and if not close the session
end)
nnoremap("<leader>8", function()
  dap.terminate()
  dap.terminate()
  dapui.close({})
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
