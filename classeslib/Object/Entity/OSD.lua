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

--- On Screen Display.
--
-- This class displays arbitrary lines of text on screen in the given corner.
-- Useful to display debug information and statistics.
--
-- @classmod Object.Entity.OSD

local Vector    = require("caress/Vector")
local error     = require("caress/error")

local _class = {}

local corner = -1
local aabb = Vector.new()
local color = Vector.color()
local text = nil

local game
local graphicsDevice

function _class:init(parent, coh, _corner, _aabb, _color)
  self.super:init(parent)

  game = GAME
  graphicsDevice = game.graphicsDevice

  if _corner == 'top left' then
    corner = 0
  end
  if _corner == 'top right' then
    corner = 1
  end
  if _corner == 'bottom right' then
    corner = 2
  end
  if _corner == 'bottom left' then
    corner = 3
  end
  if corner < 0 then
    error.errhand("Invalid corner value")
  end

  Vector.cpy(_aabb, aabb)
  Vector.cpy(_color, color)
end

function _class:setText(_text)
  text = _text
end

function _class:draw()
  local gd = graphicsDevice

  gd:push()
  gd:origin()

  if not text then
    return
  end

  local scr_width = game.CONFIG.game.baseCanvasWidth
  local scr_height = game.CONFIG.game.baseCanvasHeight
  local scr_aspect = scr_width/scr_height

  local x, y, limit, align

  local _color = gd:getColor()
  gd:setColor(color)

  -- TODO, add support for other corners
  if corner == 0 then
    x = 0
    y = 0

    x = x + aabb.x * scr_width
    y = y + aabb.y * scr_height

    limit = scr_width
    align = "left"
  end

  if corner == 1 then
    x = 240
    y = 0

    limit = 80
    align= "right"
  end

  if corner == 3 then
    x = 0
    y = 168

    limit = scr_width
    align = "left"
  end

  gd:printf(text, x, y, limit, align)
  gd:setColor(_color)
  gd:pop()
end

return _class
