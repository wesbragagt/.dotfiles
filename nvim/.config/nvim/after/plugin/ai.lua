local ok_copilot_chat, copilot_chat = pcall(require, "CopilotChat")

if not ok_copilot_chat then
  print("Copilot chat plugin not installed")
  return
end

copilot_chat.setup({
  debug = true,
  prompts = {
    PytestTest = {
      prompt = [[
        As a Python pytest expert, write a comprehensive unit test for the following program, aiming to maximize code coverage and ensure thorough testing of edge cases and expected behaviors. Mock dependencies where needed and do not assert unnecessary calls such as loggers.
      ]],
      description = "Custom prompt for creating unit tests in python using pytest.",
      selection = require('CopilotChat.select').visual
    }
  }
})
