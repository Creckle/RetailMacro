SLASH_CAST1 = "/cast"
SLASH_CASTRANDOM1 = "/castrandom"
SLASH_CASTSEQUENCE1 = "/castsequence"
SLASH_STOPCASTING1 = "/stopcasting"

SLASH_CLEARFOCUS1 = "/clearfocus"
SLASH_FOCUS1 = "/focus"
SLASH_TARGETFOCUS1 = "/targetfocus"

SLASH_TARGET1 = "/target"
SLASH_CLEARTARGET1 = "/cleartarget"
SLASH_ASSIST1 = "/assist"

SLASH_USE1 = "/use"
SLASH_USERANDOM1 = "/userandom"
SLASH_EQUIP1 = "/equip"
-- SLASH_EQUIPSLOT1 = "/equipslot"

SLASH_CANCELAURA1 = "/cancelaura"
SLASH_CANCELFORM1 = "/cancelform"

SLASH_PETAGRESSIVE1 = "/petagressive"
SLASH_PETDEFENSIVE1 = "/petdefensive"
SLASH_PETPASSIVE1 = "/petpassive"

SLASH_PETATTACK1 = "/petattack"
SLASH_PETFOLLOW1 = "/petfollow"
SLASH_PETSTAY1 = "/petstay"

--SLASH_STARTATTACK1 = "/startattack"
--SLASH_STOPATTACK1 = "/stopattack"

--SLASH_PETAUTOCASTOFF1 = "/petautocastoff"
--SLASH_PETAUTOCASTOM1 = "/petautocaston"

--/changeactionbar
--/swapactionbar

--/click
--/dismount

--/stopmacro

--/targetenemy
--/targetenemyplayer
--/targetfriend
--/targetlasttarget
--/targetparty
--/targetraid

local function cast_spell(param, target, target_type)
	if target == nil or target_type == nil then
		CastSpellByName(param)
	else
		local old_target = UnitName("target")
		if RetailMacro:target_unit(target, target_type) then
			CastSpellByName(param)
			if old_target ~= nil then
				TargetByName(old_target, true)
            else
                ClearTarget()
			end
		end
	end
end

function SlashCmdList.CAST(msg)
	RetailMacro:execute(
		msg,
		function(param, target, target_type)
			if param == nil then
				return
			end
			
			cast_spell(param, target, target_type)
		end 
	)
end

local function get_random_item_from_comma_separated_string(rm, param)
	local tbl = rm:strsplit(param, ",")
	local s = tbl[math.random(1,getn(tbl))]
	
	s = rm:strltrim(s)
	s = rm:strrtrim(s)
	return s
end

function SlashCmdList.CASTRANDOM(msg)
    local rm = RetailMacro
	rm:execute(
		msg,
		function(param, target, target_type)
			if param == nil then
				return
			end
			
			local s = get_random_item_from_comma_separated_string(rm, param)
			if s == "" then
				return
			end
			
			if target == nil or target_type == nil then
				CastSpellByName(s)
			else
				local old_target = UnitName("target")
				if rm:target_unit(target, target_type) then
					CastSpellByName(s)
					if old_target ~= nil then
						TargetByName(old_target, true)
                    else
                        ClearTarget()
					end
				end
			end
		end 
	)
end

local cast_sequences = { }

-- local gcd_free_spells = { }

-- local function get_spell_cd(spell)
	-- return 1.5
-- end

function SlashCmdList.CASTSEQUENCE(msg)
	RetailMacro:execute(
		msg,
		function(param, target, target_type)
			if param == nil then
				return
			end
			
			local sequence = cast_sequences[param]
			if sequence ~= nil then
				-- if (GetTime() - sequence.last_spell_casted) < sequence.last_spell_cd then
					-- return
				-- end
				
				local tbl = sequence.spells
				local num_spells = table.getn(tbl)
				
				if sequence.index == num_spells then
					-- sequence finished, restart sequence
					sequence.started = GetTime()
					cast_spell(tbl[1], target, target_type)
					sequence.last_spell_casted = GetTime()
					-- sequence.last_spell_cd = get_spell_cd(spell)
					sequence.index = 1
					return
				end
				
				local reset = sequence.reset
				local started = sequence.started
				
				sequence.index = sequence.index + 1
				if GetTime() - started > reset then
					-- sequence timed out, restart sequence
					sequence.started = GetTime()
					sequence.index = 1
				end
				--cast next spell in sequence
				
				local spell = tbl[sequence.index]
				sequence.last_spell_casted = GetTime()
				-- sequence.last_spell_cd = get_spell_cd(spell)
				cast_spell(spell, target, target_type)
				return
			end
			
			local tokenizer = RetailMacro_Tokenizer:reset(param)
			if tokenizer:get_token_id() ~= tokenizer.STRING then
				return
			end
			
			local reset = 0
			
			if strlower(t:get_token()) == "reset" then
                tokenizer:next_token()
                tokenizer:consume_whitespace()
				if t:get_token_id() ~= tokenizer.EQUAL then
					return
				end

                tokenizer:next_token()
                tokenizer:consume_whitespace()
				
				if tokenizer:get_token_id() ~= tokenizer.NUMERIC then
					return
				end
				
				reset = tonumber(t:get_token())

                tokenizer:next_token()
                tokenizer:consume_whitespace()
				if tokenizer:get_token_id() ~= tokenizer.DELIM and tokenizer:get_token() ~= "/" then
					return
				end
			end
            tokenizer:next_token()
            tokenizer:consume_whitespace()
			
			local tbl = {}
			while not tokenizer:eof() and tokenizer:get_token_id() == tokenizer.STRING do
				local s = tokenizer:get_token()
				
				while(not tokenizer:eof()) do
                    tokenizer:next_token()
					
					if tokenizer:get_token_id() == tokenizer.WHITESPACE then
						local ls = tokenizer:get_token()
                        tokenizer:next_token()
						if tokenizer:get_token_id() == tokenizer.STRING then
							s = s .. ls .. tokenizer:get_token()
						else 
							break
						end
					else
						break
					end
				end
			
				table.insert(tbl, s)
				if tokenizer:get_token_id() ~= tokenizer.COMMA then
					break
				end
                tokenizer:next_token()
                tokenizer:consume_whitespace()
			end
			
			if table.getn(tbl) == 1 then
				cast_spell(tbl[1], target, target_type)
				return 
			end

			sequence = {}
			sequence.spells = tbl
			sequence.index = 1
			sequence.reset = reset
			sequence.started = GetTime()
			sequence.last_spell_casted = GetTime()
			
			local spell = tbl[1]
			-- sequence.last_spell_cd = get_spell_cd(spell)
			cast_sequences[param] = sequence
			cast_spell(spell, target, target_type)
		end 
	)
end

function SlashCmdList.STOPCASTING(msg)
	RetailMacro:execute( msg, function() SpellStopCasting() end )
end

function SlashCmdList.CLEARFOCUS(msg)
	RetailMacro:execute( msg, function() RetailMacro:clear_focus() end )
end

function SlashCmdList.FOCUS(msg)
    local rm = RetailMacro

    RetailMacro:execute(
		msg, 
		function(param, target, target_type)
			print("hello")
			if target ~= nil and target_type ~= rm.TYPE_FOCUS then
                rm:set_focus(target, target_type)
			elseif param ~= nil then
				if rm:is_unit_id(param) then
                    rm:set_focus(param, rm.TARGET_TYPE_ID)
				else
                    rm:set_focus(param, rm.TARGET_TYPE_NAME)
				end
			elseif UnitName(target) ~= nil then
                rm:set_focus("target", rm.TARGET_TYPE_ID)
            end
		end
	)	
end

function SlashCmdList.TARGETFOCUS(msg)
	RetailMacro:execute(
		msg, 
		function()
			target_focustarget_focus()
		end
	)
end

function SlashCmdList.TARGET(msg)
    local rm = RetailMacro
    rm:execute(
		msg,
		function(param, target, target_type)
			if target ~= nil and target_type ~= nil then
                rm:target_unit(target, target_type)
			elseif param ~= nil then
                rm:target_unit(param, rm.TARGET_TYPE_NAME)
			end
		end
	)
end

function SlashCmdList.CLEARTARGET(msg)
	RetailMacro:execute( msg, function() ClearTarget() end )
end

local tooltip = CreateFrame("GameTooltip", "tooltip", nil, "GameTooltipTemplate")
tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function use_item(rm, param, target, target_type)
	local tbl = rm:strsplit(param, " ")
	if table.getn(tbl) == 2 and rm:is_numeric(tbl[1]) and rm:is_numeric(tbl[2]) then
		local b = tonumber(tbl[1])
		local s = tonumber(tbl[2])
		
		if (b >= 0 and b <= 4) and (s >= 1 and s <= GetContainerNumSlots(b)) then
			CloseMerchant()
			UseContainerItem(b, s)
			return
		end
	end
	
	if rm:is_numeric(param) then
		local p = tonumber(param)
		if p >= 0 and p <= 19 then
			UseInventoryItem(p)
		end
		return
	end
	
	local fnct = function(param)
		for i = 0, 19 do
			tooltip:ClearLines()
			tooltip:SetInventoryItem("player",i)
			
			if tooltipTextLeft1:GetText() == param then
				UseInventoryItem(i)
				return
			end
		end
		
		for i = 0, 4 do
			for b = 1, GetContainerNumSlots(i) do
				tooltip:ClearLines()
				tooltip:SetBagItem(i, b)
				local item_name = tooltipTextLeft1:GetText()
				
				if item_name == param then
					CloseMerchant()
					UseContainerItem(i, b)
					return
				end
			end
		end
	end
	
	if target == nil or target_type == nil then
		fnct(param)
	else
		local old_target = UnitName("target")
		if rm:target_unit(target, target_type) then
			fnct(param)
			if old_target ~= nil then
				TargetByName(old_target, true)
            else
                ClearTarget()
			end
		end
	end
end

function SlashCmdList.USE(msg)
    local rm = RetailMacro
    rm:execute(
		msg,
		function(param)
			if param == nil then return end
			use_item(rm, param, target, target_type)
		end 
	)
end

function SlashCmdList.EQUIP(msg)
	RetailMacro:execute(
		msg,
		function(param)
			if param == nil then
				return
			end
			
			for i = 0, 4 do
				for b = 1, GetContainerNumSlots(i) do
					tooltip:ClearLines()
					tooltip:SetBagItem(i, b)
					local item_name = tooltipTextLeft1:GetText()
					
					if item_name == param then
						CloseMerchant()
						UseContainerItem(i, b)
						return
					end
				end
			end
		end 
	)
end

function SlashCmdList.USERANDOM(msg)
    local rm = RetailMacro
    rm:execute(
		msg,
		function(param, target, target_type)
			if param == nil then
				return
			end
			
			local s = get_random_item_from_comma_separated_string(rm, param)
			if s == "" then
				return
			end
			
			use_item(rm, s, target, target_type)
		end 
	)
end

function SlashCmdList.CANCELAURA(msg)
	RetailMacro:execute(
		msg, 
		function(param) 
			if param == nil then
				return
			end
			
			local b = RetailMacro:player_get_buff(param)
			if b == 0 then 
				return
			end
			
			CancelPlayerBuff(b - 1)
		end 
	)
end

function SlashCmdList.CANCELFORM(msg)
	RetailMacro:execute(
		msg, 
		function(param) 
			if param == nil then
				return
			end

			local player_class = RetailMacro.PLAYER_CLASS

			if player_class ~= "druid" and player_class ~= "priest" and player_class ~= "rogue" then
				return
			end
			
			for i=1, GetNumShapeshiftForms() do
				local _, _, is_active = GetShapeshiftFormInfo(i)
				if is_active then
					CastShapeshiftForm(i)
				end
			end
		end 
	)
end

function SlashCmdList.PETAGRESSIVE(msg)
	RetailMacro:execute( msg, function() PetAggressiveMode() end )
end

function SlashCmdList.PETDEFENSIVE(msg)
	RetailMacro:execute( msg, function() PetDefensiveMode() end )
end

function SlashCmdList.PETPASSIVE(msg)
	RetailMacro:execute( msg, function() PetPassiveMode() end )
end

function SlashCmdList.PETATTACK(msg)
	RetailMacro:execute( msg, function() PetAttack() end )
end

function SlashCmdList.PETFOLLOW(msg)
	RetailMacro:execute( msg, function() PetFollow() end )
end

function SlashCmdList.PETSTAY(msg)
	RetailMacro:execute( msg, function() PetWait() end )
end

--function SlashCmdList.PETAUTOCASTOFF(msg)
--	DEFAULT_CHAT_FRAME:AddMessage( "petautocastoff" )
--end
--
--function SlashCmdList.PETAUTOCASTOM(msg)
--	DEFAULT_CHAT_FRAME:AddMessage( "petautocaston" )
--end
--
--function SlashCmdList.STARTATTACK(msg)
--	DEFAULT_CHAT_FRAME:AddMessage( "startattack" )
--end
--
--function SlashCmdList.STOPATTACK(msg)
--	DEFAULT_CHAT_FRAME:AddMessage( "stopattack" )
--end
print("commands")