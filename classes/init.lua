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

--- Class system module.
--
-- This module acts as a class path system for classes implemented in lua.
-- It needs to be loaded and initialized with folders containing class source
-- files.
--
-- It supports inheritance, method/field shadowing and static fields.
--
-- Some methods/fields have special meaning when implementing a class:
--
-- _class:init()
--
-- This optional method is also used for initialization after the object is
-- fully constructed, it's optional.
--
-- _class.initClass()
--
-- Like init(), but for initializing static members.
--
-- _class:main(cohandler)
--
-- Caress function that should be run at some moment after the object is
-- initialized. It can be handily run with self:start().
--
-- self.class
--
-- Class object. Has some useful methods like an isA operator and
-- getCompleteName().
--
-- @module classes

return require("caress/classes/load")
