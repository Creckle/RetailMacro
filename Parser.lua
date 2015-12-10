local idstrings = {
	"EOF",
	"WHITESPACE",
	"SQUARE_BRACKET_OPEN",
	"SQUARE_BRACKET_CLOSE",
	"COLON",
	"SEMICOLON",
	"EQUAL",
	"STRING",
	"COMMA",
	"DELIM"
}

local function id_to_string(id)
	return idstrings[id + 1]
end

local function parse_condition(tokenizer, condition)
	if tokenizer:get_token_id() ~= Tokenizer.STRING then
		condition:set_invalid()
		if tokenizer:get_token_id() == Tokenizer.EOF then
			err(tokenizer, "unexpected end of macro")
		else
			err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
		end
		return false
	end

	local s = strlower(tokenizer:get_token())
	tokenizer:next_token()
	tokenizer:consume_whitespace()
	if tokenizer:get_token_id() == Tokenizer.EQUAL then
		if s ~=  "target" then 
			condition:set_invalid()
			err(tokenizer, "\"" .. s .. "\" should be be \"target\"")
			return true
		end
		tokenizer:next_token()
		tokenizer:consume_whitespace()
		
		if tokenizer:get_token_id() == Tokenizer.STRING then
			if not condition:set_target( strlower(tokenizer:get_token()) ) then
				condition:set_invalid()
			end
			tokenizer:next_token()
			return true
		else
			condition:set_invalid()
			err(tokenizer, "string expected after equal character <" .. s .. "=???>")
			return true
		end
		
	elseif tokenizer:get_token_id() == Tokenizer.COLON then
		tokenizer:next_token()
		tokenizer:consume_whitespace()
		if tokenizer:get_token_id() == Tokenizer.STRING then
			if not condition:evaluate_condition( strlower(s), strlower(tokenizer:get_token()) ) then
				condition:set_invalid()
			end
			tokenizer:next_token()
			return true
		elseif tokenizer:get_token_id() == Tokenizer.NUMERIC then
			local c = ""
			while tokenizer:get_token_id() == Tokenizer.NUMERIC or (tokenizer:get_token_id() == Tokenizer.DELIM and tokenizer:get_token() == "/") do
				c = c .. tokenizer:get_token()
				tokenizer:next_token()
				tokenizer:consume_whitespace()
			end

			if not condition:evaluate_condition( strlower(s), strlower(c) ) then
				condition:set_invalid()
			end
			return true
		else
			condition:set_invalid()
			err(tokenizer, "string expected after colon character <" .. s .. ":???>")
			return true
		end
	else
		if string.sub(s, 1, 1) == "@" then
			if not condition:set_target( strlower(string.sub(s, 2)) ) then
				condition:set_invalid()
			end
		elseif s == "exists" then
			if not condition:check_exists(true) then condition:set_invalid() end
		elseif s == "noexists" then
			if not condition:check_exists(false) then condition:set_invalid() end
		elseif s == "dead" then 
			if not condition:check_dead(true) then condition:set_invalid() end
		elseif s == "nodead" then
			if not condition:check_dead(false) then condition:set_invalid() end
		elseif s == "harm" then
			if not condition:check_harm(true) then condition:set_invalid() end
		elseif s == "noharm" then
			if not condition:check_harm(false) then condition:set_invalid() end
		elseif s == "help" then
			if not condition:check_help(true) then condition:set_invalid() end
		elseif s == "nohelp" then
			if not condition:check_help(false) then condition:set_invalid() end
		else
			if not condition:evaluate_condition(strlower(s), nil) then
				condition:set_invalid()
			end
		end
		
		if tokenizer:get_token_id() == Tokenizer.SQUARE_BRACKET_CLOSE then
			return true
		elseif tokenizer:get_token_id() ~= Tokenizer.COMMA then
			condition:set_invalid()
			err(tokenizer, "unexpected character \"" .. id_to_string(tokenizer:get_token_id()) .. "\"")
			return true
		end
	end
	
	return true
end

local function parse_conditional_block(tokenizer)
	if tokenizer:get_token_id() == Tokenizer.SQUARE_BRACKET_OPEN then
		tokenizer:next_token()
	else
		return false, true
	end
	
	tokenizer:consume_whitespace()
	
	if tokenizer:get_token_id() == Tokenizer.SQUARE_BRACKET_CLOSE then
		tokenizer:next_token()
		return true, true
	end
	
	local condition = Condition:reset(tokenizer)
	while parse_condition(tokenizer, condition) do
		if condition:is_set_invalid() then
			-- discard the rest of the block
			while not tokenizer:eof() do
				if tokenizer:get_token_id() == Tokenizer.SQUARE_BRACKET_CLOSE then
					tokenizer:next_token()
					tokenizer:consume_whitespace()
					return true, false, nil, nil
				else
					tokenizer:next_token()
				end
			end
			break;
		end
	

		tokenizer:consume_whitespace()
		if tokenizer:get_token_id() == Tokenizer.COMMA then
			tokenizer:next_token()
			tokenizer:consume_whitespace()
		elseif tokenizer:get_token_id() == Tokenizer.SQUARE_BRACKET_CLOSE then
			tokenizer:next_token()
			tokenizer:consume_whitespace()
			break
		else
			if tokenizer:get_token_id() ~= Tokenizer.EOF then 
				err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
				return false
			end
			break
		end
	end
	
	if condition:is_set_invalid() then
		return true, false, condition:get_target(), target_type
	end
	
	local condition_result, target_type = condition:evaluate()
	return true, condition_result, condition:get_target(), target_type
end

-- returns false if parameter was invalid, true if it was valid and nil if there was no parameter
local function parse_parameter(tokenizer)
	tokenizer:consume_whitespace()
	if tokenizer:get_token_id() ~= Tokenizer.STRING and tokenizer:get_token_id() ~= Tokenizer.NUMERIC then
		if tokenizer:get_token_id() ~= Tokenizer.EOF then
			err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
			return false
		end
		return nil
	end
	
	local s = tokenizer:get_token()
	local ls = ""
	tokenizer:next_token()
	
	while true do
		if tokenizer:get_token_id() == Tokenizer.STRING or tokenizer:get_token_id() == Tokenizer.NUMERIC then
			s = s .. tokenizer:get_token()
			tokenizer:next_token()
		elseif tokenizer:get_token_id() == Tokenizer.WHITESPACE then
			ls = tokenizer:get_token()
			tokenizer:next_token()
			if tokenizer:get_token_id() == Tokenizer.STRING or tokenizer:get_token_id() == Tokenizer.NUMERIC then
				s = s .. ls
			else 
				break
			end
			
		elseif tokenizer:get_token_id() == Tokenizer.COLON or tokenizer:get_token_id() == Tokenizer.EQUAL or tokenizer:get_token_id() == Tokenizer.COMMA or
			(
				tokenizer:get_token_id() == Tokenizer.DELIM and (
					tokenizer:get_token() == "/"
					or tokenizer:get_token() == "("
					or tokenizer:get_token() == ")"
				) 
			) then
			s = s .. tokenizer:get_token()
			tokenizer:next_token()
		elseif tokenizer:eof() or tokenizer:get_token_id() == Tokenizer.SEMICOLON then
			break
		else
			err(tokenizer, "unexpected character2 \"" .. tokenizer:get_token() .. "\"")
			break
		end
	end
	
	return true, s
end

local function discard_blocks(tokenizer)
	while true do
		tokenizer:consume_whitespace()
		if tokenizer:get_token_id() ~= Tokenizer.SQUARE_BRACKET_OPEN then
			return true
		end
		
		while tokenizer:get_token_id() ~= Tokenizer.SQUARE_BRACKET_CLOSE do
			tokenizer:next_token()
			
			if tokenizer:get_token_id() == Tokenizer.EOF then
				err(tokenizer, "unvalid block")
				return false
			end
		end
		
		tokenizer:next_token()
		return true
	end
end

local function parse_sequence(tokenizer)
	local block_result, evaluation_result, target, target_type = parse_conditional_block(tokenizer)

	if not block_result then
		local param_result, param = parse_parameter(tokenizer);
		return param_result, true, target, param, target_type
	end
	
	tokenizer:consume_whitespace()
	if tokenizer:get_token_id() ~= Tokenizer.SQUARE_BRACKET_OPEN then
		if not evaluation_result then
			while tokenizer:get_token_id() ~= Tokenizer.SEMICOLON and not tokenizer:eof() do 
				tokenizer:next_token()
			end
	
			return true, false, nil, nil, nil
		end
	end
	
	if not evaluation_result then
		while block_result do
			tokenizer:consume_whitespace()
			if evaluation_result then 
				break
			else
				block_result, evaluation_result, target, target_type = parse_conditional_block(tokenizer)
			end
		end
	end
	
	if not discard_blocks(tokenizer) then 
		return false, false, nil, nil, nil
	end
	
	local param_result, param = parse_parameter(tokenizer);
	if param_result == false then
		return false, false, target, param, target_type
	elseif param_result == nil then
		return false, evaluation_result, target, param, target_type
	else
		return param_result, evaluation_result, target, param, target_type
	end
end

local targettypes = {
	"ID",
	"FOCUS",
	"NAME"
}

local function type_to_string(id)
	if id == nil then
		return "NONE"
	end
	return targettypes[id + 1]
end

local function debug_macro(macro, eval_result, target, param, target_type)
	local s_eval_result, s_param, s_target, s_target_type
	
	if eval_result then
		s_eval_result = "SUCCESS"
	else
		s_eval_result = "FAILED"
	end
	
	if param == nil then
		s_param = "NIL"
	else
		s_param = param
	end

	if target == nil then
		s_target  = "NIL"
	else
		s_target = target
	end
	
	if target_type == nil then
		s_target_type = "NONE"
	else
		s_target_type = type_to_string(target_type)
	end
	
	DEFAULT_CHAT_FRAME:AddMessage(macro .. " Evaluation: " .. s_eval_result .. " Target: " .. s_target .. " Target Type: " .. s_target_type .. " Param: " .. s_param)
end

function parse_macro(msg) 
	local tokenizer = Tokenizer:reset(msg)
	local sequence_result, evaluation_result, target, param, target_type = parse_sequence(tokenizer)
	
	while sequence_result and not evaluation_result do
		tokenizer:consume_whitespace()
		if tokenizer:get_token_id() == Tokenizer.SEMICOLON then
			tokenizer:next_token()
			tokenizer:consume_whitespace()
			sequence_result, evaluation_result, target, param, target_type = parse_sequence(tokenizer)
		elseif tokenizer:eof() then
			break
		else
			err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
			break
		end
	end

	-- debug_macro(msg, evaluation_result, target, param, target_type)
	return evaluation_result, target, param, target_type
end