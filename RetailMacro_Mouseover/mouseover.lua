local rm = RetailMacro

RetailMacro_Mouseover = {
}

function RetailMacro_Mouseover:setEnterHook(frame, unitid)
    local func = frame:GetScript("OnEnter")
    frame:SetScript("OnEnter",
        function()
            rm:set_mouseover(unitid, true)
            func()
        end
    )
end

function RetailMacro_Mouseover:setLeaveHook(frame)
    local func = frame:GetScript("OnLeave")
    frame:SetScript("OnLeave",
        function()
            rm:set_mouseover(nil, false)
            func()
        end
    )
end

function RetailMacro_Mouseover:onLoad()
--    self:register_blizzard_unit_frames()
--  self:register_blizzard_raid_frames()
end

RetailMacro:RegisterAddon("RetailMacro_Mouseover", RetailMacro_Mouseover)