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

--
--- Object class.
--
-- Basic Object class. It's only feature is to implement a basic interface for
-- event emitting and listening. It shouldn't be used directly in most cases,
-- instead, see @{Object.Entity}.
--
-- @classmod Object

local collection    = require("caress/collection")
local error_errhand = require("caress/error").errhand

local _class = {}

local listeners = {}

local ipairs = ipairs
local string_gmatch = string.gmatch
local table_insert = table.insert

local function splitString(str, delimiter)
  local result = {}
  for w in string_gmatch(str, "(%a+)%.?") do
    table_insert(result, w)
  end
  return result
end

--- Adds a listener function to an event name.
-- @param eventName Identifier in the form 'name.subname.subsubname'. A
--                  listener added for 'name' receives also all events with
--                  names starting with 'name'. A listener added to nil listens
--                  to all events.
-- @param listener Function with signature func(evtObj).
function _class:addEventListener(eventName, listener)
  local t = listeners

  if eventName then
    for _, name in ipairs(splitString(eventName, ".")) do
      if not t[name] then
        t[name] = {}
      end
      t = t[name]
    end
  end

  if not t._l then
    t._l = collection.List.new()
  end
  t._l:push_back(listener)

  return listener
end

local function _removeEventListener(self, eventName, listener)
  local t = listeners

  if eventName then
    for _, name in ipairs(splitString(eventName, ".")) do
      -- error? no listeners found for this event name
      if not t then
        break
      end
      t = t[name]
    end
  end

  if t and t._l then
    return t._l:remove(listener)
  end
end

--- Removes a listener added with @{addEventListener}.
-- @param eventName Must match name used when listener was added.
-- @param listener Same function that was added with @{addEventListener}
function _class:removeEventListener(eventName, listener)
  return _removeEventListener(self, eventName, listener)
end

local function __emit(self, name, t, evtObj)
  if not t._l then
    return
  end

  -- fix list of listeners in a new collection, because it can change as
  -- listeners are triggered and their logic add new listeners
  local listeners = t._l:clone()

  local listenersToRemove = collection.List.new()

  local opt

  for _, listener in listeners:iterator() do
    opt = listener(evtObj)
    if opt ~= "keep" and opt ~= "remove" then
      error_errhand("Invalid listener return '" .. (opt and opt or "nil") .. "'")
    end
    if opt == "remove" then
      listenersToRemove:push_back(listener)
    end
  end


  local listenersToKeep = collection.List.new()

  for _, listener in t._l:iterator() do
    if not listenersToRemove:contains(listener) then
      listenersToKeep:push_back(listener)
    end
  end

  t._l = listenersToKeep
end

function _class:_emit(evtObj)
  local name = evtObj.name
  local t = listeners

  __emit(self, name, t, evtObj)

  if evtObj.consumed then
    return
  end

  if name then
    for _, _name in ipairs(splitString(name, ".")) do
      if not t[_name] then
        return
      end
      t = t[_name]
      __emit(self, name, t, evtObj)

      if evtObj.consumed then
        return
      end
    end
  end
end

local type = type

--- Emits an event.
-- Emits an event to all listeners registered for this event's name or names
-- that starts with it. If parameter 'arg1' is a table, it's expected that it
-- contains a field name and 'arg2' is ignored. This is useful because allows
-- this method to be called in the form 'self:emit{}'. If 'arg1' is a string,
-- it's used as an event name and 'arg2' as event data.
-- @param arg1 Event object or event name.
-- @param arg2 Optional event data. Ignored if arg1 is a table.
function _class:emit(arg1, arg2)
  local evtObj

  if type(arg1) == "table" then
    evtObj = arg1
  elseif type(arg1) == "string" then
    evtObj = {name=arg1, data=arg2}
  else
    error_errhand("Invalid parameters")
  end

  evtObj.source = self
  evtObj.origin = self

  self:_emit(evtObj)
end

--- Reemits an event.
-- When first emitted, both source and origin fields on an event object are
-- equals to the object that emitted it. A reemitted event allows other objects
-- to propagate an event. In this case, the origin attribute is set to the
-- object that reemitted it.
-- @param evtObj Event object previously received.
function _class:reemit(evtObj)
  evtObj.origin = self
  self:_emit(evtObj)
end

--- Removes all listeners.
function _class:clearListeners()
  listeners = {}
end

return _class
