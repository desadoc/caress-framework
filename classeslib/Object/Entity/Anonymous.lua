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

--
--- Anonymous class.
--
-- This class allows the declaration of inline anonymous classs.
--
-- @classmod Object.Entity.Anonymous

local _class = {}

function _class:init(parent, layer, coh, _methods)
  
  for k, v in pairs(_methods) do
    if k ~= "init" then
      self[k] = v
    end
  end
  
  if _methods.init then
    _methods.init(self, parent, layer, coh)
  else
    self.super:init(parent, layer, coh)
  end
end

return _class
