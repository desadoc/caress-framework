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

--- Utility lib for saving data.
-- 
-- This module contains functions for saving of acyclic tables into
-- files within game App Data directory.
--
-- @module save

local collection = require("caress/collection")
local lfs = love.filesystem

local _M = {}

local ls = "\n"

function _M.save(filename, data)
  lfs.write(filename, "return " .. collection.tableToString(data, true) .. ls)
end

function _M.exists(filename)
  return lfs.exists(filename)
end

function _M.load(filename)
  local chunk = lfs.load(filename)
  return chunk()
end

function _M.remove(filename)
  lfs.remove(filename)
end

return _M
