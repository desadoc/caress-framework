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

---
--
-- Module with especial text and string handling functions.
-- 
-- @module text

local _M = {}

local table_insert  = table.insert
local string_len    = string.len
local string_find   = string.find
local string_sub    = string.sub

--- Tokenizes string.
-- Tokenizes a string by a separator pattern and returns it as an array table.
-- @param str String to be tokenized.
-- @param pattern Separator pattern.
-- @param mode Mode of operations, it dictates how 'pattern' will be
--             interpreted. Currently, it only supports 'plain' and 'lua'
--             modes. Plain means pattern is treated as plain text to be
--             located within the string. Lua mode uses lua patterns, see
--             @{string.find}.
-- @param includeSeparators If matched separators should be included
--                          in results.
-- @return An array table containing tokens.
function _M.tokenize(str, pattern, mode, includeSeparators)
  mode = mode or "lua"

  if mode == "lua" or mode == "plain" then

    local tokens = {}

    local plain = mode == plain

    local pos = 1
    local i, j = string_find(str, pattern, pos, plain)
    while i do
      if i > pos then
        table_insert(tokens, string_sub(str, pos, i-1))
      end
      if includeSeparators then
        table_insert(tokens, string_sub(str, i, j))
      end
      pos = j + 1
      i, j = string_find(str, pattern, pos, plain)
    end

    table_insert(tokens, string_sub(str, pos))

    return tokens
  end

  error("Invalid #2 parameter 'mode'", 2)
end

local function _matchesInFull(str, pattern)
  local p, q = string_find(str, pattern)
  return p and ((q-p+1) == #str)
end

local function _breakText_findLine(tokens, sepPattern, limitFunction, start)
  local currLineEnd
  local candidateText = ""

  for pos=start,#tokens do
    local token = tokens[pos]
    candidateText = candidateText .. token

    if not limitFunction(candidateText) then
      break
    end

    local isSep = _matchesInFull(token, sepPattern)

    if not isSep then
      currLineEnd = pos
    end
  end

  return currLineEnd
end

--- Breaks a text into lines given a limit length.
-- A text is considered to be a string containing words and punctuation forming
-- sentences. The string is then splitted into lines while keeping words
-- intact.
-- @param text Text to be broken into lines.
-- @param limitFunction Function with assignature limit(str) that returns true
--                      if str's length is appropriate, false otherwise.
-- @return An array table containing resulting lines.
function _M.breakText(text, limitFunction)
  local sepPattern = "%s+"

  local lines = {}
  local tokens = _M.tokenize(text, sepPattern, "lua", true)

  local start = 1
  local lineEnd

  while start <= #tokens do
    lineEnd = _breakText_findLine(tokens, sepPattern, limitFunction, start)

    if not lineEnd then return lines end

    local line = ""
    for i=start,lineEnd do
      line = line .. tokens[i]
    end

    table_insert(lines, line)

    start = lineEnd + 2
  end

  return lines
end

return _M
