-- Full credits to Tyrir from the Project Zomboid Offical discord
-- Source: https://discord.com/channels/136501320340209664/232196827577974784/1034907613038641262

local MxUtils = {}

--[[
    Usage example:

    local function func(arg1, arg2)
        print(tostring(arg1))
        print(tostring(arg2))
    end
    local debouncedFunc = MxUtils.debounce(func, 5000)

    debouncedFunc("foo", "bar")
]]
MxUtils.debounce = function(func, timeout)
  local intervalTimer = MxUtils.createIntervalTimer(timeout, nil, false)
  return function(...)
    local args = { ... }
    intervalTimer.intervalElapsedEventHandler = function(timer)
      func(unpack(args))
    end
    intervalTimer.start()
  end
end


--[[
  Usage example:

  local intervalTimer = MxUtils.createIntervalTimer(5000, function()
      print("5 seconds have elapsed!")
  end)

  intervalTimer.start()
  -- ...
  intervalTimer.stop()
  intervalTimer.intervalInMilliseconds = 15000
  intervalTimer.intervalElapsedEventHandler = function(timer)
      print("15 seconds have elapsed, but it will be 25 seconds next time!")
      timer.intervalInMilliseconds = 25000
      timer.myData = timer.myData or {}
      if not timer.myData.doneSomething then
          -- do something
          timer.myData.doneSomething = true
      end
  end
  intervalTimer.autoRestart = false
  intervalTimer.start()
]]
MxUtils.createIntervalTimer = function(intervalInMilliseconds, intervalElapsedEventHandler,
                                       autoRestart, pollingEventName)
  local timer
  timer = {
    intervalInMilliseconds = intervalInMilliseconds,
    intervalElapsedEventHandler = intervalElapsedEventHandler,
    pollingEventName = pollingEventName or "OnTick", -- Consider Events.OnTickEvenPaused
    autoRestart = autoRestart == nil or autoRestart,
    poll = function(tickCounter)
      local time = math.floor(os.time() * 1000)
      if os.difftime(time, timer.nextIntervalTime) >= 0 then
        if not timer.autoRestart then
          timer.stop()
        end
        timer.nextIntervalTime = time + timer.intervalInMilliseconds
        timer.intervalElapsedEventHandler(timer)
      end
    end,
    stop = function()
      Events[timer.pollingEventName].Remove(timer.poll)
      timer.isRunning = false
      return timer
    end,
    start = function()
      timer.nextIntervalTime = math.floor(os.time() * 1000) + timer.intervalInMilliseconds
      if not timer.isRunning then
        Events[timer.pollingEventName].Add(timer.poll)
        timer.isRunning = true
      end
      return timer
    end,
  }

  return timer
end

-- MxUtils.tableForEach = function(table, callback)
--   for index, value in ipairs(table) do
--     callback(value, index, table)
--   end
-- end

return MxUtils