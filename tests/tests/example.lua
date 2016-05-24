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

require 'luaspec'

describe["An Example"] = function()
  before = function()
    bar = 1
  end

  it["should demonstrate that luaspec is working"] = function()
    expect(bar).should_be(1)
  end

  it["should demonstrate how size operator works"] = function()
    local _n = nil

    _n = {}
    expect(#_n).should_be(0)

    _n = {
      _v = {}
    }
    expect(#_n._v).should_be(0)
  end

  it["should demonstrate that closures don't return the same locals"]
  = function()
    local closureFunctor =
    function()
      local bar = ""
      return function()
        bar = bar .. "demo"
        return bar
      end
    end

    local closure_a = closureFunctor()
    local closure_b = closureFunctor()
    
    expect(closure_a).should_not_be(closure_b)

    expect(closure_a()).should_be("demo")
    expect(closure_a()).should_be("demodemo")
    expect(closure_b()).should_be("demo")
  end

  it["should demonstrate that require always return the same cached value"] = function()
    local module_1 = require("caress/tests/example_module")
    local module_2 = require("caress/tests/example_module")

    expect(module_1.barPlusPlus()).should_be(1)
    expect(module_2.barPlusPlus()).should_be(2)
    expect(module_1.barPlusPlus()).should_be(3)
    expect(module_2.barPlusPlus()).should_be(4)
  end

  it["should verify some string operators semantic"] = function()

    local function startsWith(str1, str2)
      return string.find(str1, str2, 1, true) == 1
    end

    local function splitString(str, delimiter)
      local result = {}
      for w in string.gmatch(str, "(%a+)%.?") do
        table.insert(result, w)
      end
      return result
    end

    expect(startsWith("abcde", "a")).should_be(true)
    expect(startsWith("abcde", "ab")).should_be(true)
    expect(startsWith("abcde", "abc")).should_be(true)
    expect(startsWith("abcde", "abcd")).should_be(true)
    expect(startsWith("abcde", "abd")).should_be(false)
    expect(startsWith("abcde", "abcde")).should_be(true)
    expect(startsWith("abcde", "abcdef")).should_be(false)
    expect(startsWith("abcde", "b")).should_be(false)
    expect(startsWith("abcde", "bcde")).should_be(false)
    expect(startsWith("abcde", "")).should_be(true)
    
    local tokens = splitString("a.b.c.d.e", ".")
    
    expect(#tokens).should_be(5)
    expect(tokens[1]).should_be("a")
    expect(tokens[2]).should_be("b")
    expect(tokens[3]).should_be("c")
    expect(tokens[4]).should_be("d")
    expect(tokens[5]).should_be("e")
    
    local tokens = splitString("a.b.c.d.e.", ".")
    
    expect(#tokens).should_be(5)
    expect(tokens[1]).should_be("a")
    expect(tokens[2]).should_be("b")
    expect(tokens[3]).should_be("c")
    expect(tokens[4]).should_be("d")
    expect(tokens[5]).should_be("e")
  end

end

