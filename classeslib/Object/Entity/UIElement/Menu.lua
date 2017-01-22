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

  methods.gridLayout = function(horizontal, columnCount, columnWidth, rowCount, rowHeight)
    local _new = {
      update = function(self, items)

        if horizontal then
          columnCount = columnCount or 4
        else
          rowCount = rowCount or 6
        end

        columnWidth = columnWidth or 360
        rowHeight = rowHeight or 60

        self.grid = {}

        if horizontal then
          self.width = columnCount
          self.height = math.ceil(items:size()/columnCount)
        else
          self.width = math.ceil(items:size()/rowCount)
          self.height = rowCount
        end

        for i=1,self.width do
          self.grid[i] = {}
        end

        local column, row = 1, 1
        local offset = Vector.new()

        local origin = self.parent:getPosition()

        for _, item in items:iterator() do

          if item.itemParams.offset then
            offset = item.itemParams.offset + offset
          end

          item:setRectangle(Vector.new(
            origin.x + (column-1)*columnWidth + offset.x,
            origin.y + (row-1)*rowHeight + offset.y,
            columnWidth,
            rowHeight
          ))

          self.grid[column][row] = item

          if horizontal then
            column = column + 1
            if column > columnCount then
              column = 1
              row = row + 1
            end
          else
            row = row + 1
            if row > rowCount then
              row = 1
              column = column + 1
            end
          end
        end
      end,
      navigate = function(self, cursorState, direction)
        if not cursorState then
          return {item = self.grid[1][1], pos = Vector.new(1, 1)}
        end

        local pos = cursorState.pos:cpy()

        local gridIter

        if direction == "right" then
          gridIter = function(pos)
            pos.x = pos.x + 1
            if pos.x > self.width then
              pos.x = 1
            end
          end
        end

        if direction == "left" then
          gridIter = function(pos)
            pos.x = pos.x - 1
            if pos.x < 1 then
              pos.x = self.width
            end
          end
        end

        if direction == "up" then
          gridIter = function(pos)
            pos.y = pos.y - 1
            if pos.y < 1 then
              pos.y = self.height
            end
          end
        end

        if direction == "down" then
          gridIter = function(pos)
            pos.y = pos.y + 1
            if pos.y > self.height then
              pos.y = 1
            end
          end
        end

        if not gridIter then return cursorState end

        while true do
          gridIter(pos)
          local item = self.grid[pos.x][pos.y]
          if item then
            return {item = item, pos = pos:cpy()}
          end
        end
      end
    }

    return _new
  end

  methods.textItem = function(coh, text)
    return TextLine(nil, nil, coh, text)
  end

  methods.imageCursor = function(coh, imageFilename)
    return UIElement.Cursor.ImageCursor(nil, nil, coh, GAME.assetCache:load(imageFilename))
  end

  return methods
end

local textColor

local items
local cursor

local navigationSuspended
local cursorState

local layout

local game
local graphicsDevice

local super

function _class:init(parent, coh, params)
  self.super:init(parent, coh)
  super = self.super

  game = GAME
  graphicsDevice = game.graphicsDevice

  params = params or {}

  local scrWidth, scrHeight = game:getTargetDimensions()

  local pos = params.pos or Vector.new(scrWidth*0.2, scrHeight*0.1)
  local size = params.size or Vector.new(scrWidth*0.6, scrHeight*0.8)
  self:setRectangle(Vector.new(pos.x, pos.y, size.x, size.y))

  textColor = params.textColor or Vector.color(255, 255, 255)

  cursor = params.cursor or UIElement.Cursor.SimpleCursor(nil, nil, coh)
  cursor.parent = self

  items = List.new()

  for _, item in params.items:iterator() do
    items:push_back(self:create(UIElement.MenuItem, coh, item))
  end

  layout = params.layout or self.class.gridLayout(true, 2, 360, nil, 60)
  layout.parent = self

  layout:update(items)
  cursorState = layout:navigate()
end

function _class:inputEventListener(inputEvent)
  local key = inputEvent.data.key

  if navigationSuspended then return "keep" end

  if key == "pause" or key == "b" then
    self:emit("canceled")
    return "keep"
  end

  if key == "a" or key == "menu" then
    local data = cursorState.item:getData()
    local actualData
    if type(data) == "function" then
      actualData = data()
    else
      actualData = data
    end

    self:emit("selection", actualData)
    inputEvent.consumed = true
    return "keep"
  end

  local oldItem = cursorState and cursorState.item

  cursorState = layout:navigate(cursorState, key)

  local newItem = cursorState and cursorState.item

  if oldItem ~= newItem then
    self:emit("update", {oldItem = oldItem, newItem = newItem})
  end

  return "keep"
end

function _class:main(coh)

  cursor:start()

  for _, item in items:iterator() do
    item:start()
  end

  self:on(game.input, "input.keypressed", self.inputEventListener)
  self:on(self, "finished", function(self, event)
    self:off(game.input, "input.keypressed")
    return "remove"
  end)
end

function _class:getItems()
  return items
end

function _class:getCurrentItem()
  return cursorState and cursorState.item
end

function _class:getCursor()
  return cursor
end

function _class:hideCursor()
  cursor:hide()
end

function _class:showCursor()
  cursor:show()
end

function _class:suspendNavigation()
  navigationSuspended = true
end

function _class:resumeNavigation()
  navigationSuspended = false
end

function _class:update(dt)
  cursor:setItem(cursorState.item)
  super:update(dt)
end

function _class:draw()
  local gd = graphicsDevice
  local scrWidth, scrHeight = game:getTargetDimensions()

  gd:origin()
  gd:setColor(textColor)

  for _, item in items:iterator() do
    self:drawChild(item)
  end

  self:drawChild(cursor)
end

return _class
