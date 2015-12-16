local rm = RetailMacro
local _G = getfenv(0)

local calls = 0

local DATA_COLLECTION_TIMEOUT = 1

local focusdata = {
    unit = "focus",
    age = 0
}

local mouseoverdata = {
    unit = "mouseover",
    age = 0
}

local hooks = {}

local FOCUS, MOUSEOVER, MOUSEOVER_AGE;
local MOUSEOVER_ISUNITID = false;
--local MOUSEOVER_TIMEOUT = 1.5;

---------------------------
--  MOUSEOVER FUNCTIONS  --
---------------------------

function rm:set_mouseover(value, isUnitId)
    MOUSEOVER = value
    --    MOUSEOVER_AGE = GetTime()
    MOUSEOVER_ISUNITID = isUnitId
end

function rm:get_mouseover()
    if MOUSEOVER == nil then
        return nil
    end

    --    print(GetTime() - MOUSEOVER_AGE)

    --    if GetTime() - MOUSEOVER_AGE < MOUSEOVER_TIMEOUT then
    return MOUSEOVER
    --    end
    --    print("TIMEOUT")
    --    return nil
end

function rm:get_mouseover_name()
    if self:get_mouseover() == nil then
        return "unknown"
    end
    return self:get_mouseover()
end

function rm:target_mouseover()
    if MOUSEOVER == nil then
        return false
    end

    if UnitName("playertarget") == MOUSEOVER then
        return true
    end

    UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
    TargetByName(MOUSEOVER, true)
    UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")

    return UnitName("target") == MOUSEOVER
end

-----------------------
--  FOCUS FUNCTIONS  --
-----------------------

function rm:set_focus(unit_name, unit_type)
    if unit_type == RetailMacro.TARGET_TYPE_FOCUS then
        return false
    end

    local name
    if unit_type == RetailMacro.TARGET_TYPE_NAME then
        name = unit_name
    else
        print(unit_name)
        name = UnitName(unit_name)
    end

    if name ~= FOCUS and name ~= nil then
        DEFAULT_CHAT_FRAME:AddMessage( "new focus: " .. name )
        FOCUS = name
        fire_event(self, "PLAYER_FOCUS_CHANGED")
    end
end

function rm:get_focus()
    return FOCUS
end

function rm:get_focus_name()
    if self:get_focus() == nil then
        return "unknown"
    end
    return self:get_focus()
end

function rm:clear_focus()
    FOCUS = nil
end

function rm:target_focus()
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

-------------------------
--  HOOKING FUNCTIONS  --
-------------------------

local function get_data(data, value)
    if GetTime() - data.age > DATA_COLLECTION_TIMEOUT
--            or (data.unit == "focus" and data.name ~= rm:get_focus_name())
--            or (data.unit == "mouseover" and data.name ~= rm:get_mouseover_name())
    then

        print("focusupdate")

        if data.unit == "focus" then
           data.name = rm:get_focus_name()
        elseif data.unit == "mouseover" then
            data.name = rm:get_mouseover_name()
        end

        local last_target = UnitName("target")
        TargetUnit(data.unit)

        data.exists = UnitExists("target")
        data.isdead = UnitIsDead("target")
        data.isghost = UnitIsGhost("target")

        data.health = UnitHealth("target")
        data.healthmax = UnitHealthMax("target")
        data.mana = UnitMana("target")
        data.manamax = UnitManaMax("target")

        data.powertype = UnitPowerType("target")

        data.isconnected = UnitIsConnected("target")

        if last_target ~= nil then
            TargetByName(last_target, true)
        else
            ClearTarget()
        end
        focusdata.age = GetTime()
    end

    return data[value]
end

local function inject_hooks()

    hooks.exists = _G["UnitExists"]
    hooks.isdead = _G["UnitIsDead"]
    hooks.isghost = _G["UnitIsGhost"]
    hooks.name = _G["UnitName"]
    hooks.health = _G["UnitHealth"]
    hooks.healthmax = _G["UnitHealthMax"]
    hooks.mana = _G["UnitMana"]
    hooks.manamax = _G["UnitManaMax"]
    hooks.powertype = _G["UnitPowerType"]
    hooks.target = _G["TargetUnit"]
    hooks.unitisunit = _G["UnitIsUnit"]
    hooks.portraittexture = _G["SetPortraitTexture"]
    hooks.isconnected = _G["UnitIsConnected"]
    hooks.isplayer = _G["UnitIsPlayer"]

    _G["UnitExists"] = (
    function(unit)
--        if unit == "focus" then
--            return (rm:get_focus() ~= nil)
--        elseif unit == "mouseover" then
--            return (rm:get_mouseover() ~= nil)
--        end

        if unit == "focus" then
--            if rm:get_focus() == nil then
--                return false
--            end
--            return get_data(focusdata, "exists")
            return true
        elseif unit == "mouseover" then
--            if rm:get_mouseover() == nil then
--                return false
--            end
--            return get_data(mouseoverdata, "exists")
            return true
        end

        return hooks.exists(unit)
    end)

    _G["UnitIsDead"] = (
    function(unit)
        if unit == "focus" then
            return get_data(focusdata, "isdead")
        elseif unit == "mouseover" then
            return get_data(mouseoverdata, "isdead")
        end

        return hooks.isdead(unit)
    end)

    _G["UnitIsGhost"] = (
    function(unit)
        if unit == "focus" then
            return get_data(focusdata, "isghost")
        elseif unit == "mouseover" then
            return get_data(mouseoverdata, "isghost")
        end

        return hooks.isghost(unit)
    end)

    _G["UnitName"] = (
    function(unit)
        if unit == "focus" then
            return rm:get_focus_name()
        elseif unit == "mouseover" then
            return rm:get_mouseover_name()
        end

        if unit == nil then
            return ""

        end

        return hooks.name(unit)
    end)

    _G["UnitHealth"] = (
    function(unit)
        if unit == "focus" then
            print(get_data(focusdata, "health"))
            return get_data(focusdata, "health")
        elseif unit == "mouseover" then
            return get_data(mouseoverdata, "health")
        end
        return hooks.health(unit)
    end)

    _G["UnitHealthMax"] = (
    function(unit)
        if unit == "focus" then
            return get_data(focusdata, "healthmax")
        elseif unit == "mouseover" then
            return get_data(mouseoverdata, "healthmax")
        end
        return hooks.healthmax(unit)
    end)

    _G["UnitMana"] = (
    function(unit)
        if unit == "focus" then
            return get_data(focusdata, "mana")
        elseif unit == "mouseover" then
            return get_data(mouseoverdata, "mana")
        end
        return hooks.mana(unit)
    end)

    _G["UnitManaMax"] = (
    function(unit)
        if unit == "focus" then
            return get_data(focusdata, "manamax")
        elseif unit == "mouseover" then
            return get_data(mouseoverdata, "manamax")
        end
        return hooks.manamax(unit)
    end)

    _G["UnitPowerType"] = (
    function(unit)
        if unit == "focus" then
            return get_data(focusdata, "powertype")
        elseif unit == "mouseover" then
            return get_data(mouseoverdata, "powertype")
        end
        return hooks.powertype(unit)
    end)

    _G["TargetUnit"] = (
    function(unit)
        calls = calls + 1
--        print("target unit "..tostring(calls))
        if unit == "focus" then
            return rm:target_focus()
        elseif unit == "mouseover" then
            return rm:target_mouseover()
        end

        return hooks.target(unit)
    end)

    _G["UnitIsUnit"] = (
    function(unit, unit2)
        if unit == "focus" or unit2 == "focus" or unit == "mouseover" or unit2 == "mouseover" then
            return (UnitName(unit) == UnitName(unit2))
        end

        return hooks.unitisunit(unit, unit2)
    end)

    _G["SetPortraitTexture"] = (
    function(portrait, unit)
        if unit == "focus" then
            return nil
        elseif unit == "mouseover" then
            return nil
        end

        return hooks.portraittexture(portrait, unit)
    end)

    _G["UnitIsConnected"] = (
    function(unit)
        if unit == "focus" then
            return true
        elseif unit == "mouseover" then
            return true
        end

        return hooks.isconnected(unit)
    end)

    _G["UnitIsPlayer"] = (
    function(unit)
        if unit == "focus" or unit == "mouseover" then
            return UnitIsUnit(unit, "player")
        end

        return hooks.isplayer(unit)
    end)
end

local function onEvent()
    print("event")

    if event == "UPDATE_MOUSEOVER_UNIT" then
        local name
        local text_left_1 = GameTooltipTextLeft1:GetText()
        if GameTooltip:NumLines() > 1 then
            local text_left_2 = GameTooltipTextLeft2:GetText()
            local len = strlen(text_left_2)
            if len > 7 and strsub(text_left_2, len -7) == "(Player)" then
                local tbl = rm:strsplit(text_left_1, " ")
                name = tbl[table.getn(tbl)]
            else
                name = text_left_1
            end
        else
            name = text_left_1
        end
        print(name)
        if name ~= "unknown" then
            rm:set_mouseover(name, false)
        end
    end
end


local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:SetScript("onEvent", onEvent)



inject_hooks()

print("unitids")