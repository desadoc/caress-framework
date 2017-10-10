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

local luaspec = require("luaspec")

describe["Entity"] = function()
  before = function()
    Classes = require("classes")
    Classes.registerClass(Classes, "Object", "classeslib/Object")
    Classes.registerClass(Classes.Object, "Entity", "classeslib/Object/Entity")
    Classes.registerClass(
      Classes.Object, "Cohandler", "classeslib/Object/Cohandler"
    )
    Classes.registerClass(
      Classes.Object, "Condition", "classeslib/Object/Condition"
    )
    Classes.registerClass(
      Classes.Object.Condition, "EventCondition",
      "classeslib/Object/Condition/EventCondition"
    )
    Classes:finish()
  end

  it["should be able to have a main coroutine"] = function()
    local foo = 0
    local e1 = Classes.Object.Entity:AnonClass(function()
      local class = {}
      function class:main(coh)
        foo = foo + 1
      end
      return class
    end):new()

    expect(foo).should_be(0)

    e1:start()
    expect(foo).should_be(1)
  end

  it["should be able to have async calls on coroutines"] = function()
    local foo = 0
    local e1 = Classes.Object.Entity:AnonClass(function()
      local class = {}
      function class:main(coh)
        foo = foo + 1
        coh:event(self, "bar"):wait()
        foo = foo + 1
      end
      return class
    end):new()

    e1:start()
    expect(foo).should_be(1)

    e1:emit("bar")
    e1:update(0)
    expect(foo).should_be(2)
  end

  it["should be able to create conditions and satisfy them before waiting"] =
  function()
    local foo = 0

    local e1 = Classes.Object.Entity:AnonClass(function()
      local class = {}
      function class:main(coh)
        self:emit("bar")
      end
      return class
    end):new()

    local e2 = Classes.Object.Entity:AnonClass(function()
      local class = {}
      function class:main(coh)
        foo = foo + 1
        local cond = coh:event(e1, "bar")
        coh:setCondition(cond)

        e1:start()
        cond:wait()
        
        foo = foo + 1
      end
      return class
    end):new()

    e2:start()
    expect(foo).should_be(1)

    e2:update(0)
    expect(foo).should_be(2)
  end
end
