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
  end

  it["should create objects"] = function()
    a1 = Classes.A:new()
    b1 = Classes.A.B:new()
    c1 = Classes.A.C:new()
  end

  it["should inherit fields"] = function()
    a1 = Classes.A:new()
    expect(a1._bar).should_be(42)

    b1 = Classes.A.B:new()
    expect(b1._bar).should_be(42)

    b1._bar = 84
    expect(b1._bar).should_be(84)
    expect(b1.super._bar).should_be(nil)
  end

  it["should inherit methods"] = function()
    b1 = Classes.A.B:new()

    b1:foo1()
    expect(b1._bar).should_be(43)
    b1:foo2()
    expect(b1._bar).should_be(42)
  end

  it["should allow method overriding"] = function()
    b1 = Classes.A.B:new()

    b1:foo1()
    expect(b1._bar).should_be(43)
    b1:foo2()
    expect(b1._bar).should_be(42)
    b1:foo3()
    expect(b1._bar).should_be(84)
  end

  it["should allow to call super class overrided methods"] = function()
    b1 = Classes.A.B:new()

    b1:foo1()
    expect(b1._bar).should_be(43)
    b1:foo2()
    expect(b1._bar).should_be(42)
    b1.super:foo3()
    expect(b1._bar).should_be(21)
    b1:foo1()
    expect(b1._bar).should_be(22)
    b1.super.foo3(b1)
    expect(b1._bar).should_be(21)
  end

  it["should allow to override (and shadow) fields"] = function()
    c1 = Classes.A.C:new()

    expect(c1._bar).should_be(168)
    expect(c1.super._bar).should_be(42)

    c1:foo1()
    expect(c1._bar).should_be(169)
    expect(c1.super._bar).should_be(42)

    c1.super:foo1()
    expect(c1._bar).should_be(170)
    expect(c1.super._bar).should_be(42)

    c1.super.foo1(c1)
    expect(c1._bar).should_be(171)
    expect(c1.super._bar).should_be(42)

  end

end

