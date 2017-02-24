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

--- Sprite class.
--
-- Represents a single sprite in a sprite sheet.
--
-- @classmod Object.Sprite

local _class = {}

local spriteSheet
local quad
local width
local height

function _class:init(_spriteSheet, _spriteData)
  spriteSheet = _spriteSheet

  quad    = _spriteData.quad
  width   = _spriteData.width
  height  = _spriteData.height
end

function _class:getSpriteSheet()
  return spriteSheet
end

function _class:getQuad()
  return quad
end

function _class:getWidth()
  return width
end

function _class:getHeight()
  return height
end

return _class
