-- Caress-Lib, a lua library for games.
-- Copyright (C) 2016, 2017,  Erivaldo Filho "desadoc@gmail.com"

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
-- AABBs, to positions, velocities or colors.
--
-- In case of AABBs, (x, y) are the top left corner.
--
-- @module Vector

local _M = {}
_M.__index = _M

--- Allocates and initializes a new instance.
-- Creates a new Vector, fields default to zero if parameters are absent.
-- @return New vector instance.
function _M.new(_x, _y, _z, _w)
  return setmetatable({
    x = _x or 0,
    y = _y or 0,
    z = _z or 0,
    w = _w or 0,
  }, _M)
end

--- Copy.
function _M:cpy(v)
  if v then
    v.x = self.x
    v.y = self.y
    v.z = self.z
    v.w = self.w

    return
  end

  return _M.new(self.x, self.y, self.z, self.w)
end

function _M:unpack()
  return self.x, self.y, self.z, self.w
end

--- Returns a Vector to represent a color.
-- This method is equals to new with the single difference of making 'w'
-- coordinate, the alpha channel, to default to 255 instead of 0.
function _M.color(r, g, b, a)
  return _M.new(
    r or 0,
    g or 0,
    b or 0,
    a or 255
  )
end

--- Return true if vectors are equals.
function _M:equals(v)
  return
    self.x == v.x and
    self.y == v.y and
    self.z == v.z and
    self.w == v.w
end

_M.__eq = _M.equals

--- Returns a string representation of a vector.
-- The returned representation is pure lua and can be interpreted back into the
-- original data .
function _M:tostring()
  return "{x = " .. self.x .. ", y = " .. self.y ..
    ", z = " .. self.z .. ", w = " .. self.w .. "}"
end

_M.__tostring = _M.tostring

--- Returns a string representation of a vector, two dimensions only.
-- Only includes x and y coordinates, see @{tostring}.
function _M:tostring2()
  return "{x = " .. self.x .. ", y = " .. self.y .. "}"
end

--- Sets multiple values on a vector.
function _M:set(_x, _y, _z, _w)
  self.x = _x or self.x
  self.y = _y or self.y
  self.z = _z or self.z
  self.w = _w or self.w
end

--- Adds two vectors.
function _M:add(v)
  return _M.new(
    self.x + v.x,
    self.y + v.y,
    self.z + v.z,
    self.w + v.w
  )
end

_M.__add = _M.add

--- Unary operator.
function _M:unm()
  return _M.new(
    -self.x,
    -self.y,
    -self.z,
    -self.w
  )
end

_M.__unm = _M.unm

--- Subtraction.
function _M:sub(v)
  return _M.new(
    self.x - v.x,
    self.y - v.y,
    self.z - v.z,
    self.w - v.w
  )
end

_M.__sub = _M.sub

--- Multiplication.
function _M:mul(arg)
  if type(arg) == 'table' then
    return _M.new(
      self.x*arg.x,
      self.y*arg.y,
      self.z*arg.z,
      self.w*arg.w
    )
  end

  if type(arg) == 'number' then
    return _M.new(
      self.x*arg,
      self.y*arg,
      self.z*arg,
      self.w*arg
    )
  end

  error("bad parameter", 2)
end

_M.__mul = _M.mul

--- Division.
function _M:div(arg)
  if type(arg) == 'table' then
    return _M.new(
      self.x/arg.x,
      self.y/arg.y,
      self.z/arg.z,
      self.w/arg.w
    )
  end

  if type(arg) == 'number' then
    return _M.new(
      self.x/arg,
      self.y/arg,
      self.z/arg,
      self.w/arg
    )
  end

  error("bad parameter", 2)
end

_M.__div = _M.div

--- Module operator.
function _M:mod(arg)
  if type(arg) == 'table' then
    return _M.new(
      self.x%arg.x,
      self.y%arg.y,
      self.z%arg.z,
      self.w%arg.w
    )
  end

  if type(arg) == 'number' then
    return _M.new(
      self.x%arg,
      self.y%arg,
      self.z%arg,
      self.w%arg
    )
  end

  error("bad parameter", 2)
end

_M.__mod = _M.mod

--- Comparator useful to sort vectors, left top first.
function _M.xy_cmp(aabb1, aabb2)
  if aabb1.x < aabb2.x then
    return 1
  end
  if aabb1.x > aabb2.x then
    return -1
  end
  return aabb2.y - aabb1.y
end

local math_sqrt = math.sqrt

--- Returns 4-dimensional vector's length.
function _M:length()
  return math_sqrt(self.x*self.x + self.y*self.y + self.z*self.z + self.w*self.w)
end

--- Returns 2-dimensional vector's length.
function _M:length2()
  return math_sqrt(self.x*self.x + self.y*self.y)
end

--- Normalizes a vector inplace.
function _M:normalize()
  local l = self:length()
  if l > 0.0 then
    self:div(l):cpy(self)
  end
  return self
end

function _M:cross2(v)
  return self.x*v.x + self.y*v.y
end

--- Returns 2-dimensional distance between two vectors (or points).
function _M:distance2(v)
  return self:sub(v):length2()
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

local math_sin = math.sin
local math_cos = math.cos

--- Projects an bidimensional vector onto a line rads degrees apart from it.
function _M:project(rads)
  return _M.new(self.x*math_cos(rads), self.y*math_sin(rads))
end

return _M
