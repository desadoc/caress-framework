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

--- Array list class.
--
-- This module defines an array list implementation over a traditional lua
-- array. The object itself is an lua array and can be manipulated with
-- usual lua methods (e.g. ipairs). Moreover, the table has a metatable
-- with additional methods.
--
-- It is usually a lot faster than LinkedList and it's the default
-- implementation for List.
--
-- @module collection.ArrayList

local _M = {}

_M = {}
_M.__index = _M
_M._typename = "ArrayList"

--- Creates a new array.
-- @param array Optional traditional lua array for initialization.
function _M.new(array)
  local _new = array or {}

  setmetatable(_new, _M)

  return _new
end

--- Compares itself with another list.
-- @param list List to compare to, must support iterator().
-- @param cmp Optional compare function in the form of function(a, b),
--            default comparator is 'function(a, b) return a == b end'.
-- @return True if lists are equal (same elements in same order).
function _M:equals(list, cmp)
  cmp = cmp or function(a, b) return a == b end
  
  if self:size() ~= list:size() then return false end

  local selfIter = self:begin()
  local listIter = list:begin()
  local selfValue, listValue
  
  while self:has_next(selfIter) do
    selfIter, selfValue = self:next(selfIter)
    listIter, listValue = list:next(listIter)
    
    if not cmp(selfValue, listValue) then return false end
  end

  return true
end

--- Returns string representation.
--@return String representation of a table with each item in order.
function _M:__tostring()
  local str = "{"
  for iter, item in self:iterator() do
    str = str .. tostring(item) .. ", "
  end
  str = str .. "}"
  return str
end

_M.tostring = _M.__tostring

--- Appends an item to the back.
function _M:push_back(item)
  table.insert(self, item)
end

--- Adds an item to the front.
function _M:push_front(item)
  table.insert(self, 1, item)
end

--- Appends an entire list to the back.
-- @param list A list object that supports iterator().
function _M:append(list)
  for iter, item in list:iterator() do
    table.insert(self, item)
  end
end

--- Removes an item from the back.
-- @return Returns the removed item.
function _M:remove_back()
  return table.remove(self)
end

--- Removes an item from the front.
-- @return Returns the removed item.
function _M:remove_front()
  return table.remove(self, 1)
end

--- Iterator suitable for use within a for loop.
-- This iterator works in the same fashion as pairs/ipairs functions.
-- @return Returns "next" function, table and initial iterator state.
function _M:iterator()
  return ipairs(self)
end

function _M:begin()
  return 1
end

function _M:finish()
  return #self
end

function _M:indexToIterator(index)
  return index
end

function _M:iteratorToIndex(iter)
  return iter
end

function _M:has_next(iter)
  return iter <= #self
end

function _M:next(iter)
  return iter+1, self[iter]
end

function _M:has_previous(iter)
  return iter > 0
end

function _M:previous(iter)
  return iter-1, self[iter]
end

--- Filters the list.
-- This method filters the list and returns a new array list or pushes items
-- into list passed as parameter.
-- @param filter Function of signature function(item) that indicates if an item
--               should be included.
-- @param result Optional. List into which items should be added, if nil a new
--               list is returned instead.
-- @return Returns resulting list, if either new or passed as parameter.
function _M:filter(filter, result)
  result = result or _M.new()
  for iter, item in self:iterator() do
    if filter(item) then
      result:push_back(item)
    end
  end
  return result
end

--- Searches for an item.
-- @return Returns true if item was found.
function _M:contains(item)
  for iter, _item in self:iterator() do
    if item == _item then return true end
  end
  return false
end

--- Returns item at front.
-- @return Item at front or nil if empty.
function _M:front()
  if #self > 0 then return self[1] end
end

--- Returns item at back.
-- @return Item at back or nil if empty.
function _M:back()
  if #self > 0 then return self[#self] end
end

--- Returns item at iterator.
-- This method is equivalent of self[iter].
-- @param iter Iterator at which item is to be located. This iterator is just
--             an index number to the object itself.
-- @return Item at iterator position.
function _M:at(iter)
  return self[iter]
end

--- Returns item at index position.
function _M:at_index(index)
  return self[index]
end

--- Inserts an item before iterator.
-- @param iter Iterator.
-- @param item Item to insert.
function _M:insert_before(iter, item)
  table.insert(self, iter, item)
end

--- Inserts an item after iterator.
-- @param iter Iterator.
-- @param item Item to insert.
function _M:insert_after(iter, item)
  table.insert(self, iter+1, item)
end

--- Removes and returns item at iterator.
-- @param iter Iterator.
-- @return Removed item.
function _M:remove_at(iter)
  return table.remove(self, iter)
end

--- Removes an item withing the array.
-- Locates an item within the array list, and if found, removes and returns
-- it.
function _M:remove(item)
  for iter, _item in self:iterator() do
    if item == _item then
      self:remove_at(iter)
      return item
    end
  end
end

--- Returns an iterator that points to an item, if found.
-- @return Iterator (in this case a number) at 'item' position, if found.
function _M:find(item)
  for iter, _item in self:iterator() do
    if item == _item then
      return iter
    end
  end
end

--- Returns an iterator that points to an item, if it satisfies a function.
-- Returns an iterator, see @{find}.
-- @param func Locator function.
-- @return Iterator at the first item that satisfies 'func'
function _M:findWithFunction(func)
  for iter, _item in self:iterator() do
    if func(_item) then
      return iter
    end
  end
end

--- Swaps two items positions.
function _M:swap(iter1, iter2)
  local item1 = self[iter1]
  self[iter1] = self[iter2]
  self[iter2] = item1
end

--- Moves item at 'iter2' before item at 'iter1'.
function _M:move_before(iter1, iter2)
  if not iter1 or not iter2 then
    error("Invalid parameter: is null")
  end
  if iter1 == iter2 then
    return
  end
  if (iter2-1) == iter1 then
    return
  end
  if iter2 > #self then
    error("Can't move an item to this position")
  end

  local item1 = table.remove(self, iter1)
  if iter1 < iter2 then
    table.insert(self, iter2-1, item1)
  else
    table.insert(self, iter2, item1)
  end
end

-- Moves item at 'iter2' after item at 'iter1'.
function _M:move_after(iter1, iter2)
  if not iter1 or not iter2 then
    error("Invalid parameter: is null")
  end
  if iter1 == iter2 then
    return
  end
  if (iter2+1) == iter1 then
    return
  end
  if iter2 > #self then
    error("Can't move an item to this position")
  end

  local item1 = table.remove(self, iter1)
  if iter1 < iter2 then
    table.insert(self, iter2, item1)
  else
    table.insert(self, iter2+1, item1)
  end
end

--- Sorts this list.
-- Sorts the list ascending or descending following criteria passed as
-- parameter.
-- @param criteria Sorting criteria, it can be a field name within each item or
--                 a function with signature function(a, b) that returns the
--                 value of (b-a) for an ascending sorting.
-- @param ord Sorting order, must be 'asc' or 'desc'. This parameter is ignored
--            if 'criteria' is a function.
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

  table.sort(self,
    function(a, b)
      return comparator(a, b) > 0
    end
  )
end

--- Returns list's size.
function _M:size()
  return #self
end

--- Clears the list.
function _M:clear()
  for i=1,#self do
    self[i] = nil
  end
end

--- Returns true if list is empty.
function _M:is_empty()
  return #self == 0
end

-- TODO otimizar?
--- Clones this list. 
-- Returns a shallow copy of the list.
-- @return New copy.
function _M:clone()
  local _new = _M.new()
  for iter, item in self:iterator() do
    _new:push_back(item)
  end
  return _new
end

return _M
