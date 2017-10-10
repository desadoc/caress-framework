-- Caress-Lib, a lua library for games.
-- Copyright (C) 2016, 2017,  Erivaldo Filho "desadoc@gmail.com"

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

--- Input class.
--
-- An instance of this class is created somwhere and receives events, which it
-- translates into @{Object} events.
--
-- Entities interested in input events should add themselves as listeners
-- of events sent by this class by using either @{Object.Entity}'s on/off API
-- or @{Object.Cohandler}'s event conditions.
--
-- This class also acts as an abstracting over real control method. It maps
-- keyboard or gamepad buttons to virtual buttons, which currently are 'A',
-- 'B', 'C', 'D', 'Up', 'Down', 'Right', 'Left', 'Menu', 'Pause' and some extra
-- buttons that you can find at 'conf.lua'.
--
-- @classmod Object.Entity.Input

local keyboard      = require("keyboard")
local collection    = require("collection")

local _class = {}

local inputEvents = collection.List.new()
local mapping
local reverseMapping
local lastActiveDevice

local gamepad
local mapping

function _class:init(parent, coh, inputMapping, _gamepad)
  self.super:init(parent)

  gamepad = _gamepad
  mapping = inputMapping

  self:loadMapping()
end

function _class:getLastActiveDevice()
  return lastActiveDevice
end

function _class:loadMapping()
  mapping = {}
  mapping.keyboard = mapping.keyboard
  mapping.gamepad = mapping.gamepad

  reverseMapping = {}
  reverseMapping.keyboard = {}
  reverseMapping.gamepad = {}

  for k, v in pairs(mapping.keyboard) do
    reverseMapping.keyboard[v] = k
  end

  for k, v in pairs(mapping.gamepad) do
    reverseMapping.gamepad[v] = k
  end
end

function _class:main(cohandler)
end

--- Updates input, emitting all events received in the past frame.
function _class:update(dt)
  for iter, item in inputEvents:iterator() do
    if item.type == "keypressed" then
      self:emit("keypressed", item)
    end
    if item.type == "keyreleased" then
      self:emit("keyreleased", item)
    end
  end

  inputEvents = collection.List.new()
end

function _class:registerKeyboardInput(type, key, isRepeat)
  lastActiveDevice = "keyboard"

  local nativeKey = key

  if reverseMapping.keyboard[key] then
    key = reverseMapping.keyboard[key]
  end

  inputEvents:push_back({type=type, key=key, isRepeat=isRepeat, device="keyboard", nativeKey=nativeKey})
end

function _class:registerGamepadInput(type, key, isRepeat)
  lastActiveDevice = "gamepad"

  local nativeKey = key

  if reverseMapping.gamepad[key] then
    key = reverseMapping.gamepad[key]
  end

  inputEvents:push_back({type=type, key=key, isRepeat=isRepeat, device="gamepad", nativeKey=nativeKey})
end

function _class:isDown(key)

  local gamepadDown
  local keyboardDown

  if gamepad then
    local gamepadKey = mapping.gamepad[key]
    if gamepadKey then
      gamepadDown = gamepad:isGamepadDown(gamepadKey)
    end
  end

  local keyboardKey = mapping.keyboard[key]
  if keyboardKey then
    keyboardDown = keyboard.isDown(keyboardKey)
  end

  return gamepadDown or keyboardDown
end

function _class:getMapping()
  return mapping
end

function _class:getReverseMapping()
  return reverseMapping
end

return _class
