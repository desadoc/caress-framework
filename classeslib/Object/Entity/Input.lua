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

--- Input class.
--
-- An instance of this class is created at Game and made available on
-- 'game.input'. The game instance then passes all love input events to it, and
-- it translates these love events as @{Object} events.
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

local collection    = require("caress/collection")

local _class = {}

local inputEvents = collection.List.new()
local mapping
local reverseMapping

local gamepad

local game

function _class:init(parent, _, coh, _gamepad)
  self.super:init(parent, nil, coh)

  game = _game

  gamepad = _gamepad

  self:loadMapping()
end

function _class:loadMapping()
  mapping = {}
  mapping.keyboard = game.CONFIG.game.inputMapping.keyboard
  mapping.gamepad = game.CONFIG.game.inputMapping.gamepad

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
      self:emit("input.keypressed", item)
    end
    if item.type == "keyreleased" then
      self:emit("input.keyreleased", item)
    end
  end

  inputEvents = collection.List.new()
end

function _class:registerKeyboardInput(type, key, isRepeat)
  if reverseMapping.keyboard[key] then
    key = reverseMapping.keyboard[key]
  end

  inputEvents:push_back({type=type, key=key, isRepeat=isRepeat})
end

function _class:registerGamepadInput(type, key, isRepeat)
  if reverseMapping.gamepad[key] then
    key = reverseMapping.gamepad[key]
  end

  inputEvents:push_back({type=type, key=key, isRepeat=isRepeat})
end

function _class:isDown(key)
  if game.CONFIG.game.useGamepad then
    if mapping.gamepad[key] then
      key = mapping.gamepad[key]
    else
      print("unknown key: " .. key)
    end

    return gamepad:isGamepadDown(key)
  else
    if mapping.keyboard[key] then
      key = mapping.keyboard[key]
    else
      print("unknown key: " .. key)
    end

    return love.keyboard.isDown(key)
  end
end

return _class
