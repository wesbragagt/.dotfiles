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
    },
    JestTest = {
      prompt = [[
        As a Jest expert, write a comprehensive unit test for the following program, aiming to maximize code coverage and ensure thorough testing of edge cases and expected behaviors. Mock dependencies where needed and do not assert unnecessary calls such as loggers. When creating the test context, consider pulling it out to a separate function called testContext where the spies, service and mocks are created. For example:

        function testContext(){
          const mockRepo = createMock<Repo>()
          const service = new Service(mockRepo)
          const spies = {
            repo: jest.spyOn(mockRepo, 'method')
          }
          return {service, spies}
        }
      ]],
      description = "Custom prompt for creating unit tests in javascript using jest.",
      selection = require('CopilotChat.select').visual
    }
  }
})
