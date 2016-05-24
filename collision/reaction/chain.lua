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

local Vector      = require("caress/Vector")
local geom        = require("caress/geom")
local collection  = require("caress/collection")

local base        = require("caress/collision/base")

local _M = {}
_M.__index = _M
_M._typename = "Reaction.Chain"

function _M.new(entity)
    local _new = {
    entity = entity,
    colls = collection.List.new(),
    allColls = collection.List.new()
  }

  setmetatable(_new, _M)

  return _new
end

function _M:cleanup()
  self.preCollInfo = {
    vel = Vector.new_cpy(self.entity:getVelocity()),
    pos = Vector.new_cpy(self.entity:getPosition()),
  }

  self.colls = collection.List.new()
  self.allColls = collection.List.new()
end

function _M:collisionListener(collInfo)
  collInfo.transparent =
    self:isCollTransparent(collInfo.side, collInfo.collider) or
    self:isCollTransparent(geom.invertDir(collInfo.side), self)

  local findCollFunc =
  function(coll)
    return coll.source == collInfo.source
  end

  if self.allCollisions:filter(findCollFunc):is_empty() then
    self.allCollisions:push_back(collInfo)
  end

  if collInfo.collider == collInfo.source then
    self.collisions:push_back(collInfo)
  end

  -- transparent collisions aren't forwarded to neighbors
  if collInfo.transparent then
    return
  end

  for _, _collInfo in self.collisions:iterator() do
    if geom.areOpposites(_collInfo.side, collInfo.side) then
      if _collInfo.collider.collisionListener then
        local forwardColl =
          base.createCollObj(
            _collInfo.collider,
            collInfo.source,
            self,
            collInfo.side,
            -1.0
          )

        _collInfo.collider:collisionListener(forwardColl)
      end
    end
  end

  if collInfo.collider == collInfo.source then
    if collInfo.collider.collisionListener then
      for _, _collInfo in self.allCollisions:iterator() do
        if geom.areOpposites(_collInfo.side, collInfo.side) then
          local backwardColl =
            base.createCollObj(
              collInfo.collider,
              _collInfo.source,
              self,
              _collInfo.side,
              -1.0
            )

          collInfo.collider:collisionListener(backwardColl)
        end
      end
    end
  end
end

function _M:update(dt)
end

function _M:_getCollisionResponse(collDir, collClass)
  if not self.entity.getCollisionResponseMap then return nil end

  for dir, response in pairs(self.entity:getCollisionResponseMap(collClass)) do
    if geom.isNearToDir(dir, collDir) then
      return response
    end
  end
end

function _M:_getCollisionChain(collDir, colliderClass)
  local response = self:getCollisionResponse(collDir, colliderClass)
  if not response then return nil end

  local collisions = collection.List.new()

  for _, collInfo in self.colls:iterator() do
    if geom.areOpposites(collInfo.side, collDir) then

      local invResponse = self:getCollisionResponse(
        geom.invertDir(collDir),
        collInfo.collider.class
      )

      if invResponse then
        if collInfo.collider.getCollisionChain then
          collInfo.next = collInfo.collider:getCollisionChain(collDir)
        end

        collisions:push_back(collInfo)
      end
    end
  end

  if collisions:is_empty() then return nil end
  return collisions
end

return _M
