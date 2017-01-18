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

package.path =
  "./?.lua;./?/init.lua;" .. package.path

local classes = require("caress/classes")

classes.registerClass(classes, "A", "caress/tests/classes/A")
classes.registerClass(classes.A, "B", "caress/tests/classes/A/B")
classes.registerClass(classes.A, "C", "caress/tests/classes/A/C")
classes.registerClass(classes.A.C, "E", "caress/tests/classes/A/C/E")

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
