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

local _M = {}

local function printMessage(message, stackLevel)
  local x = debug.getinfo(stackLevel, 'nlS')
  print(x.source .. ", line " .. x.currentline ..
    ": " .. (message or "assert failed"))
end

function _M.assert(value, message)
  if not value then
    printMessage(x.source .. ", line " .. x.currentline ..
      ": " .. (message or "assert failed"), 3)
  end
end

function _M.assertEquals(value1, value2, message)
  if value1 ~= value2 then
    printMessage((message and (message .. ": ") or "") .. tostring(value1) ..
      " and " .. tostring(value2) .. " are different", 3)
  end
end

function _M.assertTrue(value, message)
  _M.assertEquals(value, true, message)
end

function _M.assertFalse(value, message)
  _M.assertEquals(value, false, message)
end

return _M
