--function Focus_OnUpdate(elapsed)
--    if ( CURRENT_FOCUS ~= UnitName("focus") ) then
--        CURRENT_FOCUS = UnitName("focus");
--        SetPortraitTexture(this.portrait, this.unit);
--        this.name:SetText(GetUnitName(this.unit));
--    end
--    Focus_Update();
--end
--
--function Focus_Update()
----    print("FOCUS UPDATE")
--    if ( UnitExists("focus") and ( UnitHealth("focus") > 0 ) ) then
--        FocusFrame:Show();
--    else
--        print(UnitHealth("focus"))
--        print("hide")
--        FocusFrame:Hide();
--    end
--
--    if ( FocusFrame:IsShown() ) then
--        UnitFrameHealthBar_Update(this.healthbar, this.unit);
--        UnitFrameManaBar_Update(this.manabar, this.unit);
--        Focus_CheckDead();
--        FocusPortrait:SetAlpha(1.0);
--        TargetDebuffButton_Update();
----        RefreshBuffs(this, 0, "focus");
--    end
--
--end
--
--function Focus_CheckDead()
--    if ( (UnitHealth("focus") <= 0) and UnitIsConnected("focus") ) then
--        FocusBackground:SetAlpha(0.9);
--        FocusDeadText:Show();
--    else
--        FocusBackground:SetAlpha(1);
--        FocusDeadText:Hide();
--    end
--end
--
--
--function FocusHealthCheck()
--    if ( UnitIsPlayer("focus") ) then
--        local unitMinHP, unitMaxHP, unitCurrHP;
--        unitHPMin, unitHPMax = this:GetMinMaxValues();
--        unitCurrHP = this:GetValue();
--        this:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
--        if ( UnitIsDead("focus") ) then
--            FocusPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
--        elseif ( UnitIsGhost("focus") ) then
--            FocusPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
--        elseif ( (this:GetParent().unitHPPercent > 0) and (this:GetParent().unitHPPercent <= 0.2) ) then
--            FocusPortrait:SetVertexColor(1.0, 0.0, 0.0);
--        else
--            FocusPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
--        end
--    end
--end
--
--function Focus_OnClick(button)
--    print(button)
--    print("onclick")
--    if ( SpellIsTargeting() and button == "RightButton" ) then
--        SpellStopTargeting();
--        return;
--    end
--    if ( button == "LeftButton" ) then
--        if ( SpellIsTargeting() ) then
--            SpellTargetUnit("focus");
--        elseif ( CursorHasItem() ) then
--            DropItemOnUnit("focus");
--        else
--            TargetUnit("focus");
--        end
--    end
--end
--
--RetailMacro:RegisterEvent("PLAYER_FOCUS_CHANGED", function() Focus_Update() end)