SLASH_CAST1 = "/cast"
SLASH_CASTRANDOM1 = "/castrandom"
SLASH_CASTSEQUENCE1 = "/castsequence"
SLASH_STOPCASTING1 = "/stopcasting"

SLASH_STARTATTACK1 = "/startattack"
SLASH_STOPATTACK1 = "/stopattack"

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

SLASH_PETAUTOCASTOFF1 = "/petautocastoff"
SLASH_PETAUTOCASTOM1 = "/petautocaston"

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
		if target_unit(target, target_type) then
			CastSpellByName(param)
			if old_target ~= nil then
				TargetByName(old_target, true)
			end
		end
	end
end

function SlashCmdList.CAST(msg)
	execute_macro(
		msg,
		function(param, target, target_type)
			if param == nil then
				return
			end
			
			cast_spell(param, target, target_type)
		end 
	)
end

local function get_random_item_from_comma_separated_string(s)
	local tbl = strsplit(param, ",")
	local s = tbl[math.random(1,getn(tbl))]
	
	s = strltrim(s)
	s = strrtrim(s)
	return s
end

function SlashCmdList.CASTRANDOM(msg)
	execute_macro(
		msg,
		function(param, target, target_type)
			if param == nil then
				return
			end
			
			local s = get_random_item_from_comma_separated_string(param)
			if s == "" then
				return
			end
			
			if target == nil or target_type == nil then
				CastSpellByName(s)
			else
				local old_target = UnitName("target")
				if target_unit(target, target_type) then
					CastSpellByName(s)
					if old_target ~= nil then
						TargetByName(old_target, true)
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
	execute_macro(
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
			
			local t = Tokenizer:reset(param)
			if t:get_token_id() ~= Tokenizer.STRING then
				return
			end
			
			local reset = 0
			
			if strlower(t:get_token()) == "reset" then
				t:next_token()
				t:consume_whitespace()
				if t:get_token_id() ~= Tokenizer.EQUAL then
					return
				end
				
				t:next_token()
				t:consume_whitespace()
				
				if t:get_token_id() ~= Tokenizer.NUMERIC then
					return
				end
				
				reset = tonumber(t:get_token())
				
				t:next_token()
				t:consume_whitespace()
				if t:get_token_id() ~= Tokenizer.DELIM and t:get_token() ~= "/" then
					return
				end
			end
			t:next_token()
			t:consume_whitespace()
			
			local tbl = {}
			while not t:eof() and t:get_token_id() == Tokenizer.STRING do
				local s = t:get_token()
				
				while(not t:eof()) do
					t:next_token()
					
					if t:get_token_id() == Tokenizer.WHITESPACE then
						local ls = t:get_token()
						t:next_token()
						if t:get_token_id() == Tokenizer.STRING then
							s = s .. ls .. t:get_token()
						else 
							break
						end
					else
						break
					end
				end
			
				table.insert(tbl, s)
				if t:get_token_id() ~= Tokenizer.COMMA then
					break
				end
				t:next_token()
				t:consume_whitespace()
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
	execute_macro( msg, function() SpellStopCasting() end )
end

function SlashCmdList.CLEARFOCUS(msg)
	execute_macro( msg, function() FOCUS = nil end )
end

function SlashCmdList.FOCUS(msg)
	execute_macro(
		msg, 
		function(param , target, target_type)
			if target ~= nil and target_type ~= Condition.TYPE_FOCUS then
				set_focus(target, target_type)
			elseif param ~= nil then
				if is_unit_id(param) then
					set_focus(param, Condition.TARGET_TYPE_ID)
				else
					set_focus(param, Condition.TARGET_TYPE_NAME)
				end
			elseif UnitName(target) ~= nil then
				set_focus("target", Condition.TARGET_TYPE_ID)
			end
		end
	)	
end

function SlashCmdList.TARGETFOCUS(msg)
	execute_macro(
		msg, 
		function() 
			target_focus()
		end
	)
end

function SlashCmdList.TARGET(msg)
	execute_macro(
		msg,
		function(param, target, target_type)
			if target ~= nil and target_type ~= nil then
				target_unit(target, target_type)
			elseif param ~= nil then
				target_unit(param, TARGET.TYPE_NAME)
			end
		end
	)
end

function SlashCmdList.CLEARTARGET(msg)
	execute_macro( msg, function() ClearTarget() end )
end

local tooltip = CreateFrame("GameTooltip", "tooltip", nil, "GameTooltipTemplate")
tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function use_item(param, target, target_type)
	local tbl = strsplit(param, " ")
	if table.getn(tbl) == 2 and is_numeric(tbl[1]) and is_numeric(tbl[2]) then
		local b = tonumber(tbl[1])
		local s = tonumber(tbl[2])
		
		if (b >= 0 and b <= 4) and (s >= 1 and s <= GetContainerNumSlots(b)) then
			CloseMerchant()
			UseContainerItem(b, s)
			return
		end
	end
	
	if is_numeric(param) then
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
		if target_unit(target, target_type) then
			fnct(param)
			if old_target ~= nil then
				TargetByName(old_target, true)
			end
		end
	end
end

function SlashCmdList.USE(msg)
	execute_macro(
		msg,
		function(param)
			if param == nil then return end
			use_item(param, target, target_type)
		end 
	)
end

function SlashCmdList.EQUIP(msg)
	execute_macro(
		msg,
		function(param, target, target_type)
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
	execute_macro(
		msg,
		function(param, target, target_type)
			if param == nil then
				return
			end
			
			local s = get_random_item_from_comma_separated_string(param)
			if s == "" then
				return
			end
			
			use_item(s, target, target_type)
		end 
	)
end

function SlashCmdList.CANCELAURA(msg)
	execute_macro(
		msg, 
		function(param) 
			if param == nil then
				return
			end
			
			local b = player_get_buff(param)
			if b == 0 then 
				return
			end
			
			CancelPlayerBuff(b - 1)
		end 
	)
end

function SlashCmdList.CANCELFORM(msg)
	execute_macro(
		msg, 
		function(param) 
			if param == nil then
				return
			end
			
			if PLAYER_CLASS ~= "druid" and PLAYER_CLASS ~= "priest" and PLAYER_CLASS ~= "rogue" then
				return
			end
			
			for i=1, GetNumShapeshiftForms() do
				local _, _, is_active = GetShapeshiftFormInfo(i)
				if GetNumShapeshiftForms then
					CastShapeshiftForm(i)
				end
			end
		end 
	)
end

function SlashCmdList.PETAGRESSIVE(msg)
	execute_macro( msg, function() PetAggressiveMode() end )
end

function SlashCmdList.PETDEFENSIVE(msg)
	execute_macro( msg, function() PetDefensiveMode() end )
end

function SlashCmdList.PETPASSIVE(msg)
	execute_macro( msg, function() PetPassiveMode() end )
end

function SlashCmdList.PETATTACK(msg)
	execute_macro( msg, function() PetAttack() end )
end

function SlashCmdList.PETFOLLOW(msg)
	execute_macro( msg, function() PetFollow() end )
end

function SlashCmdList.PETSTAY(msg)
	execute_macro( msg, function() PetWait() end )
end

function SlashCmdList.PETAUTOCASTOFF(msg)
	DEFAULT_CHAT_FRAME:AddMessage( "petautocastoff" )
end

function SlashCmdList.PETAUTOCASTOM(msg)
	DEFAULT_CHAT_FRAME:AddMessage( "petautocaston" )
end

function SlashCmdList.STARTATTACK(msg)
	DEFAULT_CHAT_FRAME:AddMessage( "startattack" )
end

function SlashCmdList.STOPATTACK(msg)
	DEFAULT_CHAT_FRAME:AddMessage( "stopattack" )
end
