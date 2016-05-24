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

describe["List"] = function()
  before = function()
    List = require("caress/collection").List

    l = List.new()
    m = List.new()
    count = 0
    concat = ""
  end

  it["should start empty"] = function()
    expect(l:size()).should_be(0)
    expect(l:is_empty()).should_be(true)
    expect(tostring(l)).should_be("{}")
  end

  it["should allow to be cleared"] = function()
    l:push_back(1)
    l:clear()

    expect(l:size()).should_be(0)
    expect(l:is_empty()).should_be(true)
    expect(tostring(l)).should_be("{}")
  end

  it["should allow items to be pushed back"]  = function()
    l:push_back(1)

    expect(l:front()).should_be(1)
    expect(l:back()).should_be(1)
    expect(l:size()).should_be(1)
    expect(l:is_empty()).should_be(false)
    expect(tostring(l)).should_be("{1, }")

    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    expect(l:front()).should_be(1)
    expect(l:back()).should_be(5)
    expect(l:size()).should_be(5)
    expect(l:is_empty()).should_be(false)
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
  end

  it["should allow items to be pushed at front"]  = function()
    l:push_front(5)

    expect(l:front()).should_be(5)
    expect(l:back()).should_be(5)
    expect(l:size()).should_be(1)
    expect(l:is_empty()).should_be(false)
    expect(tostring(l)).should_be("{5, }")

    l:push_front(4)
    l:push_front(3)
    l:push_front(2)
    l:push_front(1)

    expect(l:front()).should_be(1)
    expect(l:back()).should_be(5)
    expect(l:size()).should_be(5)
    expect(l:is_empty()).should_be(false)
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
  end

  it["should allow mixed pushs"] = function()
    l:push_back(3)
    l:push_front(2)
    l:push_back(4)
    l:push_front(1)
    l:push_back(5)

    expect(l:size()).should_be(5)
    expect(l:is_empty()).should_be(false)
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
  end

  it["should allow items to be removed from the back"] = function()
    l:push_front(1)

    expect(l:remove_back()).should_be(1)

    expect(l:size()).should_be(0)
    expect(l:is_empty()).should_be(true)
    expect(tostring(l)).should_be("{}")

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    expect(l:remove_back()).should_be(5)
    expect(l:remove_back()).should_be(4)
    expect(l:remove_back()).should_be(3)
    expect(l:remove_back()).should_be(2)
    expect(l:remove_back()).should_be(1)

    expect(l:size()).should_be(0)
    expect(l:is_empty()).should_be(true)
    expect(tostring(l)).should_be("{}")
  end

  it["should allow items to be removed from the front"] = function()
    l:push_back(1)

    expect(l:remove_front()).should_be(1)

    expect(l:size()).should_be(0)
    expect(l:is_empty()).should_be(true)
    expect(tostring(l)).should_be("{}")

    l:push_front(5)
    l:push_front(4)
    l:push_front(3)
    l:push_front(2)
    l:push_front(1)

    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")

    expect(l:remove_front()).should_be(1)
    expect(l:remove_front()).should_be(2)
    expect(l:remove_front()).should_be(3)
    expect(l:remove_front()).should_be(4)
    expect(l:remove_front()).should_be(5)

    expect(l:size()).should_be(0)
    expect(l:is_empty()).should_be(true)
    expect(tostring(l)).should_be("{}")
  end

  it["should be iterable front to back"] = function()

    for iter, item in l:iterator() do
      expect(true).should_be(false)
    end

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    for iter, item in l:iterator() do
      count = count + 1
      concat = concat .. item
    end

    expect(concat).should_be("12345")
    expect(count).should_be(5)
  end

  it["should allow lists to be tested for equality"] = function()

    expect(l:equals(m)).should_be(true)
    l:push_back(1)
    expect(l:equals(m)).should_be(false)
    m:push_back(1)
    expect(l:equals(m)).should_be(true)
    l:push_back(2)
    expect(l:equals(m)).should_be(false)
    m:push_back(2)
    expect(l:equals(m)).should_be(true)
    m:clear()
    m:push_back(2)
    m:push_back(1)
    expect(l:equals(m)).should_be(false)
  end

  it["should allow lists to be filtered"] = function()
    expect(l:filter(function() return true end):is_empty()).should_be(true)
    expect(tostring(l:filter(function() return true end))).should_be("{}")

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    expect(l:filter(
      function(item)
        return (item%2) == 0
      end
    ):size()).should_be(2)
    expect(tostring(l:filter(
      function(item)
        return (item%2) == 0
      end
    ))).should_be("{2, 4, }")
  end

  it["should allow to find arbitrary items"] = function()

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    expect(l:at(l:find(1))).should_be(1)
    expect(l:at(l:find(2))).should_be(2)
    expect(l:at(l:find(3))).should_be(3)
    expect(l:at(l:find(4))).should_be(4)
    expect(l:at(l:find(5))).should_be(5)

    for iter, item in l:iterator() do
      expect(l:find(item)).should_be(iter)
    end
  end
  
  it["should answer if it contains an item"] = function()
    
    l:push_back(1)
    l:push_back(2)
    l:push_back(4)
    l:push_back(5)

    expect(l:contains(0)).should_be(false)
    expect(l:contains(1)).should_be(true)
    expect(l:contains(2)).should_be(true)
    expect(l:contains(3)).should_be(false)
    expect(l:contains(4)).should_be(true)
    expect(l:contains(5)).should_be(true)
    expect(l:contains(6)).should_be(false)
    
    l:clear()
    
    l:push_back("a")
    l:push_back("b")
    l:push_back("d")
    l:push_back("e")
    
    expect(l:contains("z")).should_be(false)
    expect(l:contains("a")).should_be(true)
    expect(l:contains("b")).should_be(true)
    expect(l:contains("c")).should_be(false)
    expect(l:contains("d")).should_be(true)
    expect(l:contains("e")).should_be(true)
    expect(l:contains("f")).should_be(false)
    
    l:clear()
    
    local a = {}
    local b = {}
    local c = {}
    local d = {}
    local e = {}
    local f = nil
    
    l:push_back(a)
    l:push_back(b)
    l:push_back(d)
    l:push_back(e)
    
    expect(l:contains(nil)).should_be(false)
    expect(l:contains(a)).should_be(true)
    expect(l:contains(b)).should_be(true)
    expect(l:contains(c)).should_be(false)
    expect(l:contains(d)).should_be(true)
    expect(l:contains(e)).should_be(true)
    expect(l:contains(f)).should_be(false)
  end

  it["should allow items to be removed from returned iterators"] = function()

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    l:remove_at(l:find(1))
    l:remove_at(l:find(2))
    l:remove_at(l:find(3))
    l:remove_at(l:find(4))
    l:remove_at(l:find(5))

    expect(tostring(l)).should_be("{}")

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    l:remove_at(l:find(5))
    l:remove_at(l:find(4))
    l:remove_at(l:find(3))
    l:remove_at(l:find(2))
    l:remove_at(l:find(1))

    expect(tostring(l)).should_be("{}")
  end

  it["should allow items to be swapped"] = function()

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:swap(l:find(1), l:find(3))
    expect(tostring(l)).should_be("{3, 2, 1, 4, 5, }")
    l:swap(l:find(2), l:find(4))
    expect(tostring(l)).should_be("{3, 4, 1, 2, 5, }")
    l:swap(l:find(2), l:find(3))
    expect(tostring(l)).should_be("{2, 4, 1, 3, 5, }")
    l:swap(l:find(5), l:find(4))
    expect(tostring(l)).should_be("{2, 5, 1, 3, 4, }")
  end

  it["should allow items to be moved after another"] = function()

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    l:move_after(l:find(1), l:find(1))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_after(l:find(2), l:find(2))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_after(l:find(3), l:find(3))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_after(l:find(4), l:find(4))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_after(l:find(5), l:find(5))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")

    l:move_after(l:find(1), l:find(2))
    expect(tostring(l)).should_be("{2, 1, 3, 4, 5, }")
    l:move_after(l:find(1), l:find(3))
    expect(tostring(l)).should_be("{2, 3, 1, 4, 5, }")
    l:move_after(l:find(1), l:find(4))
    expect(tostring(l)).should_be("{2, 3, 4, 1, 5, }")
    l:move_after(l:find(1), l:find(5))
    expect(tostring(l)).should_be("{2, 3, 4, 5, 1, }")

    l:move_after(l:find(1), l:find(3))
    expect(tostring(l)).should_be("{2, 3, 1, 4, 5, }")
    l:move_after(l:find(1), l:find(2))
    expect(tostring(l)).should_be("{2, 1, 3, 4, 5, }")
    l:move_after(l:find(1), l:find(4))
    expect(tostring(l)).should_be("{2, 3, 4, 1, 5, }")
    l:move_after(l:find(1), l:find(3))
    expect(tostring(l)).should_be("{2, 3, 1, 4, 5, }")
    l:move_after(l:find(1), l:find(5))
    expect(tostring(l)).should_be("{2, 3, 4, 5, 1, }")
  end

  it["should allow items to be moved before another"] = function()

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    l:move_before(l:find(1), l:find(1))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_before(l:find(2), l:find(2))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_before(l:find(3), l:find(3))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_before(l:find(4), l:find(4))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_before(l:find(5), l:find(5))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")

    l:move_before(l:find(1), l:find(5))
    expect(tostring(l)).should_be("{2, 3, 4, 1, 5, }")
    l:move_before(l:find(1), l:find(4))
    expect(tostring(l)).should_be("{2, 3, 1, 4, 5, }")
    l:move_before(l:find(1), l:find(3))
    expect(tostring(l)).should_be("{2, 1, 3, 4, 5, }")
    l:move_before(l:find(1), l:find(2))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")

    l:move_before(l:find(1), l:find(4))
    expect(tostring(l)).should_be("{2, 3, 1, 4, 5, }")
    l:move_before(l:find(1), l:find(5))
    expect(tostring(l)).should_be("{2, 3, 4, 1, 5, }")
    l:move_before(l:find(1), l:find(3))
    expect(tostring(l)).should_be("{2, 1, 3, 4, 5, }")
    l:move_before(l:find(1), l:find(4))
    expect(tostring(l)).should_be("{2, 3, 1, 4, 5, }")
    l:move_before(l:find(1), l:find(2))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
  end

  it["should allow mixed moving of items after and before one another"] = function()

    l:push_back(1)
    l:push_back(2)
    l:push_back(3)
    l:push_back(4)
    l:push_back(5)

    l:move_after(l:find(1), l:find(2))
    expect(tostring(l)).should_be("{2, 1, 3, 4, 5, }")
    l:move_before(l:find(5), l:find(4))
    expect(tostring(l)).should_be("{2, 1, 3, 5, 4, }")
    l:move_after(l:find(1), l:find(3))
    expect(tostring(l)).should_be("{2, 3, 1, 5, 4, }")
    l:move_before(l:find(5), l:find(1))
    expect(tostring(l)).should_be("{2, 3, 5, 1, 4, }")
    l:move_after(l:find(1), l:find(4))
    expect(tostring(l)).should_be("{2, 3, 5, 4, 1, }")
    l:move_before(l:find(5), l:find(3))
    expect(tostring(l)).should_be("{2, 5, 3, 4, 1, }")
    l:move_before(l:find(5), l:find(2))
    expect(tostring(l)).should_be("{5, 2, 3, 4, 1, }")
    l:move_before(l:find(1), l:find(5))
    expect(tostring(l)).should_be("{1, 5, 2, 3, 4, }")
    l:move_after(l:find(5), l:find(4))
    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")
    l:move_after(l:find(2), l:find(4))
    expect(tostring(l)).should_be("{1, 3, 4, 2, 5, }")
    l:move_after(l:find(1), l:find(5))
    expect(tostring(l)).should_be("{3, 4, 2, 5, 1, }")
    l:move_after(l:find(5), l:find(3))
    expect(tostring(l)).should_be("{3, 5, 4, 2, 1, }")
    l:move_after(l:find(4), l:find(5))
    expect(tostring(l)).should_be("{3, 5, 4, 2, 1, }")
    l:move_before(l:find(4), l:find(5))
    expect(tostring(l)).should_be("{3, 4, 5, 2, 1, }")
    l:move_before(l:find(4), l:find(5))
    expect(tostring(l)).should_be("{3, 4, 5, 2, 1, }")
    l:move_before(l:find(2), l:find(3))
    expect(tostring(l)).should_be("{2, 3, 4, 5, 1, }")
    l:move_before(l:find(1), l:find(4))
    expect(tostring(l)).should_be("{2, 3, 1, 4, 5, }")
  end

  it["should be sorteable"] = function()
    l:push_front(1)
    l:push_front(2)

    l:sort(
      function(a, b)
        return b-a
      end
    )

    expect(tostring(l)).should_be("{1, 2, }")

    l:sort(
      function(a, b)
        return a-b
      end
    )

    expect(tostring(l)).should_be("{2, 1, }")

    l:sort()

    expect(tostring(l)).should_be("{1, 2, }")

    l:sort()

    expect(tostring(l)).should_be("{1, 2, }")

    l:push_front(3)

    l:sort()

    expect(tostring(l)).should_be("{1, 2, 3, }")

    l:sort()

    expect(tostring(l)).should_be("{1, 2, 3, }")

    l:sort(
      function(a, b)
        return a-b
      end
    )

    expect(tostring(l)).should_be("{3, 2, 1, }")

    l:sort()

    expect(tostring(l)).should_be("{1, 2, 3, }")

    l:push_back(4)
    l:push_back(5)

    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")

    l:sort(
      function(a, b)
        return a-b
      end
    )

    expect(tostring(l)).should_be("{5, 4, 3, 2, 1, }")

    l:sort()

    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, }")

    l:clear()

    l:push_back(1)
    l:push_back(3)
    l:push_back(5)
    l:push_back(7)
    l:push_back(9)

    l:push_back(2)
    l:push_back(4)
    l:push_back(6)
    l:push_back(8)
    l:push_back(10)

    l:sort()

    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, }")

    l:sort(
      function(a,b)
        return a-b
      end
    )

    expect(tostring(l)).should_be("{10, 9, 8, 7, 6, 5, 4, 3, 2, 1, }")

    l:sort()

    expect(tostring(l)).should_be("{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, }")
  end
end
