local M = {}

local jobId = -1
local infoBufferId = -1

local function createBuffer()
  infoBufferId = vim.api.nvim_create_buf(false, true)
  vim.cmd("vsplit")
  return infoBufferId
end

local function writeToBuffer(data)
  if data then
    -- Make it temporarily writable so we don't have warnings.
    vim.api.nvim_buf_set_option(infoBufferId, "readonly", false)
    -- Write to the buffer
    vim.api.nvim_buf_set_lines(infoBufferId, -1, -1, false, data)
    -- Make readonly again.
    vim.api.nvim_buf_set_option(infoBufferId, "readonly", true)
    -- Mark as not modified, otherwise you'll get an error when
    -- attempting to exit vim.
    vim.api.nvim_buf_set_option(infoBufferId, "modified", false)
  end
end

local function createFlutterJob(command)
  if infoBufferId == -1 then
    print("you need to attach first.")
    return
  end

  jobId = vim.fn.jobstart("fvm flutter " .. command, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      if data then
        writeToBuffer(data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        writeToBuffer(data)
      end
    end,
    on_exit = function(_, _)
      print("Flutter exited")
    end
  })
end

local function toggleBuffer()
  -- Check if the buffer is currently visible in any window
  local buf_visible = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == infoBufferId then
      buf_visible = true
      vim.api.nvim_win_close(win, true) -- Close the window to "hide" the buffer
      return
    end
  end

  -- If the buffer is not visible, open it in a vertical split
  if not buf_visible then
    vim.cmd('vsplit')                          -- Open a new vertical split
    vim.api.nvim_set_current_buf(infoBufferId) -- Set the buffer in the new split
  end
end


local function flutterLaunchCommand(command)
  createBuffer()
  vim.api.nvim_set_current_buf(infoBufferId)

  createFlutterJob(command)
end

local function sendCommand(command)
  if jobId ~= -1 then
    vim.fn.chansend(jobId, { command, "" })
  else
    print("You need to attach first.")
  end
end

local function terminateJob()
  if jobId ~= -1 then
    vim.fn.jobstop(jobId)
  else
    print("You need to attach first.")
  end
end

M.launchCommand = flutterLaunchCommand
M.sendCommand = sendCommand
M.terminateJob = terminateJob
M.toggleInfoBuffer = toggleBuffer

return M
