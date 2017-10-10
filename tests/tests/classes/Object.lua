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

describe["Object"] = function()
  before = function()
    Classes = require("classes")
    Classes.registerClass(Classes, "Object", "classeslib/Object")
    Classes:finish()
  end

  it["should be possible to add listeners"] = function()
    local obj = Classes.Object:new()
    local foo = 0

    obj:emit("bar")
    expect(foo).should_be(0)

    obj:addEventListener("bar", function()
      foo = foo + 1
      return "keep"
    end)

    obj:emit("bar")
    expect(foo).should_be(1)
    obj:emit("bar")
    expect(foo).should_be(2)
    obj:emit("bar")
    expect(foo).should_be(3)
  end

  it["should be possible to remove listeners"] = function()
    local obj = Classes.Object:new()
    local foo = 0

    local listenerFn = function()
      foo = foo + 1
      return "keep"
    end

    obj:addEventListener("bar", listenerFn)
    obj:removeEventListener("bar", listenerFn)

    obj:emit("bar")
    expect(foo).should_be(0)
    obj:emit("bar")
    expect(foo).should_be(0)
    obj:emit("bar")
    expect(foo).should_be(0)
  end

  it["should be possible to remove listeners after being called"] = function()
    local obj = Classes.Object:new()
    local foo = 0

    local listenerFn = function()
      foo = foo + 1
      return "remove"
    end

    obj:addEventListener("bar", listenerFn)

    obj:emit("bar")
    expect(foo).should_be(1)
    obj:emit("bar")
    expect(foo).should_be(1)
    obj:emit("bar")
    expect(foo).should_be(1)
  end

  it["should be possible to reemit events"] = function()
    local obj = Classes.Object:new()
    local pbj = Classes.Object:new()
    local foo = 0

    local listenerFn = function(evt)
      foo = foo + 1
      pbj:reemit(evt)
      return "keep"
    end

    local listenerFn2 = function()
      foo = foo + 2
      return "keep"
    end

    obj:addEventListener("bar", listenerFn)
    pbj:addEventListener("bar", listenerFn2)

    obj:emit("bar")
    expect(foo).should_be(3)
    obj:emit("bar")
    expect(foo).should_be(6)
    obj:emit("bar")
    expect(foo).should_be(9)
  end

  it["should be possible to have complex event names"] = function()
    local obj = Classes.Object:new()
    local foo = 0

    local listenerFn1 = function()
      foo = foo + 1
      return "keep"
    end

    local listenerFn2 = function()
      foo = foo + 2
      return "keep"
    end

    local listenerFn3 = function()
      foo = foo + 3
      return "keep"
    end

    obj:addEventListener("bar", listenerFn1)
    obj:addEventListener("bar.ber", listenerFn2)
    obj:addEventListener("bar.ber.bir", listenerFn3)

    obj:emit("bar")
    expect(foo).should_be(1)
    obj:emit("bar.ber")
    expect(foo).should_be(4)
    obj:emit("bar.ber.bir")
    expect(foo).should_be(10)
    obj:emit("bar.ber.bir.bur")
    expect(foo).should_be(16)
  end
end
