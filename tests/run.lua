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

package.path =
  "./extra/luaspec/src/?.lua;./?.lua;./?/init.lua;" ..
  package.path

dofile("tests/tests/example.lua")
dofile("tests/tests/lib/Vector.lua")
dofile("tests/tests/lib/text.lua")
dofile("tests/tests/lib/collection/List.lua")
dofile("tests/tests/lib/BSP.lua")
dofile("tests/tests/lib/classes.lua")
dofile("tests/tests/classes/Object.lua")
dofile("tests/tests/classes/Entity.lua")

spec:report(true)
