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
-- @classmod Object.Entity.UIElement.Menu

local Vector  = require("caress/Vector")
local List    = require("caress/collection").List
local classes = require("caress/classes")

local UIElement = classes.Object.Entity.UIElement
local TextLine  = UIElement.TextLine

local _class = {}
_class._static = function()
  local methods = {}

  methods.columns = {}
  methods.columns.layout = function(columnCount, columnWidth, rowHeight)
    local updateFunc = function(menu, items, dt)
      local menuRect = menu:getRectangle()
      local column, row

      column = 0
      row = 1
      
      local offset = Vector.new()

      for _, item in items:iterator() do
        column = column + 1
        if column > columnCount then
          column = 1
          row = row + 1
        end
        
        if item.offset then
          Vector.add(offset, item.offset, offset)
        end

        item.element:setRectangle(Vector.new(
          menuRect.x + columnWidth*(column-1) + menu:getCursor():getSize().x + offset.x,
          menuRect.y + rowHeight*(row-1) + offset.y,
          columnWidth,
          rowHeight
        ))
      end
    end

    return updateFunc
  end

  methods.columns.navigation = function(columnCount)
    local updateFunc = function(menu, currItem, items, inputEvent)
      local key = inputEvent.data.key
      inputEvent.consumed = true

      local selIndex = 0
      for _, item in items:iterator() do
        selIndex = selIndex + 1
        if currItem == item then
          break
        end
      end

      -- nothing selected
      if selIndex == 0 then
        return items:front()
      end

      if key == "down" then
        if (selIndex + columnCount) > items:size() then
          return
        end

        return items:at(selIndex + columnCount)
      end

      if key == "up" then
        if (selIndex - columnCount) <= 0 then
          return
        end

        return items:at(selIndex - columnCount)
      end

      if key == "right" then
        if (selIndex + 1) > items:size() then
          return
        end

        return items:at(selIndex + 1)
      end

      if key == "left" then
        if (selIndex - 1) <= 0 then
          return
        end

        return items:at(selIndex - 1)
      end
    end

    return updateFunc
  end

  methods.textItem = function(coh, text)
    return TextLine(nil, nil, coh, text)
  end
  
  methods.imageCursor = function(coh, imageFilename)
    return UIElement.Cursor.ImageCursor(nil, nil, coh, _game.assetCache:load(imageFilename))
  end

  return methods
end

local textColor

local cancelable
local items
local cursor

local currItem

local layoutFunc
local navigationFunc

local game
local graphicsDevice

function _class:init(parent, layer, coh, params)
  self.super:init(parent, layer, coh)

  game = _game
  graphicsDevice = game.graphicsDevice

  params = params or {}

  items = params.items or List.new()

  for _, item in items:iterator() do
    item.element.parent = self
  end

  currItem = not items:is_empty() and items:front()
  cancelable = params.cancelable

  cursor = params.cursor or UIElement.Cursor.SimpleCursor(nil, nil, coh)
  
  cursor.layer = layer
  cursor.parent = self

  layoutFunc = params.layout or self.class.columns.layout(1, 960, 16)
  navigationFunc = params.navigation or self.class.columns.navigation(1)

  textColor = params.textColor or Vector.color(255, 255, 255)

  local scrWidth, scrHeight = game:getTargetDimensions()

  local pos = params.pos or Vector.new(scrWidth*0.2, scrHeight*0.1)
  local size = params.size or Vector.new(scrWidth*0.6, scrHeight*0.8)

  self:setRectangle(Vector.new(pos.x, pos.y, size.x, size.y))
end

function _class:update(dt)
  layoutFunc(self, items, dt)
  cursor:setItem(currItem.element)
  
  self.super:update(dt)
end

function _class:inputEventListener(inputEvent)
  local key = inputEvent.data.key

  if self:isCancelable() then
    if key == "pause" or key == "b" then
      self:emit("finished")
      return "keep"
    end
  end

  if key == "a" or key == "menu" then
    local actualData
    if type(currItem.data) == "function" then
      actualData = currItem.data()
    else
      actualData = currItem.data
    end
    
    self:emit("selection", actualData)
    inputEvent.consumed = true
    return "keep"
  end

  local newSelection = navigationFunc(self, currItem, items, inputEvent)
  if newSelection then
    currItem = newSelection
  end

  return "keep"
end

function _class:main(coh)

  cursor:start()
  
  for _, item in items:iterator() do
    item.element:start()
  end

  self:on(game.input, "input.keypressed", self.inputEventListener)
  self:on(self, "finished", function(self, event)
    self:off(game.input, "input.keypressed")
    return "remove"
  end)
end

function _class:getCursor()
  return cursor
end

function _class:isCancelable()
  return cancelable
end

function _class:draw()
  local gd = graphicsDevice
  local scrWidth, scrHeight = game:getTargetDimensions()

  gd:origin()
  gd:setColor(textColor)

  for _, item in items:iterator() do
    self:drawChild(item.element)
  end
  
  self:drawChild(cursor)
end

return _class
