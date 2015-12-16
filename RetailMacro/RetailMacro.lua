RetailMacro = CreateFrame("Frame");

local rm = RetailMacro

RetailMacro.ADDON_NAME = "RetailMacro"
RetailMacro.ADDONS = {}
RetailMacro.EVENTS = {
    ["PLAYER_FOCUS_CHANGED"] = {}
}

RetailMacro.MAX_NUM_BUFFS = 16;
RetailMacro.PLAYER_BUFFS = {};
RetailMacro.PLAYER_CLASS = strlower(UnitClass("player"));
RetailMacro.PLAYER_RACE = strlower(UnitRace("player"));
RetailMacro.PLAYER_HAS_STANCE_OR_FORM = (PLAYER_CLASS == "warrior" or PLAYER_CLASS == "druid" or PLAYER_CLASS == "rogue" or PLAYER_CLASS == "priest" or PLAYER_CLASS == "shaman");

RetailMacro.TARGET_TYPE_ID = 0
RetailMacro.TARGET_TYPE_FOCUS = 1
RetailMacro.TARGET_TYPE_MOUSEOVER = 2
RetailMacro.TARGET_TYPE_NAME = 3

RetailMacro.CONDITION_COMBAT = 0
RetailMacro.CONDITION_GROUP = 1
RetailMacro.CONDITION_STEALTH = 2
RetailMacro.CONDITION_MOUNTED = 3
RetailMacro.CONDITION_STANCE = 4

RetailMacro.CONDITION_TARGET_EXISTS = 5
RetailMacro.CONDITION_TARGET_DEAD = 6
RetailMacro.CONDITION_TARGET_HARM = 7
RetailMacro.CONDITION_TARGET_HELP = 8

RetailMacro.CONDITION_MOD_ALT = 9
RetailMacro.CONDITION_MOD_SHIFT = 10
RetailMacro.CONDITION_MOD_CTRL = 11
RetailMacro.CONDITION_MOD_ANY = 12

RetailMacro.CONDITION_PET = 13
RetailMacro.CONDITION_PARTY = 14
RetailMacro.CONDITION_RAID = 15

local unit_ids = {
	"player",
	"target",
	"pet"
}

------------------------
--  HELPER FUNCTIONS  --
------------------------

function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end
print("hey")
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function RetailMacro:err(tokenizer, msg)
    if tokenizer == nil then
        DEFAULT_CHAT_FRAME:AddMessage( "|cFFFF0000Invalid Macro:|r " .. RetailMacro_Tokenizer:get_input())
    else
        DEFAULT_CHAT_FRAME:AddMessage( "|cFFFF0000Invalid Macro:|r " .. tokenizer:get_input())
    end

    DEFAULT_CHAT_FRAME:AddMessage( "|cFFFFFF00" .. msg .. "|r" )
end

------------------------
--  STRING FUNCTIONS  --
------------------------

function RetailMacro:is_numeric(c)
    return tonumber(c) ~= nil
end

function RetailMacro:strsplit(pString, pPattern)
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

function RetailMacro:strltrim(s)
    local c = s
    while (strsub(c, 1, 1) == " ") do
        c = strsub(c, 2)
    end
    return c
end

function RetailMacro:strrtrim(s)
    local c = s
    local l = strlen(s)
    while strsub(c, l) == " " do
        l = l - 1
        c = strsub(c, 1, l)
    end
    return c
end

-----------------------
--  ADDON FUNCTIONS  --
-----------------------

function RetailMacro:RegisterAddon(name, frame)
    self.ADDONS[name] = frame
end

function RetailMacro:RegisterEvent(event_name, func)
    if self.EVENTS[event_name] == nil then
        return false
    end

    table.insert(self.EVENTS[event_name], func)
end

local function fire_event(rm, event_name)
    local event_table = rm.EVENTS[event_name]
    if event_table == nil then
        return false
    end

    for _, func in event_table do
        func()
    end
end

----------------------
--  UNIT FUNCTIONS  --
----------------------

function RetailMacro:is_unit_id(param)
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

function RetailMacro:target_unit(unit_name, unit_type)
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
    if unit_type == self.TARGET_TYPE_ID then
        TargetUnit(unit_name)
        result = UnitIsUnit("player", unit_name) ~= nil
    else
        if unit_type == self.TARGET_TYPE_FOCUS then
            if FOCUS == nil then
                result = false
            else
                TargetByName(FOCUS, true)
                result = UnitName("target") == FOCUS
            end
        elseif unit_type == self.TARGET_TYPE_MOUSEOVER then
            local mouseover = self:get_mouseover()
            if mouseover == nil then
                result = false
            else
                if MOUSEOVER_ISUNITID then
                    TargetUnit(mouseover)
                    result = UnitIsUnit("player", mouseover) ~= nil
                else
                    TargetByName(mouseover, true)
                    result = UnitName("target") == mouseover
                end
            end
        else
            TargetByName(unit_name, true)
            result = UnitName("target") == unit_name
        end
    end
    UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
    return result
end

function RetailMacro:get_name(unit_name, unit_type)
	if unit_type == self.TARGET_TYPE_FOCUS then
		return FOCUS
    elseif unit_type == self.TARGET_TYPE_MOUSEOVER then
        return self:get_mouseover()
	elseif unit_type == self.TARGET_TYPE_NAME then
		return unit_name
	else
		return UnitName(unit_name)
	end
end

----------------------
--  AURA FUNCTIONS  --
----------------------

function RetailMacro:player_has_buff(buff_name)
	for _, v in ipairs(PLAYER_BUFFS) do
		if v == buff_name then
			return true
		end
	end
	return false
end

function RetailMacro:player_get_buff(buff_name)
	for i, v in ipairs(PLAYER_BUFFS) do
		if v == buff_name then
			return i
		end
	end
	return 0
end

--------------
--  EVENTS  --
--------------

local function onEvent()
    print("event")

    local rm = RetailMacro
    if event == "ADDON_LOADED" then
        local addon = rm.ADDONS[arg1]
        if addon ~= nil then
            if addon.onLoad ~= nil then
                addon:onLoad()
            end
        end
    elseif event == "PLAYER_AURAS_CHANGED" then
        rm.PLAYER_BUFFS = {}
        local gt = GameToolTip
        for i = 0, rm.MAX_NUM_BUFFS do
            local b = GetPlayerBuff(i, 'HELPFUL')
            gt:SetOwner(UIParent, 'ANCHOR_NONE')
            gt:ClearLines()
            gt:SetPlayerBuff(b)
            table.insert(rm.PLAYER_BUFFS, GameTooltipTextLeft1:GetText())
        end
    end
end

rm:RegisterEvent("ADDON_LOADED")
rm:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
RetailMacro:SetScript("onEvent", onEvent)