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

--- MenuItem
--
-- @classmod Object.Entity.UIElement.MenuItem

local _class = {}

local Vector  = require("caress/Vector")

local game

local innerElement
local data
local selected

function _class:init(parent, layer, coh, _item)
  self.super:init(parent, layer, coh)

  game = _game

  innerElement = _item.element
  data = _item.data
  self.itemParams = _item
  
  innerElement.parent = self
end

function _class:main(coh)
  innerElement:start()
end

function _class:update(dt)
  local cursor = self.parent:getCursor()

  local x, y

  if cursor:isFusedOnX() then
    x = self:getPosition().x
  else
    x = self:getPosition().x + cursor:getSize().x
  end

  if cursor:isFusedOnY() then
    y = self:getPosition().y
  else
    y = self:getPosition().y + cursor:getSize().y
  end
  
  local yOfs = math.ceil((self:getSize().y - innerElement:getSize().y)/2)

  innerElement:setPosition(Vector.new(x, y + yOfs))
  innerElement:update(dt)
end

function _class:setHasCursor(value)
  self.super:setHasCursor(value)
  innerElement:setHasCursor(value)
end

function _class:draw()
  innerElement:draw()
end

function _class:getInnerElement()
  return innerElement
end

function _class:getData()
  return data
end

function _class:setSelected(value)
  selected = value
end

function _class:isSelected()
  return selected
end

return _class
