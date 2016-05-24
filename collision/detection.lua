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

local Vector        = require("caress/Vector")
local geom          = require("caress/geom")
local collection    = require("caress/collection")

local base          = require("caress/collision/base")

local _M = {}

local PI = math.pi
local math_abs = math.abs
local reversePosOffset = base.reversePosOffset

-- locals for fast access
local collDir_E   = geom.collDir.E
local collDir_NE  = geom.collDir.NE
local collDir_N   = geom.collDir.N
local collDir_NW  = geom.collDir.NW
local collDir_W   = geom.collDir.W
local collDir_SW  = geom.collDir.SW
local collDir_S   = geom.collDir.S
local collDir_SE  = geom.collDir.SE

local _AABB_contains_test = base._AABB_contains_test

local function getAABBxAABBCollPoint(
  a_pos_x, a_pos_y, a_size_x, a_size_y,
  b_pos_x, b_pos_y, b_size_x, b_size_y)

  if _AABB_contains_test(
    a_pos_x, a_pos_y, a_size_x, a_size_y,
    b_pos_x, b_pos_y, b_size_x, b_size_y) or
    _AABB_contains_test(
    b_pos_x, b_pos_y, b_size_x, b_size_y,
    a_pos_x, a_pos_y, a_size_x, a_size_y) then

    return Vector.new((a_pos_x+b_pos_x)/2, (a_pos_y+a_size_y/2+b_pos_y+b_size_y/2)/2)
  else

    local x =
    (math.max(a_pos_x-a_size_x/2, b_pos_x-b_size_x/2) +
    math.min(a_pos_x+a_size_x/2, b_pos_x+b_size_x/2))/2

    local y =
    (math.max(a_pos_y, b_pos_y) +
    math.min(a_pos_y+a_size_y, b_pos_y+b_size_y))/2

    return Vector.new(x, y)
  end
end

local function getAABBxCIRCLECollPoint(
  a_pos_x, a_pos_y, a_size_x, a_size_y,
  b_center_x, b_center_y, b_radius)

  local x =
  (math.max(a_pos_x-a_size_x/2, b_center_x-b_radius) +
  math.min(a_pos_x+a_size_x/2, b_center_x+b_radius))/2

  local y =
  (math.max(a_pos_y, b_center_y-b_radius) +
  math.min(a_pos_y+a_size_y, b_center_y+b_radius))/2

  if (x == a_pos_x and y == (a_pos_y+a_size_y/2)) or (x == b_center_x and y == b_center_y) then
    return Vector.new((a_pos_x+b_center_x)/2, (a_pos_y+a_size_y/2+b_center_y)/2)
  else
    return Vector.new(x, y)
  end
end

local function getCIRCLExCIRCLECollPoint(
  a_center_x, a_center_y, b_center_x, b_center_y
  )
  return Vector.new((a_center_x + b_center_x)/2.0, (a_center_y + b_center_y)/2.0)
end

local function getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)
  local collDir

  local a_center_x = a_pos_x + a_shape.x
  local a_center_y = a_pos_y + a_shape.y + a_shape.w/2

  local _collDirX = collPoint.x-a_center_x
  local _collDirY = collPoint.y-a_center_y
  local _collDirD = math.sqrt(_collDirX*_collDirX + _collDirY*_collDirY)
  local collPointDir = math.atan2(_collDirY/_collDirD, _collDirX/_collDirD)

  local p1arc = a_shape.p1arc
  local p1arc_compl = PI/2 - p1arc

  if geom.isNearToDir(collPointDir, collDir_S, p1arc_compl) then
    collDir = collDir_S
  end

  if geom.isNearToDir(collPointDir, collDir_N, p1arc_compl) then
    collDir = collDir_N
  end

  if geom.isNearToDir(collPointDir, collDir_W, p1arc) then
    collDir = collDir_W
  end

  if geom.isNearToDir(collPointDir, collDir_E, p1arc) then
    collDir = collDir_E
  end

  return collDir
end

local function getCIRCLECollDir(a_pos_x, a_pos_y, a_shape, collPoint)
  local collDir

  local a_center_x = a_pos_x + a_shape.x
  local a_center_y = a_pos_y + a_shape.y + a_shape.z

  local _collDirX = collPoint.x-a_center_x
  local _collDirY = collPoint.y-a_center_y
  local _collDirD = math.sqrt(_collDirX*_collDirX + _collDirY*_collDirY)
  local collPointDir = math.atan2(_collDirY/_collDirD, _collDirX/_collDirD)

  return collPointDir
end

local function dynAABBxdynCIRCLE(a_pos, a_shape, a_vel, b_pos, b_shape, b_vel, dt)
  local a_pos_x = a_pos.x + a_shape.x
  local a_pos_y = a_pos.y + a_shape.y
  local a_size_x = a_shape.z
  local a_size_y = a_shape.w
  local a_vel_x = a_vel.x
  local a_vel_y = a_vel.y
  local a_center_x = a_pos_x
  local a_center_y = a_pos_y + a_size_y/2.0

  local b_pos_x = b_pos.x + b_shape.x
  local b_pos_y = b_pos.y + b_shape.y
  local b_radius = b_shape.z
  local b_diameter = b_radius*2
  local b_vel_x = b_vel.x
  local b_vel_y = b_vel.y
  local b_center_x = b_pos_x
  local b_center_y = b_pos_y + b_radius

  -- distance between them in both axis
  local dx = math_abs(a_center_x-b_center_x) - a_size_x/2.0 - b_radius
  local dy = math_abs(a_center_y-b_center_y) - a_size_y/2.0 - b_radius

  dx = math.max(dx, -b_radius)
  dy = math.max(dy, -b_radius)

  if dx < reversePosOffset then
    local dist_y = dy + b_radius - math.sqrt(-2*b_radius*dx - dx*dx)

    if dist_y < reversePosOffset then
      local collPoint = getAABBxCIRCLECollPoint(
      a_pos_x, a_pos_y, a_size_x, a_size_y,
      b_center_x, b_center_y, b_radius)

      local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

      return collDir, collPoint, -1.0
    else
      if (a_vel_y-b_vel_y)*(a_center_y-b_center_y) < 0 then
        local vy = math_abs(a_vel_y-b_vel_y)
        local t0 = dist_y/vy

        if t0 < (dt+0.000000001) then
          local collPoint = getAABBxCIRCLECollPoint(
          a_pos_x+a_vel_x*t0, a_pos_y+a_vel_y*t0, a_size_x, a_size_y,
          b_center_x+b_vel_x*t0, b_center_y+b_vel_y*t0, b_radius)

          local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

          return collDir, collPoint, t0
        end
      end
    end
  end

  if dy < reversePosOffset then
    local dist_x = dx + b_radius - math.sqrt(-2*b_radius*dy - dy*dy)

    if dist_x < reversePosOffset then
      local collPoint = getAABBxCIRCLECollPoint(
      a_pos_x, a_pos_y, a_size_x, a_size_y,
      b_center_x, b_center_y, b_radius)

      local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

      return collDir, collPoint, -1.0
    else
      if (a_vel_x-b_vel_x)*(a_center_x-b_center_x) < 0 then
        local vx = math_abs(a_vel_x-b_vel_x)
        local t0 = dist_x/vx

        if t0 < (dt+0.000000001) then
          local collPoint = getAABBxCIRCLECollPoint(
          a_pos_x+a_vel_x*t0, a_pos_y+a_vel_y*t0, a_size_x, a_size_y,
          b_center_x+b_vel_x*t0, b_center_y+b_vel_y*t0, b_radius)

          local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

          return collDir, collPoint, t0
        end
      end
    end
  end

end

local function dynCIRCLExdynCIRCLE(a_pos, a_shape, a_vel, b_pos,
    b_shape, b_vel, dt)
  local a_radius = a_shape.z
  local a_pos_x = a_pos.x + a_shape.x
  local a_pos_y = a_pos.y + a_shape.y
  local a_center_x = a_pos_x
  local a_center_y = a_pos_y + a_radius

  local b_radius = b_shape.z
  local b_pos_x = b_pos.x + b_shape.x
  local b_pos_y = b_pos.y + b_shape.y
  local b_center_x = b_pos_x
  local b_center_y = b_pos_y + b_radius

  local radius_sum = a_radius + b_radius
  local center_distance = math.sqrt((a_center_x - b_center_x)^2 + (a_center_y - b_center_y)^2)

  if center_distance < (radius_sum+0.000000001) then
    local collPoint = getCIRCLExCIRCLECollPoint(a_center_x, a_center_y, b_center_x, b_center_y)

    return getCIRCLECollDir(a_pos_x, a_pos_y, a_shape, collPoint), collPoint, 0.0
  end
end

local function dynAABBxdynAABB(a_pos, a_shape, a_vel, b_pos,
    b_shape, b_vel, dt)
  local a_pos_x = a_pos.x + a_shape.x
  local a_pos_y = a_pos.y + a_shape.y
  local a_size_x = a_shape.z
  local a_size_y = a_shape.w
  local a_vel_x = a_vel.x
  local a_vel_y = a_vel.y
  local a_center_x = a_pos_x
  local a_center_y = a_pos_y + a_size_y/2.0

  local b_pos_x = b_pos.x + b_shape.x
  local b_pos_y = b_pos.y + b_shape.y
  local b_size_x = b_shape.z
  local b_size_y = b_shape.w
  local b_vel_x = b_vel.x
  local b_vel_y = b_vel.y
  local b_center_x = b_pos_x
  local b_center_y = b_pos_y + b_size_y/2.0

  -- distance between them in both axis
  local dx = math_abs(a_center_x-b_center_x) - a_size_x/2.0 - b_size_x/2.0
  local dy = math_abs(a_center_y-b_center_y) - a_size_y/2.0 - b_size_y/2.0

  if dx < 0.0 then
    if dy < reversePosOffset then
      local collPoint = getAABBxAABBCollPoint(
      a_pos_x, a_pos_y, a_size_x, a_size_y,
      b_pos_x, b_pos_y, b_size_x, b_size_y)

      local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

      return collDir, collPoint, -1.0
    else
      if (a_vel_y-b_vel_y)*(a_center_y-b_center_y) < 0 then
        local vy = math_abs(a_vel_y-b_vel_y)
        local t0 = dy/vy

        if t0 < (dt+0.000000001) then
          local collPoint = getAABBxAABBCollPoint(
          a_pos_x, a_pos_y+a_vel_y*t0, a_size_x, a_size_y,
          b_pos_x, b_pos_y+b_vel_y*t0, b_size_x, b_size_y)

          local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

          return collDir, collPoint, t0
        end
      end
    end
  end

  if dy < 0.0 then
    if dx < reversePosOffset then
      local collPoint = getAABBxAABBCollPoint(
      a_pos_x, a_pos_y, a_size_x, a_size_y,
      b_pos_x, b_pos_y, b_size_x, b_size_y)

      local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

      return collDir, collPoint, -1.0
    else
      if (a_vel_x-b_vel_x)*(a_center_x-b_center_x) < 0 then
        local vx = math_abs(a_vel_x-b_vel_x)
        local t0 = dx/vx

        if t0 < (dt+0.000000001) then
          local collPoint = getAABBxAABBCollPoint(
          a_pos_x+a_vel_x*t0, a_pos_y, a_size_x, a_size_y,
          b_pos_x+b_vel_x*t0, b_pos_y, b_size_x, b_size_y)

          local collDir = getAABBCollDir(a_pos_x, a_pos_y, a_shape, collPoint)

          return collDir, collPoint, t0
        end
      end
    end
  end
end

local function dynAABBxstaticAABB(a_pos, a_shape, a_vel, b_shape, dt)
  return dynAABBxdynAABB(a_pos, a_shape, a_vel, b_shape, Vector.new(0, 0, b_shape.z, b_shape.w), Vector.new(0, 0), dt)
end

function _M.collideAABBEntityAndAABBEntityList(
  entity, entities, collGroup, dt, condition, collisions)

  if not entity or not entities then
    return
  end

  local a = entity
  local a_pos = a:getPosition()
  local a_shape = a:getShape(collGroup)
  local a_vel = a:getVelocity()

  if not a_shape then
    return
  end

  for iter, b in entities:iterator() do
    local b_shape = b:getShape(collGroup)
    if (a ~= b) and b_shape and (not condition or condition(a, b)) then
      local collDir, collPoint, collTime = dynAABBxdynAABB(a_pos, a_shape, a_vel, b:getPosition(), b_shape, b:getVelocity(), dt)

      if collDir then
        local collInfo = base.createCollObj(a, b, nil, collDir, collTime)
        collInfo.collPoint = collPoint
        collisions:push_back(collInfo)
      end
    end
  end

end

function _M.collideAABBEntityAndAABBShapeList(
  entity, aabbList, collGroup, dt, condition, collisions)

  if not entity or not aabbList then
    return
  end

  local a = entity
  local a_pos = a:getPosition()
  local a_shape = a:getShape(collGroup)
  local a_vel = a:getVelocity()

  if not a_shape then
    return
  end

  for iter, b in aabbList:iterator() do
    if not condition or condition(a, b) then
      local collDir, collPoint, collTime = dynAABBxstaticAABB(a_pos, a_shape, a_vel, b, dt)

      if collDir then
        local collInfo = base.createCollObj(a, b, nil, collDir, collTime)
        collInfo.collPoint = collPoint
        collisions:push_back(collInfo)
      end
    end
  end

end

local collFunctions = {}
collFunctions[2] = dynAABBxdynAABB
collFunctions[3] = dynAABBxdynCIRCLE
collFunctions[4] = dynCIRCLExdynCIRCLE

local collDirFunctions = {}
collDirFunctions[1] = getAABBCollDir
collDirFunctions[2] = getCIRCLECollDir

function _M.collideEntityAndEntityList(
  entity, entityList, collGroup, dt, condition, collisions)

  if not entity or not entityList then
    return
  end

  local a = entity
  local a_pos = a:getPosition()
  local a_shape = a:getShape(collGroup)
  local a_vel = a:getVelocity()

  if not a_shape then
    return
  end

  for iter, b in entityList:iterator() do
    local b_shape = b:getShape(collGroup)
    if (a ~= b) and b_shape and (not condition or condition(a, b)) then
      local collFunc = collFunctions[a_shape.type+b_shape.type]

      local collDir, collPoint, collTime
      if a_shape.type <= b_shape.type then
        collDir, collPoint, collTime = collFunc(a_pos, a_shape, a_vel,
          b:getPosition(), b_shape, b:getVelocity(), dt)
      else
        collDir, collPoint, collTime = collFunc(b:getPosition(), b_shape,
          b:getVelocity(), a_pos, a_shape, a_vel, dt)
        if collDir then
          local collDirFunc = collDirFunctions[a_shape.type]
          collDir = collDirFunc(a_pos.x, a_pos.y, a_shape, collPoint)
        end
      end

      if collDir then
        local collInfo = base.createCollObj(a, b, nil, collDir, collTime)
        collInfo.collPoint = collPoint
        collisions:push_back(collInfo)
      end
    end
  end
end

return _M
