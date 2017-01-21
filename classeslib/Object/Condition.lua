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

--- Coroutine wait condition
--
-- This class represents a condition upon which a coroutine can wait upon. It
-- shouldn't be used directly, see @{Object.Cohandler} for methods that create
-- conditions.
--
-- @classmod Object.Condition

local _class = {}

local paused = true

function _class:init(coh)
  self.coh = coh
end

function _class:pause()
  paused = true
end

function _class:resume()
  paused = false
end

function _class:isPaused()
  return paused
end

function _class:wait()
  self.coh:setCondition(self)
  return self.coh:wait()
end

return _class
