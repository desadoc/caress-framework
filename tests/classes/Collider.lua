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

local Vector  = require("caress/Vector")
local geom    = require("caress/geom")

local _class = {}

function _class:init()
  self.pos      = Vector.new(0.0, 0.0)
  self.vel      = Vector.new(0.0, 0.0)
  self.shape    = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
end

function _class:getPosition()
  return self.pos
end

function _class:getShape(collGroup)
  return self.shape
end

function _class:getVelocity()
  return self.vel
end

return _class

