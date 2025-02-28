local plugin = require("flutter-launch")

vim.api.nvim_create_user_command("FlutterAttach", function()
  plugin.launchCommand("attach")
end, {})
vim.api.nvim_create_user_command("FlutterRun", function()
  plugin.launchCommand("run")
end, {})
vim.api.nvim_create_user_command("FlutterHotReload", function()
  plugin.sendCommand("r")
end, {})
vim.api.nvim_create_user_command("FlutterHotRestart", function()
  plugin.sendCommand("R")
end, {})
vim.api.nvim_create_user_command("FlutterDetach", function()
  plugin.terminateJob()
end, {})
vim.api.nvim_create_user_command("FlutterInfoToggle", function()
  plugin.toggleInfoBuffer()
end, {})
vim.api.nvim_create_user_command("FlutterAttachToDebugger", function()
  plugin.attachToDebugger()
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("FlutterReloadOnSave", {}),
  pattern = { "*.dart" },
  callback = function(_) plugin.sendCommand("r") end,
})
