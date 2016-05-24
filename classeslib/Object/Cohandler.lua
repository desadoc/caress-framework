-- Caress, a small framework for games in lua and love.
-- Copyright (C) 2016  Erivaldo Filho "desadoc@gmail.com"

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.

-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

--- Coroutine Handler class
--
-- This class wraps a coroutine, making it easier to run async code and to
-- synchronize it's execution with time, event and other types of conditions.
-- A typical usage cenario is "coh:time(1.0):wait()", which makes the current
-- coroutine to wait 1s before resuming.
--
-- @classmod Object.Cohandler

local classes   = require("caress/classes")
local error     = require("caress/error")

local _class = {}

local dead = false
local frameTimeLimit = nil

function _class.setFrameTimeLimit(limit)
  frameTimeLimit = limit or 12/1000.0
end
_class.setFrameTimeLimit()

local function createCoroutine(func)
  return coroutine.create(function(...)
    xpcall(
      func,
      function(err)
        print(err .. "\n" .. debug.traceback() .. "\n")
      end,
      ...
    )
  end)
end

function _class:init(func)
  self.func = func
  self.co = createCoroutine(func)
end

-- resumes a coroutine and saves yielded update function as coroutine's request
local function __run(cohandler, ...)
  local r1, r2 = coroutine.resume(cohandler.co, ...)
  if not r1 then
    error.errhand(r2)
  end
end

--- Runs a coroutine for the first time.
-- Runs a coroutine and also passes itself as the first parameter.
-- @param ... Additional parameters to pass to the coroutine.
function _class:run(...)
  self:resumeCoroutine(self, ...)
end

function _class:resumeCoroutine(...)
  if not self:isDead() then
    self.resumeTime = love.timer.getTime()
    __run(self, ...)
  end
end

--- Resumes a coroutine.
function _class:resume()
  -- check if it's really paused.
  if not self.condition or not self.condition:isPaused() then
    return
  end

  self.condition:resume()
end

function _class:pause()
  if not self.condition or self.condition:isPaused() then
    return
  end

  self.condition:pause()
end

function _class:kill()
  dead = true
end

--- Updates a coroutine.
-- Calls coroutine's task update function and resumes it in case
-- it returns true. Additional values returned by the task are passed on to the
-- coroutine. This function is intended to be called by entities every frame
-- for every coroutine it has spawned and not yet ended.
-- @param ... Additional parameters to pass to task function
function _class:update(...)
  self.condition:update(...)
end

function _class:checkResultAndResume()
  local r = {self.condition:result()}

  if r[1] then
    self:resumeCoroutine(unpack(r))
  end
end

--- Returns true if it hasn't finished.
function _class:isDead()
  return dead or coroutine.status(self.co) == "dead"
end

function _class:isPaused()
  return not self:isDead() and self.condition and self.condition:isPaused()
end

--- Returns elapsed time since last time coroutine was resumed.
function _class:getElapsedTime()
  return love.timer.getTime() - self.resumeTime
end

--- Yields if elapsed time is above limit threshold.
function _class:checkTimeLimit()
  if self:getElapsedTime() >= frameTimeLimit then
    self:wait()
  end
end

--- Makes coroutine yield and wait until 'condition' is satisfied.
function _class:wait(condition)
  condition = condition or self:custom(function() return true end)

  self.condition = condition
  condition:enable()
  local r = {coroutine.yield()}
  condition:disable()
  self.condition = nil

  return unpack(r)
end

local Condition = classes.Object.Condition

--- Custom wait condition.
-- Returns a custom condition that is satisfied when 'cb' return true. Upon
-- resume returns value return by 'cb'.
function _class:custom(cb)
  return Condition.CustomCondition(self, cb)
end

--- Time condition.
-- Returns a condition that is satisfied when at least 'amount' seconds have
-- passed. Upon resume, returns total elapsed time.
function _class:time(amount)
  return Condition.TimeCondition(self, amount)
end

--- Event condition.
-- Returns a condition that is satisfied when source emits an event under
-- 'name'. Upon resume, returns the event emitted.
function _class:event(source, name, cb)
  return Condition.EventCondition(self, source, name, cb)
end

--- Key press condition.
-- Returns a condition that is satisfied when 'input' emits a key press event
-- for 'key'. Upon resume, returns the key press event.
function _class:keypress(input, key)
  return Condition.EventCondition(
    self, input, "input.keypressed",
    function(evt) if evt.data.key == key then return evt end end
  )
end

--- Key release condition.
-- Returns a condition that is satisfied when 'input' emits a key release event
-- for 'key'. Upon resume, returns the key release event.
function _class:keyrelease(input, key)
  return Condition.EventCondition(
    self, input, "input.keyreleased",
    function(evt) if evt.data.key == key then return evt end end
  )
end

local function processMultiConditionArgs(...)
  local args = {...}
  local conditions = nil

  if #args == 1 and not args[1].class then
    conditions = args[1]
  else
    conditions = args
  end

  return conditions
end

--- Multi condition 'all'.
-- Returns a condition that is satisfied when all conditions passed as
-- parameter are satisfied simultaneously. Upon resume, returns an array
-- containing the return of every condition.
function _class:all(...)
  return Condition.MultiCondition.AllCondition(
    self, processMultiConditionArgs(...)
  )
end

--- Multi condition 'one'.
-- Returns a condition that is satisfied when at least one condition passed as
-- parameter is satisfied. Upon resume, returns the returned value from the
-- first satisfied condition. 
function _class:one(...)
  return Condition.MultiCondition.OneCondition(
    self, processMultiConditionArgs(...)
  )
end

--- Multi condition 'any'.
-- Returns a condition that is satisfied when any of the conditions passed as
-- parameter is satisfied. Upon resume, returns an array containing the return
-- of every condition that was satisfied and nil for conditions that didn't
-- complete.
function _class:any(...)
  return Condition.MultiCondition.AnyCondition(
    self, processMultiConditionArgs(...)
  )
end

return _class
