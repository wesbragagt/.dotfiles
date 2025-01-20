local dap_ok, dap = pcall(require, "dap")
local nnoremap = require("utils").nnoremap

if not dap_ok then
  return
end

local dapui_ok, dapui = pcall(require, "dapui")

if not dapui_ok then
  return
end

dapui.setup(
  {
    controls = {
      element = "repl",
      enabled = true,
      icons = {
        disconnect = "",
        pause = "",
        play = "",
        run_last = "",
        step_back = "",
        step_into = "",
        step_out = "",
        step_over = "",
        terminate = ""
      }
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
      border = "single",
      mappings = {
        close = { "q", "<Esc>" }
      }
    },
    force_buffers = true,
    icons = {
      collapsed = "",
      current_frame = "",
      expanded = ""
    },
    layouts = { {
        elements = { {
            id = "scopes",
            size = 0.25
          }, {
            id = "breakpoints",
            size = 0.25
          }, {
            id = "stacks",
            size = 0.25
          }, {
            id = "watches",
            size = 0.25
          } },
        position = "left",
        size = 40
      }, {
        elements = { {
            id = "repl",
            size = 0.5
          }, {
            id = "console",
            size = 0.5
          } },
        position = "bottom",
        size = 10
      } },
    mappings = {
      edit = "e",
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      repl = "r",
      toggle = "t"
    },
    render = {
      indent = 1,
      max_value_lines = 100
    }
  }
)

local dap_virtual_text_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")

if not dap_virtual_text_ok then
  return
end

dap_virtual_text.setup({})

-- check existence of ~/.local/share/nvim/lazy/vscode-js-debug/out/src/vsDebugServer.js
local HOME = os.getenv("HOME")
local vscode_js_debug_path = vim.fn.expand(HOME .. "/.local/share/nvim/lazy/vscode-js-debug/out/src/vsDebugServer.js")

if not vim.fn.filereadable(vscode_js_debug_path) == 1 then
  -- log error
  print("vscode-js-debug not found at path:", vscode_js_debug_path)
end

dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = "9229",
  executable = {
    command = "node",
    -- 💀 Make sure to update this path to point to your installation
    args = { vscode_js_debug_path, "9229" },
  },
  cwd = function()
    local _cwd = require("lspconfig").util.root_pattern("package.json")(vim.fn.getcwd())
    print(_cwd)
    return _cwd
  end
}


dap.adapters.python = {
  type = "executable",
  command = "python",
  args = { "-m", "debugpy.adapter" },
  cwd = function()
    local _cwd = require("lspconfig").util.root_pattern("pyproject.toml")(vim.fn.getcwd())
    print(_cwd)
    return _cwd
  end,
  pythonPath = function()
    local VIRTUAL_ENV = "VIRTUAL_ENV"
    local path = os.getenv(VIRTUAL_ENV)
    print(path)
    -- prioritize virtualenv python path
    return path or vim.fn.exepath("python")
  end
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
  },
  {
    name = "Python: Pytest - Current File",
    type = "python",
    request = "launch",
    module = "pytest",
    cwd = "${workspaceFolder}",
    env = {
      PYTHONPATH = "${workspaceFolder}"
    },
    args = {
      "${file}"
    },
    justMyCode = true,
    console = "integratedTerminal"
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
      ["pwa-node"] = { "typescript", "javascript" },
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
