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

--- ImageCursor
--
-- @classmod Object.Entity.UIElement.ImageCursor

local Vector  = require("caress/Vector")

local _class = {}

local game
local image

local math_ceil = math.ceil

function _class:init(parent, coh, _image)
  self.super:init(parent, coh)

  game = GAME
  image = _image

  self:setSize(Vector.new(image:getWidth(), image:getHeight()))

  self:setFusedOnX(false)
  self:setFusedOnY(true)
end

function _class:draw()

  local gd = game.graphicsDevice
  local pos = self:getItem():getPosition()
  
  local yOfs = math_ceil((self:getItem():getSize().y - self:getSize().y)/2)
  gd:draw(
    image,
    pos.x,
    pos.y + yOfs
  )
end

return _class
