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

local textList
local width
local aligning
local currIter

function _class:init(parent, layer, coh, _textList, _width, _aligning)
  self.super:init(parent, layer, coh)

  game = _game

  textList = _textList or List.new{"CHANGEME_1", "CHANGEME_2", "CHANGEME_3"}
  width = _width or 9999
  aligning = _aligning or "left"
  
  currIter = textList:begin()
  
  self:setSize(Vector.new(0, game.graphicsDevice:getFont():getHeight()))
end

function _class:draw()
  local gd = game.graphicsDevice
  
  local text = textList:at(currIter)
  
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
  if currIter == textList:finish() then
    currIter = textList:begin()
    return
  end
  
  currIter = textList:next(currIter)
end

function _class:previous()
  if currIter == textList:begin() then
    currIter = textList:finish()
    return
  end
  
  currIter = textList:previous(currIter)
end

function _class:getCurrentItem()
  return textList:at(currIter)
end

function _class:setCurrentIndex(index)
  currIter = textList:indexToIterator(index)
end

function _class:getCurrentIndex(index)
  return textList:iteratorToIndex(currIter)
end

return _class
