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

local _class = {}

local item
local fusedOnX
local fusedOnY

function _class:setItem(value)
  item = value
end

function _class:getItem()
  return item
end

function _class:setFusedOnX(value)
  fusedOnX = value
end

function _class:isFusedOnX()
  return fusedOnX
end

function _class:setFusedOnY(value)
  fusedOnY = value
end

function _class:isFusedOnY()
  return fusedOnY
end

return _class
