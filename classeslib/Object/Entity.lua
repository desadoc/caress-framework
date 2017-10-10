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

--- An entity.
--
-- An entity is a dynamic object, which can send and receive events, have
-- childs and multiple caress coroutines in execution, besides being drawable
-- and updateable. Most game objects will inherit from this class.
--
-- @classmod Object.Entity

local collection      = require("collection")
local classes         = require("classes")
local error           = require("error")

local _class = {}

local children = collection.List.new()
local listeners = collection.List.new()
local coroutines = collection.List.new()

local paused = true
local hidden = true

local listening = collection.List.new()

--- Initializes an entity. Entities may have a parent.
function _class:init(parent)
  self.parent = parent
end

function _class:getChildrenByClass(class)
  return self:getChildren():filter(
    function(child)
      return child.class == class
    end
  )
end

function _class:addChild(child)
  children:push_back(child)
  return child
end

function _class:removeChild(child)
  return children:remove(child)
end

function _class:getChildren()
  return children
end

function _class:getCoroutines()
  return coroutines
end

function _class:getListening()
  return listening
end

function _class:updateCoroutines(dt)
  local updatedCoroutines = collection.List.new()
  local coroutinesToRemove = collection.List.new()
  local coroutinesToKeep = collection.List.new()

  -- fix coroutine list
  local cos = coroutines:clone()

  for iter, co in cos:iterator() do
    if co:getStatus() == "dead" then
      coroutinesToRemove:push_back(co)
    elseif not co:isPaused() then
      co:update(dt)
      updatedCoroutines:push_back(co)
    end
  end

  for iter, co in updatedCoroutines:iterator() do
    if co:getStatus() == "suspended" then
      co:checkResultAndResume()
    end
  end

  for iter, co in coroutines:iterator() do
    if not coroutinesToRemove:contains(co) then
      coroutinesToKeep:push_back(co)
    end
  end

  coroutines = coroutinesToKeep
end

function _class:updateChild(child, dt)
  local update = child.update
  if update and not child:isPaused() then
    update(dt)
  end
end

function _class:updateChildList(entityList, dt)
  for _, child in entityList:iterator() do
    self:updateChild(child, dt)
  end
end

function _class:updateChilds(dt)
  self:updateChildList(self:getChildren(), dt)
end

--- Updates entity logic.
-- This method updates coroutines and child entities. When overriding it's
-- important to call self.super:update(dt) within your update method. Also,
-- it's the parent responsibility to check if childs are paused or hidden
-- before updating or drawing them, or rather force their update/draw
-- regardless of their state.
function _class:update(dt)
  self:updateCoroutines(dt)
  self:updateChilds(dt)
end

function _class:pause()
  if paused then
    return
  end

  paused = true

  for iter, co in coroutines:iterator() do
    co:pause()
  end

  for _, child in self:getChildren():iterator() do
    if not child:isPaused() then
      -- we flag that this child should be resumed when this entity resumes.
      child._softPause = true
      child:pause()
    end
  end

  for _, l in listening:iterator() do
    l.source:removeEventListener(l.name, l._listener)
  end
end

function _class:resume()
  if not paused then
    return
  end

  paused = false

  for iter, co in coroutines:iterator() do
    co:unpause()
  end

  for _, child in self:getChildren():iterator() do
    if child._softPause then
      child._softPause = false
      child:resume()
    end
  end

  for _, l in listening:iterator() do
    l.source:addEventListener(l.name, l._listener)
  end
end

function _class:isPaused()
  return paused
end

function _class:drawChild(child)
  local draw = child.draw
  if draw and not child:isHidden() then
    draw()
  end
end

function _class:drawChildList(childList)
  for _, child in childList:iterator() do
    self:drawChild(child)
  end
end

function _class:drawChilds()
  self:drawChildList(self:getChildren())
end

--- Renders the entity.
-- This basic implementation only draws child entities. It is responsibility of
-- parent entity to check if childs are hidden before rendering them, similarly
-- to what happens at @{update}.
function _class:draw()
  self:drawChilds()
end

function _class:hide()
  hidden = true
end

function _class:show()
  hidden = false
end

function _class:isHidden()
  return hidden
end

function _class:enable()
  self:resume()
  self:show()
end

function _class:disable()
  self:pause()
  self:hide()
end

--- Creates and adds an entity as a child.
function _class:create(class, ...)
  local obj = class(self, ...)
  self:addChild(obj)
  return obj
end

--- Destroys an entity previously created with @{create}.
function _class:destroy(obj)
  self:removeChild(obj)
  obj:disable()
  obj:clearListeners()
end


function _class:createCo(func)
  local coh = classes.Object.Cohandler(
    function(...)
      func(self, ...)
    end
  )

  coroutines:push_back(coh)

  return coh
end

--- Runs a coroutine.
-- Runs a coroutine with signature _class:myCo(coh, ...), extra parameters are
-- passed to it.
function _class:createAndRunCo(func, ...)
  local coh = self:createCo(func)

  coh:run(...)

  return coh
end

--- Starts the entity.
-- Starts the entity by using caress to call it's main function. First
-- parameter main receives (besides a self reference) is a cohandler, a handler
-- to the caress coroutine. Additional parameters are passed after it.
function _class:start(parentCoh, parentCondition)
  self:enable()
  if self.main then
    local coh = self:createCo(self.main)
    if parentCoh then
      parentCoh:runAndWait(parentCondition, coh)
    else
      coh:run()
    end
  end
  return self
end

--- Adds a listener.
-- Listeners added through this function receive a self reference as the first
-- parameter and are managed by the entity, being paused and resumed together
-- with the entity.
function _class:on(source, name, listener)
  local _listener = function(...)
    local opt = listener(self, ...)
    if opt ~= "keep" and opt ~= "remove" then
      error.errhand("Invalid listener return '" .. (opt and opt or "nil") .. "'")
    end
    if opt == "remove" then
      self:off(source, name, listener)
    end
    return "keep"
  end

  listening:push_back({
    source = source,
    name = name,
    listener = listener,
    _listener = _listener,
  })

  if not self:isPaused() then
    source:addEventListener(name, _listener)
  end
end

--- Removes a listener added with @{on}.
function _class:off(source, name, listener)
  local _listening = collection.List.new()

  for _, l in listening:iterator() do
    if l.source ~= source or
      l.name ~= name or
      (listener and
      l.listener ~= listener) then
      _listening:push_back(l)
    else
      if not self:isPaused() then
        source:removeEventListener(name, l._listener)
      end
    end
  end

  listening = _listening
end

function _class:clearListeners()
  listening = collection.List.new()
  self.super:clearListeners()
end

return _class
