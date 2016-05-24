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

--- BSP tree module.
--
-- BSP stands for binary spatial partition, and this module implements it as
-- a binary tree. Each node represents an rectangular area and each child
-- is created by vertically or horizontally splitting the area covered by
-- it's parent, depending on which side is wider. Items belonging to various
-- nodes are added to each of them.
--
-- Items are stored at leaves only. It receives as parameters the maximum
-- number of items per leaf, maximum depth and a load factor that dictates
-- when two subtrees are to be joined together upon item removal. Items may be
-- of any type or even nil. A tree created only with nils has a normal tree
-- structure.
--
-- @module BSP

local collection    = require("caress/collection")
local Vector        = require("caress/Vector")
local collision     = require("caress/collision")

local AABB_intersection_test = collision.base.AABB_intersection_test
local vector_cpy = Vector.cpy
local linked_list_remove_front = collection.LinkedList.remove_front

local function fast_queue_new()
  return 1, 0, {}
end

local function fast_queue_is_empty(back, front)
  return back > front
end

local function fast_queue_clear()
  return 1, 0
end

local function fast_queue_insert(back, front, data, item)
  data[front+1] = item
  return back, front+1
end

local function fast_queue_remove(back, front, data)
  return back+1, front, data[back]
end

local _M = {}
_M.__index = _M
_M._typename = "BSP"

local function newNode(_aabb, _parent)
  local _new = {}

  _new.parent = _parent
  -- count means the total number of items in the whole subtree's leaves
  _new.count = 0
  -- depth of this node, tree root's is 1
  _new.depth = _parent and _parent.depth + 1 or 1
  _new.aabb = Vector.new()

  if _aabb then
    vector_cpy(_aabb, _new.aabb)
  end

  return _new
end

-- Creates a new leaf.
-- @param _aabb AABB of the leaf, this table is copied.
-- @param _parent parent node.
local function newLeaf(_aabb, _parent)
  local _new = newNode(_aabb, _parent)
  _new.items = collection.List.new()
  return _new
end

--- Creates a new BSP.
-- @param aabb AABB representing space to be partioned by the BSP.
-- @param _maxItemsPerLeaf Upper limit before a leaf is splitten.
-- @param _maxDepth Maximum height for the BSP.
-- @param _joinFactor If both leaves of a node have at most 
--                    (_joinFactor*_maxItemsPerLeaf) items
--                    they are to be joined.
function _M.new(aabb, _maxItemsPerLeaf, _maxDepth, _joinFactor)
  local _new = {
    maxItemsPerLeaf = _maxItemsPerLeaf or 4,
    maxDepth = _maxDepth or 12,
    joinFactor = _joinFactor or 0.5,
    root = newLeaf(aabb, nil),
    -- to keep additional information about items
    item_data = {}
  }

  setmetatable(_new, _M)

  return _new
end

--- Clears the BSP.
function _M:clear()
  self.root = newLeaf(self.root.aabb)
  self.item_data = {}
end

function _M:getRoot()
  return self.root
end

function _M:getMaxItemsPerLeaf()
  return self.maxItemsPerLeaf
end

function _M:getMaxDepth()
  return self.maxDepth
end

function _M:getJoinFactor()
  return self.joinFactor
end

function _M:size()
  return self.root.count
end

local function getMinHeightRec(self, root)
  if root.items then
    return 1
  end

  local height_a = getMinHeightRec(self, root.child_a)
  local height_b = getMinHeightRec(self, root.child_b)

  return height_a < height_b and (height_a + 1) or (height_b + 1)
end

--- Returns height from leaf with the lowest depth to root.
function _M:getMinHeight()
  return getMinHeightRec(self, self.root)
end

local function getMaxHeightRec(self, root)
  if root.items then
    return 1
  end

  local height_a = getMaxHeightRec(self, root.child_a)
  local height_b = getMaxHeightRec(self, root.child_b)

  return height_a > height_b and (height_a + 1) or (height_b + 1)
end

--- Returns height from deepest leaf to root.
function _M:getMaxHeight()
  return getMaxHeightRec(self, self.root)
end

--- Pre order breadth first traversal.
-- This functions does a breadth first traversal in pre order, calling body
-- for each node it visits.
-- @param root Tree root to start from.
-- @param test Function that decides if a subtree needs to be visited.
-- @param body Function called on every node.
-- @param cb Function that decides if a node needs to be passed to body.
function _M.breadthFirstTraversalPreOrder(root, test, body, cb)
  local _root = nil

  local fq_back, fq_front
  local fq_data = {}
  fq_back, fq_front, fq_data = fast_queue_new()

  if test(root) then
    fq_back, fq_front = fast_queue_insert(fq_back, fq_front, fq_data, root)
  end

  while not (fq_back > fq_front) do
    fq_back, fq_front, _root = fast_queue_remove(fq_back, fq_front, fq_data)
    if not cb or cb(_root) then
      body(_root)
    end
    if not _root.items then
      if test(_root.child_a) then
        fq_back, fq_front =
          fast_queue_insert(fq_back, fq_front, fq_data, _root.child_a)
      end
      if test(_root.child_b) then
        fq_back, fq_front =
          fast_queue_insert(fq_back, fq_front, fq_data, _root.child_b)
      end
    end
  end
end

--- Post order breadth first traversal.
-- This functions does a breadth first traversal in post order, calling body
-- for each node it visits.
-- @param root Tree root to start from.
-- @param test Function that decides if a subtree needs to be visited.
-- @param body Function called on every node.
-- @param cb Function that decides if a node needs to be passed to body.
function _M.breadthFirstTraversalPostOrder(root, test, body, cb)
  local _root = nil

  local fq_back, fq_front
  local fq_data = {}
  fq_back, fq_front = fast_queue_clear()

  if test(root) then
    fq_back, fq_front = fast_queue_insert(fq_back, fq_front, fq_data, root)
  end

  while not (fq_back > fq_front) do
    fq_back, fq_front, _root = fast_queue_remove(fq_back, fq_front, fq_data)
    if not _root.items then
      if test(_root.child_a) then
        fq_back, fq_front =
          fast_queue_insert(fq_back, fq_front, fq_data, _root.child_a)
      end
      if test(_root.child_b) then
        fq_back, fq_front =
          fast_queue_insert(fq_back, fq_front, fq_data, _root.child_b)
      end
    end
    if not cb or cb(_root) then
      body(_root)
    end
  end
end

local function getRealSizeImpl(self, _root, cb)
  local count = 0

  _M.breadthFirstTraversalPostOrder(
    _root,
    function(root) return true end,
    function(root)
      if not root.items then return end
      count = count + root.items:size()
    end,
    cb
  )

  return count
end

function _M:getRealSize(cb)
  return getRealSizeImpl(self, self.root, cb)
end

-- Returns two AABB, each one being exactly half of given AABB.
-- AABB is split in its longest side, or horizontally if both are equal.
local function splitAABB(aabb)
  local aabb_1 = nil
  local aabb_2 = nil

  -- split vertically?
  if aabb.z > aabb.w then
    aabb_1 = Vector.new(aabb.x - aabb.z/4, aabb.y, aabb.z/2, aabb.w)
    aabb_2 = Vector.new(aabb.x + aabb.z/4, aabb.y, aabb.z/2, aabb.w)
  else -- split horizontally
    aabb_1 = Vector.new(aabb.x, aabb.y, aabb.z, aabb.w/2)
    aabb_2 = Vector.new(aabb.x, aabb.y + aabb.w/2, aabb.z, aabb.w/2)
  end

  return aabb_1, aabb_2
end

local function createItemData()
  return {
    currentAABB = Vector.new()
  }
end

-- Adds an item to the BSP, creating new leaves if necessary.
local function addRec(self, _root, item, aabb)
  _M.breadthFirstTraversalPostOrder(
    _root,
    -- only go into subtrees that intersect with it
    function(root)
      return AABB_intersection_test(root.aabb, aabb)
    end,
    function(root)
      -- increase count for every subtree root in the path
      root.count = root.count + 1

      -- this isnt a leaf, nothing more to do here
      if not root.items then return end

      if item then
        root.items:push_back(item)
      end

      if root.depth < self.maxDepth and
        root.count > self.maxItemsPerLeaf then
        local aabb_1, aabb_2 = splitAABB(root.aabb)

        local child_a = newLeaf(aabb_1, root)
        local child_b = newLeaf(aabb_2, root)

        for iter, _item in root.items:iterator() do
          addRec(self, child_a, _item, self.item_data[_item].currentAABB)
          addRec(self, child_b, _item, self.item_data[_item].currentAABB)
        end

        root.items = nil
        root.child_a = child_a
        root.child_b = child_b
      end
    end
  )
end

--- Adds an item to the BSP.
-- Adds an item, creating leaves if necessary. Location and size of item
-- are given by aabb. No distinction is made upon item value or attributes,
-- item can be nil, or any value allowed by the language.
-- @param item Item to add.
-- @param aabb AABB of given item.
function _M:add(item, aabb)
  self.item_data[item] = createItemData()
  vector_cpy(aabb, self.item_data[item].currentAABB)
  addRec(self, self.root, item, aabb)
end

local function collectItems(self, aabb, list, _root)
  _M.breadthFirstTraversalPostOrder(
    _root,
    aabb and
    function(root)
      return AABB_intersection_test(aabb, root.aabb)
    end or
    function(root) return true end,
    function(root)
      if not root.items then return end

      for iter, item in root.items:iterator() do
        if not list:contains(item) then
          list:push_back(item)
        end
      end
    end
  )
end

local function checkItemCount(self, root)
  if root.count <= math.modf(self.maxItemsPerLeaf * self.joinFactor) then
    local items = collection.List.new()
    collectItems(self, nil, items, root)

    root.items = items
    root.child_a = nil
    root.child_b = nil
  end
end

local function removeRec(self, _root, item, aabb)
  _M.breadthFirstTraversalPreOrder(
    _root,
    function(root)
      return AABB_intersection_test(root.aabb, aabb)
    end,
    function(root)
      root.count = root.count - 1

      if not root.items then
        checkItemCount(self, root)
        if not root.items then return end
      end

      root.items:remove(item)
    end
  )
end

--- Removes an item.
-- Removes an item from the tree. It keeps track of each item AABB and uses
-- this cached information to locate and removed it. Identical items added,
-- including nils, can't be removed correctly.
function _M:remove(item)
  if not self.item_data[item] then
    return
  end
  removeRec(self, self.root, item, self.item_data[item].currentAABB)
  self.item_data[item] = nil
end

local function collectLeavesRec(self, aabb, list, _root)
  _M.breadthFirstTraversalPostOrder(
    _root,
    aabb and
    function(root)
      return AABB_intersection_test(aabb, root.aabb)
    end or
    function(root) return true end,
    function(root)
      if not root.items then return end
      list:push_back(root)
    end
  )
end

--- Returns a list containing all leaves intersecting the AABB.
function _M:collectLeaves(aabb)
  local list = collection.List.new()
  collectLeavesRec(self, aabb, list, self.root)
  return list
end

--- Adds to list all items that intersect aabb.
function _M:filter(aabb, list)
  list = list or collection.List.new()
  collectItems(self, aabb, list, self.root)
  return list
end

local function getSubTreeRec(aabb, root)
  if root.items then
    return root
  end

  local collChildA = AABB_intersection_test(aabb, root.child_a.aabb)
  local collChildB = AABB_intersection_test(aabb, root.child_b.aabb)

  if collChildA and collChildB then
    local newRoot = newNode(root.aabb)
    newRoot.child_a = getSubTreeRec(aabb, root.child_a)
    newRoot.child_b = getSubTreeRec(aabb, root.child_b)

    return newRoot
  end

  if collChildA then
    return getSubTreeRec(aabb, root.child_a)
  end

  if collChildB then
    return getSubTreeRec(aabb, root.child_b)
  end
end

--- Returns the smallest subtree that contains aabb.
function _M:getSubTree(aabb)
  if not AABB_intersection_test(self.root.aabb, aabb) then
    return _M.new()
  end

  local root = getSubTreeRec(aabb, self.root)
  local _new = _M.new(root.aabb)
  _new.root = root
  return _new
end

local function updateRec(self, item, oldaabb, newaabb)
  local root = nil

  local fq_back, fq_front
  local fq_data = {}

  fq_back, fq_front = fast_queue_clear()
  fq_back, fq_front = fast_queue_insert(fq_back, fq_front, fq_data, self.root)

  while not (fq_back > fq_front) do

    fq_back, fq_front, root = fast_queue_remove(fq_back, fq_front, fq_data)

    local cols_old = AABB_intersection_test(root.aabb, oldaabb)
    local cols_new = AABB_intersection_test(root.aabb, newaabb)

    if cols_old then
      if cols_new then
        -- descend into children
        if not root.items then
          fq_back, fq_front =
            fast_queue_insert(fq_back, fq_front, fq_data, root.child_a)
          fq_back, fq_front =
            fast_queue_insert(fq_back, fq_front, fq_data, root.child_b)
        end
      else
        -- remove item
        removeRec(self, root, item, oldaabb)
      end
    else
      if cols_new then
        -- add item
        addRec(self, root, item, newaabb)
      end
      -- if it doesnt collide before and after
      -- updating its aabb, theres nothing to do
    end
  end
end

--- Updates an item within the tree.
-- Updates an item placement within the tree. Has the same effect as removing
-- then adding an item again with the new AABB, but is more efficient. This
-- method too doesn't work with items that are duplicated or nils. 
function _M:update(item, aabb)
  if not self.item_data[item] then
    return
  end

  if Vector.equals(self.item_data[item].currentAABB, aabb) then
    return
  end

  local oldaabb = Vector.new()
  vector_cpy(self.item_data[item].currentAABB, oldaabb)
  vector_cpy(aabb, self.item_data[item].currentAABB)
  updateRec(self, item, oldaabb, self.item_data[item].currentAABB)
end

return _M
