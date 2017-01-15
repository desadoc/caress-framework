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

require "luaspec"

describe["Actor"] = function()
  before = function()
    Vector      = require "caress/Vector"
    geom        = require "caress/geom"
    collection  = require "caress/collection"
    collision   = require "caress/collision"
    classes     = require "caress/classes"

    classes.registerClass(classes, "Object", "./caress/classeslib/Object")
    classes.registerClass(classes.Object, "Entity", "./caress/classeslib/Object/Entity")
    classes.registerClass(classes.Object.Entity, "Actor", "./caress/classeslib/Object/Entity/Actor")
    classes.registerClass(classes.Object.Entity.Actor, "SimpleActor", "./caress/tests/classes/SimpleActor")
    
    classes.finish()

    collOffset = 0.000000001

    setApproximateToExpectLimit(0.000000001)

    function collideEntities(entityA, entityB)
      local collisions = collection.List.new()
      local entityList = collection.List.new()
      entityList:push_back(entityB)

      collision.detection.collideEntityAndEntityList(entityA, entityList, 0, 1.0, function() return true end, collisions)

      return collisions:size() > 0 and collisions:front() or nil
    end

    function collideEntityAndShape(entity, shape)
      local collisions = collection.List.new()
      local shapeList = collection.List.new()
      shapeList:push_back(shape)

      collision.detection.collideAABBEntityAndAABBShapeList(entity, shapeList, 0, 1.0, function() return true end, collisions)

      return collisions:size() > 0 and collisions:front() or nil
    end

  end

  it["should make entities react to shape collisions"] = function()

    local entity  = classes.Object.Entity.Actor.SimpleActor:new()
    local shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)

    entity:cleanupCollInfo()

    entity.pos.x = 0.0
    entity.pos.y = 2.0
    entity.vel.x = 0.0
    entity.vel.y = -4.0

    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)

    expect(entity.pos.x).should_approximate_to(0.0)
    expect(entity.pos.y).should_approximate_to(2.0)
    expect(entity.vel.x).should_approximate_to(0.0)
    expect(entity.vel.y).should_approximate_to(-4.0)

    if (coll) then
      expect(coll.time).should_be(0.25)
      expect(coll.side).should_be(geom.collDir.S)

      entity:cleanupCollInfo()
      entity:collisionListener(coll)
      entity:update()

      expect(entity.pos.x).should_approximate_to(0.0)
      expect(entity.pos.y).should_approximate_to(1.0)
      expect(entity.vel.x).should_approximate_to(0.0)
      expect(entity.vel.y).should_approximate_to(0.0)
    end

  end

  it["should make entities react to entity collisions"] = function()

    function scenario01(collFunc)

      -- vertical collision

      entity1  = classes.Object.Entity.Actor.SimpleActor:new()
      entity2  = classes.Object.Entity.Actor.SimpleActor:new()

      entity1:cleanupCollInfo()
      entity2:cleanupCollInfo()

      entity1.pos.x = 0.0
      entity1.pos.y = 0.0
      entity1.vel.x = 0.0
      entity1.vel.y = 1.0

      entity2.pos.x = 0.0
      entity2.pos.y = 2.0
      entity2.vel.x = 0.0
      entity2.vel.y = -1.0

      coll1 = collideEntities(entity1, entity2)
      coll2 = collideEntities(entity2, entity1)
      expect(coll1).should_not_be(nil)
      expect(coll2).should_not_be(nil)

      expect(entity1.pos.x).should_approximate_to(0.0)
      expect(entity1.pos.y).should_approximate_to(0.0)
      expect(entity1.vel.x).should_approximate_to(0.0)
      expect(entity1.vel.y).should_approximate_to(1.0)

      expect(entity2.pos.x).should_approximate_to(0.0)
      expect(entity2.pos.y).should_approximate_to(2.0)
      expect(entity2.vel.x).should_approximate_to(0.0)
      expect(entity2.vel.y).should_approximate_to(-1.0)

      if (coll1 and coll2) then
        expect(coll1.time).should_be(0.5)
        expect(coll2.time).should_be(0.5)

        expect(coll1.colliderInfo.pos.x).should_approximate_to(0.0)
        expect(coll1.colliderInfo.pos.y).should_approximate_to(2.0)
        expect(coll1.colliderInfo.vel.x).should_approximate_to(0.0)
        expect(coll1.colliderInfo.vel.y).should_approximate_to(-1.0)

        expect(coll2.colliderInfo.pos.x).should_approximate_to(0.0)
        expect(coll2.colliderInfo.pos.y).should_approximate_to(0.0)
        expect(coll2.colliderInfo.vel.x).should_approximate_to(0.0)
        expect(coll2.colliderInfo.vel.y).should_approximate_to(1.0)

        expect(coll1.side).should_be(geom.collDir.N)
        expect(coll2.side).should_be(geom.collDir.S)

        collFunc()

        entity1:update()
        entity2:update()

        expect(coll1.colliderInfo.pos.x).should_approximate_to(0.0)
        expect(coll1.colliderInfo.pos.y).should_approximate_to(2.0)
        expect(coll1.colliderInfo.vel.x).should_approximate_to(0.0)
        expect(coll1.colliderInfo.vel.y).should_approximate_to(-1.0)

        expect(coll2.colliderInfo.pos.x).should_approximate_to(0.0)
        expect(coll2.colliderInfo.pos.y).should_approximate_to(0.0)
        expect(coll2.colliderInfo.vel.x).should_approximate_to(0.0)
        expect(coll2.colliderInfo.vel.y).should_approximate_to(1.0)


        expect(entity1.pos.x).should_approximate_to(0.0)
        expect(entity1.pos.y).should_approximate_to(0.5)
        expect(entity1.vel.x).should_approximate_to(0.0)
        expect(entity1.vel.y).should_approximate_to(0.0)

        expect(entity2.pos.x).should_approximate_to(0.0)
        expect(entity2.pos.y).should_approximate_to(1.5)
        expect(entity2.vel.x).should_approximate_to(0.0)
        expect(entity2.vel.y).should_approximate_to(0.0)
      end

    end

    scenario01(function()
      entity1:collisionListener(coll1)
      entity2:collisionListener(coll2)
    end)

    scenario01(function()
      entity2:collisionListener(coll2)
      entity1:collisionListener(coll1)
    end)

    function scenario02(collFunc)

      -- vertical collision but no reaction because entities are moving away

      entity1  = classes.Object.Entity.Actor.SimpleActor:new()
      entity2  = classes.Object.Entity.Actor.SimpleActor:new()

      entity1:cleanupCollInfo()
      entity2:cleanupCollInfo()

      entity1.pos.x = 0.0
      entity1.pos.y = 0.0
      entity1.vel.x = 0.0
      entity1.vel.y = 0.0

      entity2.pos.x = 0.0
      entity2.pos.y = 1.0
      entity2.vel.x = 0.0
      entity2.vel.y = 1.0

      coll1 = collideEntities(entity1, entity2)
      coll2 = collideEntities(entity2, entity1)
      expect(coll1).should_not_be(nil)
      expect(coll2).should_not_be(nil)

      expect(entity1.pos.x).should_approximate_to(0.0)
      expect(entity1.pos.y).should_approximate_to(0.0)
      expect(entity1.vel.x).should_approximate_to(0.0)
      expect(entity1.vel.y).should_approximate_to(0.0)

      expect(entity2.pos.x).should_approximate_to(0.0)
      expect(entity2.pos.y).should_approximate_to(1.0)
      expect(entity2.vel.x).should_approximate_to(0.0)
      expect(entity2.vel.y).should_approximate_to(1.0)

      if (coll1 and coll2) then
        expect(coll1.time).should_be(-1.0)
        expect(coll2.time).should_be(-1.0)

        expect(coll1.side).should_be(geom.collDir.N)
        expect(coll2.side).should_be(geom.collDir.S)

        collFunc()

        entity1:update()
        entity2:update()

        expect(entity1.pos.x).should_approximate_to(0.0)
        expect(entity1.pos.y).should_approximate_to(0.0)
        expect(entity1.vel.x).should_approximate_to(0.0)
        expect(entity1.vel.y).should_approximate_to(0.0)

        expect(entity2.pos.x).should_approximate_to(0.0)
        expect(entity2.pos.y).should_approximate_to(1.0)
        expect(entity2.vel.x).should_approximate_to(0.0)
        expect(entity2.vel.y).should_approximate_to(1.0)
      end
    end

    scenario02(function()
      entity1:collisionListener(coll1)
      entity2:collisionListener(coll2)
    end)

    scenario02(function()
      entity2:collisionListener(coll2)
      entity1:collisionListener(coll1)
    end)

    function scenario03(collFunc)

      -- horizontal collision

      entity1  = classes.Object.Entity.Actor.SimpleActor:new()
      entity2  = classes.Object.Entity.Actor.SimpleActor:new()

      entity1:cleanupCollInfo()
      entity2:cleanupCollInfo()

      entity1.pos.x = 0.0
      entity1.pos.y = 0.0
      entity1.vel.x = 1.0
      entity1.vel.y = 0.0

      entity2.pos.x = 2.0
      entity2.pos.y = 0.0
      entity2.vel.x = 0.0
      entity2.vel.y = 0.0

      coll1 = collideEntities(entity1, entity2)
      coll2 = collideEntities(entity2, entity1)
      expect(coll1).should_not_be(nil)
      expect(coll2).should_not_be(nil)

      expect(entity1.pos.x).should_approximate_to(0.0)
      expect(entity1.pos.y).should_approximate_to(0.0)
      expect(entity1.vel.x).should_approximate_to(1.0)
      expect(entity1.vel.y).should_approximate_to(0.0)

      expect(entity2.pos.x).should_approximate_to(2.0)
      expect(entity2.pos.y).should_approximate_to(0.0)
      expect(entity2.vel.x).should_approximate_to(0.0)
      expect(entity2.vel.y).should_approximate_to(0.0)

      if (coll1 and coll2) then
        expect(coll1.time).should_be(1.0)
        expect(coll2.time).should_be(1.0)

        expect(coll1.side).should_be(geom.collDir.E)
        expect(coll2.side).should_be(geom.collDir.W)

        collFunc()

        entity1:update()
        entity2:update()

        expect(entity1.pos.x).should_approximate_to(1.0)
        expect(entity1.pos.y).should_approximate_to(0.0)
        expect(entity1.vel.x).should_approximate_to(0.5)
        expect(entity1.vel.y).should_approximate_to(0.0)

        expect(entity2.pos.x).should_approximate_to(2.0)
        expect(entity2.pos.y).should_approximate_to(0.0)
        expect(entity2.vel.x).should_approximate_to(0.5)
        expect(entity2.vel.y).should_approximate_to(0.0)
      end
    end

    scenario03(function()
      entity1:collisionListener(coll1)
      entity2:collisionListener(coll2)
    end)

    scenario03(function()
      entity2:collisionListener(coll2)
      entity1:collisionListener(coll1)
    end)

    function scenario04(collFunc)

      -- horizontal collision but no reaction because entities are moving away

      entity1  = classes.Object.Entity.Actor.SimpleActor:new()
      entity2  = classes.Object.Entity.Actor.SimpleActor:new()

      entity1:cleanupCollInfo()
      entity2:cleanupCollInfo()

      entity1.pos.x = 0.0
      entity1.pos.y = 0.0
      entity1.vel.x = -1.0
      entity1.vel.y = 0.0

      entity2.pos.x = 1.0
      entity2.pos.y = 0.0
      entity2.vel.x = 1.0
      entity2.vel.y = 0.0

      coll1 = collideEntities(entity1, entity2)
      coll2 = collideEntities(entity2, entity1)
      expect(coll1).should_not_be(nil)
      expect(coll2).should_not_be(nil)

      expect(entity1.pos.x).should_approximate_to(0.0)
      expect(entity1.pos.y).should_approximate_to(0.0)
      expect(entity1.vel.x).should_approximate_to(-1.0)
      expect(entity1.vel.y).should_approximate_to(0.0)

      expect(entity2.pos.x).should_approximate_to(1.0)
      expect(entity2.pos.y).should_approximate_to(0.0)
      expect(entity2.vel.x).should_approximate_to(1.0)
      expect(entity2.vel.y).should_approximate_to(0.0)

      if (coll1 and coll2) then
        expect(coll1.time).should_be(-1.0)
        expect(coll2.time).should_be(-1.0)

        expect(coll1.side).should_be(geom.collDir.E)
        expect(coll2.side).should_be(geom.collDir.W)

        collFunc()

        entity1:update()
        entity2:update()

        expect(entity1.pos.x).should_approximate_to(0.0)
        expect(entity1.pos.y).should_approximate_to(0.0)
        expect(entity1.vel.x).should_approximate_to(-1.0)
        expect(entity1.vel.y).should_approximate_to(0.0)

        expect(entity2.pos.x).should_approximate_to(1.0)
        expect(entity2.pos.y).should_approximate_to(0.0)
        expect(entity2.vel.x).should_approximate_to(1.0)
        expect(entity2.vel.y).should_approximate_to(0.0)
      end
    end

    scenario04(function()
      entity1:collisionListener(coll1)
      entity2:collisionListener(coll2)
    end)

    scenario04(function()
      entity2:collisionListener(coll2)
      entity1:collisionListener(coll1)
    end)

  end

  it["should make entities react to shape and entity collisions"] = function()

    function scenario01(collFunc)

      -- vertical collision

      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.0
      b_entity.vel.x = 0.0
      b_entity.vel.y = 0.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.0
      c_entity.vel.x = 0.0
      c_entity.vel.y = 0.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.0)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(0.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.0)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(0.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(-1.0)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        expect(b_entity.vel.x).should_approximate_to(0.0)
        expect(b_entity.vel.y).should_approximate_to(0.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        expect(c_entity.vel.x).should_approximate_to(0.0)
        expect(c_entity.vel.y).should_approximate_to(0.0)

      end

    end

    scenario01(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)

    function scenario02(collFunc)

      -- vertical collision with a moving entity

      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.0
      b_entity.vel.x = 0.0
      b_entity.vel.y = 1.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.0
      c_entity.vel.x = 0.0
      c_entity.vel.y = -1.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_not_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.0)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(1.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.0)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(-1.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(-1.0)
        expect(coll_ca.time).should_approximate_to(1.0)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        expect(b_entity.vel.x).should_approximate_to(0.0)
        expect(b_entity.vel.y).should_approximate_to(0.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        expect(c_entity.vel.x).should_approximate_to(0.0)
        expect(c_entity.vel.y).should_approximate_to(0.0)
      end
    end

    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
    end)

    function scenario03(collFunc)

      -- vertical collision with a moving entity

      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.0
      b_entity.vel.x = 0.0
      b_entity.vel.y = -1.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.0
      c_entity.vel.x = 0.0
      c_entity.vel.y = 1.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.0)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(-1.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.0)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(1.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(-1.0)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        expect(b_entity.vel.x).should_approximate_to(0.0)
        expect(b_entity.vel.y).should_approximate_to(0.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        expect(c_entity.vel.x).should_approximate_to(0.0)
        expect(c_entity.vel.y).should_approximate_to(1.0)
      end
    end

    scenario03(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario03(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario03(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario03(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario03(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario03(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)

    function scenario04(collFunc)

      -- vertical collision with a moving entity

      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.0
      b_entity.vel.x = 0.0
      b_entity.vel.y = 1.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.0
      c_entity.vel.x = 0.0
      c_entity.vel.y = 1.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.0)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(1.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.0)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(1.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(-1.0)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        expect(b_entity.vel.x).should_approximate_to(0.0)
        expect(b_entity.vel.y).should_approximate_to(1.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        expect(c_entity.vel.x).should_approximate_to(0.0)
        expect(c_entity.vel.y).should_approximate_to(1.0)
      end
    end

    scenario04(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario04(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario04(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario04(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario04(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario04(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)

    function scenario05(collFunc)

      -- vertical collision with a moving entity

      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.0
      b_entity.vel.x = 0.0
      b_entity.vel.y = -1.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.0
      c_entity.vel.x = 0.0
      c_entity.vel.y = -1.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_not_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.0)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(-1.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.0)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(-1.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(-1.0)
        expect(coll_ca.time).should_approximate_to(1.0)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_ca.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        expect(b_entity.vel.x).should_approximate_to(0.0)
        expect(b_entity.vel.y).should_approximate_to(0.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        expect(c_entity.vel.x).should_approximate_to(0.0)
        expect(c_entity.vel.y).should_approximate_to(0.0)
      end
    end

    scenario05(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
    end)
    scenario05(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    scenario05(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
    end)

  end

  it["should make entities react to shape and entity priority collisions"] = function()

    function scenario01(collFunc)

      -- vertical collision

      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      c_entity:setPriority(1)

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.0
      b_entity.vel.x = 0.0
      b_entity.vel.y = 0.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.0
      c_entity.vel.x = 0.0
      c_entity.vel.y = 0.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.0)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(0.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.0)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(0.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(-1.0)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        expect(b_entity.vel.x).should_approximate_to(0.0)
        expect(b_entity.vel.y).should_approximate_to(0.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        expect(c_entity.vel.x).should_approximate_to(0.0)
        expect(c_entity.vel.y).should_approximate_to(0.0)

      end
    end

    scenario01(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)

    function scenario02(collFunc)

      -- vertical collision with a moving entity
      --
      -- This scenario is not supposed to pass including expects on velocity
      -- with reaction "filter".
      -- This is due to the algorithm being unable to handle in a single
      -- iteration a situation where a collision changes from non-existent
      -- to being a contact or a full collision.


      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      c_entity:setPriority(1)

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.0
      b_entity.vel.x = 0.0
      b_entity.vel.y = 1.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.0
      c_entity.vel.x = 0.0
      c_entity.vel.y = -1.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_not_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.0)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(1.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.0)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(-1.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(-1.0)
        expect(coll_ca.time).should_approximate_to(1.0)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_ca.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        --expect(b_entity.vel.x).should_approximate_to(0.0)
        --expect(b_entity.vel.y).should_approximate_to(0.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        --expect(c_entity.vel.x).should_approximate_to(0.0)
        --expect(c_entity.vel.y).should_approximate_to(0.0)
      end
    end

    -- Some combinations below are commented out because they reveal
    -- the order dependent nature of the current reaction algorithm (filter).
    -- They are to be used after a new algorithm, like "chain" is implemented.
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
    end)
    scenario02(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    
    scenario02(function()
    --  b_entity:collisionListener(coll_bc)
    --  b_entity:collisionListener(coll_ba)
    --  c_entity:collisionListener(coll_cb)
    --  c_entity:collisionListener(coll_ca)
    end)
    
    scenario02(function()
    --  b_entity:collisionListener(coll_bc)
    --  c_entity:collisionListener(coll_cb)
    --  b_entity:collisionListener(coll_ba)
    --  c_entity:collisionListener(coll_ca)
    end)
    
    scenario02(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    
    scenario02(function()
    --  c_entity:collisionListener(coll_cb)
    --  b_entity:collisionListener(coll_bc)
    --  b_entity:collisionListener(coll_ba)
    --  c_entity:collisionListener(coll_ca)
    end)
  end

--[[
  ---
  -- This scenario isn't expected to pass until a new reaction algorithm,
  -- maybe "chain", is finished.
  --
  it["should address these special scenarios"] = function()
    function scenario01(collFunc)

      -- vertical collision with a moving entity

      a_shape  = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
      b_entity = classes.Object.Entity.Actor.SimpleActor:new()
      c_entity = classes.Object.Entity.Actor.SimpleActor:new()

      b_entity:cleanupCollInfo()
      c_entity:cleanupCollInfo()

      c_entity:setPriority(1)

      b_entity.pos.x = 0.0
      b_entity.pos.y = 1.5
      b_entity.vel.x = 0.0
      b_entity.vel.y = -1.0

      c_entity.pos.x = 0.0
      c_entity.pos.y = 2.5
      c_entity.vel.x = 0.0
      c_entity.vel.y = -2.0

      coll_ba = collideEntityAndShape(b_entity, a_shape)
      coll_ca = collideEntityAndShape(c_entity, a_shape)
      coll_bc = collideEntities(b_entity, c_entity)
      coll_cb = collideEntities(c_entity, b_entity)

      expect(coll_ba).should_not_be(nil)
      expect(coll_ca).should_not_be(nil)
      expect(coll_bc).should_not_be(nil)
      expect(coll_cb).should_not_be(nil)

      expect(b_entity.pos.x).should_approximate_to(0.0)
      expect(b_entity.pos.y).should_approximate_to(1.5)
      expect(b_entity.vel.x).should_approximate_to(0.0)
      expect(b_entity.vel.y).should_approximate_to(-1.0)

      expect(c_entity.pos.x).should_approximate_to(0.0)
      expect(c_entity.pos.y).should_approximate_to(2.5)
      expect(c_entity.vel.x).should_approximate_to(0.0)
      expect(c_entity.vel.y).should_approximate_to(-2.0)

      if (coll_ba and coll_bc and coll_cb) then

        expect(coll_ba.time).should_approximate_to(0.5)
        expect(coll_ca.time).should_approximate_to(0.75)
        expect(coll_bc.time).should_approximate_to(-1.0)
        expect(coll_cb.time).should_approximate_to(-1.0)

        expect(coll_ba.side).should_be(geom.collDir.S)
        expect(coll_ca.side).should_be(geom.collDir.S)
        expect(coll_bc.side).should_be(geom.collDir.N)
        expect(coll_cb.side).should_be(geom.collDir.S)

        collFunc()

        b_entity:update()
        c_entity:update()

        expect(b_entity.pos.x).should_approximate_to(0.0)
        expect(b_entity.pos.y).should_approximate_to(1.0)
        expect(b_entity.vel.x).should_approximate_to(0.0)
        expect(b_entity.vel.y).should_approximate_to(0.0)

        expect(c_entity.pos.x).should_approximate_to(0.0)
        expect(c_entity.pos.y).should_approximate_to(2.0)
        expect(c_entity.vel.x).should_approximate_to(0.0)
        expect(c_entity.vel.y).should_approximate_to(0.0)
      end
    end

    scenario01(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      c_entity:collisionListener(coll_cb)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_bc)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
      b_entity:collisionListener(coll_ba)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_cb)
      c_entity:collisionListener(coll_ca)
    end)
    scenario01(function()
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_ba)
      b_entity:collisionListener(coll_bc)
      c_entity:collisionListener(coll_ca)
    end)
    scenario01(function()
      c_entity:collisionListener(coll_cb)
      b_entity:collisionListener(coll_bc)
      b_entity:collisionListener(coll_ba)
      c_entity:collisionListener(coll_ca)
    end)

  end
--]]
end

