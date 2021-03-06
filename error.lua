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

--- Error reporting module.
--
-- Functions to log and report unexpected events.
--
-- @module error

local _M = {}

_M.errhand = function(err) io.stderr:write(err) end
_M.throw = error

function _M.setErrHandFunction(errhand)
  _M.errhand = errhand
end

function _M.setThrowFunction(throw)
  _M.throw = throw
end

return _M
