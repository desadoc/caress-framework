
local _class = {}

local game

local text

function _class:init(parent, layer, coh, _text)
  self.super:init(parent, layer, coh)

  game = _game

  text = _text
end

function _class:draw()
  local gd = game.graphicsDevice
  local yOfs = math.floor((self:getSize().y - game.graphicsDevice:getFont():getHeight())/2)
  
  local actualText
  if type(text) == "string" then
    actualText = text
  end
  if type(text) == "function" then
    actualText = text()
  end
  
  gd:rawPrintf(actualText, self:getPosition().x, self:getPosition().y + yOfs, 10000, "left")
end

return _class
