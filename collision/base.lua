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

local _M = {}

local Vector  = require("caress/Vector")

local math_abs = math.abs

--- Intersection test.
-- @return true if AABB's intersect, ie. they share area greater than zero.
function _M.AABB_intersection_test(a, b)
  return
    (a.y < (b.y + b.w)) and
    (b.y < (a.y + a.w)) and
    (math_abs((a.x - b.x)*2) < (a.z + b.z))
end

--- Contains test.
-- @return true if a contains b, ie. b borders are within a borders.

local function _AABB_contains_test(
  a_pos_x, a_pos_y, a_size_x, a_size_y,
  b_pos_x, b_pos_y, b_size_x, b_size_y)
  return
    (b_pos_y > a_pos_y) and
    ((b_pos_y + b_size_y) < (a_pos_y + a_size_y)) and
    ((math_abs(a_pos_x - b_pos_x)*2) < (a_size_x - b_size_x))
end
_M._AABB_contains_test = _AABB_contains_test

function _M.AABB_contains_test(a, b)
  return _AABB_contains_test(a.x, a.y, a.z, a.w, b.x, b.y, b.z, b.w)
end

--- Creates a collision info object.
-- This simple object holds a copy of information about two colliders. This is
-- necessary because while entities are processing collisions, they update their
-- velocities or position, preventing other entities of knowing their state in
-- the moment the collision occurred.
function _M.createCollObj(self, source, collider, side, time)
  collider = collider or source

  local collInfo = {
    self = self,
    source = source,
    collider = collider,
    side = side,
    time = time,
  }

  if self and self.class then
    collInfo.selfInfo = {
      pos = Vector.new_cpy(self:getPosition()),
      vel = Vector.new_cpy(self:getVelocity())
    }
  end

  collInfo.colliderInfo = collider and collider.class and {
    pos = Vector.new_cpy(collider:getPosition()),
    vel = Vector.new_cpy(collider:getVelocity())
  } or {
    pos = Vector.new(collider.x, collider.y),
    vel = Vector.new(0.0, 0.0)
  }

  return collInfo
end

--- Position offset.
-- When adjusting an entity position to juxtapose other entity, keep this
-- distance between the two. This ensures collision occurs properly in following
-- frames.
-- Later when entities are tested for collision an reverse offset, greater than
-- this one, is used.
_M.positionOffset = 0.000000000001
_M.reversePosOffset = 2*_M.positionOffset

return _M
