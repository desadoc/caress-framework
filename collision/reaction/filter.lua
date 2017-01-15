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
local common      = require("caress/collision/reaction/common")

local _M = {}
_M.__index = _M
_M._typename = "Reaction.Filter"

function _M.new(entity)
  local _new = {
    entity = entity,
    colls = collection.List.new(),
    allColls = collection.List.new()
  }

  setmetatable(_new, _M)

  return _new
end

function _M:getDirectCollisions()
  return self.colls
end

function _M:getAllCollisions()
  return self.allColls
end

function _M:cleanup()
  self.colls    = collection.List.new()
  self.allColls = collection.List.new()
end

--- Actor update.
-- Must be called by subclasses in their update().
function _M:update(dt)
  local entity = self.entity

  local pos = entity:getPosition()
  local vel = entity:getVelocity()

  if not dt then return end

  entity:setPosition(
    pos.x + vel.x * dt,
    pos.y + vel.y * dt
  )
end

local function isTransparent(entity, collInfo)
  if not entity.class then return false end
  if not entity.getCollisionResponseMap then return true end

  local fromMap
  for dir, response in
      pairs(entity:getCollisionResponseMap(collInfo.collider.class)) do
    if geom.isNearToDir(dir, collInfo.side) then
      fromMap = response
    end
  end

  return fromMap == nil
end

local function getCollisionResponseFromMap(entity, collDir, collClass)
  if not entity.getCollisionResponseMap then return end

  for dir, response in pairs(entity:getCollisionResponseMap(collClass)) do
    if geom.isNearToDir(dir, collDir) then
      return response
    end
  end
end

function _M:getCollisionResponse(collInfo)
  local entity = self.entity

  -- if it doesn't have a response map, then it's transparent
  if not entity.getCollisionResponseMap then
    return
  end

  local invCollDir = geom.invertDir(collInfo.side)

  -- fetch from map response priority for this collision direction
  local priorityFromMap =
    getCollisionResponseFromMap(entity, collInfo.side, collInfo.collider.class)

  -- if there isn't a response for collInfo.side direction then
  -- it's transparent too
  if not priorityFromMap then return end

  local responseList = collection.List.new()
  local queriedColliders = collection.List.new()

  responseList:push_back({
    priority=priorityFromMap,
    velocity=common.getVelFromDir(collInfo.side, collInfo.selfInfo.vel)
  })

  -- search in collisions
  for _, _collInfo in self.colls:iterator() do
    if geom.areOpposites(_collInfo.side, collInfo.side) then
      -- collision with static object
      if not _collInfo.collider.collReaction then
        responseList:push_back({priority=9, velocity=0.0})
      else
        local selfPriority = getCollisionResponseFromMap(entity, invCollDir, _collInfo.collider.class)

        if selfPriority then
          if not queriedColliders:contains(_collInfo.collider) then
            local colliderResponseList = _collInfo.collider.collReaction:getCollisionResponse(collInfo)
            for _, response in colliderResponseList:iterator() do
              if response.priority > selfPriority then
                responseList:push_back(response)
              end
              if response.priority == selfPriority then
                local vel=
                  (common.getVelFromDir(collInfo.side, collInfo.selfInfo.vel) +
                  response.velocity)/2.0

                responseList:push_back({priority=response.priority, velocity=vel})
              end
            end

            queriedColliders:push_back(_collInfo.collider)
          end
        end
      end
    end
  end

  -- now order responses by velocity and priority
  responseList:sort(function(a, b)
    if a.velocity ~= b.velocity then
      if geom.isNearToDir(collInfo.side, geom.collDir.N) or
        geom.isNearToDir(collInfo.side, geom.collDir.E) then
        return a.velocity - b.velocity
      end

      if geom.isNearToDir(collInfo.side, geom.collDir.S) or
        geom.isNearToDir(collInfo.side, geom.collDir.W) then
        return b.velocity - a.velocity
      end
    end

    return a.priority - b.priority
  end)

  -- filter irrelevant responses
  local filtered = collection.List.new()

  local maxPriority = -math.huge
  for _, response in responseList:iterator() do
    if response.priority > maxPriority then
      filtered:push_back(response)
      maxPriority = response.priority
    end
  end

  return filtered
end

-- calculates the result from all responses
local function calcResponse(collInfo)
  local a = collInfo.selfResponse
  local b = collInfo.colliderResponse

  if not a or not b then
    --if not a then error("satan, not a") end
    --if not b then error("satan, not b") end
    return
  end
  if a:is_empty() or b:is_empty() then return end

  local fromTopOrRight =
    geom.isNearToDir(collInfo.side, geom.collDir.N) or
    geom.isNearToDir(collInfo.side, geom.collDir.E)

  local currResponse

  local ai = 1
  local bi = 1

  -- left & right collision or bottom and upper, in this order
  local isMovingCloser = function(leftColl, rightColl)
    return (rightColl.velocity - leftColl.velocity) < 0
  end

  local doCompare = function(currResponse, ai, bi)
    if not currResponse then

      local movingCloser
      if fromTopOrRight then
        movingCloser = isMovingCloser(a:at(ai), b:at(bi))
      else
        movingCloser = isMovingCloser(b:at(bi), a:at(ai))
      end

      if not movingCloser then
        return nil, math.huge, math.huge
      end

      if a:at(ai).priority < b:at(bi).priority then
        return b:at(bi), ai+1, bi
      end
      if b:at(bi).priority < a:at(ai).priority then
        return a:at(ai), ai, bi+1
      end

      return {
        priority = a:at(ai).priority,
        velocity = (a:at(ai).velocity + b:at(bi).velocity)/2
      }, ai+1, bi+1
    else
      local movingCloserA, movingCloserB
      if fromTopOrRight then
        movingCloserA = a:at(ai) and
          isMovingCloser(a:at(ai), currResponse) or false
        movingCloserB = b:at(bi) and
          isMovingCloser(currResponse, b:at(bi)) or false
      else
        movingCloserA = a:at(ai) and
          isMovingCloser(currResponse, a:at(ai)) or false
        movingCloserB = b:at(bi) and
          isMovingCloser(b:at(bi), currResponse) or false
      end

      if not movingCloserA and not movingCloserB then
        return currResponse, math.huge, math.huge
      end

      if movingCloserA then
        if a:at(ai).priority < currResponse.priority then
          return currResponse, ai+1, bi
        end
        if currResponse.priority < a:at(ai).priority then
          return a:at(ai), ai+1, bi
        end

        return {
          priority = a:at(ai).priority,
          velocity = (a:at(ai).velocity + currResponse.velocity)/2
        }, ai+1, bi
      end

      if movingCloserB then
        if b:at(bi).priority < currResponse.priority then
          return currResponse, ai, bi+1
        end
        if currResponse.priority < b:at(bi).priority then
          return a:at(ai), ai, bi+1
        end

        return {
          priority = b:at(bi).priority,
          velocity = (b:at(bi).velocity + currResponse.velocity)/2
        }, ai, bi+1
      end
    end
  end

  while (ai <= a:size()) or (bi <= b:size()) do
    currResponse, ai, bi = doCompare(currResponse, ai, bi)
  end

  if currResponse == a:at(1) then
    return
  end

  return currResponse
end

function _M:collisionListener(collInfo)
  local entity = self.entity

  local mirroredColl =
    base.createCollObj(
      collInfo.collider,
      collInfo.self,
      collInfo.self,
      geom.invertDir(collInfo.side),
      collInfo.time
    )

  mirroredColl.selfInfo = collInfo.colliderInfo
  mirroredColl.colliderInfo = collInfo.selfInfo

  local transparent = isTransparent(collInfo.self, collInfo) or isTransparent(mirroredColl.self, mirroredColl)

  local findCollFunc =
  function(coll)
    return coll.source == collInfo.source
  end

  if not transparent and self.allColls:filter(findCollFunc):is_empty() then
    self.allColls:push_back(collInfo)
  end

  collInfo.selfResponse = entity.collReaction:getCollisionResponse(collInfo)

  if collInfo.collider == collInfo.source then
    local staticResponse = collection.List.new()
    staticResponse:push_back({priority=9, velocity=0.0})

    collInfo.colliderResponse =
      collInfo.collider.collReaction and
      collInfo.collider.collReaction:getCollisionResponse(mirroredColl) or staticResponse
  end

  if transparent then
    return
  end

  self:collisionReactionCB(collInfo, calcResponse(collInfo))

  for _, _collInfo in self.colls:iterator() do
    if geom.areOpposites(_collInfo.side, collInfo.side) then
      if _collInfo.collider.collisionListener then
        local forwardColl =
          base.createCollObj(
            _collInfo.collider,
            collInfo.source,
            entity,
            collInfo.side,
            -1.0
          )

        forwardColl.colliderResponse = collInfo.colliderResponse

        _collInfo.collider:collisionListener(forwardColl)
      end
    end
  end

  if collInfo.collider == collInfo.source then
    if self.colls:filter(findCollFunc):is_empty() then
      self.colls:push_back(collInfo)
    end

    if collInfo.collider.collisionListener then
      for _, _collInfo in self.allColls:iterator() do
        if geom.areOpposites(_collInfo.side, collInfo.side) then
          local backwardColl =
            base.createCollObj(
              collInfo.collider,
              _collInfo.source,
              entity,
              _collInfo.side,
              -1.0
            )

          backwardColl.colliderResponse = _collInfo.colliderResponse

          collInfo.collider:collisionListener(backwardColl)
        end
      end
    end

  end

end

local collisionOffset = base.positionOffset

function _M:collisionReactionCB(collInfo, response)
  local entity = self.entity

  local time = collInfo.time
  local colliderPos = collInfo.colliderInfo and
    collInfo.colliderInfo.pos or {x=collInfo.collider.x, y=collInfo.collider.y}
  local colliderSize = collInfo.collider.getSize and
    collInfo.collider:getSize() or
    {x=collInfo.collider.z, y=collInfo.collider.w}
  local colliderVel = collInfo.colliderInfo and
    collInfo.colliderInfo.vel or {x=0.0, y=0.0}

  local collDirN = geom.isNearToDir(collInfo.side, geom.collDir.N)
  local collDirS = geom.isNearToDir(collInfo.side, geom.collDir.S)
  local collDirE = geom.isNearToDir(collInfo.side, geom.collDir.E)
  local collDirW = geom.isNearToDir(collInfo.side, geom.collDir.W)

  if collDirN or collDirS then
    if time > 0.0 then
      if collDirN then
        entity:setPosition(
          entity.pos.x,
          entity.pos.y + time*entity.vel.y - collisionOffset
        )
      end

      if collDirS then
        entity:setPosition(
          entity.pos.x,
          entity.pos.y + time*entity.vel.y + collisionOffset
        )
      end
    else
      if collDirN then
        entity:setPosition(
          entity.pos.x,
          colliderPos.y - entity:getSize().y - collisionOffset
        )
      end

      if collDirS then
        entity:setPosition(
          entity.pos.x,
          colliderPos.y + colliderSize.y + collisionOffset
        )
      end
    end

    if response then
      if (collDirN and entity.vel.y > colliderVel.y) or
          (collDirS and entity.vel.y < colliderVel.y) then
        entity:setVelocity(
          entity.vel.x,
          response.velocity
        )

        if collDirS then
          entity:emit("on_ground", collInfo)
        end
      end
    end
  end

  if collDirE or collDirW then
    if time > 0.0 then
      if collDirE then
        entity:setPosition(
          entity.pos.x + time*entity.vel.x - collisionOffset,
          entity.pos.y
        )
      end

      if collDirW then
        entity:setPosition(
          entity.pos.x + time*entity.vel.x + collisionOffset,
          entity.pos.y
        )
      end
    else
      if collDirE then
        entity:setPosition(
          colliderPos.x -
            (colliderSize.x + entity:getSize().x)/2 - collisionOffset,
          entity.pos.y
        )
      end

      if collDirW then
        entity:setPosition(
          colliderPos.x +
            (colliderSize.x + entity:getSize().x)/2 + collisionOffset,
          entity.pos.y
        )
      end
    end

    if response then
      if (collDirE and entity.vel.x > colliderVel.x) or
          (collDirW and entity.vel.x < colliderVel.x) then
        entity:setVelocity(
          response.velocity,
          entity.vel.y
        )
      end
    end
  end
end

return _M
