local GlobalAddonName, MRT = ...

MRT.Options = {}

local ELib,L = MRT.lib,MRT.L


local OptionsFrameName = "MRTOptionsFrame"
local Options = ELib:Template("ExRTBWInterfaceFrame",UIParent)
_G[OptionsFrameName] = Options

MRT.Options.Frame = Options

Options.Width = 863
Options.Height = 650
Options.ListWidth = 165

Options:Hide()
Options:SetPoint("CENTER",0,0)
Options:SetSize(Options.Width,Options.Height)
Options.HeaderText:SetText("")
Options:SetMovable(true)
Options:RegisterForDrag("LeftButton")
Options:SetScript("OnDragStart", function(self) self:StartMoving() end)
Options:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
Options:SetDontSavePosition(true)
-- CoA: avoid shadow layers that render as stray colored texture fragments
-- on the customized 3.3.5a client. Keep the functional main frame intact.
-- Options.border = MRT.lib.CreateShadow(Options,20)
-- ELib:ShadowInside(Options)

-- Use explicit text controls rather than texture-atlas glyphs for critical actions.
-- Original button objects and their OnClick handlers remain unchanged.
local function CoAControlLabel(button, label, tip)
    if not button then return end
    if button.NormalTexture then button.NormalTexture:Hide() end
    if button.HighlightTexture then button.HighlightTexture:Hide() end
    if button.PushedTexture then button.PushedTexture:Hide() end
    if button.DisabledTexture then button.DisabledTexture:Hide() end
    button:SetSize(23,22)
    button:SetFrameLevel(Options:GetFrameLevel()+12)
    local text = button:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    text:SetPoint("CENTER",0,0)
    text:SetText(label)
    text:SetTextColor(1,0.85,0.28)
    button.CoALabel=text
    button:EnableMouse(true)
    button:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_BOTTOM")
        GameTooltip:SetText(tip)
        GameTooltip:Show()
        text:SetTextColor(1,1,1)
    end)
    button:SetScript("OnLeave",function()
        GameTooltip:Hide()
        text:SetTextColor(1,0.85,0.28)
    end)
end
CoAControlLabel(Options.buttonClose,"X","Close MRT")
CoAControlLabel(Options.backToInterface,"<","Return to interface options")
Options.buttonClose:ClearAllPoints()
Options.buttonClose:SetPoint("TOPRIGHT",Options,"TOPRIGHT",-5,-2)
Options.backToInterface:ClearAllPoints()
Options.backToInterface:SetPoint("TOPRIGHT",Options.buttonClose,"TOPLEFT",-4,0)

Options.bossButton:Hide()
Options.backToInterface:SetScript("OnClick",function ()
	MRT.Options.Frame:Hide()
	if SettingsPanel then
		SettingsPanel:Show()
	else
		InterfaceOptionsFrame:Show()
	end
end)


Options.modulesList = ELib:ScrollList(Options):LineHeight(24):Size(Options.ListWidth - 1,Options.Height):Point(0,0):FontSize(11):HideBorders()
Options.modulesList.SCROLL_WIDTH = 10
Options.modulesList.LINE_PADDING_LEFT = 7
Options.modulesList.LINE_TEXTURE = "Interface\\Addons\\"..GlobalAddonName.."\\media\\White"
Options.modulesList.LINE_TEXTURE_IGNOREBLEND = true
Options.modulesList.LINE_TEXTURE_HEIGHT = 24
Options.modulesList.LINE_TEXTURE_COLOR_HL = {1,1,1,.5}
Options.modulesList.LINE_TEXTURE_COLOR_P = {1,.82,0,.6}
Options.modulesList.EnableHoverAnimation = true

Options.modulesList.border_right = ELib:Texture(Options.modulesList,.24,.25,.30,1,"BORDER"):Point("TOPLEFT",Options.modulesList,"TOPRIGHT",0,0):Point("BOTTOMRIGHT",Options.modulesList,"BOTTOMRIGHT",1,0)

Options.modulesList.Frame.ScrollBar:Size(8,0):Point("TOPRIGHT",0,0):Point("BOTTOMRIGHT",0,0)
Options.modulesList.Frame.ScrollBar.thumb:SetHeight(100)
Options.modulesList.Frame.ScrollBar.buttonUP:Hide()
Options.modulesList.Frame.ScrollBar.buttonDown:Hide()

Options.modulesList.Frame.ScrollBar.border_right = ELib:Texture(Options.modulesList.Frame.ScrollBar,.24,.25,.30,1,"BORDER"):Point("TOPLEFT",Options.modulesList.Frame.ScrollBar,"TOPLEFT",-1,0):Point("BOTTOMRIGHT",Options.modulesList.Frame.ScrollBar,"BOTTOMLEFT",0,0)

Options.Frames = {}

Options:SetScript("OnShow",function(self)
	self.modulesList:Update()
	if Options.CurrentFrame and Options.CurrentFrame.AdditionalOnShow then
		Options.CurrentFrame:AdditionalOnShow()
	end

	if type(Options.CurrentFrame.OnShow) == 'function' then
		Options.CurrentFrame:OnShow()
	end
end)

function Options:SetPage(page,dontreload)
	local isSamePage = Options.CurrentFrame == page
	if Options.CurrentFrame and (not dontreload or not isSamePage) then
		Options.CurrentFrame:Hide()
	end
	Options.CurrentFrame = page

	if Options.CurrentFrame.AdditionalOnShow and (not dontreload or not isSamePage) then
		Options.CurrentFrame:AdditionalOnShow()
	end

	if (not dontreload or not isSamePage) then
		Options.CurrentFrame:Show()
	end

	local function RepinTopLeft(setWidthTo)
		local left, top = Options:GetLeft(), Options:GetTop()
		Options:SetWidth(setWidthTo)
		if left and top then
			Options:ClearAllPoints()
			Options:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		end
	end

	if Options.CurrentFrame.isWide and Options.nowWide ~= Options.CurrentFrame.isWide then
		local frameWidth = type(Options.CurrentFrame.isWide)=='number' and Options.CurrentFrame.isWide or 850
		RepinTopLeft(frameWidth+Options.ListWidth)
		Options.nowWide = Options.CurrentFrame.isWide
	elseif not Options.CurrentFrame.isWide and Options.nowWide then
		RepinTopLeft(Options.Width)
		Options.nowWide = nil
	end

	if Options.CurrentFrame.isWide then
		Options.CurrentFrame:SetWidth(type(Options.CurrentFrame.isWide)=='number' and Options.CurrentFrame.isWide or 850)
		Options.CurrentFrame._wasWide = true
	elseif Options.CurrentFrame._wasWide then
		Options.CurrentFrame:SetWidth(Options.Width-Options.ListWidth)
		Options.CurrentFrame._wasWide = nil
	end

	if type(Options.CurrentFrame.OnShow) == 'function' then
		Options.CurrentFrame:OnShow()
	end
end


function Options.modulesList:SetListValue(index)
	Options:SetPage(Options.Frames[index])
end


function MRT.Options:Add(moduleName,frameName,isHidden)
	local self = CreateFrame("Frame",OptionsFrameName..moduleName,Options)
	self:SetSize(Options.Width-Options.ListWidth,Options.Height-16)
	self:SetPoint("TOPLEFT",Options.ListWidth,-16)
	self.moduleName = moduleName

	if not isHidden then
		local pos = #Options.Frames + 1
		Options.modulesList.L[pos] = frameName or moduleName
		Options.Frames[pos] = self

		if Options:IsShown() then
			Options.modulesList:Update()
		end
	end

	self:Hide()

	return self
end

function MRT.Options:AddIcon(moduleName,icon)
	Options.modulesList.IconsRight = Options.modulesList.IconsRight or {}
	for i=1,#Options.Frames do
		if Options.Frames[i].moduleName == moduleName then
			Options.modulesList.IconsRight[i] = icon
			break
		end
	end
	if Options:IsShown() then
		Options.modulesList:Update()
	end
end
function MRT.Options:RemoveIcon(moduleName)
	if not Options.modulesList.IconsRight then
		return
	end
	for i=1,#Options.Frames do
		if Options.Frames[i].moduleName == moduleName then
			Options.modulesList.IconsRight[i] = nil
			break
		end
	end
	if Options:IsShown() then
		Options.modulesList:Update()
	end
end


-- MRT-CoA: register spellbook controls directly with the main options list.
-- This is intentionally in Options.lua, not a late-loaded standalone panel.
do
 local page = MRT.Options:Add("CoASpellbook", "|cff33ff99CoA Spellbook|r")
 local title = page:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
 title:SetPoint("TOPLEFT",page,"TOPLEFT",24,-30)
 title:SetText("Conquest Reborn Spellbook")
 local info = page:CreateFontString(nil,"OVERLAY","GameFontNormal")
 info:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-20)
 info:SetWidth(580)
 info:SetJustifyH("LEFT")
 info:SetText("Scan your learned spells for the current class and specialization. Spell IDs are read from the game client; cooldown values are observations, not verified base cooldowns.")
 local status = page:CreateFontString(nil,"OVERLAY","GameFontHighlight")
 status:SetPoint("TOPLEFT",info,"BOTTOMLEFT",0,-75)
 status:SetWidth(600)
 status:SetJustifyH("LEFT")
 status:SetText("Ready to scan")
 local summary = page:CreateFontString(nil,"OVERLAY","GameFontHighlight")
 summary:SetPoint("TOPLEFT",status,"BOTTOMLEFT",0,-20)
 summary:SetWidth(600)
 summary:SetJustifyH("LEFT")
 local function refresh()
  local db=_G.MRTCoASpells
  local key=(UnitName("player") or "Unknown").."-"..(GetRealmName() or "Unknown")
  local char=db and db.characters and db.characters[key]
  local specs,spells=0,0
  if char and char.specs then
   for _,entry in pairs(char.specs) do
    specs=specs+1
    if entry.spells then spells=spells+#entry.spells end
   end
  end
  summary:SetText("Saved: "..specs.." specialization(s), "..spells.." learned spells")
 end
 local scan=CreateFrame("Button",nil,page,"UIPanelButtonTemplate")
 scan:SetSize(180,28)
 scan:SetPoint("TOPLEFT",info,"BOTTOMLEFT",0,-25)
 scan:SetText("Scan My Spellbook")
 scan:SetScript("OnClick",function()
  -- Built-in scan: no dependency on slash commands or external scanner registration.
  local function directScan()
   local className,classToken=UnitClass("player")
   local specID=0
   if C_CharacterAdvancement and type(C_CharacterAdvancement.GetActiveChrSpec)=="function" then
    local success,value=pcall(C_CharacterAdvancement.GetActiveChrSpec)
    if success and type(value)=="number" then specID=value end
   end
   local spells,seen={},{}
   local scanned,named,ids=0,0,0
   local book=BOOKTYPE_SPELL or "spell"
   local function addSpell(i)
    scanned=scanned+1
    local name,rank,spellID,icon
    if GetSpellName then
     local ok,n,r=pcall(GetSpellName,i,book)
     if ok then name,rank=n,r end
    end
    if GetSpellBookItemInfo then
     local ok,kind,id=pcall(GetSpellBookItemInfo,i,book)
     if ok and type(id)=="number" and id>0 then spellID=id end
    end
    if GetSpellLink then
     local ok,link=pcall(GetSpellLink,i,book)
     if ok and type(link)=="string" then spellID=tonumber(link:match("spell:(%d+)")) or spellID end
    end
    if not name and spellID and GetSpellInfo then name=GetSpellInfo(spellID) end
    if type(name)=="string" and name~="" then
     named=named+1
     if GetSpellInfo then
      local _,_,tex=GetSpellInfo(spellID or name)
      icon=tex
     end
     if not icon and GetSpellTexture then
      local ok,tex=pcall(GetSpellTexture,i,book)
      if ok then icon=tex end
     end
     if spellID then ids=ids+1 end
     local key=spellID and tostring(spellID) or (name..":"..tostring(rank or ""))
     if not seen[key] then
      seen[key]=true
      spells[#spells+1]={id=spellID,name=name,rank=rank,icon=icon,spellbookIndex=i}
     end
    end
   end
   local numTabs=GetNumSpellTabs and GetNumSpellTabs() or 0
   local tabSlots=0
   if GetSpellTabInfo then
    for tab=1,numTabs do
     local ok,_,_,offset,count=pcall(GetSpellTabInfo,tab)
     if ok and type(offset)=="number" and type(count)=="number" then
      for i=offset+1,math.min(offset+count,offset+1000) do
       tabSlots=tabSlots+1
       addSpell(i)
      end
     end
    end
   end
   -- The modified client may return zero/invalid tabs, or expose entries outside them.
   -- Always probe actual spellbook slots if the tab pass found no named spells.
   local probed=0
   if #spells==0 then
    local lastFound=0
    for i=1,800 do
     local n,link,kind,id
     if GetSpellName then
      local ok,v=pcall(GetSpellName,i,book)
      if ok then n=v end
     end
     if GetSpellLink then
      local ok,v=pcall(GetSpellLink,i,book)
      if ok then link=v end
     end
     if GetSpellBookItemInfo then
      local ok,k,v=pcall(GetSpellBookItemInfo,i,book)
      if ok then kind,id=k,v end
     end
     if n or link or (type(id)=="number" and id>0) then
      lastFound=i
      addSpell(i)
     end
     probed=i
     if i>100 and i-lastFound>100 then break end
    end
   end
   table.sort(spells,function(a,b) return a.name<b.name end)
   MRTCoASpells=MRTCoASpells or {version=1,characters={}}
   MRTCoASpells.characters=MRTCoASpells.characters or {}
   local key=(UnitName("player") or "Unknown").."-"..(GetRealmName() or "Unknown")
   local character=MRTCoASpells.characters[key] or {specs={}}
   character.specs=character.specs or {}
   character.className=className
   character.familyToken=classToken
   character.lastSpec=specID
   -- Never replace previously collected spells with an empty scan.
   if #spells>0 then
    character.specs[tostring(specID)]={specID=specID,familyToken=classToken,spells=spells}
   end
   MRTCoASpells.characters[key]=character
   return {spells=spells,tabs=numTabs,scanned=scanned,named=named,ids=ids,tabSlots=tabSlots,probed=probed,hasName=GetSpellName~=nil,hasInfo=GetSpellBookItemInfo~=nil,hasLink=GetSpellLink~=nil}
  end
  local ok,result=pcall(directScan)
  if not ok then status:SetText("Scan failed: "..tostring(result))
  else
   status:SetText("Scan: "..#result.spells.." spells; "..result.scanned.." reads, "..result.tabs.." tabs, "..result.ids.." IDs")
   if #result.spells==0 then
    local report="MRT-CoA spellbook diagnostics: tabs="..result.tabs..", tabSlots="..result.tabSlots..", probed="..result.probed..", GetSpellName="..tostring(result.hasName)..", GetSpellBookItemInfo="..tostring(result.hasInfo)..", GetSpellLink="..tostring(result.hasLink)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(report) end
    status:SetText("0 spells: diagnostics printed to chat; existing saved data preserved")
   end
  end
  refresh()
 end)
 local refreshButton=CreateFrame("Button",nil,page,"UIPanelButtonTemplate")
 refreshButton:SetSize(145,28)
 refreshButton:SetPoint("LEFT",scan,"RIGHT",14,0)
 refreshButton:SetText("Refresh Saved Data")
 refreshButton:SetScript("OnClick",refresh)
 page:SetScript("OnShow",refresh)
end

local OptionsFrame = MRT.Options:Add("Method Raid Tools","|cffffa800Method Raid Tools|r")
Options.modulesList:SetListValue(1)
Options.modulesList.selected = 1
Options.modulesList:Update()


MRT.Options.InBlizzardInterface = CreateFrame( "Frame", nil )
MRT.Options.InBlizzardInterface.name = "Method Raid Tools"
if SettingsPanel then
	local category = Settings.RegisterCanvasLayoutCategory(MRT.Options.InBlizzardInterface, "Method Raid Tools")
	Settings.RegisterAddOnCategory(category)
else
	InterfaceOptions_AddCategory(MRT.Options.InBlizzardInterface)
end
MRT.Options.InBlizzardInterface:Hide()

MRT.Options.InBlizzardInterface:SetScript("OnShow",function (self)
	if SettingsPanel then
		if SettingsPanel:IsShown() then
			HideUIPanel(SettingsPanel)
		end
	else
		if InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Hide()
		end
	end
	MRT.Options:Open()
	self:SetScript("OnShow",nil)
end)

MRT.Options.InBlizzardInterface.button = ELib:Button(MRT.Options.InBlizzardInterface,"Method Raid Tools",0):Size(400,25):Point("TOP",0,-100):OnClick(function ()
	if SettingsPanel then
		if SettingsPanel:IsShown() then
			HideUIPanel(SettingsPanel)
		end
	else
		if InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Hide()
		end
	end
	MRT.Options:Open()
end)


Options.scale = ELib:Slider(Options):_Size(70,8):Point("TOPRIGHT",-45,-5):Range(50,200,true):OnShow(function(self)
	VMRT.Addon.Scale = tonumber(VMRT.Addon.Scale or "1") or 1
	VMRT.Addon.Scale = max( min( VMRT.Addon.Scale,2 ),0.5)

	self:SetTo((VMRT.Addon.Scale or 1)*100):Scale(1 / (VMRT.Addon.Scale or 1)):OnChange(function(self,event)
		if self.disable then
			self:SetTo(100)
			self.tooltipText = L.bossmodsscale.."|n100%|n"..L.SetScaleReset
			return
		end
		event = MRT.F.Round(event)
		VMRT.Addon.Scale = event / 100
		MRT.F.SetScaleFixTR(Options,VMRT.Addon.Scale)
		self:SetScale(1 / VMRT.Addon.Scale)
		self.tooltipText = L.bossmodsscale.."|n"..event.."%|n"..L.SetScaleReset
		self:tooltipReload(self)
		if MRT and MRT.F and MRT.F.AddonScaleBroadcast then
			MRT.F.AddonScaleBroadcast(VMRT.Addon.Scale)
		end
	end)
	self:SetScript("OnShow",nil)
	self.tooltipText = L.bossmodsscale.."|n"..((VMRT.Addon.Scale or 1) * 100).."%|n"..L.SetScaleReset
	self:Point("TOPRIGHT",-45 * (VMRT.Addon.Scale or 1),-5)
	Options:SetScale(VMRT.Addon.Scale or 1)
end,true)

Options.scale:SetScript("OnMouseDown",function(self,button)
	if button == "RightButton" then
		self:SetTo(100)
		self.disable = true
	end
end)
Options.scale:SetScript("OnMouseUp",function(self,button)
	if button == "RightButton" then
		self.disable = nil
	end
	self:Point("TOPRIGHT",-45 * (VMRT.Addon.Scale or 1),-5)
end)

if Options.scale and Options.scale.SetHitRectInsets then
	Options.scale:SetHitRectInsets(-10, -10, -10, -10)
end
if Options.scale then
	Options.scale:HookScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then self.__mrt_dragging = true end
	end)
	Options.scale:HookScript("OnMouseUp", function(self)
		self.__mrt_dragging = nil
	end)
	Options.scale:SetScript("OnLeave", function(self)
		if self.__mrt_dragging and not IsMouseButtonDown("LeftButton") then
			self.__mrt_dragging = nil
		end
	end)
end


local MiniMapIcon = CreateFrame("Button", "LibDBIcon10_MethodRaidTools", Minimap)
MRT.MiniMapIcon = MiniMapIcon
MiniMapIcon:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
MiniMapIcon:SetSize(32,32)
MiniMapIcon:SetFrameStrata("MEDIUM")
MiniMapIcon:SetFrameLevel(8)
MiniMapIcon:SetPoint("CENTER", -12, -80)
MiniMapIcon:SetDontSavePosition(true)
MiniMapIcon:RegisterForDrag("LeftButton")
MiniMapIcon.icon = MiniMapIcon:CreateTexture(nil, "BACKGROUND")
MiniMapIcon.icon:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap")
MiniMapIcon.icon:SetSize(18,18)
MiniMapIcon.icon:SetPoint("CENTER",0,1)
MiniMapIcon.iconMini = MiniMapIcon:CreateTexture(nil, "BACKGROUND")
MiniMapIcon.iconMini:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap")
MiniMapIcon.iconMini:SetSize(18,18)
MiniMapIcon.iconMini:SetPoint("CENTER", 0, 1)
MiniMapIcon.iconMini:SetVertexColor(1,.5,.5,1)
MiniMapIcon.iconMini:Hide()
MiniMapIcon.border = MiniMapIcon:CreateTexture(nil, "ARTWORK")
MiniMapIcon.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
MiniMapIcon.border:SetTexCoord(0,0.6,0,0.6)
MiniMapIcon.border:SetAllPoints()
MiniMapIcon:RegisterForClicks("anyUp")
MiniMapIcon:SetScript("OnEnter",function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("Method Raid Tools")
	GameTooltip:AddLine(L.minimaptooltiplmp,1,1,1)
	GameTooltip:AddLine(L.minimaptooltiprmp,1,1,1)
	GameTooltip:Show()
	self.anim:Play()
	self.iconMini:Show()
end)
MiniMapIcon:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
	self.anim:Stop()
	self.iconMini:Hide()
end)
if not MRT.isClassic then
	MiniMapIcon.icon:SetSize(20,20)
	MiniMapIcon.iconMini:SetSize(20,20)
	MiniMapIcon.icon:SetPoint("CENTER",1,0)
	MiniMapIcon.iconMini:SetPoint("CENTER", 1, 0)
end


MiniMapIcon.anim = MiniMapIcon:CreateAnimationGroup()
MiniMapIcon.anim:SetLooping("BOUNCE")
MiniMapIcon.timer = MiniMapIcon.anim:CreateAnimation()
MiniMapIcon.timer:SetDuration(2)
MiniMapIcon.timer:SetScript("OnUpdate", function(self,elapsed)
	MiniMapIcon.iconMini:SetAlpha(self:GetProgress())
end)

local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {false, true, false, true},
	["SIDE-RIGHT"] = {true, false, true, false},
	["SIDE-TOP"] = {false, false, true, true},
	["SIDE-BOTTOM"] = {true, true, false, false},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function IconMoveButton(self)
	if self.dragMode == "free" then
		local centerX, centerY = Minimap:GetCenter()
		local x, y = GetCursorPosition()
		x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
		self:ClearAllPoints()
		self:SetPoint("CENTER", x, y)
		VMRT.Addon.IconMiniMapLeft = x
		VMRT.Addon.IconMiniMapTop = y
	else
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale

		local angle = math.atan2(py - my, px - mx)
		local x, y, q = math.cos(angle), math.sin(angle), 1
		if x < 0 then q = q + 1 end
		if y > 0 then q = q + 2 end
		local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
		local quadTable = minimapShapes[minimapShape]
		local w = (Minimap:GetWidth() / 2) + 5
		local h = (Minimap:GetHeight() / 2) + 5
		if quadTable[q] then
			x, y = x*w, y*h
		else
			local diagRadiusW = sqrt(2*(w)^2)-10
			local diagRadiusH = sqrt(2*(h)^2)-10
			x = max(-w, min(x*diagRadiusW, w))
			y = max(-h, min(y*diagRadiusH, h))
		end
		self:ClearAllPoints()
		self:SetPoint("CENTER", Minimap, "CENTER", x, y)
		VMRT.Addon.IconMiniMapLeft = x
		VMRT.Addon.IconMiniMapTop = y
	end
end

MiniMapIcon:SetScript("OnDragStart", function(self)
	self:LockHighlight()
	self:SetScript("OnUpdate", IconMoveButton)
	self.isMoving = true
	GameTooltip:Hide()
end)
MiniMapIcon:SetScript("OnDragStop", function(self)
	self:UnlockHighlight()
	self:SetScript("OnUpdate", nil)
	self.isMoving = false
end)

local function MiniMapIconOnClick(self, button)
	if button == "RightButton" then
		for _,func in pairs(MRT.MiniMapMenu) do
			func:miniMapMenu()
		end
		MRT.Options:UpdateModulesList()

		ELib.ScrollDropDown.EasyMenu(self,MRT.F.menuTable,150)
	elseif button == "LeftButton" then
		MRT.Options:Open()
	end
end

MRT_MinimapClickFunction = function()
	MRT.Options:Open()
end

MiniMapIcon:SetScript("OnMouseUp", MiniMapIconOnClick)

MRT.Options.MiniMapDropdown = CreateFrame("Frame", "MRTMiniMapMenuFrame", nil, "UIDropDownMenuTemplate")

local MinimapMenu_UIDs = {}
local MinimapMenu_UIDnumeric = 0
local MinimapMenu_Level = {3,4,5,5}

function MRT.F.MinimapMenuAdd(text, func, level, uid, subMenu)
	level = level or 2
	if not uid then
		MinimapMenu_UIDnumeric = MinimapMenu_UIDnumeric + 1
		uid = MinimapMenu_UIDnumeric
	end
	if MinimapMenu_UIDs[uid] then
		return
	end
	local menuTable = { text = text, func = func, notCheckable = true, keepShownOnClick = true, }
	if subMenu then
		menuTable.hasArrow = true
		menuTable.menuList = subMenu
		menuTable.subMenu = subMenu
	end
	tinsert(MRT.F.menuTable,MinimapMenu_Level[level],menuTable)
	for i=level,#MinimapMenu_Level do
		MinimapMenu_Level[i] = MinimapMenu_Level[i] + 1
	end
	MinimapMenu_UIDs[uid] = menuTable
end

function MRT.F.MinimapMenuRemove(uid)
	for i=1,#MRT.F.menuTable do
		if MRT.F.menuTable[i] == MinimapMenu_UIDs[uid] then
			for j=i,#MRT.F.menuTable do
				MRT.F.menuTable[j] = MRT.F.menuTable[j+1]
			end
			for j=1,#MinimapMenu_Level do
				if i <= MinimapMenu_Level[j] then
					MinimapMenu_Level[j] = MinimapMenu_Level[j] - 1
				end
			end
			MinimapMenu_UIDs[uid] = nil
			return
		end
	end
end

function MRT.Options:Open(PANEL)
	CloseDropDownMenus()
	ELib.ScrollDropDown.Close()
	Options:Show()

	Options:SetPage(PANEL or Options.Frames[Options.modulesList.selected or 1])

	if PANEL then
		for i=1,#Options.Frames do
			if Options.Frames[i] == PANEL then
				Options.modulesList.selected = i
				Options.modulesList:Update()
				break
			end
		end
	end
end

function MRT.Options:OpenByModuleName(moduleName)
	for i=1,#Options.Frames do
		if Options.Frames[i].moduleName == moduleName then
			Options:Show()

			Options:SetPage(Options.Frames[i])

			Options.modulesList.selected = i
			Options.modulesList:Update()
			return Options.Frames[i]
		end
	end
end

MRT.F.menuTable = {
{ text = L.minimapmenu, isTitle = true, notCheckable = true, notClickable = true },
{ text = L.minimapmenuset, func = MRT.Options.Open, notCheckable = true, keepShownOnClick = true, },
{ text = " ", isTitle = true, notCheckable = true, notClickable = true },
{ text = " ", isTitle = true, notCheckable = true, notClickable = true },
{ text = "Profiling", func = function() CloseDropDownMenus() ELib.ScrollDropDown.Close() MRT.F:ProfilingWindow() end, notCheckable = true },
{ text = " ", isTitle = true, notCheckable = true, notClickable = true },
{ text = L.minimapmenuclose, func = function() CloseDropDownMenus() ELib.ScrollDropDown.Close() end, notCheckable = true },
}

if MRT.Dev == true then
	tinsert(MRT.F.menuTable, { text = "Reload UI", func = function() ReloadUI() end, notCheckable = true })
end

local modulesActive = {}
function MRT.Options:UpdateModulesList()
	for i=1,#MRT.ModulesOptions do
		MRT.F.MinimapMenuAdd(MRT.ModulesOptions[i].name, function()
			MRT.Options:Open(MRT.ModulesOptions[i])
		end, 2,MRT.ModulesOptions[i].name)
	end
end


local OptionsFrame_title, OptionsFrame_image

OptionsFrame_image = OptionsFrame:CreateTexture(nil,"ARTWORK")

local p = {[0] = OptionsFrame_image[0]}
setmetatable(p,getmetatable(OptionsFrame_image))
OptionsFrame_image[0] = nil
OptionsFrame_image = p

OptionsFrame_image:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\OptionLogo2")
OptionsFrame_image:SetPoint("TOPLEFT",15,5)
OptionsFrame_image:SetSize(140,140)
OptionsFrame_image.Point = OptionsFrame_image.SetPoint


OptionsFrame_title = ELib:Texture(OptionsFrame,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\logoname2"):Point("LEFT",OptionsFrame_image,"RIGHT",15,-5):Size(512*0.7,128*0.7)


OptionsFrame.chkIconMiniMap = ELib:Check(OptionsFrame,L.setminimap1):Point(25,-155):OnClick(function(self)
	if self:GetChecked() then
		VMRT.Addon.IconMiniMapHide = true
		MRT.MiniMapIcon:Hide()
	else
		VMRT.Addon.IconMiniMapHide = nil
		MRT.MiniMapIcon:Show()
	end
end)
OptionsFrame.chkIconMiniMap:SetScript("OnShow", function(self,event)
	self:SetChecked(VMRT.Addon.IconMiniMapHide)
end)

OptionsFrame.chkHideOnEsc = ELib:Check(OptionsFrame,L.SetHideOnESC):Point(350,-155):OnClick(function(self)
	if self:GetChecked() then
		VMRT.Addon.DisableHideESC = true
		for i=1,#UISpecialFrames do
			if UISpecialFrames[i] == "MRTOptionsFrame" then
				tremove(UISpecialFrames, i)
				break
			end
		end
	else
		VMRT.Addon.DisableHideESC = nil
		tinsert(UISpecialFrames, "MRTOptionsFrame")
	end
end)
OptionsFrame.chkHideOnEsc:SetScript("OnShow", function(self,event)
	self:SetChecked(VMRT.Addon.DisableHideESC)
end)

OptionsFrame.authorLeft = ELib:Text(OptionsFrame,L.setauthor,12):Size(150,25):Point(15,-195):Shadow():Top()
OptionsFrame.authorRight = ELib:Text(OptionsFrame,"Uncle Bone (MRT-CoA maintainer)",12):Size(520,25):Point(135,-195):Color():Shadow():Top()

OptionsFrame.versionLeft = ELib:Text(OptionsFrame,L.setver,12):Size(150,25):Point(15,-215):Shadow():Top()
OptionsFrame.versionRight = ELib:Text(OptionsFrame,(MRT.VString or ("v"..tostring(MRT.V)))..(MRT.T == "R" and "" or " "..MRT.T),12):Size(520,25):Point(135,-215):Color():Shadow():Top()

OptionsFrame.contactLeft = ELib:Text(OptionsFrame,L.setcontact,12):Size(150,25):Point(15,-235):Shadow():Top()
OptionsFrame.contactRight = ExRT.F.LinkText(OptionsFrame,"github.com/downingwow/MRT-CoA","https://github.com/downingwow/MRT-CoA",12)
OptionsFrame.contactRight:SetPoint("TOPLEFT",OptionsFrame,"TOPLEFT",135,-231)

OptionsFrame.thanksLeft = ELib:Text(OptionsFrame,"Original contributors",12):Size(150,25):Point(15,-255):Shadow():Top()
OptionsFrame.thanksRight = ELib:Text(OptionsFrame,"Phanx, funkydude, Shurshik, Kemayo, Guillotine, Rabbit, fookah, diesal2010, Felix, yuk6196, martinkerth, Gyffes, Cubetrace, tigerlolol, Morana, SafeteeWoW, Dejablue, Wollie, eXochron, Firehead94, Mitalie, m33shoq",12):Size(540,0):Point(135,-255):Color():Shadow():Top()

if L.TranslateBy ~= "" then
	OptionsFrame.translateLeft = ELib:Text(OptionsFrame,L.SetTranslate,12):Size(150,25):Point("LEFT",OptionsFrame,15,0):Point("TOP",OptionsFrame.thanksRight,"BOTTOM",0,-8):Shadow():Top()
	OptionsFrame.translateRight = ELib:Text(OptionsFrame,L.TranslateBy,12):Size(520,25):Point("LEFT",OptionsFrame.thanksRight,"LEFT",0,0):Point("TOP",OptionsFrame.translateLeft,0,0):Color():Shadow():Top()
end

OptionsFrame.Changelog = ELib:ScrollFrame(OptionsFrame):Size(680,180):Point("TOP",0,-335):OnShow(function(self)
	local text = MRT.Options.Changelog or ""
	text = text:gsub("(v%.%d+([^\n]*).-\n\n)",function(a,b)
		if (b == "-Classic" and MRT.isClassic and not MRT.isBC) or (b == "-BC" and MRT.isBC and not MRT.isLK) or (b == "-LK" and MRT.isLK) then
			return a
		else
			return ""
		end
	end)
	local isFind
	text = text:gsub("^[ \t\n]*","|cff99ff99"):gsub("v%.(%d+)",function(ver)
		if not isFind and ver ~= tostring(MRT.V) then
			isFind = true
			return "|rv."..ver
		end
	end)
	if #text > 8192 then
		local lennow = 0
		local texts = {""}
		local c = 1
		for w in string.gmatch(text,"[^\n]+\n*") do
			lennow = lennow + #w
			if lennow > 8192 then
				c = c + 1
				texts[c] = ""
				lennow = #w
			end
			texts[c] = texts[c] .. w
		end
		for i=2,c do
			self["Text"..i] = ELib:Text(self.C,texts[i],12):Point("LEFT",3,0):Point("RIGHT",-3,0):Point("TOP",self["Text"..(i-1)] or self.Text,"BOTTOM",0,0):Left():Color(1,1,1)
		end
		text = texts[1]
	end
	self.Text:SetText(text)
	self:Height(self.Text:GetStringHeight()+50)
	self:OnShow(function()
		local height = 6 + self.Text:GetStringHeight()
		local c = 2
		while self["Text"..c] do
			height = height + self["Text"..c]:GetStringHeight()
			c = c + 1
		end
		self:Height(height)
		self:OnShow()
	end,true)
end,true)
ELib:Border(OptionsFrame.Changelog,0)

ELib:DecorationLine(OptionsFrame):Point("BOTTOM",OptionsFrame.Changelog,"TOP",0,0):Point("LEFT",OptionsFrame):Point("RIGHT",OptionsFrame):Size(0,1)
ELib:DecorationLine(OptionsFrame):Point("TOP",OptionsFrame.Changelog,"BOTTOM",0,0):Point("LEFT",OptionsFrame):Point("RIGHT",OptionsFrame):Size(0,1)

OptionsFrame.Changelog.Text = ELib:Text(OptionsFrame.Changelog.C,"",12):Point("TOPLEFT",3,-3):Point("TOPRIGHT",-3,-3):Left():Color(1,1,1)
OptionsFrame.Changelog.Header = ELib:Text(OptionsFrame.Changelog,"Changelog",12):Point("BOTTOMLEFT",OptionsFrame.Changelog,"TOPLEFT",0,2):Left()

local VersionCheckReqSended = {}
local function UpdateVersionCheck()
	OptionsFrame.VersionUpdateButton:Enable()
	local list = OptionsFrame.VersionCheck.L
	wipe(list)

	MRT.RaidVersions[UnitName("player")] = MRT.V

	for _, name, _, class in MRT.F.IterateRoster do
		list[#list + 1] = {
			"|c"..MRT.F.classColor(class or "?")..name,
			0,
			name,
		}
	end

	for i=1,#list do
		local name = list[i][3]

		local ver = MRT.RaidVersions[name]
		if not ver and not name:find("%-") then
			for long_name,v in pairs(MRT.RaidVersions) do
				if long_name:find("^"..name) then
					ver = v
					break
				end
			end
		end
		if not ver then
			local shortName = name:match("^(.-)%-")
			if shortName then
				ver = MRT.RaidVersions[shortName]
			end
		end
		if not ver then
			if VersionCheckReqSended[name] then
				if not UnitIsConnected(name) then
					ver = "|cff888888offline"
				else
					ver = "|cffff8888no addon"
				end
			else
				ver = "???"
			end
		elseif not tonumber(ver) then

		elseif tonumber(ver) >= MRT.V then
			ver = "|cff88ff88"..ver
		else
			ver = "|cffffff88"..ver
		end

		list[i][2] = ver
	end

	sort(list,function(a,b) return a[3]<b[3] end)
	OptionsFrame.VersionCheck:Update()
end

OptionsFrame.VersionCheck = ELib:ScrollTableList(OptionsFrame,0,130):Point("TOPLEFT",OptionsFrame.Changelog,"BOTTOMLEFT",0,-3):Size(350,115):HideBorders():OnShow(UpdateVersionCheck,true)
OptionsFrame.VersionUpdateButton = ELib:Button(OptionsFrame,UPDATE):Point("BOTTOMLEFT",OptionsFrame.VersionCheck,"BOTTOMRIGHT",10,3):Size(100,20):Tooltip(L.OptionsUpdateVerTooltip):OnClick(function()
	MRT.F.SendExMsg("needversion","")
	C_Timer.After(2,UpdateVersionCheck)
	for _, name in MRT.F.IterateRoster do
		VersionCheckReqSended[name]=true
	end
	local list = OptionsFrame.VersionCheck.L
	for i=1,#list do
		list[i][2] = "..."
	end
	OptionsFrame.VersionCheck:Update()
	OptionsFrame.VersionUpdateButton:Disable()
end)

local function CreateDataBrokerPlugin()
	local dataObject = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(GlobalAddonName, {
		type = 'launcher',
		icon = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap",
		OnClick = MiniMapIconOnClick,
	})
end
CreateDataBrokerPlugin()
