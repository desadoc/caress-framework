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

require "luaspec"

describe["BSP"] = function()
  before = function()
    BSP = require("BSP")
    Vector = require("Vector")

    aabb = Vector.new(0, 0, 16, 16)
    b = BSP.new(aabb)

    function concat_items(bsp)
      local concat = ""

      BSP.breadthFirstTraversalPostOrder(
        bsp:getRoot(),
        function(root)
          return true
        end,
        function(root)
          if not root.items then
            concat = concat .. "."
          else
            for iter, item in root.items:iterator() do
              concat = concat .. item
            end
            concat = concat .. ","
          end
        end
      )
      return concat
    end
  end

  it["should start with some default parameter values"] = function()
    -- AABB on BSP's root should be a copy
    expect(rawequal(aabb, b:getRoot().aabb)).should_be(false)
    expect(aabb == b:getRoot().aabb).should_be(true)
    expect(b:getMaxItemsPerLeaf()).should_be(4)
    expect(b:getMaxDepth()).should_be(12)
    expect(b:getJoinFactor()).should_be(0.5)

    expect(concat_items(b)).should_be(",")
    expect(b:getMinHeight()).should_be(1)
    expect(b:getMaxHeight()).should_be(1)
  end

  it["should accept parameters"] = function()
    b = BSP.new(aabb, 2, 10, 1.0)

    expect(rawequal(aabb, b:getRoot().aabb)).should_be(false)
    expect(aabb == b:getRoot().aabb).should_be(true)
    expect(b:getMaxItemsPerLeaf()).should_be(2)
    expect(b:getMaxDepth()).should_be(10)
    expect(b:getJoinFactor()).should_be(1.0)
  end

  it["should allow items to be added [01]"] = function()
    b = BSP.new(aabb, 2, 10, 1.0)

    b:add(1, Vector.new(-7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("1,")
    b:add(2, Vector.new( 7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("12,")
    b:add(3, Vector.new(-7.5, 0, 1, 1))
    expect(concat_items(b)).should_be(".3,12,")
    b:add(4, Vector.new( 0, 7.5, 1, 1))
    expect(concat_items(b)).should_be(".34,.14,24,")
    b:add(5, Vector.new( 0, 15.0, 1, 1))
    expect(concat_items(b)).should_be(".34,...4,15,4,25,")
    b:add(6, Vector.new( 7.5, 7.0, 1, 1))
    expect(concat_items(b)).should_be("...34,46,..4,15,4,25,")
  end

  it["should allow items to be added [02]"] = function()
    expect(concat_items(b)).should_be(",")

    b:add(1, Vector.new(-7.5, 0, 1, 1))
    expect(concat_items(b)).should_be("1,")
    b:add(2, Vector.new( 7.5, 0, 1, 1))
    expect(concat_items(b)).should_be("12,")
    b:add(3, Vector.new(-6.5, 0, 1, 1))
    expect(concat_items(b)).should_be("123,")
    b:add(4, Vector.new( 6.5, 0, 1, 1))
    expect(concat_items(b)).should_be("1234,")

    expect(b:getMinHeight()).should_be(1)
    expect(b:getMaxHeight()).should_be(1)

    b:add(5, Vector.new( -7.5, 1, 1, 1))
    expect(concat_items(b)).should_be("..,135,24,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(3)

    b:add(6, Vector.new( -7.5, 8, 1, 1))
    expect(concat_items(b)).should_be("..6,135,24,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(3)

    b:add(7, Vector.new( -6.5, 8, 1, 1))
    expect(concat_items(b)).should_be("..67,135,24,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(3)

    b:add(8, Vector.new( 5.5, 0, 1, 1))
    expect(concat_items(b)).should_be("..67,135,248,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(3)

    b:add(9, Vector.new( 4.5, 0, 1, 1))
    expect(concat_items(b)).should_be("..67,135,2489,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(3)

    b:add("A", Vector.new( 0.5, 0, 1, 1))
    expect(concat_items(b)).should_be("..67,135,..,A,2489,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(5)

    b:add("B", Vector.new( -7.5, 7.5, 1, 1))
    expect(concat_items(b)).should_be("..67B,135B,..,A,2489,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(5)

    b:add("C", Vector.new( -0.5, 7.5, 1, 1))
    expect(concat_items(b)).should_be("..67BC,..135,BC,.,A,2489,")

    expect(b:getMinHeight()).should_be(2)
    expect(b:getMaxHeight()).should_be(5)

    b:add("D", Vector.new( 0.5, 7.5, 1, 1))
    expect(concat_items(b)).should_be(".....67BC,D,135,BC,.D,A,2489,")

    expect(b:getMinHeight()).should_be(3)
    expect(b:getMaxHeight()).should_be(5)

    b:clear()

    expect(concat_items(b)).should_be(",")
    expect(b:getMinHeight()).should_be(1)
    expect(b:getMaxHeight()).should_be(1)
  end

  it["should allow items to be removed [01]"] = function()
    b:add(1, Vector.new(-7.5, 0, 1, 1))
    expect(concat_items(b)).should_be("1,")
    b:remove(1)

    expect(concat_items(b)).should_be(",")
    expect(b:getMinHeight()).should_be(1)
    expect(b:getMaxHeight()).should_be(1)
  end

  it["should allow items to be removed [02]"] = function()
    b = BSP.new(aabb, 2, 10, 1.0)

    b:add(1, Vector.new(-7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("1,")
    b:remove(1)
    b:add(1, Vector.new(-7.5, 15, 1, 1))

    b:add(2, Vector.new( 7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("12,")
    b:remove(2)
    b:add(2, Vector.new( 7.5, 15, 1, 1))

    b:add(3, Vector.new(-7.5, 0, 1, 1))
    expect(concat_items(b)).should_be(".3,12,")
    b:remove(3)
    b:add(3, Vector.new(-7.5, 0, 1, 1))

    b:add(4, Vector.new( 0, 7.5, 1, 1))
    expect(concat_items(b)).should_be(".34,.14,24,")
    b:remove(4)
    b:add(4, Vector.new( 0, 7.5, 1, 1))

    b:add(5, Vector.new( 0, 15.0, 1, 1))
    expect(concat_items(b)).should_be(".34,...4,15,4,25,")
    b:remove(5)
    b:add(5, Vector.new( 0, 15.0, 1, 1))

    b:add(6, Vector.new( 7.5, 7.0, 1, 1))
    expect(concat_items(b)).should_be("...34,46,..4,15,4,25,")
    b:remove(6)
    b:add(6, Vector.new( 7.5, 7.0, 1, 1))

    expect(concat_items(b)).should_be("...34,46,..4,15,4,25,")
  end

  it["should allow items to be removed [03]"] = function()
    b = BSP.new(aabb, 2, 10, 1.0)

    b:add(1, Vector.new(-7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("1,")
    b:add(2, Vector.new( 7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("12,")
    b:add(3, Vector.new(-7.5, 0, 1, 1))
    expect(concat_items(b)).should_be(".3,12,")
    b:add(4, Vector.new( 0, 7.5, 1, 1))
    expect(concat_items(b)).should_be(".34,.14,24,")
    b:add(5, Vector.new( 0, 15.0, 1, 1))
    expect(concat_items(b)).should_be(".34,...4,15,4,25,")
    b:add(6, Vector.new( 7.5, 7.0, 1, 1))
    expect(concat_items(b)).should_be("...34,46,..4,15,4,25,")

    b:remove(4)
    expect(concat_items(b)).should_be(".36,.15,25,")
    b:remove(5)
    expect(concat_items(b)).should_be(".36,12,")
    b:remove(3)
    expect(concat_items(b)).should_be(".6,12,")
    b:remove(2)
    expect(concat_items(b)).should_be("61,")
    b:remove(6)
    expect(concat_items(b)).should_be("1,")
    b:remove(1)
    expect(concat_items(b)).should_be(",")
  end

  it["should allow items to be updated"] = function()
    b = BSP.new(aabb, 2, 10, 1.0)

    b:add(1, Vector.new(-7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("1,")
    b:add(2, Vector.new( 7.5, 15, 1, 1))
    expect(concat_items(b)).should_be("12,")
    b:add(3, Vector.new(-7.5, 0, 1, 1))
    expect(concat_items(b)).should_be(".3,12,")
    b:add(4, Vector.new( 0, 7.5, 1, 1))
    expect(concat_items(b)).should_be(".34,.14,24,")
    b:add(5, Vector.new( 0, 15.0, 1, 1))
    expect(concat_items(b)).should_be(".34,...4,15,4,25,")
    b:add(6, Vector.new( 7.5, 7.0, 1, 1))
    expect(concat_items(b)).should_be("...34,46,..4,15,4,25,")

    b:update(4, Vector.new(-0.5, 7.5, 1, 1))
    expect(concat_items(b)).should_be("...34,6,.25,4,15,")
    b:update(6, Vector.new( 7.5, 7.5, 1, 1))
    expect(concat_items(b)).should_be("...34,6,..4,15,6,25,")
    b:update(6, Vector.new( 7.5, 8.0, 1, 1))
    expect(concat_items(b)).should_be(".34,...4,15,6,25,")
    b:update(5, Vector.new( 0.5, 15.0, 1, 1))
    expect(concat_items(b)).should_be(".34,.41,.6,25,")
    b:update(1, Vector.new(-7.5, 7.5, 1, 1))
    expect(concat_items(b)).should_be("....,41,.3,41,6,25,")
  end
end
