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
	



	

	for action_slot = 1, 120 do
		local action_text = GetActionText(action_slot)
		
		if action_text ~= nil then
			local index = GetMacroIndexByName(action_text)
			local name, icon_texture, body, isLocal = GetMacroInfo(index)

--			print(name)
--			print(body)
--			print(isLocal)

--            print(body)


            table.insert(macros, RetailMacro:parse_macro(body))


--			local macro = {
--                commands = {
--                    sequences = { },
--                    command = ""
--                },
--                tooltip = { },
--                name = name,
--                default_texture = icon_texture
--            }
--
--            local sequence = {
--                command = "",
--                parameter = "",
--                RetailMacro_Conditions = {},
--                target = "",
--                target_id = 0
--
--            }
		end
	end
    print_r(macros)
end

--local function onEvent()
--    print(event)
--
----    if arg1 ~= nil then
----        print(arg1)
----    end
----    if arg2 ~= nil then
----        print(arg2)
----    end
--
--
--	if event == "ACTIONBAR_SLOT_CHANGED" then --http://wowwiki.wikia.com/wiki/Events/Action_Bar
--
--	elseif event == "SKILL_LINES_CHANGED" then --http://wowwiki.wikia.com/wiki/Events/Skill
--        for i = 1, GetNumSpellTabs() do
--            local _, _, offset, numSpells = GetSpellTabInfo(i)
--            for n = 1, numSpells do
--                local spell = { }
--                spell.id = offset + n
--                spell.texture = GetSpellTexture(offset + n, BOOKTYPE_SPELL)
--                spells[GetSpellName(offset + n, BOOKTYPE_SPELL)] = spell
--            end
--        end
--	elseif event == "UPDATE_MACROS" then
--        for i = 1, GetNumMacroIcons() do
--            local texture = GetMacroIconInfo(i)
--            for _, sn in pairs(spells) do
--                if sn.texture == texture then
--                    sn.macro_icon = i
--                end
--            end
--        end
--
--    elseif event == "MODIFIER_STATE_CHANGED" then
--
--	end
--end
--
--

--
--frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
--frame:RegisterEvent("SKILL_LINES_CHANGED")
--frame:RegisterEvent("UPDATE_MACROS")
--
--frame:RegisterEvent("MODIFIER_STATE_CHANGED")
--frame:RegisterEvent("PLAYER_TARGET_CHANGED")
--frame:RegisterEvent("UNIT_AURA")
--frame:RegisterEvent("UNIT_COMBAT")
--frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
--frame:RegisterEvent("UNIT_PET")
--

--local frame = CreateFrame("Frame");
--local function onEvent()
--    print(event)
--
--end
--
--frame:RegisterAllEvents();
--frame:SetScript("OnEvent", onEvent)