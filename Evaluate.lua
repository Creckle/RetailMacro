Condition = { }
Condition.__index = Condition
Condition.self = setmetatable({}, Condition)

Condition.TARGET_TYPE_ID = 0
Condition.TARGET_TYPE_FOCUS = 1
Condition.TARGET_TYPE_NAME = 2

function Condition:reset(tokenizer)
	self.tokenizer = tokenizer
	self.invalid = false
	self.target = nil
	self.target_type = nil
	self.target_exists = nil
	self.target_harm = nil
	self.target_help = nil
	self.target_dead = nil
	return self
end

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

local function evaluate_unit_exists(bool, condition)
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

	-- if condition:get_target_type() ~= Condition.TARGET_TYPE_ID then
		-- local unit_name
		-- if condition:get_target_type() == Condition.TARGET_TYPE_FOCUS then
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
	
	if condition:get_target_type() ~= Condition.TARGET_TYPE_ID then -- tmp fix
		return false
	end
	
	if bool and UnitExists(condition:get_target()) == 1 then 
		return false
	elseif not bool and UnitExists(condition:get_target()) == nil then 
		return false
	end
	return true
	
	
	-- local unit
	-- print(condition:get_target_type())
	-- if condition:get_target_type() == Condition.TARGET_TYPE_FOCUS then 
		-- if FOCUS == nil then
			-- return false
		-- end
		-- unit = FOCUS 
	-- else
		-- unit = condition:get_target()
	-- end
	
	-- if condition:get_target_type() ~= Condition.TARGET_TYPE_ID then
		
	-- end
	
	
	-- print(unit)
	
	
end

local function evaluate_unit_harm(c, condition)
	if condition:get_target_type() ~= Condition.TARGET_TYPE_ID then -- tmp fix
		return false
	end

	if c and UnitIsEnemy("player", condition:get_target()) == 1 then
		return false
	elseif not c and UnitIsEnemy("player", condition:get_target()) == nil then
		return false
	end
	return true
end

local function evaluate_unit_help(c, condition)
	if condition:get_target_type() ~= Condition.TARGET_TYPE_ID then -- tmp fix
		return false
	end
	
	if c and UnitIsFriend("player", condition:get_target()) == 1 then
		return false
	elseif not c and UnitIsFriend("player", condition:get_target()) == nil then
		return false
	end
	return true
end

local function evaluate_unit_dead(c, condition)
	if condition:get_target_type() ~= Condition.TARGET_TYPE_ID then -- tmp fix
		return false
	end
	
	if c and UnitIsDeadOrGhost(condition:get_target()) == 1 then
		return false
	elseif not c and UnitIsDeadOrGhost(condition:get_target()) == nil then
		return false
	end
	return true
end

function Condition:check_exists(c)
	if self.target == nil then
		self.target_exists = c
		return true
	end
	
	return evaluate_unit_exists(c, self)
end

function Condition:check_harm(c)
	if self.target == nil then
		self.target_harm = c
		return true
	end
	
	return evaluate_unit_harm(c, self)
end

function Condition:check_help(c)
	if self.target == nil then
		self.target_help = c
		return true
	end
	
	return evaluate_unit_help(c, self)
end

function Condition:check_dead(c)
	if self.target == nil then
		self.target_dead = c
		return true
	end
	
	return evaluate_unit_dead(c, self)
end

function Condition:get_target()
	return self.target
end

function Condition:get_target_type()
	return self.target_type
end

function Condition:set_invalid()
	self.invalid = true
end

function Condition:is_set_invalid()
	return self.invalid
end

local function player_has_stealth()
	if PLAYER_RACE == "nightelf" and player_has_buff("Shadowmeld") then
		return true
	elseif PLAYER_CLASS == "rogue" and player_has_buff("Stealth") then
		return true
	elseif PLAYER_CLASS == "druid" and player_has_buff("Prowl") then
		return true
	elseif player_has_buff("Lesser Invisibility") or player_has_buff("Phase Shift") then
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
	if PLAYER_CLASS == "warlock" and (player_has_buff("Summon Felsteed") or player_has_buff("Summon DreadSteed")) then
		return true
	elseif PLAYER_CLASS == "paladin" and (player_has_buff("Summon Warhorse") or player_has_buff("Summon Charger")) then
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

function Condition:set_target(t)
	self.target = t
	if t == nil then
		return false
	elseif t == "focus" then
		self.target_type = Condition.TARGET_TYPE_FOCUS
		if FOCUS ~= nil then
			return true
		end
	elseif t == "player" then
		self.target_type = Condition.TARGET_TYPE_ID
		return true
	elseif t == "target" then
		self.target_type = Condition.TARGET_TYPE_ID
		if UnitName("target") ~= nil then
			return true
		end
	elseif t == "pet" then
		self.target_type = Condition.TARGET_TYPE_ID
		if UnitName("pet") ~= nil then
			return true
		end
	elseif valid_party_unit_id(t) or valid_raid_unit_id(t) then
		self.target_type = Condition.TARGET_TYPE_ID
		return true
	elseif valid_party_pet_unit_id(t) or valid_raid_pet_unit_id(t) then
		self.target_type = Condition.TARGET_TYPE_ID
		return true
	else
		self.target_type = Condition.TARGET_TYPE_NAME
		return true
	end
end

local function eval_single_condition(s, condition)
	if s == "combat" 							then return UnitAffectingCombat("player")
	elseif s == "nocombat" 						then return not UnitAffectingCombat("player")
	
	elseif s == "group" 						then return UnitInParty("player") == nil and UnitInRaid("player") == nil
	elseif s == "nogroup" 						then return UnitInParty("player") ~= nil or UnitInRaid("player") ~= nil
		
	elseif s == "stealth" 						then return player_has_stealth()
	elseif s == "nostealth" 					then return not player_has_stealth()
		
	elseif s == "mod" or s == "modifier"		then return (IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown())
	elseif s == "nomod" or s == "nomodifier" 	then return not(IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown())

	elseif s == "mounted" 						then return player_is_mounted()					
	elseif s == "nomounted"						then return not player_is_mounted()
	
	-- elseif s == "swimming" 						then return player_is_swimming()
	-- elseif s == "noswimming" 					then return not player_is_swimming()
	
	-- elseif s == "indoors" 						then return player_is_indoors()
	-- elseif s == "noindoors" 					then return not player_is_indoors()

	-- elseif s == "outdoors" 						then return not player_is_indoors()
	-- elseif s == "nooutdoors" 					then return player_is_indoors()
	
	elseif s == "stance" or s == "form"			then return get_player_stance_or_form() > 0
	elseif s == "nostance" or s == "noform"		then return get_player_stance_or_form() == 0
	else
		err(condition.tokenizer, "unsupported condition \"" .. s .. "\"")
		return false
	end
end

local function eval_multi_condition(s, v, condition)
	if s  == "pet"									then return player_evaluate_pet(v)
	elseif s == "nopet" 							then return not player_evaluate_pet(v)
	
	elseif s == "party" 							then return UnitInParty(v) == nil
	elseif s == "noparty" 							then return UnitInParty(v) ~= nil
	
	elseif s == "raid" 								then return UnitInRaid(v) ~= nil
	elseif s == "noraid" 							then return UnitInRaid(v) == nil
	
	elseif s == "stance" or s == "form" then
		local tbl = strsplit(v, "/")
		local stance = get_player_stance_or_form()
		
		for i, n in pairs(tbl) do
			if tonumber(n) == stance then
				return true 
			end
		end
	elseif s == "nostance" or s == "noform"	then 
		local tbl = strsplit(v, "/")
		local stance = get_player_stance_or_form()

		for i, n in pairs(tbl) do
			if tonumber(n) ~= stance then
				return true 
			end
		end
	elseif s == "mod" or s == "modifier" then
		if v == "shift" 	then if IsShiftKeyDown() then return true end
		elseif v == "alt" 	then if IsAltKeyDown() then return true end
		elseif v == "ctrl" 	then if IsControlKeyDown() then return true end
		else
			err(condition.tokenizer, "unsupported parameter  \"" .. v .. "\" for 'modifier' must be one of shift | alt | ctrl.")
			return false
		end
	elseif s == "nomod" or s == "nomodifier" then
		if v == "shift" 	then if not IsShiftKeyDown() then return true end
		elseif v == "alt" 	then if not IsAltKeyDown() then return true end
		elseif v == "ctrl" 	then if not IsControlKeyDown() then return true end
		else
			err(condition.tokenizer, "unsupported parameter \"" .. v .. "\" for 'modifier'  must be one of shift | alt | ctrl.")
			return false
		end
	else
		err(condition.tokenizer, "unsupported condition \"" .. s .. "\"")
		return false
	end
end

function Condition:evaluate_condition(k, v)
	if v == nil then
		return eval_single_condition(k, self)
	else
		return eval_multi_condition(k, v, self)
	end
end

function Condition:evaluate()
	if self.invalid then
		return false
	end
	
	-- if self.target == nil then
		-- return true, nil
	-- end

	-- local target_type = nil
	-- if self.target ~= nil then
		-- target_type = self.target_type
	-- end
	
	
	if self.target == nil then
		self.target = "target"
		self.target_type = Condition.TARGET_TYPE_ID
	end
	
	if not evaluate_unit_exists(self.target_exists, self) 	then return false, self.target_type end
	if not evaluate_unit_harm(self.target_harm, self) 		then return false, self.target_type end
	if not evaluate_unit_help(self.target_help, self) 		then return false, self.target_type end
	if not evaluate_unit_dead(self.target_dead, self) 		then return false, self.target_type end
	
	return true, target_type
end