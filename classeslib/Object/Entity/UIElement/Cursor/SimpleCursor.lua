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

--- Cursor
--
-- @classmod Object.Entity.UIElement.Cursor

local Vector  = require("caress/Vector")

local _class = {}

local game

local math_floor = math.floor

function _class:init(parent, coh)
  self.super:init(parent, coh)

  game = GAME

  self:setSize(Vector.new(12, 12))

  self:setFusedOnX(false)
  self:setFusedOnY(true)
end

function _class:draw()

  local gd = game.graphicsDevice

  local item = self:getItem()

  local pos = Vector.new(
    item:getPosition().x - self:getSize().x,
    item:getPosition().y
  )

  local actualSize = self:getSize().x*0.6
  local yOfs = math_floor((item:getSize().y - actualSize)/2)
  
  local cursorAABB = Vector.new(
    pos.x + (self:getSize().x - actualSize)/2,
    pos.y + yOfs,
    actualSize,
    actualSize
  )
  gd:drawAABB("fill", cursorAABB)
end

return _class
