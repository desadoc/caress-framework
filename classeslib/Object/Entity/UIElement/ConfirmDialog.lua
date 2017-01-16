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

--- Confirmation Dialog
--
-- @classmod Object.Entity.UIElement.ConfirmationDialog

local Vector  = require("caress/Vector")
local List    = require("caress/collection").List

local _class = {}

local pos
local size
local bgColor
local highlightColor

local title
local currSelOption

local game
local graphicsDevice

function _class:init(parent, layer, coh, params)
  self.super("init", parent, layer, coh)

  game = _game
  graphicsDevice = game.graphicsDevice

  params = params or {}

  local scrWidth, scrHeight = game.getTargetDimensions()

  pos = params.pos or Vector.new(scrWidth*0.5, scrHeight*0.05)
  size = params.size or Vector.new(scrWidth*0.4, scrHeight*0.2)
  bgColor = params.bgColor or Vector.color(128, 160, 255)
  highlightColor = params.highlightColor or Vector.color(160, 192, 255)

  title = params.title or "Are you sure?"
  currSelOption = "no"
end

function _class:inputEventListener(event)
  local key = event.data.key

  if key == "right" then
    if currSelOption == "no" then
      currSelOption = "yes"
    else
      currSelOption = "no"
    end

    event.consumed = true
    return "keep"
  end

  if key == "left" then
    if currSelOption == "yes" then
      currSelOption = "no"
    else
      currSelOption = "yes"
    end

    event.consumed = true
    return "keep"
  end

  if key == "z" or key == "menu" then
    self:emit("selection", currSelOption)

    event.consumed = true
    return "keep"
  end

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
  local scrWidth, scrHeight = game.getTargetDimensions()

  gd:drawAABB("fill", {
    x = pos.x,
    y = pos.y,
    z = size.x,
    w = size.y
  }, bgColor)

  if currSelOption == "no" then
    gd:drawAABB("fill", {
      x = pos.x - size.x*0.225,
      y = pos.y + size.y*0.475,
      z = size.x*0.45,
      w = scrHeight*0.05
    }, highlightColor)
  end

  if currSelOption == "yes" then
    gd:drawAABB("fill", {
      x = pos.x + size.x*0.225,
      y = pos.y + size.y*0.475,
      z = size.x*0.45,
      w = scrHeight*0.05
    }, highlightColor)
  end

  gd:rawPrintf(title, pos.x - size.x*0.5, pos.y + size.y*0.1, size.x, "center", 0.0, 1.0, 1.0)
  gd:rawPrintf("No", pos.x - size.x*0.5, pos.y + size.y*0.5, size.x*0.5, "center", 0.0, 1.0, 1.0)
  gd:rawPrintf("Yes", pos.x, pos.y + size.y*0.5, size.x*0.5, "center", 0.0, 1.0, 1.0)
end

return _class
