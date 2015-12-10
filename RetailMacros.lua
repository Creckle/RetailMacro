FOCUS = nil
MAX_NUM_BUFFS = 16
PLAYER_BUFFS = {}

PLAYER_CLASS = strlower(UnitClass("player"))
PLAYER_RACE = strlower(UnitRace("player"))

PLAYER_HAS_STANCE_OR_FORM = (PLAYER_CLASS == "warrior" or PLAYER_CLASS == "druid" or PLAYER_CLASS == "rogue" or PLAYER_CLASS == "priest" or PLAYER_CLASS == "shaman")

Target = { }
Target.TYPE_ID = 0
Target.TYPE_FOCUS = 1
Target.TYPE_NAME = 2

local unit_ids = {
	"player",
	"target",
	"pet"
}

function is_unit_id(param) 
	local lowerparam = strlower(param)
	
	for _, s in pairs(unit_ids) do
		if lowerparam == s then
			return true
		end
		
		local p = s
		local l = strlen(lowerparam)
		
		while strlen(p) < l do 
			p = p .. "target"
			if lowerparam == p then
				return true
			end
		end
	end
	
	if strsub(lowerparam, 0, 5) == "party" then
		local n = strsub(lowerparam, 6, 6)
		if is_numeric(n) then
			local b = tonumber(n)
			if b < 1 or b > 4 then
				return false
			end
			
			local p = "party" .. n
			local l = strlen(lowerparam)
			
			if l == strlen(p) then 
				return true
			end
			
			while strlen(p) < l do
				p = p .. "target"
				if lowerparam == p then
					return true
				end
			end
		end
	elseif strsub(lowerparam, 0, 4) == "raid" then
		local n = strsub(lowerparam, 5, 5)
		if is_numeric(n) then
			local t = strsub(lowerparam, 5, 6)
			if is_numeric(t) then
				n = t
				
			end
			
			local b = tonumber(n)
			if b < 1 or b > 40 then
				return false
			end
			
			local p = "raid" .. n
			local l = strlen(lowerparam)
			
			if l == strlen(p) then 
				return true
			end
			
			while strlen(p) < l do
				p = p .. "target"
				if lowerparam == p then
					return true
				end
			end
		end
	end
	return false
end

function target_unit(unit_name, unit_type)
	if unit_name == nil or unit_type == nil then
		return false
	end
	
	if UnitName("target") == unit_name then
		return true
	end
	
	if unit_name == "target" then
		return UnitName("target") ~= nil
	end

	local result
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	if unit_type == Target.TYPE_ID then
		TargetUnit(unit_name)
		result = UnitIsUnit("player", unit_name) ~= nil
	else
		if unit_type == Target.TYPE_FOCUS then
			if FOCUS == nil then
				result = false
			else
				TargetByName(FOCUS, true)
				result = UnitName("target") == FOCUS
			end
		else
			TargetByName(unit_name, true)
			result = UnitName("target") == unit_name
		end	
	end
	UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
	return result
end

function target_focus()
	if FOCUS == nil then
		return false
	end

	if UnitName("playertarget") == FOCUS then
		return true
	end 
	
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	TargetByName(FOCUS, true)
	UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")

	return UnitName("target") == FOCUS
end

function set_focus(unit_name, unit_type)
	if unit_type == Condition.TARGET_TYPE_FOCUS then
		return false
	end
	
	local name
	if unit_type == Condition.TARGET_TYPE_NAME then
		name = unit_name
	else
		name = UnitName(unit_name)
	end

	if name ~= FOCUS and name ~= nil then
		DEFAULT_CHAT_FRAME:AddMessage( "new focus: " .. name )
		FOCUS = name
	end
end

function get_name(unit_name, unit_type)
	if unit_type == Target.TYPE_FOCUS then
		return FOCUS
	elseif unit_type == Target.TYPE_NAME then
		return unit_name
	else
		return UnitName(unit_name)
	end
end

function err(tokenizer, msg)
	DEFAULT_CHAT_FRAME:AddMessage( "|cFFFF0000Invalid Macro:|r " .. tokenizer:get_input())
	DEFAULT_CHAT_FRAME:AddMessage( "|cFFFFFF00" .. msg .. "|r" )
end

function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function is_numeric(c)
	return tonumber(c) ~= nil
end

function strsplit(pString, pPattern)
	local tbl = {}
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = strfind(pString, fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(tbl,cap)
		end
		last_end = e+1
		s, e, cap = strfind(pString, fpat, last_end)
	end
	if last_end <= strlen(pString) then
		cap = strsub(pString, last_end)
		table.insert(tbl, cap)
	end
	return tbl
end

function strltrim(s)
	local c = s
	while (strsub(c, 1, 1) == " ") do
		c = strsub(c, 2)
	end
	return c
end

function strrtrim(s)
	local c = s
	local l = strlen(s)
	while strsub(c, l) == " " do
		l = l - 1
		c = strsub(c, 1, l)	
	end
	return c
end

function player_has_buff(buff_name)
	for i, v in ipairs(PLAYER_BUFFS) do
		if v == buff_name then
			return true
		end
	end
	return false
end

function player_get_buff(buff_name)
	for i, v in ipairs(PLAYER_BUFFS) do
		if v == buff_name then
			return i
		end
	end
	return 0
end

local function onEvent(arg1, arg2)
	if event == "PLAYER_AURAS_CHANGED" then
		PLAYER_BUFFS = { }
		for i = 0, MAX_NUM_BUFFS do
			local b = GetPlayerBuff(i, 'HELPFUL')
			GameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
            GameTooltip:ClearLines()
            GameTooltip:SetPlayerBuff(b)
			table.insert(PLAYER_BUFFS, GameTooltipTextLeft1:GetText())
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_AURAS_CHANGED")
frame:SetScript("OnEvent", onEvent)