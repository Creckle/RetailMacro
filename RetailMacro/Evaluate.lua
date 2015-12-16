
-- return true if target was found, false if not, and function result as 2nd return parameter
local function temporary_target_by_name(name, fnct)
	if UnitName("target") == name then
		return true, fnct()
	end
	
	local old_target = UnitName("target")
	TargetByName(name)
	if UnitName("target") == name then
		return true, fnct()
	end
	TargetByName(old_target)
	return false
end

local function evaluate_unit_exists(target, target_type)
    local rm = RetailMacro
    if target_type == rm.TARGET_TYPE_ID then
        return UnitName(target) ~= nil
    elseif target_type == rm.TARGET_TYPE_FOCUS then
        return rm.get_focus() ~= nil
    else
        return false
    end




	-- local fnct = (
		-- function(c, unit)
			-- if c and UnitExists(unit) == 1 then
				-- return false
			-- elseif not c and UnitExists(unit) == nil then
				-- return false
			-- end
			-- return true
		-- end
	-- )

	-- if condition:get_target_type() ~= RetailMacro.TARGET_TYPE_ID then
		-- local unit_name
		-- if condition:get_target_type() == RetailMacro.TARGET_TYPE_FOCUS then
			-- unit_name = FOCUS
		-- else
			-- unit_name = condition:get_target()
		-- end
		-- local could_target, fnct_result = temporary_target_by_name(unit_name, fnct(bool, "target"))
		-- if not could_target then
			-- return false
		-- end
		-- return fnct_result
	-- else
		-- return fnct(bool, condition:get_target())
	-- end

--	if condition:get_target_type() ~= RetailMacro.TARGET_TYPE_ID then -- tmp fix
--		return false
--	end
--
--	if bool and UnitExists(condition:get_target()) == 1 then
--		return false
--	elseif not bool and UnitExists(condition:get_target()) == nil then
--		return false
--	end
	
	
	-- local unit
	-- print(condition:get_target_type())
	-- if condition:get_target_type() == RetailMacro.TARGET_TYPE_FOCUS then 
		-- if FOCUS == nil then
			-- return false
		-- end
		-- unit = FOCUS 
	-- else
		-- unit = condition:get_target()
	-- end
	
	-- if condition:get_target_type() ~= RetailMacro.TARGET_TYPE_ID then
		
	-- end
	
	
	-- print(unit)
	
	
end

local function evaluate_unit_harm(target, target_type)
--	if condition:get_target_type() ~= RetailMacro.TARGET_TYPE_ID then -- tmp fix
--		return false
--	end
--
--	if c and UnitIsEnemy("player", condition:get_target()) == 1 then
--		return false
--	elseif not c and UnitIsEnemy("player", condition:get_target()) == nil then
--		return false
--	end
	return true
end

local function evaluate_unit_help(target, target_type)
--	if condition:get_target_type() ~= RetailMacro.TARGET_TYPE_ID then -- tmp fix
--		return false
--	end
--
--	if c and UnitIsFriend("player", condition:get_target()) == 1 then
--		return false
--	elseif not c and UnitIsFriend("player", condition:get_target()) == nil then
--		return false
--	end
	return true
end

local function evaluate_unit_dead(target, target_type)
--	if condition:get_target_type() ~= RetailMacro.TARGET_TYPE_ID then -- tmp fix
--		return false
--	end
--
--	if c and UnitIsDeadOrGhost(condition:get_target()) == 1 then
--		return false
--	elseif not c and UnitIsDeadOrGhost(condition:get_target()) == nil then
--		return false
--	end
	return true
end

local function player_has_stealth()
	if PLAYER_RACE == "nightelf" and RetailMacro:player_has_buff("Shadowmeld") then
		return true
	elseif PLAYER_CLASS == "rogue" and RetailMacro:player_has_buff("Stealth") then
		return true
	elseif PLAYER_CLASS == "druid" and RetailMacro:player_has_buff("Prowl") then
		return true
	elseif RetailMacro:player_has_buff("Lesser Invisibility") or RetailMacro:player_has_buff("Phase Shift") then
		return true
	else
		return false
	end
end

local mount_names = {
	alliance = {
		"Ram", 
		"Mechanostrider",
		"Stallion",
		"Horse",
		"Mare",
		"Pinto",
		"Steed",
		"Palomino",
		"Frostsaber",
		"Mistsaber",
		"Stormsaber"
	},
	horde = {
		"Wolf",
		"Kodo",
		"Raptor",
		"Horse",
		"Warhorse"
	},
	neutral = {
		"Battlestrider",
		"Charger",
		"Howler",
		"Tiger",  
		"Bear",
		"Deathcharger",
		"Panther"
	}
}

local function find_mount_buff_in_table(tbl)
	for _, v in ipairs(PLAYER_BUFFS) do
		local i = strlen(v) - 1
		while i > 1 do 
			if string.sub(v, i, i) == " " then
				local s = string.sub(v, i+1, strlen(v))
				for _, n in ipairs(tbl) do
					if n == s then
						return true
					end
				end			
				break
			end
			i = i - 1
		end
	end	
	return false
end

local function player_is_mounted()
	if PLAYER_CLASS == "warlock" and (RetailMacro:player_has_buff("Summon Felsteed") or RetailMacro:player_has_buff("Summon DreadSteed")) then
		return true
	elseif PLAYER_CLASS == "paladin" and (RetailMacro:player_has_buff("Summon Warhorse") or RetailMacro:player_has_buff("Summon Charger")) then
		return true
	end
	
	if UnitFactionGroup("player") == "Alliance" then
		if find_mount_buff_in_table(mount_names["alliance"]) then return true end
	else
		if find_mount_buff_in_table(mount_names["horde"]) then return true end
	end

	return find_mount_buff_in_table(mount_names["neutral"])
end

-- local function player_is_swimming()
	-- return false
-- end

-- local function player_is_indoors()
	-- return false
-- end

local function player_evaluate_pet(v)
	if UnitExists("pet") == nil then 
		return false
	end
	
	return strlower(UnitName("pet")) == v or strlower(UnitCreatureFamily("pet")) == v
end

local function valid_party_unit_id(target)
	if UnitInParty("player") == nil then
		return false
	end
	
	if string.sub(target, 1, 5) ~= "party" then
		return false
	end
	
	local n = tonumber(string.sub(target, 5))
	return n >= 1 and n <= 4
end

local function valid_party_pet_unit_id(target)
	if UnitInParty("player") == nil then
		return false
	end
	
	if string.sub(target, 1, 8) ~= "partypet" then
		return false
	end
	
	local n = tonumber(string.sub(target, 8))
	return n >= 1 and n <= 4
end

local function valid_raid_unit_id(target)
	if UnitInRaid("player") == nil then
		return false
	end
	
	if string.sub(target, 1, 4) ~= "raid" then
		return false
	end
	
	local n = tonumber(string.sub(target, 4))
	return n >= 1 and n <= 40
end

local function valid_raid_pet_unit_id(target)
	if UnitInRaid("player") == nil then
		return false
	end
	
	if string.sub(target, 1, 7) ~= "raid" then
		return false
	end
	
	local n = tonumber(string.sub(target, 7))
	return n >= 1 and n <= 40
end

local function get_player_stance_or_form()
	if not PLAYER_HAS_STANCE_OR_FORM then
		return 0
	end
	for i=1, GetNumShapeshiftForms() do
		local _, _, active = GetShapeshiftFormInfo(i)
		if active then
			return i
		end
	end
	return 0
end

function RetailMacro:evaluate_target(t)
    if t == "focus" then
        if self:get_focus() ~= nil then
            return t, self.TARGET_TYPE_FOCUS
		end
	elseif t == "mouseover" then
        if self:get_mouseover() ~= nil then
            return t, self.TARGET_TYPE_MOUSEOVER
        end
    elseif t == "player" then
        return t, self.TARGET_TYPE_ID
    elseif t == "target" then
        if UnitName("target") ~= nil then
            return t, self.TARGET_TYPE_ID
        end
    elseif t == "pet" then
        if UnitName("pet") ~= nil then
            return t, self.TARGET_TYPE_ID
        end
    elseif valid_party_unit_id(t) or valid_raid_unit_id(t) then
        return t, self.TARGET_TYPE_ID
    elseif valid_party_pet_unit_id(t) or valid_raid_pet_unit_id(t) then
        return t, self.TARGET_TYPE_ID
    else
        return t, self.TARGET_TYPE_NAME
    end
end

function RetailMacro:get_check(k, v)
    if v == nil then
        if k == "combat"                            then return function() return UnitAffectingCombat("player") end
        elseif k == "nocombat"                      then return function() return not UnitAffectingCombat("player") end
        elseif k == "group" 						then return function() return UnitInParty("player") == nil and UnitInRaid("player") == nil end
        elseif k == "nogroup" 						then return function() return UnitInParty("player") ~= nil or UnitInRaid("player") ~= nil end

        elseif k == "stealth" 						then return function() return player_has_stealth() end
        elseif k == "nostealth" 					then return function() return not player_has_stealth() end

        elseif k == "mod" or k == "modifier"		then return function() return (IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown()) ~= nil end
        elseif k == "nomod" or k == "nomodifier" 	then return function() return not (IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown()) end

        elseif k == "mounted" 						then return function() return player_is_mounted() end
        elseif k == "nomounted"						then return function() return not player_is_mounted() end

        elseif k == "stance" or k == "form"			then return function() return get_player_stance_or_form() > 0 end
        elseif k == "nostance" or k == "noform"		then return function() return get_player_stance_or_form() == 0 end

        elseif k == "exists"                        then return function(target, target_type) return evaluate_unit_exists(target, target_type) end
        elseif k == "noexists"                      then return function(target, target_type) return not evaluate_unit_exists(target, target_type) end
        elseif k == "dead"                          then return function(target, target_type) return evaluate_unit_dead(target, target_type) end
        elseif k == "nodead"                        then return function(target, target_type) return not evaluate_unit_dead(target, target_type) end
        elseif k == "harm"                          then return function(target, target_type) return evaluate_unit_harm(target, target_type) end
        elseif k == "noharm"                        then return function(target, target_type) return not evaluate_unit_harm(target, target_type) end
        elseif k == "help"                          then return function(target, target_type) return evaluate_unit_help(target, target_type) end
        elseif k == "nohelp"                        then return function(target, target_type) return not evaluate_unit_help(target, target_type) end

        else
            RetailMacro:err(nil, "unsupported condition \"" .. k .. "\"")
            return function() return false end
        end
    end

    if k  == "pet"									then return function() return player_evaluate_pet(v) end
    elseif k == "nopet" 							then return function() return not player_evaluate_pet(v) end

    elseif k == "party" 							then return function() return UnitInParty(v) == nil end
    elseif k == "noparty" 							then return function() return UnitInParty(v) ~= nil end

    elseif k == "raid" 								then return function() return UnitInRaid(v) ~= nil end
    elseif k == "noraid" 							then return function() return UnitInRaid(v) == nil end

    elseif k == "stance" or k == "form" then return (
        function()
            local tbl = RetailMacro:strsplit(v, "/")
            local stance = get_player_stance_or_form()

            for _, n in pairs(tbl) do
                if tonumber(n) == stance then
                    return true
                end
            end
        end
    )

    elseif k == "nostance" or k == "noform"	then return (
        function()
            local tbl = RetailMacro:strsplit(v, "/")
            local stance = get_player_stance_or_form()

            for _, n in pairs(tbl) do
                if tonumber(n) ~= stance then
                    return true
                end
            end
        end
    )

    elseif k == "mod" or k == "modifier" then return (
        function()
            if v == "shift" 	then if IsShiftKeyDown() then return true end
            elseif v == "alt" 	then if IsAltKeyDown() then return true end
            elseif v == "ctrl" 	then if IsControlKeyDown() then return true end
            else
                RetailMacro:err(nil, "unsupported parameter  \"" .. v .. "\" for 'modifier' must be one of shift | alt | ctrl.")
                return false
            end
        end
    )

    elseif k == "nomod" or k == "nomodifier" then return (
        function()
            if v == "shift" 	then if not IsShiftKeyDown() then return true end
            elseif v == "alt" 	then if not IsAltKeyDown() then return true end
            elseif v == "ctrl" 	then if not IsControlKeyDown() then return true end
            else
                RetailMacro:err(nil, "unsupported parameter \"" .. v .. "\" for 'modifier'  must be one of shift | alt | ctrl.")
                return false
            end
        end
    )

    else
        RetailMacro:err(nil, "unsupported condition \"" .. k .. "\"")
        return function() return false end
    end
end

--RetailMacro.STATUS_IN_COMBAT = false
--
--local frame = CreateFrame("Frame");
--local function onEvent()
--    print(event)
--
--    if arg1 ~= nil then
--        print("ARG1: " .. arg1)
--    end
--    if arg2 ~= nil then
--        print("ARG2: " .. arg2)
--    end
--
--
--    if event == "UNIT_COMBAT" then
--        RetailMacro.STATUS_IN_COMBAT = UnitAffectingCombat("player")
--    elseif event == "SKILL_LINES_CHANGED" then --http://wowwiki.wikia.com/wiki/Events/Skill
--
--
--    elseif event == "MODIFIER_STATE_CHANGED" then
--
--    end
--end
--
--frame:RegisterEvent("MODIFIER_STATE_CHANGED")
--frame:RegisterEvent("PLAYER_TARGET_CHANGED")
--frame:RegisterEvent("UNIT_AURA")
--frame:RegisterEvent("UNIT_COMBAT")
--frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
--frame:RegisterEvent("UNIT_PET")
--
--frame:SetScript("OnEvent", onEvent)

print("evaluate")