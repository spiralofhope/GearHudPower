--血量阀值, 血量处于在两个值之间时显示对应材质, 
--血量高于第一个值则不显示, 如果第一个值为100则一直显示,
--血量低于最后一个值也不显示, 如果希望死亡也有骷髅, 请设置为-1
GEAR_HUD_POWER_THRESH_HOLD = { 75, 50, 25, 10, 5 };

--
-- User configuration
--
-- You can change these settings and see your changes immediately in the game by typing:
--   /console reloadui
-- You can reduce your health and mana by removing and re-wearing your gear.  I make a gear set which has all empty slots, which makes this very easy to do.
-- You can also edit your per-character settings directly.
-- I'm not entirely sure how this all works, so you may have to quit the game and delete that file if you're having difficulties.
--   /World of Warcraft/WTF/Account/ACCOUNT_NAME/SERVER_NAME/CHARACTER_NAME/SavedVariables/GearHudPower.lua
-- Example contents:
--   GearHudPowerSettings = {
           --["y"] = 40,
           --["x"] = 0,
           --["scale"] = 1.5,
--   }

--距离屏幕中心的偏移位置
-- {x, y}
-- Higher x moves to the right
-- Higher y moves up
GEAR_HUD_POWER_OFFSET = {0, 40};

-- This is good for a scale of 1.5
-- GEAR_HUD_POWER_OFFSET = {0, 40};

--挨打提示的停留时间
GEARHUDPOWER_INDICATOR_SHOWTIME = 0.3
--挨打提示的渐隐时间
GEARHUDPOWER_INDICATOR_FADETIME = 0.2

GEARHUDPOWER_SCALE = 1.5

--四个材质根据血量比例的透明度范围, 该属性一般不用修改.
GEAR_HUD_POWER_ALPHA = { 
	{1, 1},
	{1, 1},
	{1, 1},
	{0.75, 0.75},
};

------------------------------- 以下为常量, 请勿修改 -----------------------
GEAR_HUD_POWER_CENTER_SIZE=148;
--{ 齿轮左上角X坐标, Y坐标, 增加的宽度, 增加的高度 }
GEAR_HUD_POWER_TEX_POS = {
	{ 12, 5, 5, 5 },
	{ 215, 6, 30, 10},
	{ 254, 164, 100, 10},
	{ 174, 341, 170, 25},
}

GearHudPowerSettings = {
	x = GEAR_HUD_POWER_OFFSET[1],
	y = GEAR_HUD_POWER_OFFSET[2],
	scale = GEARHUDPOWER_SCALE,
}

function GearHudPower_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("UNIT_COMBAT");
	self:RegisterEvent("VARIABLES_LOADED");

	GearHudPower_Reset();

	GearHudPowerTexture2:SetTexCoord(
		(GEAR_HUD_POWER_TEX_POS[1][1] - GEAR_HUD_POWER_TEX_POS[2][3])/512,
		(GEAR_HUD_POWER_TEX_POS[1][1] + GEAR_HUD_POWER_TEX_POS[2][3] + GEAR_HUD_POWER_CENTER_SIZE)/512,
		(GEAR_HUD_POWER_TEX_POS[1][2] - GEAR_HUD_POWER_TEX_POS[2][4])/512, 
		(GEAR_HUD_POWER_TEX_POS[1][2] + GEAR_HUD_POWER_TEX_POS[2][4] + GEAR_HUD_POWER_CENTER_SIZE)/512
	)
end

function GearHudPower_UpdateScale()
  -- FIXME:  There is no GearHudPower:SetScale()
	GearHudPower:SetScale(GearHudPowerSettings.scale);
	if(GearHudPowerIndicator) then GearHudPowerIndicator:SetScale(GearHudPowerSettings.scale); end
	if(GearHudPowerIndicator) then GearHudPowerIndicator:Show(); end
end

function GearHudPower_Reset()
	GearHudPowerSettings.scale = GEARHUDPOWER_SCALE;
	GearHudPower:ClearAllPoints();
	GearHudPower:SetPoint("CENTER", UIParent, "CENTER", GearHudPowerSettings.x, GearHudPowerSettings.y);
	GearHudPower_UpdateScale();
end

function GearHudPower_OnEvent(event, arg1, arg2)
	if(event=="VARIABLES_LOADED") then
		GearHudPower_BuildDrag();
    -- FIXME:  Not working?
		GearHudPower_UpdateScale();
		GearHudPower_Lock();
	elseif((event=="UNIT_POWER" or event=="UNIT_MAXPOWER") and arg1=="player") then
		GearHudPower_Update();
  -- TODO:  I'm not sure about this bit.  Wounding doesn't make sense.
	elseif(event=="UNIT_COMBAT" and arg1=="player" and arg2=="WOUND") then
		GearHudPowerIndicator:Show();
		GearHudPowerIndicator.timer=GEARHUDPOWER_INDICATOR_SHOWTIME + GEARHUDPOWER_INDICATOR_FADETIME; 
		GearHudPowerIndicator:SetAlpha(1.0);
	end
end

function GearHudPower_Update(power)
	if(not power) then power = UnitPower("player")/UnitPowerMax("player")*100; end
	if(UnitIsDead("player") or UnitIsGhost("player")) then power = 0; end
	if(GearHudPower.tex and GearHudPower.tex:IsVisible()) then power = 1 end;
	for i=1, table.getn(GEAR_HUD_POWER_THRESH_HOLD) do
		if(power>GEAR_HUD_POWER_THRESH_HOLD[i]) then
			if(i==3) then
				GearHudPowerTexture2:Show();
			else
				GearHudPowerTexture2:Hide();
			end
			if(i==1) then
				GearHudPower:Hide();
			else
				GearHudPower:Show();
				GearHudPower:SetWidth(GEAR_HUD_POWER_CENTER_SIZE + GEAR_HUD_POWER_TEX_POS[i-1][3] * 2);
				GearHudPower:SetHeight(GEAR_HUD_POWER_CENTER_SIZE + GEAR_HUD_POWER_TEX_POS[i-1][4] * 2);
				GearHudPowerTexture:SetTexCoord(
					(GEAR_HUD_POWER_TEX_POS[i-1][1] - GEAR_HUD_POWER_TEX_POS[i-1][3])/512,
					(GEAR_HUD_POWER_TEX_POS[i-1][1] + GEAR_HUD_POWER_TEX_POS[i-1][3] + GEAR_HUD_POWER_CENTER_SIZE)/512,
					(GEAR_HUD_POWER_TEX_POS[i-1][2] - GEAR_HUD_POWER_TEX_POS[i-1][4])/512, 
					(GEAR_HUD_POWER_TEX_POS[i-1][2] + GEAR_HUD_POWER_TEX_POS[i-1][4] + GEAR_HUD_POWER_CENTER_SIZE)/512
				)
				local factor = (GEAR_HUD_POWER_THRESH_HOLD[i-1]-power)/(GEAR_HUD_POWER_THRESH_HOLD[i-1]-GEAR_HUD_POWER_THRESH_HOLD[i]);
				local alpha = GEAR_HUD_POWER_ALPHA[i-1][1] + (GEAR_HUD_POWER_ALPHA[i-1][2]-GEAR_HUD_POWER_ALPHA[i-1][1])*factor;
				GearHudPower:SetAlpha(alpha);
			end
			break;
		end
		if(i==5) then
			GearHudPower:Hide();
		end
	end
end

function GearHudPowerIndicator_OnUpdate(self, arg1)
	self.timer = self.timer - arg1;
	if(self.timer <= 0) then
		self:Hide();
	elseif (self.timer <= GEARHUDPOWER_INDICATOR_FADETIME) then
		self:SetAlpha( self.timer/GEARHUDPOWER_INDICATOR_FADETIME );
	end
end

function GearHudPower_BuildDrag()
	GearHudPower:EnableMouse(false);
	GearHudPower:SetScript("OnMouseDown", function() GearHudPower:StartMoving() end);
	GearHudPower:SetScript("OnMouseUp", function() GearHudPower:StopMovingOrSizing() end);
	
	GearHudPower.tex = GearHudPower.tex or GearHudPower:CreateTexture("$parent_T_Green", "OVERLAY");
	GearHudPower.tex:SetTexture(0, 0.6, 0, 0.5);
	GearHudPower.tex:SetAllPoints(GearHudPower);
	GearHudPower.tex:Hide();
	
	GearHudPower.Background = GearHudPower.tex;
end

function GearHudPower_Lock()
	GearHudPower:EnableMouse(false);
	if GearHudPower.tex then
		GearHudPower.tex:Hide();
		GearHudPower.resizeButton:Hide();
	end
	GearHudPower_Update();
	GearHudPowerIndicator:Show();
end

function GearHudPower_UnLock()
	GearHudPower:EnableMouse(true);
	GearHudPower:Show();
	GearHudPower.tex:Show();
	GearHudPower.resizeButton:Show();
	GearHudPower_Update();
end

SLASH_GEARHUDPOWER1 = "/gearhudpower";
SLASH_GEARHUDPOWER2 = "/ghp";
SlashCmdList["GEARHUDPOWER"] = function(msg)
	if(msg and strlower(msg)=="reset") then
		GearHudPower_Reset();
		GearHudPower_UnLock();
	else
		if(GearHudPower.tex:IsVisible()) then
			GearHudPower_Lock();
		else
			GearHudPower_UnLock();
		end		
	end
end
