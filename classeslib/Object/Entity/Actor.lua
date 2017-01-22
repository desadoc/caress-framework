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

--- Actor class.
--
-- Actors are basically moving entities like characters and enemies. They are
-- able to move around, colliding with other actors and static level objects.
--
-- @classmod Object.Entity.Actor

local Vector            = require("caress/Vector")
local collection        = require("caress/collection")
local collision         = require("caress/collision")
local classes           = require("caress/classes")

local collisionOffset   = collision.positionOffset

local _class = {}

local super

function _class:init(...)
  self.super:init(...)
  super = self.super

  self.pos = Vector.new()
  self.vel = Vector.new()
  self.aabb = Vector.new()
  self.shapes = {}

  self.collReaction = collision.reaction.new(self)
end

function _class:main(...)
end

function _class:cleanupCollInfo()
  self.collReaction:cleanup()
end

--- Actor update.
-- Must be called by subclasses at the beginning of their update(). The main
-- task of the 'update' method at sub classes is to update actor speed every
-- frame, which will be taken into account at next collision calculation round.
-- Collision information available to sub classes shouldn't be used to check if
-- the actor can move in some direction and at what speed, this is already done
-- by this super class. Collision info should be used to update game logic,
-- e.g., apply contact damage to enemies, activate traps, etc.
-- Position shouldn't be set manually, it's already done by this super class
-- and doing it will cause errors.
function _class:update(dt)
  super:update(dt)

  self.collReaction:update(dt)
  self.collisions = self.collReaction:getDirectCollisions()
  self.allCollisions = self.collReaction:getAllCollisions()
end

function _class:collisionListener(collInfo)
  self.collReaction:collisionListener(collInfo)
end

function _class:getVelocity()
  return self.vel
end

function _class:setVelocity(x, y)
  self.vel.x = x
  self.vel.y = y
end

function _class:getPosition()
  return self.pos
end

function _class:setPosition(x, y)
  self.pos.x = x
  self.pos.y = y

  self:_updateAABB()
end

function _class:getSize()
  return Vector.new(self.aabb.z, self.aabb.w)
end

function _class:getShape(collGroup)
  return self.shapes[collGroup]
end

function _class:getAABB()
  return self.aabb
end

function _class:_updateAABB()
  self.aabb.x = self.pos.x
  self.aabb.y = self.pos.y
end

function _class:getBspQueryAABB()
  local queryAABB = Vector.new()
  Vector.cpy(self:getAABB(), queryAABB)

  queryAABB.y = queryAABB.y - queryAABB.w/2
  queryAABB.w = queryAABB.w * 2
  queryAABB.z = queryAABB.z * 2

  return queryAABB
end

return _class
