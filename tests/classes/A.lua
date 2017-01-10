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
local _class = {}

_class.static = function()
  return {
    FOO = 21,
    BAR = 84
  }
end

function _class:init()
  self.bar = 42
end

function _class:foo1()
  self.bar = self.bar + 1
end

function _class:foo2()
  self.bar = self.bar - 1
end

function _class:foo3()
  self.bar = 21
end

return _class

