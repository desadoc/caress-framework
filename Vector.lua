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

--- Vector class.
--
-- This class represents an 4-dimensional vector, with x, y, z and w
-- coordinates. It can be used to represent many different things, from
-- AABBs, to positions or velocities.
--
-- In case of AABBs, (x, y) are the top left corner.
--
-- To avoid creating many tables, this module uses a syntax similar to
-- assembly, where you must specify operands and the variable that will hold
-- the result. Instances doesn't methods or a metatable, "self:" calls won't
-- work. 
--
-- @module Vector

local _M = {}

--- Allocates and initializes a new instance.
-- Creates a new Vector, fields default to zero if parameters are absent.
-- @return New vector instance.
function _M.new(_x, _y, _z, _w)
  return {
    x = _x or 0,
    y = _y or 0,
    z = _z or 0,
    w = _w or 0,
  }
end

--- Allocates a new Vector and initializes it with v1 values.
function _M.new_cpy(v1)
  return _M.new(v1.x, v1.y, v1.z, v1.w)
end

--- Returns a Vector to represent a color.
-- This method is equals to new with the single difference of making 'w'
-- coordinate, the alpha channel, to default to 255 instead of 0.
function _M.color(r, g, b, a)
  return {
    x = r or 0,
    y = g or 0,
    z = b or 0,
    w = a or 255,
  }
end

--- Return true if vectors are equals.
function _M.equals(v1, v2)
  return
    v1.x == v2.x and
    v1.y == v2.y and
    v1.z == v2.z and
    v1.w == v2.w
end

--- Returns a string representation of a vector.
-- The returned representation is pure lua and can be interpreted back into the
-- original data .
function _M.tostring(v)
  return "{x = " .. v.x .. ", y = " .. v.y ..
    ", z = " .. v.z .. ", w = " .. v.w .. "}"
end

--- Returns a string representation of a vector, two dimensions only.
-- Only includes x and y coordinates, see @{tostring}.
function _M.tostring2(v)
  return "{x = " .. v.x .. ", y = " .. v.y .. "}"
end

--- Prints a vector to standard output.
function _M.print(v)
  print(_M.tostring(v))
end

--- Prints two dimensional representation of a vector, see @{print}.
function _M.print2(v)
  print(_M.tostring2(v))
end

--- Sets multiple values on a vector. I created this method because I'm lazy.
function _M.set(v1, _x, _y, _z, _w)
  v1.x = _x or v1.x
  v1.y = _y or v1.y
  v1.z = _z or v1.z
  v1.w = _w or v1.w
end

--- Copies the first vector onto the second.
function _M.cpy(v1, v2)
  v2.x = v1.x
  v2.y = v1.y
  v2.z = v1.z
  v2.w = v1.w
end

--- Adds first two vectors, puts result into the third.
function _M.add(v1, v2, v3)
  v3.x = v1.x + v2.x
  v3.y = v1.y + v2.y
  v3.z = v1.z + v2.z
  v3.w = v1.w + v2.w
end

--- Unary operator, result is put into second vector.
function _M.unm(v1, v2)
  v2.x = -v1.x
  v2.y = -v1.y
  v2.z = -v1.z
  v2.w = -v1.w
end

--- Puts (v1-v2) into v3.
function _M.sub(v1, v2, v3)
  v3.x = v1.x - v2.x
  v3.y = v1.y - v2.y
  v3.z = v1.z - v2.z
  v3.w = v1.w - v2.w
end

--- Puts (v1*v2) into v3, v2 can be a vector or a number.
function _M.mul(v1, v2, v3)
  if type(v2) == 'table' then
    v3.x = v1.x * v2.x
    v3.y = v1.y * v2.y
    v3.z = v1.z * v2.z
    v3.w = v1.w * v2.w

    return
  end

  if type(v2) == 'number' then
    v3.x = v1.x * v2
    v3.y = v1.y * v2
    v3.z = v1.z * v2
    v3.w = v1.w * v2

    return
  end

  error("bad parameter", 2)
end

--- Puts (v1/v2) into v3, v2 can be a vector or a number.
function _M.div(v1, v2, v3)
  if type(v2) == 'table' then
    v3.x = v1.x / v2.x
    v3.y = v1.y / v2.y
    v3.z = v1.z / v2.z
    v3.w = v1.w / v2.w

    return
  end

  if type(v2) == 'number' then
    v3.x = v1.x / v2
    v3.y = v1.y / v2
    v3.z = v1.z / v2
    v3.w = v1.w / v2

    return
  end

  error("bad parameter", 2)
end

--- Module operator, puts (v1%v2) into v3, v2 can be a vector or a number.
function _M.mod(v1, v2, v3)
  if type(v2) == 'table' then
    v3.x = v1.x % v2.x
    v3.y = v1.y % v2.y
    v3.z = v1.z % v2.z
    v3.w = v1.w % v2.w

    return
  end

  if type(v2) == 'number' then
    v3.x = v1.x % v2
    v3.y = v1.y % v2
    v3.z = v1.z % v2
    v3.w = v1.w % v2

    return
  end

  error("bad parameter", 2)
end

--- Comparator useful to sort vectors, left first, top second.
function _M.xy_cmp(aabb1, aabb2)
  if aabb1.x < aabb2.x then
    return 1
  end
  if aabb1.x > aabb2.x then
    return -1
  end
  return aabb2.y - aabb1.y
end

--- Returns 4-dimensional vector's length.
function _M.length(v)
  return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w)
end

--- Returns 2-dimensional vector's length.
function _M.length2(v)
  return math.sqrt(v.x*v.x + v.y*v.y)
end

--- Normalizes a vector, storing result in itself.
function _M.normalize(v)
  local l = _M.length(v)
  if l > 0.0 then
    _M.div(v, l, v)
  else
    error("zero length vector", 2)
  end
end

local _dist_tmp = _M.new()

--- Returns 2-dimensional distance between two vectors (or points).
function _M.distance2(v1, v2)
  _M.sub(v1, v2, _dist_tmp)
  return _M.length2(_dist_tmp)
end

--- Updates aabb1 so aabb2 is fully within it.
function _M.expand_aabb(aabb1, aabb2)
  local left = aabb1.x - aabb1.z/2
  local right = aabb1.x + aabb1.z/2
  local top = aabb1.y + aabb1.w
  local bottom = aabb1.y

  if left > (aabb2.x - aabb2.z/2) then
    left = aabb2.x - aabb2.z/2
  end

  if right < (aabb2.x + aabb2.z/2) then
    right = aabb2.x + aabb2.z/2
  end

  if top < (aabb2.y + aabb2.w) then
    top = aabb2.y + aabb2.w
  end

  if bottom > aabb2.y then
    bottom = aabb2.y
  end

  aabb1.x = (right + left)/2
  aabb1.y = bottom
  aabb1.z = right - left
  aabb1.w = top - bottom
end

--- Projects an bidimensional vector onto a line rads degrees apart from it.
function _M.project(v, rads)
  return _M.new(v.x*math.cos(rads), v.y*math.sin(rads))
end

return _M
