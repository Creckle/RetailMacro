SLASH_SHOWTOOLTIP1 = "/showtooltip"
SLASH_SHOW1 = "/show"

local spells = { }
local macros = { }

function reportActionButtons()
	-- local lActionSlot = 0;
	-- for lActionSlot = 1, 120 do
		-- local lActionText = GetActionText(lActionSlot);
		-- local lActionTexture = GetActionTexture(lActionSlot);
		-- if lActionTexture then
			-- local lMessage = "Slot " .. lActionSlot .. ": [" .. lActionTexture .. "]";
			-- if lActionText then
				-- lMessage = lMessage .. " \"" .. lActionText .. "\"";
			-- end
			-- DEFAULT_CHAT_FRAME:AddMessage(lMessage);
		-- end
		
		
		
		
		
		
		
		-- local macro_name = GetActionText(lActionSlot);
		-- if macro_name ~= nil then
			-- local index = GetMacroIndexByName(macro_name);
			-- print(index)
			
		-- end
	-- end
	
	-- local icon_id = math.random(1, 69)
	
	-- EditMacro(2, "RunTests", icon_id, "yolo", 1, true)
	
	-- local iconTexture = GetMacroIconInfo(icon_id)
	-- print(iconTexture)
	
	for i = 1, GetNumSpellTabs() do
		local _, _, offset, numSpells = GetSpellTabInfo(i)
		for n = 1, numSpells do
			local spell = { }
			spell.id = offset + n
			spell.texture = GetSpellTexture(offset + n, BOOKTYPE_SPELL)
			spells[GetSpellName(offset + n, BOOKTYPE_SPELL)] = spell
		end
	end

	for i = 1, GetNumMacroIcons() do
		local texture = GetMacroIconInfo(i)
		for si, sn in pairs(spells) do
			if sn.texture == texture then
				sn.macro_icon = i
			end
		end
	end
	

	for action_slot = 1, 120 do
		local action_text = GetActionText(action_slot)
		
		if action_text ~= nil then
			local index = GetMacroIndexByName(action_text)
			local name, icon_texture, body, isLocal = GetMacroInfo(index)
			
			print(name)
			print(body)
			print(isLocal)
			
			local macro = { }
			macro.conditions = { }
			macro.name = name
			macro.default_texture = icon_texture
		end
	end
	
end

local function onEvent(arg1, arg2)
	if event == "ACTIONBAR_SLOT_CHANGED" then --http://wowwiki.wikia.com/wiki/Events/Action_Bar
		print("ACTIONBAR_SLOT_CHANGED")
	elseif event == "SKILL_LINES_CHANGED" then --http://wowwiki.wikia.com/wiki/Events/Skill
		print("SKILL_LINES_CHANGED")
	elseif event == "UPDATE_MACROS" then 
		print("UPDATE_MACROS")
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("UPDATE_MACROS")
frame:SetScript("OnEvent", onEvent)