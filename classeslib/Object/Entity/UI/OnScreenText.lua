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

--- On Screen Text class
--
-- Text displaying entity suited for info panels and dialogs, it implements a
-- typing effect.
--
-- @classmod Object.Entity.UI.OnScreenText

local classes = require("caress/classes")
local text_lib    = require("caress/text")

local _class = {}

local baseSpeed = 10
local text, px, py, limit, progress, _progress

local game
local graphicsDevice

function _class:init(parent, layer, coh, _text, _px, _py, _limit)
  self.super:init(parent, layer, coh)
  
  game = _game
  graphicsDevice = game.graphicsDevice

  local font = game.graphicsDevice:getFont()


  local lines = text_lib.breakText(_text, function(str)
    return font:getWidth(str) <= _limit
  end)

  text = ""
  for _, line in ipairs(lines) do
    text = text .. line .. "\n"
  end

  px = _px
  py = _py
  limit = _limit
  progress = 0
  _progress = 0.0
end

local string_len = string.len
local string_sub = string.sub

function _class:main(coh)

  local btnPressesCount = 0

  self:on(game.input, "input.keypressed", function(self, evt)
    local key = evt.data.key

    if key == "a" or key == "b" then
      if btnPressesCount > 0 then
        _progress = string_len(text)
      end
      btnPressesCount = btnPressesCount + 1
    end
    
    return "keep"
  end)

  coh:custom(function()
    return progress > string_len(text)
  end):wait()

  coh:time(0.5):wait()

  coh:any(
    coh:keypress(game.input, "a"),
    coh:keypress(game.input, "b")
  ):wait()
  self:emit("finished")
end

function _class:update(dt)
  self.super:update(dt)
  
  local speed

  if game.input:isDown("a") or game.input:isDown("b") then
    speed = baseSpeed * 8.0
  else
    speed = baseSpeed
  end
  
  _progress = _progress + speed*dt
  progress = math.modf(_progress)
end

function _class:draw()
  local gd = graphicsDevice
  gd:rawPrintf(string_sub(text, 1, progress), px, py, limit)
end

return _class
