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

local function parse_condition2(rm, tokenizer, mode)
    if tokenizer:get_token_id() ~= tokenizer.STRING then
        if tokenizer:get_token_id() == tokenizer.EOF then
            rm:err(tokenizer, "unexpected end of macro")
        else
            rm:err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
        end
        return false
    end

    local token, value, target
    local s = strlower(tokenizer:get_token())
    tokenizer:next_token()
    tokenizer:consume_whitespace()

    if tokenizer:get_token_id() == tokenizer.EQUAL then
        if s ~=  "target" then
            rm:err(tokenizer, "\"" .. s .. "\" should be be \"target\"")
            return true
        end
        tokenizer:next_token()
        tokenizer:consume_whitespace()

        if tokenizer:get_token_id() == tokenizer.STRING then
            target = strlower(tokenizer:get_token())
            tokenizer:next_token()
        else
            rm:err(tokenizer, "string expected after equal character <" .. s .. "=???>")
            return true
        end

    elseif tokenizer:get_token_id() == tokenizer.COLON then
        tokenizer:next_token()
        tokenizer:consume_whitespace()
        if tokenizer:get_token_id() == tokenizer.STRING then
            token = strlower(s)
            value = strlower(tokenizer:get_token())
            tokenizer:next_token()
        elseif tokenizer:get_token_id() == tokenizer.NUMERIC then
            local c = ""
            while tokenizer:get_token_id() == tokenizer.NUMERIC or (tokenizer:get_token_id() == tokenizer.DELIM and tokenizer:get_token() == "/") do
                c = c .. tokenizer:get_token()
                tokenizer:next_token()
                tokenizer:consume_whitespace()
            end
            token = strlower(s)
            value = strlower(c)
        else
            rm:err(tokenizer, "string expected after colon character <" .. s .. ":???>")
            return true
        end
    else
        if string.sub(s, 1, 1) == "@" then
            target = strlower(string.sub(s, 2))
        else
            token = strlower(s)
        end
    end

    if mode == 0 then
        if token ~= nil then
            token = rm:get_check(token, value)
        end
    end

    if tokenizer:get_token_id() == tokenizer.SQUARE_BRACKET_CLOSE then
        return true, token, value, target
    elseif tokenizer:get_token_id() ~= tokenizer.COMMA then
        rm:err(tokenizer, "unexpected character \"" .. id_to_string(tokenizer:get_token_id()) .. "\"")
        return true
    end
    return true, token, value, target
end

local function parse_condition(rm, tokenizer)
	if tokenizer:get_token_id() ~= tokenizer.STRING then
		if tokenizer:get_token_id() == tokenizer.EOF then
            rm:err(tokenizer, "unexpected end of macro")
		else
            rm:err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
		end
		return false
	end

	local s = strlower(tokenizer:get_token())
	tokenizer:next_token()
	tokenizer:consume_whitespace()

    local condition, target
	if tokenizer:get_token_id() == tokenizer.EQUAL then
		if s ~=  "target" then
            rm:err(tokenizer, "\"" .. s .. "\" should be be \"target\"")
			return true
		end
		tokenizer:next_token()
		tokenizer:consume_whitespace()

		if tokenizer:get_token_id() == tokenizer.STRING then
            target = strlower(tokenizer:get_token())
			tokenizer:next_token()
		else
            rm:err(tokenizer, "string expected after equal character <" .. s .. "=???>")
			return true
		end

	elseif tokenizer:get_token_id() == tokenizer.COLON then
		tokenizer:next_token()
		tokenizer:consume_whitespace()
		if tokenizer:get_token_id() == tokenizer.STRING then
            condition = rm:get_check( strlower(s), strlower(tokenizer:get_token()) )
            tokenizer:next_token()
		elseif tokenizer:get_token_id() == tokenizer.NUMERIC then
			local c = ""
			while tokenizer:get_token_id() == tokenizer.NUMERIC or (tokenizer:get_token_id() == tokenizer.DELIM and tokenizer:get_token() == "/") do
				c = c .. tokenizer:get_token()
				tokenizer:next_token()
				tokenizer:consume_whitespace()
			end
            condition = rm:get_check(strlower(s), strlower(c))
		else
            rm:err(tokenizer, "string expected after colon character <" .. s .. ":???>")
			return true
		end
    else
		if string.sub(s, 1, 1) == "@" then
            target = strlower(string.sub(s, 2))
        else
            condition = rm:get_check(strlower(s))
        end
	end
    if tokenizer:get_token_id() == tokenizer.SQUARE_BRACKET_CLOSE then
        return true, condition, target
    elseif tokenizer:get_token_id() ~= tokenizer.COMMA then
        rm:err(tokenizer, "unexpected character \"" .. id_to_string(tokenizer:get_token_id()) .. "\"")
        return true
    end
    return true, condition, target
end

local function parse_conditional_block(rm, tokenizer)
	if tokenizer:get_token_id() == tokenizer.SQUARE_BRACKET_OPEN then
		tokenizer:next_token()
    else
        return false
	end

    local block = {}

	tokenizer:consume_whitespace()

	if tokenizer:get_token_id() == tokenizer.SQUARE_BRACKET_CLOSE then
		tokenizer:next_token()
--		return true, true
        return true, block
	end

    local conditions = {}

    local target_name, target_type
    while true do
        local parsing_result, condition, target = parse_condition(rm, tokenizer)

        if not parsing_result then
            break
        end

        if condition ~= nil then
            table.insert(conditions, condition)
        end

        if target ~= nil then
            target_name, target_type = rm:evaluate_target(target)
            block.target = target_name
            block.target_type = target_type
        end

        tokenizer:consume_whitespace()
        if tokenizer:get_token_id() == tokenizer.COMMA then
            tokenizer:next_token()
            tokenizer:consume_whitespace()
        elseif tokenizer:get_token_id() == tokenizer.SQUARE_BRACKET_CLOSE then
            tokenizer:next_token()
            tokenizer:consume_whitespace()
            break
        else
            if tokenizer:get_token_id() ~= tokenizer.EOF then
                rm:err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
                return false
            end
            break
        end
    end

    if table.getn(conditions) > 0 then
        block.conditions = conditions
    end

--    local result = true
--    for _, c in (conditions) do
--        if not c(target_name, target_type) then
--            result = false
--            break
--        end
--    end

    return true, block
--    return true, result, target_name, target_type
end

-- returns false if parameter was invalid, true if it was valid and nil if there was no parameter
local function parse_parameter(rm, tokenizer)
	tokenizer:consume_whitespace()
	if tokenizer:get_token_id() ~= tokenizer.STRING and tokenizer:get_token_id() ~= tokenizer.NUMERIC then
		if tokenizer:get_token_id() ~= tokenizer.EOF then
			rm:err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
			return false
		end
		return nil
	end

	local s = tokenizer:get_token()
	tokenizer:next_token()

	while true do
		if tokenizer:get_token_id() == tokenizer.STRING or tokenizer:get_token_id() == tokenizer.NUMERIC then
			s = s .. tokenizer:get_token()
			tokenizer:next_token()
		elseif tokenizer:get_token_id() == tokenizer.WHITESPACE then
			local ls = tokenizer:get_token()
			tokenizer:next_token()
			if tokenizer:get_token_id() == tokenizer.STRING or tokenizer:get_token_id() == tokenizer.NUMERIC then
				s = s .. ls
			else
				break
			end

		elseif tokenizer:get_token_id() == tokenizer.COLON or tokenizer:get_token_id() == tokenizer.EQUAL or tokenizer:get_token_id() == tokenizer.COMMA or
			(
				tokenizer:get_token_id() == tokenizer.DELIM and (
					tokenizer:get_token() == "/"
					or tokenizer:get_token() == "("
					or tokenizer:get_token() == ")"
				)
			) then
			s = s .. tokenizer:get_token()
			tokenizer:next_token()
		elseif tokenizer:eof() or tokenizer:get_token_id() == tokenizer.SEMICOLON then
			break
		else
--			rm:err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
            tokenizer:next_token()
			break
		end
	end

	return true, s
end

local function discard_blocks(tokenizer)
	while true do
		tokenizer:consume_whitespace()
		if tokenizer:get_token_id() ~= tokenizer.SQUARE_BRACKET_OPEN then
			return true
		end

		while tokenizer:get_token_id() ~= tokenizer.SQUARE_BRACKET_CLOSE do
			tokenizer:next_token()

			if tokenizer:get_token_id() == tokenizer.EOF then
				rm:err(tokenizer, "unvalid block")
				return false
			end
		end

		tokenizer:next_token()
		return true
	end
end

local function parse_sequence(rm, tokenizer)
    local sequence = {}

--	local block_result, evaluation_result, target, target_type = parse_conditional_block(rm, tokenizer, parse_only)
    local block_result, block = parse_conditional_block(rm, tokenizer, parse_only)

    if not block_result then
        local param_result, param = parse_parameter(rm, tokenizer);
--        return param_result, true, target, param, target_type
        sequence.param = param
        return param_result, sequence
    end
    sequence.blocks = {}
    table.insert(sequence.blocks, block)
--    if not block_result then
--        local param_result, param = parse_parameter(rm, tokenizer);
--        result[1].evaluation = true
--        if param_result then
--            result[1].param = param
--        end
--        return result
--    end

	tokenizer:consume_whitespace()
--	if tokenizer:get_token_id() ~= tokenizer.SQUARE_BRACKET_OPEN then
----		if not evaluation_result then
----			while tokenizer:get_token_id() ~= tokenizer.SEMICOLON and not tokenizer:eof() do
----				tokenizer:next_token()
----            end
--            print("DEBUG")
--            return false
----			return true, false, nil, nil, nil
----		end
--	end

    while block_result do
        tokenizer:consume_whitespace()
--                block_result, evaluation_result, target, target_type, conditions = parse_conditional_block(rm, tokenizer, parse_only)
        block_result, block = parse_conditional_block(rm, tokenizer, parse_only)

        if block_result then
            table.insert(sequence.blocks, block)
        end
    end

--    if parse_only then
--        if not discard_blocks(tokenizer) then
----            return false, false, nil, nil, nil
--            return false
--        end
--    end

    local param_result, param = parse_parameter(rm, tokenizer);
    if param_result == false then
        return false
    elseif param_result == nil then
--        return false, evaluation_result, target, param, target_type
        return true, sequence
    else
        sequence.param = param
        return param_result, sequence
--        return param_result, evaluation_result, target, param, target_type
    end

--	local param_result, param = parse_parameter(rm, tokenizer);
--	if param_result == false then
--		return false, false, target, param, target_type
--	elseif param_result == nil then
--		return false, evaluation_result, target, param, target_type
--	else
--		return param_result, evaluation_result, target, param, target_type
--	end
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

local function evaluate_block(block)
    if block.conditions == nil then
        return true
    end
    for _, condition in block.conditions do
        if not condition(block.target, block.target_type) then
            return false
        end
    end
    return true
end

function RetailMacro:parse_macro(msg)
    local tokenizer = RetailMacro_Tokenizer:reset(msg)
    tokenizer:consume_whitespace()

    local macro = {}

    while tokenizer:get_token_id() == tokenizer.DELIM and tokenizer:get_token() == "/" do
        tokenizer:consume_whitespace()
        tokenizer:next_token()

        local command = tokenizer:get_token()

        tokenizer:next_token()
        tokenizer:consume_whitespace()


--        print(tokenizer:get_token_id())

        if not tokenizer:eof() then
            table.insert(macro, self:parse_command(tokenizer))
        else
            print(command)
        end
    end
    print_r(macro)
    return macro
end

function RetailMacro:parse_command(tokenizer)
    local sequences = { }

    while(true) do
        local sequence_result, sequence = parse_sequence(self, tokenizer, parse_only)

        if not sequence_result then
            break
        end

        if sequence_result and sequence ~= nil then
            table.insert(sequences, sequence)
        end

        table.insert(sequences, sequence)
        tokenizer:consume_whitespace()
        if tokenizer:get_token_id() == tokenizer.SEMICOLON then
            tokenizer:next_token()
            tokenizer:consume_whitespace()
        elseif tokenizer:eof() then
            break
        elseif tokenizer:get_token_id() == tokenizer.DELIM and tokenizer:get_token() == "/" then
            break
        else
            self:err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
            break
        end
    end
    return sequences
end

function RetailMacro:evaluate_command(msg)
	local tokenizer = RetailMacro_Tokenizer:reset(msg)

    while(true) do
        local sequence_result, sequence = parse_sequence(self, tokenizer, parse_only)

        if not sequence_result then
            break
		end

        if sequence ~= nil then
            local result = true
            if sequence.blocks ~= nil and table.getn(sequence.blocks) > 0 then
                for _, block in sequence.blocks do
                    if evaluate_block(block) then
                        return true, sequence.param, block.target, block.target_type
                    end
                end
                result = false
            end

            if result and sequence.param ~= nil then
                return true, sequence.param
            end
        end


        tokenizer:consume_whitespace()
        if tokenizer:get_token_id() == tokenizer.SEMICOLON then
            tokenizer:next_token()
            tokenizer:consume_whitespace()
        elseif tokenizer:eof() then
            break
        else
            self:err(tokenizer, "unexpected character \"" .. tokenizer:get_token() .. "\"")
            break
        end
    end
    return false
end

function RetailMacro:execute(macro, fnct)
    local evaluation_result, param, target, target_type = self:evaluate_command(macro)
--    debug_macro(macro, evaluation_result, target, param, target_type)

    if not evaluation_result then
        return
    end

    fnct(param, target, target_type)
end

print("parser")