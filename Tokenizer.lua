Tokenizer = { }
Tokenizer.__index = Tokenizer

Tokenizer.self = setmetatable({}, Tokenizer)

Tokenizer.EOF = 0
Tokenizer.WHITESPACE = 1
Tokenizer.SQUARE_BRACKET_OPEN = 2
Tokenizer.SQUARE_BRACKET_CLOSE = 3
Tokenizer.COLON = 4
Tokenizer.SEMICOLON = 5
Tokenizer.EQUAL = 6
Tokenizer.STRING = 7
Tokenizer.COMMA = 8
Tokenizer.DELIM = 9
Tokenizer.NUMERIC = 10

function Tokenizer:reset(s)
	self.pos = 1
	self.input = s
	self:next_token()
	return self
end

function Tokenizer:eof()
	return self.input == nil or self.pos > string.len(self.input)
end

function Tokenizer:advance(n)
	self.pos = self.pos + n
end

function Tokenizer:current_char()
	return string.sub(self.input, self.pos - 1, self.pos - 1)
end

function Tokenizer:next_char()
	return string.sub(self.input, self.pos, self.pos)
end

function Tokenizer:consume_char()
	local c = self:next_char()
	self:advance(1)
	return c
end

function Tokenizer:consume_whitespace()
	if self:get_token_id() == Tokenizer.WHITESPACE then 
		self:next_token()
	end
end

local function valid_string_char(c) 
	return string.find(c, "%w") or c == "@" or c == "!"
end

local function next_token_internal(tokenizer)
	if tokenizer:eof() then
		return Tokenizer.EOF, "eof"
	end
	
	local c = tokenizer:next_char()
	if c == " " then
		tokenizer:advance(1)
		local current_token = " "
		while not tokenizer:eof() do
			if tokenizer:next_char() == " " then
				tokenizer:advance(1)
				current_token = current_token .. " "
			else 
				break
			end
		end
		return Tokenizer.WHITESPACE, current_token
	elseif c == "[" then
		tokenizer:advance(1)
		return Tokenizer.SQUARE_BRACKET_OPEN, "["
	elseif c == "]" then
		tokenizer:advance(1)
		return Tokenizer.SQUARE_BRACKET_CLOSE, "]"
	elseif c == ":" then
		tokenizer:advance(1)
		return Tokenizer.COLON, ":"
	elseif c == "=" then
		tokenizer:advance(1)
		return Tokenizer.EQUAL, "="
	elseif c == ";" then
		tokenizer:advance(1)
		return Tokenizer.SEMICOLON, ";"
	elseif c == "," then
		tokenizer:advance(1)
		return Tokenizer.COMMA, ","
	elseif is_numeric(c) then
		tokenizer:advance(1)

		local number = c
		local n = tokenizer:next_char()
		
		while is_numeric(n) and not tokenizer:eof() do
			number = number .. n
			tokenizer:advance(1)
			n = tokenizer:next_char()
		end
		return Tokenizer.NUMERIC, number
	elseif valid_string_char(c) then
		tokenizer:advance(1)
		local current_token = c
		
		local n = tokenizer:next_char()
		while valid_string_char(n) and not tokenizer:eof() do
			current_token = current_token .. n
			tokenizer:advance(1)
			n = tokenizer:next_char()
		end
		
		return Tokenizer.STRING, current_token
	else
		tokenizer:advance(1)
		return Tokenizer.DELIM, c
	end
end

function Tokenizer:next_token()
	self.token_id, self.token = next_token_internal(self)
end

function Tokenizer:get_token_id()
	return self.token_id
end

function Tokenizer:get_token()
	return self.token
end

function Tokenizer:get_input()
	return self.input
end