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

--- TextLine
--
-- A UIElement containing a single line of text
--
-- @classmod Object.Entity.UIElement.TextLine

local _class = {}

local Vector  = require("caress/Vector")

local game

local text
local width
local aligning

function _class:init(parent, coh, _text, _width, _aligning)
  self.super:init(parent, coh)

  game = GAME

  text = _text or "CHANGEME"
  width = _width or 9999
  aligning = _aligning or "left"

  self:setSize(Vector.new(0, game.graphicsDevice:getFont():getHeight()))
end

function _class:draw()
  local gd = game.graphicsDevice

  local actualText
  if type(text) == "string" then
    actualText = text
  end
  if type(text) == "function" then
    actualText = text()
  end

  gd:printf(actualText, self:getPosition().x, self:getPosition().y, width, aligning)
end

return _class
