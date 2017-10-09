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

local _M = {}

--- Enumerations module
--- Creates a new enum with the given names of constants
-- @param names a table with the names of the constants
-- @module lib.Enum
-- @usage
--
-- WeekDays = enum {
--      "Monday",
--      "Tuesday",
--      "Wednesday",
--      "Thursday",
--      "Friday",
--      "Saturday",
--      "Sunday"
--      }
function _M.new( names )
  local __enumID = 0
  local _new = {}
  for _, k in ipairs(names) do
    t[k] = __enumID
    __enumID = __enumID + 1
  end
  return _new
end

return _M
