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

--- Asset cache module.
--
-- This module acts as an middle man between game entities and assets.
--
-- @module AssetCache

local collection    = require("caress/collection")
local classes       = require("caress/classes")
local error         = require("caress/error")

local _M = {}

local assetsRootPath = "assets/"

_M.__index = _M

local loaders = {}

local game
local graphicsDevice

function _M.setAssetsRootPath(path)
  assetsRootPath = path
end

function loaders.shader(self, shader1, shader2)
  return
    love.graphics.newShader(
        assetsRootPath .. shader1,
        shader2 and (assetsRootPath .. shader2) or nil
    )
end

function loaders.png(self, path)
  return love.graphics.newImage(assetsRootPath .. path)
end

function loaders.animf(self, path)
  local animfSrc = love.filesystem.read(assetsRootPath .. path)
  local chunk, err = loadstring(animfSrc)
  if err then
    error.errhand('failed to load animf file: ' .. err)
  end
  return chunk()
end

function loaders.sprs(self, path)
  local sprsSrc = love.filesystem.read(assetsRootPath .. path)
  local chunk, err = loadstring(sprsSrc)
  if err then
    error.errhand('failed to load sprs file: ' .. err)
  end
  return chunk()
end

function loaders.sndsrc(self, path)
  local sndsrcSrc = love.filesystem.read(assetsRootPath .. path)
  local chunk, err = loadstring(sndsrcSrc)
  if err then
    error.errhand('failed to load sndsrc file: ' .. err)
  end
  local sndsrcConf = chunk()
  if sndsrcConf.mode == "static" then
    sndsrcConf.data = love.sound.newSoundData(assetsRootPath .. sndsrcConf.file)
  end
  return sndsrcConf
end

local processors = {}

function processors.animf(self, aniCfg, parent, layer, coh)
  return parent:create(
    classes.Object.Entity.SpriteAnimation,
    layer, coh, aniCfg
  )
end

function processors.sprs(self, sprsSrc, ...)
  return classes.Object.SpriteSheet(sprsSrc, self.game, ...)
end

function processors.sndsrc(self, sndsrcData, ...)
  if sndsrcData.mode == "static" then
    return love.audio.newSource(sndsrcData.data)
  else
    return love.audio.newSource(assetsRootPath .. sndsrcData.file, "stream")
  end
end

function _M.new()
  local _new = {
    cache = {},
    game = _game,
    loaders = collection.tableCopy(loaders),
    processors = collection.tableCopy(processors)
  }
  
  setmetatable(_new, _M)
  
  return _new
end

--- Loads an asset.
-- Loads an asset given by path, located under the assets root folder,
-- which defaults to "assets/". Path must be complete up to a filename with
-- extension. This extension determines which loader and processor will be
-- used. Extra parameters are passed to both loader and processor.
-- @param path Complete path to file to be loaded
-- @return Loaded asset
function _M:load(path, ...)
  if not path or string.len(path) == 0 then
    error.errhand('invalid asset path')
  end

  local extension = nil

  for s in string.gmatch(path, ".(%w*)$") do
    extension = s
  end
  if not extension then
    error.errhand('path "' .. path .. '" doesn\'t have an extension')
  end

  if not self.cache[path] then
    if not self.loaders[extension] then
      error.errhand('extension "' .. extension ..
        '" doesn\'t have an associated loader')
    end

    self.cache[path] = self.loaders[extension](self, path, ...)
  end

  if self.processors[extension] then
    return self.processors[extension](self, self.cache[path], ...)
  else
    return self.cache[path]
  end
end

return _M
