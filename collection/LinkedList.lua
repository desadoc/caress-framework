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

--- Linked list module
--
-- This class implements a double linked non-circular list. It supports
-- almost the same operations as the ArrayList class, including iterators,
-- filtering and sorting. It should be used when you expect many inserts and
-- removals that aren't push_back's or remove_back's.
--
-- But for most situations it should be avoided, as it is quite slow.
--
-- @module collection.LinkedList

local _M = {}

_M = {}
_M.__index = _M
_M._typename = "LinkedList"

function _M.new()
  local _head = {}
  local _tail = {}

  _head.size = 0
  _head.next = _tail
  _head.previous = nil
  _tail.next = nil
  _tail.previous = _head

  local _n = {}
  _n.head = _head
  _n.tail = _tail

  setmetatable(_n, _M)

  return _n
end

function _M.equals(self, list, cmp)
  if self:size() ~= list:size() then
    return false
  end

  cmp = cmp or function(a, b) return a == b end
  local result = true

  _M.iterator2(self, list,
    function(a, b)
      if not cmp(a, b) then
        result = false
        return false
      end

      return true
    end
  )

  return result
end

function _M.__tostring(self)
  local str = "{"
  for iter, item in self:iterator() do
    str = str .. item .. ", "
  end
  str = str .. "}"
  return str
end

_M.tostring = _M.__tostring

function _M.push_back(self, item)
  self.head.size = self.head.size + 1
  local newNode = {previous=self.tail.previous, next=self.tail, item=item}
  self.tail.previous.next = newNode
  self.tail.previous = newNode
end

function _M.push_front(self, item)
  self.head.size = self.head.size + 1
  local newNode = {previous=self.head, next=self.head.next, item=item}
  self.head.next.previous = newNode
  self.head.next = newNode
end

function _M.append(self, list)
  if not list then
    return
  end
  for iter, item in list:iterator() do
    self:push_back(item)
  end
end

function _M.remove_back(self)
  if self.head.next == self.tail then return nil end
  self.head.size = self.head.size - 1
  local item = self.tail.previous.item
  self.tail.previous = self.tail.previous.previous
  self.tail.previous.next = self.tail
  return item
end

function _M.remove_front(self)
  if self.head.next == self.tail then return nil end
  self.head.size = self.head.size - 1
  local item = self.head.next.item
  self.head.next = self.head.next.next
  self.head.next.previous = self.head
  return item
end

function _M.iterator(self)
  return
    function(self, state)
      state = state.next
      if state == self.tail then return end
      return state, state.item
    end, self, self.head
end

function _M.reverseIterator(self)
  return
    function(self, state)
      state = state.previous
      if state == self.head then return end
      return state, state.item
    end, self, self.tail
end

function _M.iterator2(list1, list2, body)
  local iter1 = list1.head.next
  local iter2 = list2.head.next

  while iter1 ~= list1.tail or iter2 ~= list2.tail do
    local cont = body(
      iter1 ~= list1.tail and iter1.item or nil,
      iter2 ~= list2.tail and iter2.item or nil
    )
    if not cont then
      break
    end
    if iter1 ~= list1.tail then
      iter1 = iter1.next
    end
    if iter2 ~= list2.tail then
      iter2 = iter2.next
    end
  end
end

function _M.begin(self)
  return self.head.next
end

function _M.has_next(self, iter)
  return iter ~= self.tail
end

function _M.next(self, iter)
  return iter.next, iter.item
end

function _M.filter(self, filter)
  local result = _M.new()
  for iter, item in self:iterator() do
    if filter(item) then
      result:push_back(item)
    end
  end
  return result
end

function _M.contains(self, item)
  for iter, _item in self:iterator() do
    if item == _item then return true end
  end
end

function _M.front(self)
  if self.head.next ~= self.tail then return self.head.next.item end
end

function _M.back(self)
  if self.head.next ~= self.tail then return self.tail.previous.item end
end

function _M.at(self, iter)
  return iter.item
end

function _M.insert_before(self, iter, item)
  if iter == self.head then self:push_front(item); return; end
  if iter == self.tail then self:push_back(item); return; end
  self.head.size = self.head.size + 1
  local newNode = {next=iter, previous=iter.previous, item=item}
  iter.previous.next = newNode
  iter.previous = newNode
end

function _M.insert_after(self, iter, item)
  if iter == self.tail then
    self:insert_before(iter, item)
  else
    self:insert_before(iter.next, item)
  end
end

function _M.remove_at(self, iter)
  if iter == self.head or iter == self.tail then
    error("Wrong iterator state.")
  end
  self.head.size = self.head.size - 1
  iter.previous.next = iter.next
  iter.next.previous = iter.previous
end

function _M.remove(self, item)
  for iter, _item in self:iterator() do
    if item == _item then
      self:remove_at(iter)
      return item
    end
  end
end

function _M.find(self, item)
  for iter, _item in self:iterator() do
    if item == _item then
      return iter
    end
  end
end

function _M.swap(self, iter1, iter2)
  local next, previous = nil, nil

  next = iter1.next
  previous = iter1.previous

  iter1.previous.next = iter2
  iter1.next.previous = iter2
  iter1.next = iter2.next
  iter1.previous = iter2.previous

  iter2.previous.next = iter1
  iter2.next.previous = iter1
  iter2.next = next
  iter2.previous = previous
end

function _M.move_before(self, iter1, iter2)
  if not iter1 or not iter2 then
    error("Invalid parameter: is null")
  end
  if iter1 == iter2 then
    return
  end
  if iter2.previous == iter2 then
    return
  end
  if iter2 == self.head then
    error("Can't move an item to this position")
  end

  local next, previous = nil, nil

  next = iter1.next
  previous = iter1.previous

  next.previous = previous
  previous.next = next

  iter1.previous = iter2.previous
  iter1.next = iter2
  iter2.previous.next = iter1
  iter2.previous = iter1
end

function _M.move_after(self, iter1, iter2)
  if not iter1 or not iter2 then
    error("Invalid parameter: is null")
  end
  if iter1 == iter2 then
    return
  end
  if iter2.next == iter1 then
    return
  end
  if iter == self.tail then
    error("Can't move an item to this position")
  end

  local next, previous = nil, nil

  next = iter1.next
  previous = iter1.previous

  next.previous = previous
  previous.next = next

  iter1.next = iter2.next
  iter1.previous = iter2
  iter2.next.previous = iter1
  iter2.next = iter1
end

local function sort_rec(list, beginning, size, comparator)
  if size <= 1 then
    return beginning
  end

  local a_size = math.modf(size/2)
  local b_size = size - a_size

  local list_a = beginning
  local list_b = beginning

  for i=1,a_size do
    list_b = list:next(list_b)
  end

  list_a = sort_rec(list, list_a, a_size, comparator)
  list_b = sort_rec(list, list_b, b_size, comparator)
  beginning = list_a

  while (a_size > 0) or (b_size > 0) do
    if (a_size > 0) and (b_size > 0) then
      if comparator(list_a.item, list_b.item) < 0 then
        local next_b = list_b.next

        if list_a == beginning then
          beginning = list_b
        end

        list:move_before(list_b, list_a)
        list_b = next_b
        b_size = b_size - 1
      else
        list_a = list_a.next
        a_size = a_size - 1
      end
    else
      if a_size > 0 then
        list_a = list_a.next
        a_size = a_size - 1
      end

      if b_size > 0 then
        local next_b = list_b.next

        list:move_before(list_b, list_a)
        list_a = list_a.next
        list_b = next_b
        b_size = b_size - 1
      end
    end
  end

  return beginning
end

function _M:sort(criteria, ord)
  if ord then
    if ord ~= 'asc' and ord ~= 'desc' then
      error("second parameter order must be 'asc' or 'desc'")
    end
  end

  ord = ord or 'asc'

  local comparator = nil

  if type(criteria) == 'string' then
    if ord == 'asc' then
      comparator = function(a, b) return b[criteria]-a[criteria] end
    else
      comparator = function(a, b) return a[criteria]-b[criteria] end
    end
  end

  if type(criteria) == 'function' then
    comparator = criteria
  end

  if not comparator then
    if ord == 'asc' then
      comparator = function(a, b) return b-a end
    else
      comparator = function(a, b) return a-b end
    end
  end

  sort_rec(self, self:begin(), self:size(), comparator)
end

function _M.size(self)
  if self.head.size then
    return self.head.size
  end
end

function _M.clear(self)
  self.head.size = 0
  self.head.next = self.tail
  self.tail.previous = self.head
end

function _M.is_empty(self)
  return self.head.next == self.tail
end

-- TODO otimizar?
function _M.copy(self)
  local _new = _M.new()
  for iter, item in self:iterator() do
    _new:push_back(item)
  end
  return _new
end

return _M
