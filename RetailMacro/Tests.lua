SLASH_MACROTEST1 = "/macrotest"

local valid_syntax_tests = {
	" ",
	"[]",
	"[ ]",
	"[ ] [ ]",
	"[ ] Some Spell"
}

local invalid_syntax_tests = {
	"[ [] Some Spell",
	"[] ] Some Spell",
	"[] [ Some Spell",
	"] [] Some Spell",
	"] Some Spell",
	"]",
	"["
}

local valid_target_tests = {
	"[@target, exists] do smth",
	"[@target, noexists] do smth",
	"[@target, dead] do smth",
	"[@target, nodead] do smth",
	"[@target, harm] do smth",
	"[@target, noharm] do smth",
	"[@target, help] do smth",
	"[@target, nohelp] do smth"
}
	
local valid_evaluation_tests = {
	"[combat] do smth",
	"[nocombat] do smth",
	"[group] do smth",
	"[nogroup] do smth",
	"[stealth] do smth",
	"[nostealth] do smth",
	"[mod] do smth",
	"[nomod] do smth",
	"[modifier] do smth",
	"[nomodifier] do smth",
	"[mounted] do smth",
	"[nomounted] do smth",
	"[swimming] do smth",
	"[noswimming] do smth",
	"[indoors] do smth",
	"[noindoors] do smth",
	"[outdoors] do smth",
	"[nooutdoors] do smth",
	
	"[pet:Voidwalker] do smth",
	"[nopet:Voidwalker] do smth",
	
	"[party:player] do smth",
	"[noparty:player] do smth",
	
	"[raid:player] do smth",
	"[noraid:player] do smth",
	
	"[mod:alt] do smth",
	"[nomod:shift] do smth",
	
	"[modifier:alt] do smth",
	"[nomodifier:shift] do smth",
}

local invalid_evaluation_tests = {
	"[lobo:frischling] lula",
	"[mod:schmops] lula"
}

local sequence_tests = {
	"[nomod][group] lula",
	"[group][nomod] lula",
	"[mod:alt] one; [mod:ctrl] two; three",
	
	"[mod:alt] one [mod] two; three; ",
	";;",
	"[:]"
}

local parameter_test = {
	"1/3/4",
	"1 3",
	"13",
	"Shadow Word: Pain",
	"Healing Touch(Rank 2)"
}

local temp_test = {
	--"[stance:1/3] Unending Breath",
	--"[mounted] mounted; not mounted",
	--"[stealth] stealthed; not stealthed",
	-- "[indoors] indoors; outside",
	-- "[target=focus, exists]Focus Lock; Spell Lock; [pet:Succubus,target=focus, exists] Seduction;[pet:Sukkubus] Seduction; [pet:Voidwalker] Sacrifice"
	"[target=focus, exists]Focus Lock; Spell Lock;"

}

local unit_id_test = {
	-- "pet",
	-- "target",
	-- "player",
	-- "pettarget",
	-- "targettarget",
	-- "playertarget",
	-- "playertargettargettargettargettargettargettargettarget",
	"raid0",
	"raid1",
	"raid39",
	"raid40",
	"raid41",
	"party0",
	"party1",
	"party4",
	"party5",
	"raid0target",
	"raid1target",
	"party5target",
	"party4target",
	-- "Creckle",
	-- "hallotarget",
	-- "focus"
}

function SlashCmdList.MACROTEST(msg, editbox)
--    print("TESTS")
--	 for _, s in pairs(valid_syntax_tests) do
--		 RetailMacro:evaluate_command(s)
--	 end
	
--    for _, s in pairs(invalid_syntax_tests) do
--        RetailMacro:evaluate_command(s)
--    end
	
	-- for _, s in pairs(valid_target_tests) do
		-- RetailMacro:evaluate_command(s)
	-- end
	
--	 for _, s in pairs(valid_evaluation_tests) do
--		 RetailMacro:evaluate_command(s)
--	 end
	
--	 for _, s in pairs(invalid_evaluation_tests) do
--		 RetailMacro:evaluate_command(s)
--	 end
--
--	 for _, s in pairs(sequence_tests) do
--		 RetailMacro:evaluate_command(s)
--	 end
	
--	 for _, s in pairs(parameter_test) do
--		 RetailMacro:evaluate_command(s)
--	 end
	
--	 for _, s in pairs(temp_test) do
--		 RetailMacro:evaluate_command(s)
--	 end
	
	-- local t = Target:new("focus", Target.TYPE_FOCUS)
	
	-- if target_unit(t) then
		-- print("true")
	-- else
		-- print("false")
	-- end
	
	-- for i, s in pairs(unit_id_test) do
		-- local e = is_unit_id(s)
		-- local r = "false"
		-- if e == true then
			-- r = "true"
		-- end
		
		-- print(s .. " = " .. r)
	-- end
	
--	reportActionButtons()
--    RetailMacro:parse_macro("/cast [mod, @player] Unending Breath; Unending Breath /cast [mod, @player, form:0/2] Healing Touch; Healing Touch")

--	print("RUN TESTS")
--RetailMacro:inject()
end