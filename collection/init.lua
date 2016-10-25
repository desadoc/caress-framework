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

--- Collection module.
-- This module acts as a namespace for utility functions and Collection types.
-- @module collection

local _M = {}

_M.LinkedList = require("caress/collection/LinkedList")
_M.ArrayList = require("caress/collection/ArrayList")

-- default List implementation is ArrayList, because it's usually faster.
_M.List = _M.ArrayList

_M.Enum = require("caress/collection/Enum")

--- Returns a new table with values from table[i1] to table[i2].
-- @param table Original table.
-- @param i1 Starting index.
-- @param i2 Last index, inclusive.
-- @return New table.
function _M.tableSlice(table, i1, i2)
  local res = {}
  local n = #table

  -- default values for range
  i1 = i1 or 1
  i2 = i2 or n

  if i2 < 0 then
    i2 = n + i2 + 1
  elseif i2 > n then
    i2 = n
  end

  if i1 < 1 or i1 > n then
    return {}
  end

  local k = 1
  for i = i1,i2 do
    res[k] = table[i]
    k = k + 1
  end

  return res
end

--- Copies a table.
-- Makes a copy of a table and returns it.
-- @param table Table to copy.
-- @param deepCopy If it should be a deep copy.
function _M.tableCopy(table, deepCopy)
  local copy = {}

  for k, v in pairs(table) do
    if deepCopy and type(v) == 'table' then
      copy[k] = _M.tableCopy(v, true)
    else
      copy[k] = v
    end
  end

  return copy
end

local ls = "\n"

local function _tableToString(table, deep, indenting)
  local str = indenting .. "{" .. ls

  for i, v in ipairs(table) do
    if type(v) == "table" then
      if deep then
        str = str .. indenting .. _tableToString(v, true, indenting .. "  ") .. "," .. ls
      end
    else
      local _v = tostring(v)
      _v = (type(v) == "string") and ("\"" .. _v .. "\"") or _v
      str = str .. indenting .. _v .. "," .. ls
    end
  end

  for k, v in pairs(table) do
    if type(k) ~= "number" then
      if type(v) == "table" then
        if deep then
          str = str .. indenting .. "  [\"" .. tostring(k) .. "\"] = " .. ls .. _tableToString(v, true, indenting .. "  ") .. "," .. ls
        end
      else
        local _v = tostring(v)
        _v = (type(v) == "string") and ("\"" .. _v .. "\"") or _v 
        str = str .. indenting .. "  [\"" .. tostring(k) .. "\"] = " .. _v .. "," .. ls
      end
    end
  end
  return str .. indenting .. "}"
end

--- Returns a string representation of a table.
-- @param table Table to stringnize.
-- @param deep If subtables should be serialized too.
function _M.tableToString(table, deep)
  return _tableToString(table, deep, "")
end

local function _tableEquals(t1, t2, deep)
  for k, v1 in pairs(t1) do
    local v2 = t2[k]
    if not v2 then return false end
    if type(v1) == "table" then
      if deep then
        if type(v2) ~= "table" then return false end
        if not _tableCmp(v1, v2) then return false end
      end
    else
      if v1 ~= v2 then return false end
    end
  end

  return true
end

--- Returns if two tables are equal.
-- This function returns true if table 't2' has all key/values pairs that 't1'
-- has.
-- @param t1 First table.
-- @param t2 Table that may have all key/values pairs present on 't1'.
-- @param deep If subtables should be compared too.
function _M.tableEquals(t1, t2, deep)
  return _tableEquals(t1, t2, deep)
end

--- Iterates pair of key/values and filters them.
-- @param t Iterator.
-- @param f Filter function.
-- @return Returns a lua iterator.
function _M.filteredPairs(t, f)
  return
    function(t, k)
      k, v = next(t, k)
      if not k then return end
      while not f(k, v) do
        k, v = next(t, k)
        if not k then return end
      end
      return k, v
    end, t, nil
end

local _rand = math.random
local function _weightFunc()
  return _rand()
end

--- Returns a random sub list.
-- Returns a random sub list of items from 'list'. Items in the new list
-- are in the same order as in the original list. Optional parameter
-- 'weightFunc' is a function that returns the weight for an item, if missing
-- an uniform random function is used.
-- @param list Original list.
-- @param n Number of items in the new list.
-- @param weightFunc Optional. Returns the weight of an item.
function _M.randomSubList(list, n, weightFunc)
  weightFunc = weightFunc or _weightFunc

  if list:is_empty() or n <=0 then
    return _M.List.new()
  end

  local weightsList = _M.List.new()

  for _, item in list:iterator() do
    weightsList:push_back({weight=weightFunc(item), item=item})
  end

  weightsList:sort("weight")

  n = n < list:size() and n or list:size()

  local result = _M.List.new()

  for _, item in weightsList:iterator() do
    if n <= 0 then break end
    result:push_back(item.item)
    n = n - 1
  end

  return result
end

return _M
