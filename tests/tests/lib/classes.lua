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
    
    Classes.initStaticMembers(Classes)
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
    expect(b1.super.bar).should_be(84)
    expect(b1.bar == b1.super.bar).should_be(true)
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
    b1.super:foo3()
    expect(b1.bar).should_be(21)
    b1:foo1()
    expect(b1.bar).should_be(22)
    b1.super.foo3(b1)
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
    
    expect(a1.super == nil).should_be(true)
    expect(b1.super == b1).should_be(true)
    expect(c1.super == c1).should_be(true)
    expect(d1.super == nil).should_be(true)
    
    expect(b1.super == a1).should_be(false)
    expect(c1.super == a1).should_be(false)
  end
  
  it["should allow to access subclasses methods from super references"] = function()
    c1 = Classes.A.C:new()
    
    expect(c1.bar).should_be(nil)
    expect(c1.super.bar).should_be(nil)
    
    c1.super:foo4()
    expect(c1.bar).should_be(168)
    expect(c1.super.bar).should_be(168)
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
  
  it["should correctly change self reference on super calls"] = function()
    c1 = Classes.A.C:new()
    
    expect(rawequal(c1:foo5(), c1.super)).should_be(true)
  end

end

