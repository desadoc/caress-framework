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
  "./?.lua;./?/init.lua;" .. package.path

local classes = require("classes")

classes.register(classes, "A", "tests/classes/A")
classes.register(classes.A, "B", "tests/classes/A/B")
classes.register(classes.A, "C", "tests/classes/A/C")
classes.register(classes.A.C, "E", "tests/classes/A/C/E")

if classes.finish then
  classes.finish()
end

local table_insert = table.insert

local b = classes.A.B:new()
local c = classes.A.C:new()
local e = classes.A.C.E:new()

local n = 300*1000*1000

local c_super = c.super
for i=1,n do
  c_super:foo4()
end
