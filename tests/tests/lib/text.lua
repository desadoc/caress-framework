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

require "luaspec"

describe["text"] = function()
  before = function()
    text = require "caress/text"
  end

  it["should tokenize strings with plain delimiters"] = function()

    local str
    local tokens
    
    str = "The quick brown fox jumps over the lazy dog"
    tokens = text.tokenize(str, " ")

    expect(tokens[1]).should_be("The")
    expect(tokens[2]).should_be("quick")
    expect(tokens[3]).should_be("brown")
    expect(tokens[4]).should_be("fox")
    expect(tokens[5]).should_be("jumps")
    expect(tokens[6]).should_be("over")
    expect(tokens[7]).should_be("the")
    expect(tokens[8]).should_be("lazy")
    expect(tokens[9]).should_be("dog")

    str = "The quick brown fox jumps over the lazy dog"
    tokens = text.tokenize(str, "  ")

    expect(tokens[1]).should_be("The quick brown fox jumps over the lazy dog")
   
    str = " The quick brown fox jumps over the lazy dog "
    tokens = text.tokenize(str, " ")

    expect(tokens[1]).should_be("The")
    expect(tokens[2]).should_be("quick")
    expect(tokens[3]).should_be("brown")
    expect(tokens[4]).should_be("fox")
    expect(tokens[5]).should_be("jumps")
    expect(tokens[6]).should_be("over")
    expect(tokens[7]).should_be("the")
    expect(tokens[8]).should_be("lazy")
    expect(tokens[9]).should_be("dog")

    str = " The  quick   brown    fox     jumps      over       the        lazy         dog          "
    tokens = text.tokenize(str, " ")

    expect(tokens[1]).should_be("The")
    expect(tokens[2]).should_be("quick")
    expect(tokens[3]).should_be("brown")
    expect(tokens[4]).should_be("fox")
    expect(tokens[5]).should_be("jumps")
    expect(tokens[6]).should_be("over")
    expect(tokens[7]).should_be("the")
    expect(tokens[8]).should_be("lazy")
    expect(tokens[9]).should_be("dog")

  end

  it["should tokenize strings with lua patterns"] = function()

    local str
    local tokens

    str = "The quick brown fox jumps over the lazy dog"
    tokens = text.tokenize(str, "%s+", "lua")

    expect(tokens[1]).should_be("The")
    expect(tokens[2]).should_be("quick")
    expect(tokens[3]).should_be("brown")
    expect(tokens[4]).should_be("fox")
    expect(tokens[5]).should_be("jumps")
    expect(tokens[6]).should_be("over")
    expect(tokens[7]).should_be("the")
    expect(tokens[8]).should_be("lazy")
    expect(tokens[9]).should_be("dog")

  end

  it["should optionally return separators"] = function()

    local str
    local tokens

    str = "The quick brown"
    tokens = text.tokenize(str, " ", "plain", true)

    expect(tokens[1]).should_be("The")
    expect(tokens[2]).should_be(" ")
    expect(tokens[3]).should_be("quick")
    expect(tokens[4]).should_be(" ")
    expect(tokens[5]).should_be("brown")

    str = " The  quick   brown"
    tokens = text.tokenize(str, " ", "plain", true)

    expect(tokens[1]).should_be(" ")
    expect(tokens[2]).should_be("The")
    expect(tokens[3]).should_be(" ")
    expect(tokens[4]).should_be(" ")
    expect(tokens[5]).should_be("quick")
    expect(tokens[6]).should_be(" ")
    expect(tokens[7]).should_be(" ")
    expect(tokens[8]).should_be(" ")
    expect(tokens[9]).should_be("brown")

    str = " The  quick   brown"
    tokens = text.tokenize(str, "  ", "plain", true)

    expect(tokens[1]).should_be(" The")
    expect(tokens[2]).should_be("  ")
    expect(tokens[3]).should_be("quick")
    expect(tokens[4]).should_be("  ")
    expect(tokens[5]).should_be(" brown")

    str = " The  quick   brown    "
    tokens = text.tokenize(str, "%s+", "lua", true)

    expect(tokens[1]).should_be(" ")
    expect(tokens[2]).should_be("The")
    expect(tokens[3]).should_be("  ")
    expect(tokens[4]).should_be("quick")
    expect(tokens[5]).should_be("   ")
    expect(tokens[6]).should_be("brown")
    expect(tokens[7]).should_be("    ")
  end

  it["should break texts in lines"] = function()

    local str = "Abc, de fghi j klm nopqrst. A bcde fg hijklmn opq rstuv xyzw."
    local lines

    local limitFunction = function(limit)
      return function(str)
        return string.len(str) <= limit
      end
    end

    lines = text.breakText(str, limitFunction(8))

    expect(lines[1]).should_be("Abc, de")
    expect(lines[2]).should_be("fghi j")
    expect(lines[3]).should_be("klm")
    expect(lines[4]).should_be("nopqrst.")
    expect(lines[5]).should_be("A bcde")
    expect(lines[6]).should_be("fg")
    expect(lines[7]).should_be("hijklmn")
    expect(lines[8]).should_be("opq")
    expect(lines[9]).should_be("rstuv")
    expect(lines[10]).should_be("xyzw.")
    
    lines = text.breakText(str, limitFunction(9))
    
    expect(lines[1]).should_be("Abc, de")
    expect(lines[2]).should_be("fghi j")
    expect(lines[3]).should_be("klm")
    expect(lines[4]).should_be("nopqrst.")
    expect(lines[5]).should_be("A bcde fg")
    expect(lines[6]).should_be("hijklmn")
    expect(lines[7]).should_be("opq rstuv")
    expect(lines[8]).should_be("xyzw.")
    
    lines = text.breakText(str, limitFunction(10))
    
    expect(lines[1]).should_be("Abc, de")
    expect(lines[2]).should_be("fghi j klm")
    expect(lines[3]).should_be("nopqrst. A")
    expect(lines[4]).should_be("bcde fg")
    expect(lines[5]).should_be("hijklmn")
    expect(lines[6]).should_be("opq rstuv")
    expect(lines[7]).should_be("xyzw.")
    
    lines = text.breakText(str, limitFunction(11))
    
    expect(lines[1]).should_be("Abc, de")
    expect(lines[2]).should_be("fghi j klm")
    expect(lines[3]).should_be("nopqrst. A")
    expect(lines[4]).should_be("bcde fg")
    expect(lines[5]).should_be("hijklmn opq")
    expect(lines[6]).should_be("rstuv xyzw.")
    
    lines = text.breakText(str, limitFunction(12))
    
    expect(lines[1]).should_be("Abc, de fghi")
    expect(lines[2]).should_be("j klm")
    expect(lines[3]).should_be("nopqrst. A")
    expect(lines[4]).should_be("bcde fg")
    expect(lines[5]).should_be("hijklmn opq")
    expect(lines[6]).should_be("rstuv xyzw.")
    
    lines = text.breakText(str, limitFunction(15))
    
    expect(lines[1]).should_be("Abc, de fghi j")
    expect(lines[2]).should_be("klm nopqrst. A")
    expect(lines[3]).should_be("bcde fg hijklmn")
    expect(lines[4]).should_be("opq rstuv xyzw.")
  end

end

