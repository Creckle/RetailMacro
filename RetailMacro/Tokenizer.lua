RetailMacro_Tokenizer = {
    EOF = 0,
    WHITESPACE = 1,
    SQUARE_BRACKET_OPEN = 2,
    SQUARE_BRACKET_CLOSE = 3,
    COLON = 4,
    SEMICOLON = 5,
    EQUAL = 6,
    STRING = 7,
    COMMA = 8,
    DELIM = 9,
    NUMERIC = 10
}
RetailMacro_Tokenizer.__index = RetailMacro_Tokenizer

RetailMacro_Tokenizer.self = setmetatable({}, RetailMacro_Tokenizer)

function RetailMacro_Tokenizer:reset(s)
	self.pos = 1
	self.input = s
	self:next_token()
	return self
end

function RetailMacro_Tokenizer:eof()
	return self.input == nil or self.pos > string.len(self.input)
end

function RetailMacro_Tokenizer:advance(n)
	self.pos = self.pos + n
end

function RetailMacro_Tokenizer:current_char()
	return string.sub(self.input, self.pos - 1, self.pos - 1)
end

function RetailMacro_Tokenizer:next_char()
	return string.sub(self.input, self.pos, self.pos)
end

function RetailMacro_Tokenizer:consume_char()
	local c = self:next_char()
	self:advance(1)
	return c
end

function RetailMacro_Tokenizer:consume_whitespace()
	if self:get_token_id() == RetailMacro_Tokenizer.WHITESPACE then
		self:next_token()
	end
end

local function valid_string_char(c) 
	return string.find(c, "%w") or c == "@" or c == "!"
end

local function next_token_internal(RetailMacro_Tokenizer)
	if RetailMacro_Tokenizer:eof() then
		return RetailMacro_Tokenizer.EOF, "eof"
	end
	
	local c = RetailMacro_Tokenizer:next_char()
	if c == " " then
		RetailMacro_Tokenizer:advance(1)
		local current_token = " "
		while not RetailMacro_Tokenizer:eof() do
			if RetailMacro_Tokenizer:next_char() == " " then
				RetailMacro_Tokenizer:advance(1)
				current_token = current_token .. " "
			else 
				break
			end
		end
		return RetailMacro_Tokenizer.WHITESPACE, current_token
	elseif c == "[" then
		RetailMacro_Tokenizer:advance(1)
		return RetailMacro_Tokenizer.SQUARE_BRACKET_OPEN, "["
	elseif c == "]" then
		RetailMacro_Tokenizer:advance(1)
		return RetailMacro_Tokenizer.SQUARE_BRACKET_CLOSE, "]"
	elseif c == ":" then
		RetailMacro_Tokenizer:advance(1)
		return RetailMacro_Tokenizer.COLON, ":"
	elseif c == "=" then
		RetailMacro_Tokenizer:advance(1)
		return RetailMacro_Tokenizer.EQUAL, "="
	elseif c == ";" then
		RetailMacro_Tokenizer:advance(1)
		return RetailMacro_Tokenizer.SEMICOLON, ";"
	elseif c == "," then
		RetailMacro_Tokenizer:advance(1)
		return RetailMacro_Tokenizer.COMMA, ","
	elseif RetailMacro:is_numeric(c) then
		RetailMacro_Tokenizer:advance(1)

		local number = c
		local n = RetailMacro_Tokenizer:next_char()
		
		while RetailMacro:is_numeric(n) and not RetailMacro_Tokenizer:eof() do
			number = number .. n
			RetailMacro_Tokenizer:advance(1)
			n = RetailMacro_Tokenizer:next_char()
		end
		return RetailMacro_Tokenizer.NUMERIC, number
	elseif valid_string_char(c) then
		RetailMacro_Tokenizer:advance(1)
		local current_token = c
		
		local n = RetailMacro_Tokenizer:next_char()
		while valid_string_char(n) and not RetailMacro_Tokenizer:eof() do
			current_token = current_token .. n
			RetailMacro_Tokenizer:advance(1)
			n = RetailMacro_Tokenizer:next_char()
		end
		
		return RetailMacro_Tokenizer.STRING, current_token
	else
		RetailMacro_Tokenizer:advance(1)
		return RetailMacro_Tokenizer.DELIM, c
	end
end

function RetailMacro_Tokenizer:next_token()
	self.token_id, self.token = next_token_internal(self)
end

function RetailMacro_Tokenizer:get_token_id()
	return self.token_id
end

function RetailMacro_Tokenizer:get_token()
	return self.token
end

function RetailMacro_Tokenizer:get_input()
	return self.input
end

print("tokenizer")