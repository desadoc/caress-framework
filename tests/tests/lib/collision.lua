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

describe["collision"] = function()
  before = function()

    Vector      = require "caress/Vector"
    geom        = require "caress/geom"
    collection  = require "caress/collection"
    collision   = require "caress/collision"
    classes     = require "caress/classes"

    classes.registerClass(classes, "Collider", "caress/tests/classes/Collider")

    classes.registerClass(classes, "Object", "caress/classeslib/Object")
    classes.registerClass(classes.Object, "Entity", "caress/classeslib/Object/Entity")
    classes.registerClass(classes.Object.Entity, "Actor", "caress/classeslib/Object/Entity/Actor")
    classes.registerClass(classes.Object.Entity.Actor, "SimpleActor", "caress/tests/classes/SimpleActor")
    
    classes.finish()

    aabb_1 = nil
    aabb_2 = nil

    collOffset = 0.000000001

    setApproximateToExpectLimit(0.000000001)

    function floatEq(a, b)
      return math.abs(a - b) < 0.000000001
    end

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

  it["should have an AABB shape definition"] = function()

    local aabbShape = geom.aabbShape(0.0, 0.0, 1.0, 1.0)

    expect(floatEq(aabbShape.p1arc, math.pi/4)).should_be(true)

  end

  it["should be that two identicals AABBs intersect"] = function()

    aabb_1 = Vector.new(0,0,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_1)).should_be(true)

    aabb_2 = Vector.new(0,0,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)
  end

  it["should show that an shared edge doesn't implie intersection"] = function()

    aabb_1 = Vector.new(0,0,1,1)
    aabb_2 = Vector.new(0,1,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)

    aabb_2 = Vector.new(0,-1,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)

    aabb_2 = Vector.new(1,0,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)

    aabb_2 = Vector.new(-1,0,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)
  end

  it["shouldn't be that an shared vertice on diagonal means intersection"] = function()

    aabb_1 = Vector.new(0,0,1,1)
    aabb_2 = Vector.new(1,1,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)

    aabb_2 = Vector.new(-1,-1,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)

    aabb_2 = Vector.new(1,-1,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)

    aabb_2 = Vector.new(-1,1,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(false)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(false)
  end

  it["should be that the following expects pass because they should"] = function()

    aabb_1 = Vector.new(0,0,16,16)
    aabb_2 = Vector.new(-7.5,15,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(7.5,15,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(-7.5,0,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(0,7.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(0,15,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(0,0,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(-8.0,15.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new( 8.0,15.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(-8.0,-0.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new( 8.0,-0.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(-8.0,7.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new( 8.0,7.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(0,15.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

    aabb_2 = Vector.new(0,-0.5,1,1)

    expect(collision.base.AABB_intersection_test(aabb_1, aabb_2)).should_be(true)
    expect(collision.base.AABB_intersection_test(aabb_2, aabb_1)).should_be(true)

  end

  it["should verify if two directions are near"] = function()

    local isNearToDir = geom.isNearToDir

    local dir = geom.collDir.N
    local PI = math.pi

    expect(isNearToDir(dir, dir)).should_be(true)

    expect(isNearToDir(dir+PI/8.000001, dir)).should_be(true)
    expect(isNearToDir(dir-PI/8.000001, dir)).should_be(true)

    expect(isNearToDir(dir+PI/7.999999, dir)).should_be(false)
    expect(isNearToDir(dir-PI/7.999999, dir)).should_be(false)

    expect(isNearToDir(dir+PI/1000000.1, dir, PI/1000000.0)).should_be(true)
    expect(isNearToDir(dir-PI/1000000.1, dir, PI/1000000.0)).should_be(true)

    expect(isNearToDir(dir+PI/1000000.1, dir, PI/1000000.2)).should_be(false)
    expect(isNearToDir(dir-PI/1000000.1, dir, PI/1000000.2)).should_be(false)

    expect(isNearToDir(dir+2*PI, dir)).should_be(true)
    expect(isNearToDir(dir+20*PI, dir)).should_be(true)
    expect(isNearToDir(dir+200*PI, dir)).should_be(true)
    expect(isNearToDir(dir+2000*PI, dir)).should_be(true)
    expect(isNearToDir(dir+20000*PI, dir)).should_be(true)

  end

  it["should have proper direction definitions and helpers"] = function()

    local PI = math.pi
    local isNearToDir = function(dirA, dirB)
      return geom.isNearToDir(dirA, dirB, PI/1000000000000000)
    end
    local invertDir = geom.invertDir

    local N = geom.collDir.N
    local E = geom.collDir.E
    local S = geom.collDir.S
    local W = geom.collDir.W
    local NE = geom.collDir.NE
    local SE = geom.collDir.SE
    local SW = geom.collDir.SW
    local NW = geom.collDir.NW

    expect(isNearToDir(N, N)).should_be(true)
    expect(isNearToDir(E, E)).should_be(true)
    expect(isNearToDir(S, S)).should_be(true)
    expect(isNearToDir(W, W)).should_be(true)
    expect(isNearToDir(NE, NE)).should_be(true)
    expect(isNearToDir(SE, SE)).should_be(true)
    expect(isNearToDir(SW, SW)).should_be(true)
    expect(isNearToDir(NW, NW)).should_be(true)

    expect(isNearToDir(N, NE)).should_be(false)
    expect(isNearToDir(E, SE)).should_be(false)
    expect(isNearToDir(S, SW)).should_be(false)
    expect(isNearToDir(W, NW)).should_be(false)
    expect(isNearToDir(NE, E)).should_be(false)
    expect(isNearToDir(SE, S)).should_be(false)
    expect(isNearToDir(SW, W)).should_be(false)
    expect(isNearToDir(NW, N)).should_be(false)

    expect(isNearToDir(E+PI/2, N)).should_be(true)
    expect(isNearToDir(N+PI/2, W)).should_be(true)
    expect(isNearToDir(W+PI/2, S)).should_be(true)
    expect(isNearToDir(S+PI/2, E)).should_be(true)

    expect(isNearToDir(E-PI/2, N)).should_be(false)
    expect(isNearToDir(N-PI/2, W)).should_be(false)
    expect(isNearToDir(W-PI/2, S)).should_be(false)
    expect(isNearToDir(S-PI/2, E)).should_be(false)

    expect(isNearToDir(E-PI/2, S)).should_be(true)
    expect(isNearToDir(N-PI/2, E)).should_be(true)
    expect(isNearToDir(W-PI/2, N)).should_be(true)
    expect(isNearToDir(S-PI/2, W)).should_be(true)

    expect(isNearToDir(E+PI/4, NE)).should_be(true)
    expect(isNearToDir(N+PI/4, NW)).should_be(true)
    expect(isNearToDir(W+PI/4, SW)).should_be(true)
    expect(isNearToDir(S+PI/4, SE)).should_be(true)

    expect(isNearToDir(E-PI/4, NE)).should_be(false)
    expect(isNearToDir(N-PI/4, NW)).should_be(false)
    expect(isNearToDir(W-PI/4, SW)).should_be(false)
    expect(isNearToDir(S-PI/4, SE)).should_be(false)

    expect(isNearToDir(E-PI/4, SE)).should_be(true)
    expect(isNearToDir(N-PI/4, NE)).should_be(true)
    expect(isNearToDir(W-PI/4, NW)).should_be(true)
    expect(isNearToDir(S-PI/4, SW)).should_be(true)

    expect(isNearToDir(N, invertDir(S))).should_be(true)
    expect(isNearToDir(E, invertDir(W))).should_be(true)
    expect(isNearToDir(S, invertDir(N))).should_be(true)
    expect(isNearToDir(W, invertDir(E))).should_be(true)
    expect(isNearToDir(NE, invertDir(SW))).should_be(true)
    expect(isNearToDir(SE, invertDir(NW))).should_be(true)
    expect(isNearToDir(SW, invertDir(NE))).should_be(true)
    expect(isNearToDir(NW, invertDir(SE))).should_be(true)

  end

  it["should collide stopped aabb entities and aabb shapes properly"] = function()
    local entity  = classes.Collider:new()
    local shape     = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
    local coll

    -- from above and below
    entity.pos.y = 1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.S) end

    entity.pos.y = 1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.y = -1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.N) end

    entity.pos.y = -1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- from right and left
    entity.pos.y = 0.0

    entity.pos.x = 1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.W) end

    entity.pos.x = 1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.E) end

    entity.pos.x = -1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- from diagonals
    -- top right corner
    entity.pos.x = 1.0 - collOffset
    entity.pos.y = 1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)

    entity.pos.x = 1.0 - 2*collOffset
    entity.pos.y = 1.0 -   collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.S) end

    entity.pos.x = 1.0 -   collOffset
    entity.pos.y = 1.0 - 2*collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.W) end

    entity.pos.x = 1.0 + collOffset
    entity.pos.y = 1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = 1.0 - collOffset
    entity.pos.y = 1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = 1.0 + collOffset
    entity.pos.y = 1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- top left corner
    entity.pos.x = -1.0 + collOffset
    entity.pos.y =  1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)

    entity.pos.x = -1.0 + 2*collOffset
    entity.pos.y =  1.0 -   collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.S) end

    entity.pos.x = -1.0 +   collOffset
    entity.pos.y =  1.0 - 2*collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.E) end

    entity.pos.x = -1.0 - collOffset
    entity.pos.y =  1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -1.0 + collOffset
    entity.pos.y =  1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -1.0 - collOffset
    entity.pos.y =  1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- bottom right corner
    entity.pos.x =  1.0 - collOffset
    entity.pos.y = -1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)

    entity.pos.x =  1.0 - 2*collOffset
    entity.pos.y = -1.0 +   collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.N) end

    entity.pos.x =  1.0 -   collOffset
    entity.pos.y = -1.0 + 2*collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.W) end

    entity.pos.x =  1.0 + collOffset
    entity.pos.y = -1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 - collOffset
    entity.pos.y = -1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 + collOffset
    entity.pos.y = -1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- bottom left corner
    entity.pos.x = -1.0 + collOffset
    entity.pos.y = -1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)

    entity.pos.x = -1.0 + 2*collOffset
    entity.pos.y = -1.0 +   collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.N) end

    entity.pos.x = -1.0 +   collOffset
    entity.pos.y = -1.0 + 2*collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.E) end

    entity.pos.x = -1.0 - collOffset
    entity.pos.y = -1.0 + collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -1.0 + collOffset
    entity.pos.y = -1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -1.0 - collOffset
    entity.pos.y = -1.0 - collOffset
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

  end

  it["should collide moving aabb entities and shapes properly"] = function()

    local entity  = classes.Collider:new()
    local shape   = geom.aabbShape(0.0, 0.0, 1.0, 1.0)
    local coll

    -- simple left to right movement collision
    entity.pos.x = -1.0 - collOffset
    entity.pos.y =  1.0 - collOffset
    entity.vel.x =  0.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -1.0 - collOffset
    entity.pos.y =  1.0 - collOffset
    entity.vel.x = -1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -1.0 - collOffset
    entity.pos.y =  1.0 - collOffset
    entity.vel.x =  1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.E) end

    entity.pos.x = -1.0 - collOffset
    entity.pos.y =  1.0 + collOffset
    entity.vel.x =  1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- simple right to left movement collision
    entity.pos.x =  1.0 + collOffset
    entity.pos.y =  1.0 - collOffset
    entity.vel.x =  0.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 + collOffset
    entity.pos.y =  1.0 - collOffset
    entity.vel.x =  1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 + collOffset
    entity.pos.y =  1.0 - collOffset
    entity.vel.x =  -1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.W) end

    entity.pos.x =  1.0 + collOffset
    entity.pos.y =  1.0 + collOffset
    entity.vel.x =  -1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- simple up down movement collision
    entity.pos.x =  1.0 - collOffset
    entity.pos.y =  1.0 + collOffset
    entity.vel.y =  0.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 - collOffset
    entity.pos.y =  1.0 + collOffset
    entity.vel.y =  1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 - collOffset
    entity.pos.y =  1.0 + collOffset
    entity.vel.y =  -1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.S) end

    entity.pos.x =  1.0 + collOffset
    entity.pos.y =  1.0 + collOffset
    entity.vel.y =  -1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- simple down up movement collision
    entity.pos.x =  1.0 - collOffset
    entity.pos.y = -1.0 - collOffset
    entity.vel.y =  0.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 - collOffset
    entity.pos.y = -1.0 - collOffset
    entity.vel.y = -1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x =  1.0 - collOffset
    entity.pos.y = -1.0 - collOffset
    entity.vel.y =  1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.N) end

    entity.pos.x =  1.0 + collOffset
    entity.pos.y = -1.0 - collOffset
    entity.vel.y =  1.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    -- Diagonal movement isn't tested because the collision code doesn't
    -- support it intentionally. It needs to be this way so entities doesn't
    -- get blocked by blocks's corners.

    -- now checking collision times
    entity.pos.x = -2.0
    entity.pos.y =  0.0
    entity.vel.x =  0.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

    entity.pos.x = -2.0
    entity.pos.y =  0.0
    entity.vel.x = 10.0
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(floatEq(coll.time, 0.1)).should_be(true) end

    entity.pos.x = -2.0
    entity.pos.y =  0.0
    entity.vel.x =  1.5
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(floatEq(coll.time, 0.666666666)).should_be(true) end

    entity.pos.x = -2.0
    entity.pos.y =  0.0
    entity.vel.x =  1.000001
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_not_be(nil)
    if (coll) then expect(floatEq(coll.time, 0.999999000)).should_be(true) end

    entity.pos.x = -2.0
    entity.pos.y =  0.0
    entity.vel.x =  0.999999
    coll = collideEntityAndShape(entity, shape)
    expect(coll).should_be(nil)

  end

  it["should collide entities with another entities"] = function()

    local entity1  = classes.Collider:new()
    local entity2  = classes.Collider:new()
    local coll

    -- horizontal movement
    entity1.pos.x = -0.5 - collOffset
    entity1.pos.y =  0.0
    entity1.vel.x =  1.0
    entity1.vel.y =  0.0
    entity2.pos.x =  0.5 + collOffset
    entity2.pos.y =  0.0
    entity2.vel.x = -1.0
    entity2.vel.y =  0.0
    coll = collideEntities(entity1, entity2)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.E) end

    entity1.vel.x = -1.0
    entity2.vel.x =  1.0
    coll = collideEntities(entity1, entity2)
    expect(coll).should_be(nil)

    -- vertical movement
    entity1.pos.x =  0.0
    entity1.pos.y =  0.5 + collOffset
    entity1.vel.x =  0.0
    entity1.vel.y = -1.0
    entity2.pos.x =  0.0
    entity2.pos.y = -0.5 - collOffset
    entity2.vel.x =  0.0
    entity2.vel.y =  1.0
    coll = collideEntities(entity1, entity2)
    expect(coll).should_not_be(nil)
    if (coll) then expect(coll.side).should_be(geom.collDir.S) end

    entity1.vel.y =  1.0
    entity2.vel.y = -1.0
    coll = collideEntities(entity1, entity2)
    expect(coll).should_be(nil)

  end

end

