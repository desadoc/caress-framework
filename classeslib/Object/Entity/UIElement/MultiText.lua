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

--- MultiText
--
-- A UIElement that can show many different lines, one at time
--
-- @classmod Object.Entity.UIElement.MultiText

local _class = {}

local Vector  = require("caress/Vector")
local List    = require("caress/collection").List

local game

local items
local width
local aligning
local currIter

function _class:init(parent, layer, coh, _items, _width, _aligning)
  self.super:init(parent, layer, coh)

  game = _game

  items = _items or List.new{
    {text="CHANGEME_1", data="changeme_1"},
    {text="CHANGEME_2", data="changeme_2"}
  }
  
  width = _width or 9999
  aligning = _aligning or "left"
  
  currIter = items:begin()
  
  self:setSize(Vector.new(0, game.graphicsDevice:getFont():getHeight()))
end

function _class:draw()
  local gd = game.graphicsDevice
  
  local text = items:at(currIter).text
  
  local actualText
  if type(text) == "string" then
    actualText = text
  end
  if type(text) == "function" then
    actualText = text()
  end
  
  gd:rawPrintf(actualText, self:getPosition().x, self:getPosition().y, width, aligning)
end

function _class:next()
  if currIter == items:finish() then
    currIter = items:begin()
    return
  end
  
  currIter = items:next(currIter)
end

function _class:previous()
  if currIter == items:begin() then
    currIter = items:finish()
    return
  end
  
  currIter = items:previous(currIter)
end

function _class:getCurrentItem()
  return items:at(currIter)
end

function _class:setCurrentItem(_itemData)
  for iter, item in items:iterator() do
    if item.data == _itemData then
      currIter = iter
      break
    end
  end
end

return _class
