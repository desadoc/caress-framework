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

describe["classes"] = function()
  before = function()
    Classes = require "caress/classes"

    Classes.registerClass(Classes, "A", "caress/tests/classes/A")
    Classes.registerClass(Classes.A, "B", "caress/tests/classes/A/B")
    Classes.registerClass(Classes.A, "C", "caress/tests/classes/A/C")
    Classes.registerClass(Classes, "D", "caress/tests/classes/D")
    Classes.registerClass(Classes.A.C, "E", "caress/tests/classes/A/C/E")
    
    Classes:finish()
  end

  it["should create objects"] = function()
    a1 = Classes.A:new()
    b1 = Classes.A.B:new()
    c1 = Classes.A.C:new()
    d1 = Classes.D:new()
  end

  it["should inherit fields"] = function()
    a1 = Classes.A:new()
    expect(a1.bar).should_be(42)

    b1 = Classes.A.B:new()
    expect(b1.bar).should_be(42)

    b1.bar = 84
    expect(b1.bar).should_be(84)
  end

  it["should inherit methods"] = function()
    b1 = Classes.A.B:new()

    b1:foo1()
    expect(b1.bar).should_be(43)
    b1:foo2()
    expect(b1.bar).should_be(42)
  end

  it["should allow method overriding"] = function()
    b1 = Classes.A.B:new()

    b1:foo1()
    expect(b1.bar).should_be(43)
    b1:foo2()
    expect(b1.bar).should_be(42)
    b1:foo3()
    expect(b1.bar).should_be(84)
  end

  it["should allow to call super class overrided methods"] = function()
    b1 = Classes.A.B:new()

    b1:foo1()
    expect(b1.bar).should_be(43)
    b1:foo2()
    expect(b1.bar).should_be(42)
    b1.super("foo3")
    expect(b1.bar).should_be(21)
    b1:foo1()
    expect(b1.bar).should_be(22)
    b1.super("foo3")
    expect(b1.bar).should_be(21)
  end

  it["should correctly answer if two entities are equal"] = function()
    a1 = Classes.A:new()
    b1 = Classes.A.B:new()
    c1 = Classes.A.C:new()
    d1 = Classes.D:new()
    
    expect(a1 == a1).should_be(true)
    expect(b1 == b1).should_be(true)
    expect(c1 == c1).should_be(true)
    expect(d1 == d1).should_be(true)
    
    expect(a1 == b1).should_be(false)
    expect(a1 == c1).should_be(false)
    expect(a1 == d1).should_be(false)
  end

  it["should allow to access subclasses methods from super references"] = function()
    c1 = Classes.A.C:new()
    e1 = Classes.A.C.E:new()
    
    expect(c1.bar).should_be(nil)
    expect(e1.bar).should_be(170)
    
    c1:foo6()
    expect(c1.bar).should_be(168)
    
    e1:foo6()
    expect(e1.bar).should_be(169)
    
    e1.bar = 170
    expect(e1.bar).should_be(170)
    
    e1:foo4()
    expect(e1.bar).should_be(169)
    
    e1:foo7()
    expect(e1.bar).should_be(168)
  end

  it["should be possible to index tables with objects"] = function()
    c1 = Classes.A.C:new()
    
    t = {}
    t[c1] = 1
    
    expect(t[c1]).should_be(1)
    expect(t[c1:getSelf()]).should_be(1)
    expect(t[c1:getSuperSelf()]).should_be(1)
  end

  it["should be possible to query for methods consistently"] = function()
    c1 = Classes.A.C:new()
    
    expect(c1.foo6 == c1.super.foo6).should_be(true)
  end
  
  it["should call the most specialized implementation of a method"] = function()
    e1 = Classes.A.C.E:new()
    
    expect(e1:foo8()).should_be(10)
  end
  
  it["should have the correct super references after each call"] = function()
    e1 = Classes.A.C.E:new()
    
    expect(e1:onlyA()).should_be(nil)
  end
  
  it["should allow anonymous classes"] = function()

    anonClass = Classes.A:AnonClass(function()
      local _class = {}
      function _class:init()
        self.super("init")
      end
      function _class:foo2()
        return self.bar
      end
      return _class
    end)

    anon1 = anonClass:new()
    expect(anon1.bar).should_be(42)

    anon1:foo1()
    expect(anon1.bar).should_be(43)
    
    anon1:foo6()
    expect(anon1.bar).should_be(167)
    expect(anon1:foo2()).should_be(167)
  end

  it["should allow static members and static members inheritance"] = function()
    C = Classes.A.C
    c1 = Classes.A.C:new()
    
    expect(C.FOO).should_be(42)
    expect(C.super.FOO).should_be(21)
    expect(C.BAR).should_be(84)
    expect(C.super.BAR).should_be(84)
    
    expect(c1.class.FOO).should_be(42)
    expect(c1.class.super.FOO).should_be(21)
    expect(c1.class.BAR).should_be(84)
    expect(c1.class.super.BAR).should_be(84)
  end

end

