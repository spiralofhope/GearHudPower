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

--血量阀值, 血量处于在两个值之间时显示对应材质, 
--血量高于第一个值则不显示, 如果第一个值为100则一直显示,
--血量低于最后一个值也不显示, 如果希望死亡也有骷髅, 请设置为-1
GearHudPower_threshhold = { 75, 50, 25, 10, 5 };

--距离屏幕中心的偏移位置
-- {x, y}
-- A larger x moves to the right
-- A larger y moves up
GearHudPower_offset = { 0, 40 };

-- This is good for a scale of 1.5
-- GearHudPower_offset = {0, 40};

--挨打提示的停留时间
GearHudPower_indicator_showtime = 0.3
--挨打提示的渐隐时间
GearHudPower_indicator_fadetime = 0.2

GearHudPower_scale = 1.5

--四个材质根据血量比例的透明度范围, 该属性一般不用修改.
GearHudPower_ALPHA = { 
	{ 1.00, 1.00 },
	{ 1.00, 1.00 },
	{ 1.00, 1.00 },
	{ 0.75, 0.75 },
};

------------------------------- 以下为常量, 请勿修改 -----------------------
GearHudPower_center_size=148;
--{ 齿轮左上角X坐标, Y坐标, 增加的宽度, 增加的高度 }
GearHudPower_TEX_POS = {
	{  12,   5,   5,  5 },
	{ 215,   6,  30, 10 },
	{ 254, 164, 100, 10 },
	{ 174, 341, 170, 25 },
}

GearHudPowerSettings = {
	x = GearHudPower_offset[1],
	y = GearHudPower_offset[2],
	scale = GearHudPower_scale,
}

function GearHudPower_OnLoad(self)
	self:RegisterEvent( "PLAYER_ENTERING_WORLD" );
	self:RegisterEvent( "UNIT_POWER" );
	self:RegisterEvent( "UNIT_MAXPOWER" );
	self:RegisterEvent( "UNIT_COMBAT" );
	self:RegisterEvent( "VARIABLES_LOADED" );
	GearHudPower_Reset();
	GearHudPowerTexture2:SetTexCoord(
		( GearHudPower_TEX_POS[1][1] - GearHudPower_TEX_POS[2][3]                            ) / 512,
		( GearHudPower_TEX_POS[1][1] + GearHudPower_TEX_POS[2][3] + GearHudPower_center_size ) / 512,
		( GearHudPower_TEX_POS[1][2] - GearHudPower_TEX_POS[2][4]                            ) / 512, 
		( GearHudPower_TEX_POS[1][2] + GearHudPower_TEX_POS[2][4] + GearHudPower_center_size ) / 512
	)
end

function GearHudPower_UpdateScale()
	GearHudPower:SetScale( GearHudPowerSettings.scale );
	if( GearHudPowerIndicator ) then GearHudPowerIndicator:SetScale( GearHudPowerSettings.scale ); end
	if( GearHudPowerIndicator ) then GearHudPowerIndicator:Show(); end
end

function GearHudPower_Reset()
	GearHudPowerSettings.scale = GearHudPower_scale;
	GearHudPower:ClearAllPoints();
	GearHudPower:SetPoint( "CENTER", UIParent, "CENTER", GearHudPowerSettings.x, GearHudPowerSettings.y );
	GearHudPower_UpdateScale();
end

function GearHudPower_OnEvent( event, arg1, arg2 )
	if( event=="VARIABLES_LOADED" ) then
		GearHudPower_BuildDrag();
		GearHudPower_UpdateScale();
		GearHudPower_Lock();
	elseif( ( event=="UNIT_POWER" or event=="UNIT_MAXPOWER" ) and arg1=="player" ) then
		GearHudPower_Update();
  -- TODO:  I'm not sure about this bit.  Wounding doesn't make sense.
	--elseif( event=="UNIT_COMBAT" and arg1=="player" and arg2=="WOUND" ) then
  -- Ok, so let's just flash it if something interesting happens with mana.
	elseif( event=="UNIT_MAXPOWER" and arg1=="player" ) then
		GearHudPowerIndicator:Show();
		GearHudPowerIndicator.timer = GearHudPower_indicator_showtime + GearHudPower_indicator_fadetime; 
		GearHudPowerIndicator:SetAlpha( 1.0 );
	end
end

function GearHudPower_Update(power)
	if( not power ) then power = UnitPower( "player" ) / UnitPowerMax( "player" ) * 100; end
	if( UnitIsDead( "player" ) or UnitIsGhost( "player" ) ) then power = 0; end
	if( GearHudPower.tex and GearHudPower.tex:IsVisible() ) then power = 1 end;
	for i=1, table.getn( GearHudPower_threshhold ) do
		if( power>GearHudPower_threshhold[i] ) then
			if(i==3) then
				GearHudPowerTexture2:Show();
			else
				GearHudPowerTexture2:Hide();
			end
			if( i==1 ) then
				GearHudPower:Hide();
			else
				GearHudPower:Show();
				GearHudPower:SetWidth(GearHudPower_center_size + GearHudPower_TEX_POS[i-1][3] * 2);
				GearHudPower:SetHeight(GearHudPower_center_size + GearHudPower_TEX_POS[i-1][4] * 2);
				GearHudPowerTexture:SetTexCoord(
					( GearHudPower_TEX_POS[i-1][1] - GearHudPower_TEX_POS[i-1][3]                            ) / 512,
					( GearHudPower_TEX_POS[i-1][1] + GearHudPower_TEX_POS[i-1][3] + GearHudPower_center_size ) / 512,
					( GearHudPower_TEX_POS[i-1][2] - GearHudPower_TEX_POS[i-1][4]                            ) / 512, 
					( GearHudPower_TEX_POS[i-1][2] + GearHudPower_TEX_POS[i-1][4] + GearHudPower_center_size ) / 512
				)
				local factor = ( GearHudPower_threshhold[i-1]-power ) / ( GearHudPower_threshhold[i-1]-GearHudPower_threshhold[i] );
				local alpha = GearHudPower_ALPHA[i-1][1] + ( GearHudPower_ALPHA[i-1][2] - GearHudPower_ALPHA[i-1][1] ) * factor;
				GearHudPower:SetAlpha(alpha);
			end
			break;
		end
		if( i==5 ) then
			GearHudPower:Hide();
		end
	end
end

function GearHudPowerIndicator_OnUpdate( self, arg1 )
	self.timer = self.timer - arg1;
	if( self.timer <= 0 ) then
		self:Hide();
	elseif ( self.timer <= GearHudPower_indicator_fadetime ) then
		self:SetAlpha( self.timer / GearHudPower_indicator_fadetime );
	end
end

function GearHudPower_BuildDrag()
	GearHudPower:EnableMouse( false );
	GearHudPower:SetScript( "OnMouseDown", function() GearHudPower:StartMoving()        end );
	GearHudPower:SetScript( "OnMouseUp",   function() GearHudPower:StopMovingOrSizing() end );
	
	GearHudPower.tex = GearHudPower.tex or GearHudPower:CreateTexture( "$parent_T_Green", "OVERLAY" );
	GearHudPower.tex:SetTexture( 0, 0.6, 0, 0.5 );
	GearHudPower.tex:SetAllPoints( GearHudPower );
	GearHudPower.tex:Hide();
	
	GearHudPower.Background = GearHudPower.tex;
end

function GearHudPower_Lock()
	GearHudPower:EnableMouse( false );
	if GearHudPower.tex then
		GearHudPower.tex:Hide();
		GearHudPower.resizeButton:Hide();
	end
	GearHudPower_Update();
	GearHudPowerIndicator:Show();
end

function GearHudPower_UnLock()
	GearHudPower:EnableMouse( true );
	GearHudPower:Show();
	GearHudPower.tex:Show();
	GearHudPower.resizeButton:Show();
	GearHudPower_Update();
end

SLASH_GearHudPower1 = "/gearhudpower";
SLASH_GearHudPower2 = "/ghp";
SlashCmdList["GearHudPower"] = function( msg )
	if( msg and strlower( msg )=="reset" ) then
		GearHudPower_Reset();
		GearHudPower_UnLock();
	else
		if( GearHudPower.tex:IsVisible() ) then
			GearHudPower_Lock();
		else
			GearHudPower_UnLock();
		end		
	end
end
