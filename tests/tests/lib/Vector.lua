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

describe["Vector"] = function()

  before = function()
    Vector = require("caress/Vector")
  end

  it["should work"] = function()

    local v1, v2, v3

    v1 = Vector.new()

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(0)
    expect(v1.w).should_be(0)

    expect(Vector.equals(v1, v1)).should_be(true)
    expect(Vector.equals(v1, Vector.new())).should_be(true)
    expect(Vector.equals(v1, Vector.new(0, 0, 0, 0))).should_be(true)

    v1 = Vector.new(1, 2, 3)

    expect(Vector.equals(v1, Vector.new(1, 2, 3))).should_be(true)
    expect(Vector.equals(Vector.new(1, 2, 3), Vector.new(1, 2, 3, 0))).should_be(true)

    expect(v1.x).should_be(1)
    expect(v1.y).should_be(2)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(0)

    v1 = Vector.new(1, 2, 3, 4)

    expect(v1.x).should_be(1)
    expect(v1.y).should_be(2)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(4)

    v2 = Vector.new_cpy(v1)

    expect(v2.x).should_be(1)
    expect(v2.y).should_be(2)
    expect(v2.z).should_be(3)
    expect(v2.w).should_be(4)

    v2.x = -1
    v2.y = -2
    v2.z = -3
    v2.w = -4

    expect(v1.x).should_be(1)
    expect(v1.y).should_be(2)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(4)

    expect(v2.x).should_be(-1)
    expect(v2.y).should_be(-2)
    expect(v2.z).should_be(-3)
    expect(v2.w).should_be(-4)

    Vector.set(v1, 1, 1)

    expect(v1.x).should_be(1)
    expect(v1.y).should_be(1)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(4)

    Vector.set(v1, 4, 3, 2, 1)

    expect(v1.x).should_be(4)
    expect(v1.y).should_be(3)
    expect(v1.z).should_be(2)
    expect(v1.w).should_be(1)

    v2 = Vector.new()

    Vector.cpy(v1, v2)

    expect(Vector.equals(v1, v2)).should_be(true)

    expect(v2.x).should_be(4)
    expect(v2.y).should_be(3)
    expect(v2.z).should_be(2)
    expect(v2.w).should_be(1)

    v3 = Vector.new()

    Vector.add(v1, v2, v3)
    expect(Vector.equals(v1, v3)).should_be(false)
    expect(Vector.equals(v2, v3)).should_be(false)

    expect(v3.x).should_be(8)
    expect(v3.y).should_be(6)
    expect(v3.z).should_be(4)
    expect(v3.w).should_be(2)

    Vector.unm(v3, v3)

    expect(v3.x).should_be(-8)
    expect(v3.y).should_be(-6)
    expect(v3.z).should_be(-4)
    expect(v3.w).should_be(-2)

    Vector.sub(v1, v3, v3)

    expect(v3.x).should_be(12)
    expect(v3.y).should_be(9)
    expect(v3.z).should_be(6)
    expect(v3.w).should_be(3)

    Vector.set(v1, 0.5, 1.0, 2.0, 4.0)
    Vector.mul(v3, v1, v3)

    expect(v3.x).should_be(6)
    expect(v3.y).should_be(9)
    expect(v3.z).should_be(12)
    expect(v3.w).should_be(12)

    Vector.mul(v3, 0.5, v3)

    expect(v3.x).should_be(3)
    expect(v3.y).should_be(4.5)
    expect(v3.z).should_be(6)
    expect(v3.w).should_be(6)

    Vector.set(v1, 1.0, 2.0, 2.5, 4.0)

    Vector.mod(v3, v1, v3)

    expect(v3.x).should_be(0)
    expect(v3.y).should_be(0.5)
    expect(v3.z).should_be(1)
    expect(v3.w).should_be(2)

    Vector.set(v3, 5.0, 4.5, 3.0, 2.5)

    Vector.mod(v3, 2, v3)

    expect(v3.x).should_be(1)
    expect(v3.y).should_be(0.5)
    expect(v3.z).should_be(1)
    expect(v3.w).should_be(0.5)

    Vector.set(v1, 0, 0, 0, 0)

    expect(Vector.length(v1)).should_be(0)
    expect(Vector.length2(v1)).should_be(0)

    Vector.set(v1, 1, 1, 0, 0)

    local _len = 0
    _len = math.sqrt(2)

    expect(Vector.length(v1)).should_be(_len)
    expect(Vector.length2(v1)).should_be(_len)

    Vector.set(v1, 0, 0, 1, 1)

    expect(Vector.length(v1)).should_be(_len)
    expect(Vector.length2(v1)).should_be(0)

    Vector.set(v1, 1, 2, 2, 1)

    expect(Vector.length(v1)).should_be(math.sqrt(10))
    expect(Vector.length2(v1)).should_be(math.sqrt(5))

    Vector.set(v1, 1, 0, 0, 0)

    Vector.normalize(v1)

    expect(v1.x).should_be(1)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(0)
    expect(v1.w).should_be(0)

    Vector.set(v1, 1, 1, 0, 0)

    Vector.normalize(v1)

    expect(v1.x).should_be(1/math.sqrt(2))
    expect(v1.y).should_be(1/math.sqrt(2))
    expect(v1.z).should_be(0)
    expect(v1.w).should_be(0)

    Vector.set(v1, 1, 1, 1, 1)

    Vector.normalize(v1)

    expect(v1.x).should_be(0.5)
    expect(v1.y).should_be(0.5)
    expect(v1.z).should_be(0.5)
    expect(v1.w).should_be(0.5)

    Vector.set(v1, 1, 2, 3, 4)

    Vector.normalize(v1)

    expect(v1.x).should_be(1/math.sqrt(30))
    expect(v1.y).should_be(2/math.sqrt(30))
    expect(v1.z).should_be(3/math.sqrt(30))
    expect(v1.w).should_be(4/math.sqrt(30))

    Vector.set(v1, 1, 2)
    Vector.set(v2, 1, 2)

    expect(Vector.distance2(v1, v2)).should_be(0)

    Vector.set(v2, 1, 1)

    expect(Vector.distance2(v1, v2)).should_be(1)

    Vector.set(v2, 0, 1)

    expect(Vector.distance2(v1, v2)).should_be(math.sqrt(2))

    Vector.set(v2, nil, nil, 100, 100)

    expect(Vector.distance2(v1, v2)).should_be(math.sqrt(2))

    Vector.set(v1, 0, 0, 0, 0)
    Vector.set(v2, 0, 0, 1, 1)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(1)
    expect(v1.w).should_be(1)

    Vector.set(v1, 0, 0, 1, 1)
    Vector.set(v2, 0, 0, 1, 1)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(1)
    expect(v1.w).should_be(1)

    Vector.set(v1, 0, 0, 0, 0)
    Vector.set(v2, 0, 0, 0, 0)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(0)
    expect(v1.w).should_be(0)

    Vector.set(v1, 0, 0, 1, 1)
    Vector.set(v2, 0, 0, 0, 0)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(1)
    expect(v1.w).should_be(1)

    Vector.set(v1, 0, 0, 1, 1)
    Vector.set(v2, 0, 0, 2, 2)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(2)
    expect(v1.w).should_be(2)

    Vector.set(v1, 0, 0, 0, 0)
    Vector.set(v2, 1, 0, 0, 0)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0.5)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(1)
    expect(v1.w).should_be(0)

    Vector.set(v2, 0, 1, 0, 0)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0.5)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(1)
    expect(v1.w).should_be(1)

    Vector.set(v2, -1, 0, 0, 0)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(2)
    expect(v1.w).should_be(1)

    Vector.set(v2, 0, -1, 0, 0)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(-1)
    expect(v1.z).should_be(2)
    expect(v1.w).should_be(2)

    Vector.set(v2, 0, -1, 2, 2)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(-1)
    expect(v1.z).should_be(2)
    expect(v1.w).should_be(2)

    Vector.set(v1, 0, 0, 0, 0)
    Vector.set(v2, 1, 1, 1, 1)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0.75)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(1.5)
    expect(v1.w).should_be(2)

    Vector.set(v2, -1, 1, 1, 1)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(0)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(2)

    Vector.set(v2, 1, -1, 1, 1)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(-1)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(3)

    Vector.set(v2, -1, -1, 1, 1)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(-1)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(3)

    Vector.set(v2, 0, 0, 1, 1)

    Vector.expand_aabb(v1, v2)

    expect(v1.x).should_be(0)
    expect(v1.y).should_be(-1)
    expect(v1.z).should_be(3)
    expect(v1.w).should_be(3)

  end

end
