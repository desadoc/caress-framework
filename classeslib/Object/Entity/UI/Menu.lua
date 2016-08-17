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

--- Menu
--
-- Basic menu implementation, currently supports vertical, horizontal and grid
-- menus.
--
-- @classmod Object.Entity.UI.Menu

local Vector  = require("caress/Vector")
local List    = require("caress/collection").List

local _class = {}

local pos
local size
local textColor

local cancelable
local items
local columns
local cursor
local currSelPos

local game
local graphicsDevice

function _class:init(parent, layer, coh, params)
  self.super:init(parent, layer, coh)

  game = _game
  graphicsDevice = game.graphicsDevice

  params = params or {}

  items = params.items or List.new()
  cancelable = params.cancelable
  columns = params.columns or 1
  currSelPos = Vector.new(1, 1)

  cursor = params.cursor

  local scrWidth, scrHeight = game:getTargetDimensions()

  local rows = math.ceil(items:size()/columns)

  pos = params.pos or Vector.new(scrWidth*0.2, scrHeight*0.1)
  size = params.size or Vector.new(scrWidth*0.6, rows*scrHeight*0.1)
  textColor = params.textColor or Vector.color(255, 255, 255)
end

function _class:isValidCursorPos(x, y)
  if x < 1 or y < 1 then
    return false
  end

  if x > columns then
    return false
  end

  if y > self:getColumnHeight(x) then
    return false
  end

  local itemCount = items:size()
  return ((y-1)*columns + x) <= itemCount
end

function _class:getColumnHeight(i)
  local completeRows = math.modf(items:size(), columns)
  local itemsOnIncompleteRow = math.fmod(items:size(), columns)

  return completeRows + ((i <= itemsOnIncompleteRow) and 1 or 0)
end

function _class:getRowLength(j)
  local completeRows = math.modf(items:size(), columns)
  local itemsOnIncompleteRow = math.fmod(items:size(), columns)

  if j <= completeRows then
    return columns
  else
    return itemsOnIncompleteRow
  end
end

function _class:getItemAt(x, y)
  if not self:isValidCursorPos(x, y) then
    return nil
  end

  return items:at(((y-1)*columns + x))
end

function _class:inputEventListener(event)
  local key = event.data.key

  if cancelable then
    if key == "pause" or key == "b" then
      self:emit("finished")

      event.consumed = true
    end
  end

  if key == "down" then
    if self:isValidCursorPos(currSelPos.x, currSelPos.y+1) then
      currSelPos.y = currSelPos.y + 1
    else
      currSelPos.y = 1
    end

    event.consumed = true
  end

  if key == "up" then
    if self:isValidCursorPos(currSelPos.x, currSelPos.y-1) then
      currSelPos.y = currSelPos.y - 1
    else
      currSelPos.y = self:getColumnHeight(currSelPos.x)
    end

    event.consumed = true
  end

  if key == "right" then
    if self:isValidCursorPos(currSelPos.x+1, currSelPos.y) then
      currSelPos.x = currSelPos.x + 1
    else
      currSelPos.x = 1
    end

    event.consumed = true
  end

  if key == "left" then
    if self:isValidCursorPos(currSelPos.x-1, currSelPos.y) then
      currSelPos.x = currSelPos.x - 1
    else
      currSelPos.x = self:getRowLength(currSelPos.y)
    end

    event.consumed = true
  end

  if key == "a" or key == "menu" then
    self:emit("selection", self:getItemAt(currSelPos.x, currSelPos.y).data)

    event.consumed = true
  end

  return "keep"
end

function _class:main(coh)
  self:on(game.input, "input.keypressed", self.inputEventListener)
  self:on(self, "finished", function(self, event)
    self:off(game.input, "input.keypressed")
    return "remove"
  end)
end

function _class:draw()
  local gd = graphicsDevice
  local scrWidth, scrHeight = game:getTargetDimensions()

  gd:renderTo(function()
    gd:origin()

    local items_size = items:size()

    local rowHeight   = size.y/math.ceil(items_size/columns)
    local cursorWidth = rowHeight
    local columnWidth = size.x/columns - cursorWidth
    
    gd:setColor(textColor)

    for i=1,items_size do

      local item_y = math.ceil(i/columns)
      local item_x = i - (item_y-1)*columns

      local y_ofs = (item_y-1)*rowHeight
      local x_ofs = (item_x-1)*columnWidth + item_x*cursorWidth

      local selected =
        self:getItemAt(currSelPos.x, currSelPos.y) == items:at(i)

      gd:rawPrintf(
        items:at(i).text,
        pos.x+x_ofs, pos.y+y_ofs, columnWidth, "left")
    end

    if cursor then
      gd:draw(
        cursor,
        pos.x + (currSelPos.x-1)*(columnWidth + cursorWidth) + cursorWidth*0.5,
        pos.y + (currSelPos.y-1)*rowHeight + cursorWidth*0.2
        ) 
    else
      local cursorAABB = Vector.new(
        pos.x + (currSelPos.x-1)*(columnWidth + cursorWidth) + cursorWidth*0.5,
        pos.y + (currSelPos.y-1)*rowHeight + cursorWidth*0.2,
        cursorWidth*0.4,
        cursorWidth*0.4
      )
      gd:drawAABB("fill", cursorAABB, Vector.color(255, 255, 255))
    end
  end, self.layer)
end

return _class
