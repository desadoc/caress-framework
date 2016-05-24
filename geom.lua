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

--- Geometry module.
-- 
-- Data structures and functions to handle geometric entities.
-- 
-- @module geom

local Vector = require("caress/Vector")

local _M = {}

local PI = math.pi

_M.collDir = {
  E   = 0.0,
  NE  = PI/4.0,
  N   = PI/2.0,
  NW  = 3.0*PI/4.0,
  W   = PI,
  SW  = 5.0*PI/4.0,
  S   = 3.0*PI/2.0,
  SE  = 7.0*PI/4.0,
}

--- Return the opposite direction in radians.
function _M.invertDir(dir)
  local _, r = math.modf((dir+PI)/(2*PI))
  return r*2.0*PI
end

--- Returns true if given directions are opposite.
-- Directions are considered opposite to each other if they are within a
-- certain limit angle in radians from the other dir inverted. This limit
-- defaults to PI/8, 45 degrees.
function _M.areOpposites(dir1, dir2)
  return _M.isNearToDir(dir1, _M.invertDir(dir2))
end

--- Returns true if directions are near to each other.
-- Answers if the angular distance (the smallest angle) between the two given
-- directions is at most 'limit', which defaults to PI/8 radians, or 45
-- degrees.
function _M.isNearToDir(dir1, dir2, limit)
  limit = limit or PI/8.0
  local _, dist = math.modf(math.abs(dir1-dir2)/(2*PI))
  dist = dist*2*PI
  if dist > PI then
    dist = 2*PI - dist
  end
  return dist <= limit
end

_M.shapeTypesIds = {
  AABB = 1,
  CIRCLE = 2,
}

--- Creates an AABB shape data structure.
-- Returns a @{Vector} representing an AABB.
-- @param x X coordinate of top left corner.
-- @param y Y coordinate of top left corner.
-- @param z AABB's width.
-- @param w AABB's height.
function _M.aabbShape(x, y, z, w)
  local shape = Vector.new(x, y, z, w)
  shape.type = _M.shapeTypesIds.AABB
  local p1x = z/2
  local p1y = w/2
  local d = math.sqrt(p1x*p1x + p1y*p1y)
  shape.p1arc = math.acos(p1x/d)
  return shape
end

--- Creates an circle shape data structure.
-- Returns a @{Vector} representing a circle.
-- @param x X coordinate of circle's center.
-- @param y Y coordinate of circle's center.
-- @param r Circle radius.
function _M.circleShape(x, y, r)
  local shape = Vector.new(x, y, r, 2*r)
  shape.type = _M.shapeTypesIds.CIRCLE
  return shape
end

return _M
