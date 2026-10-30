-- CoA cooldown viewer; source reference values are distinguished from client timers.
local db=_G.MRT_CoACooldownDB or {}
local frame=CreateFrame("Frame","MRTCoACooldownWindow",UIParent)
frame:SetWidth(390);frame:SetHeight(350);frame:SetPoint("CENTER")
frame:SetMovable(true);frame:EnableMouse(true);frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart",function(self) self:StartMoving() end)
frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=14,insets={left=4,right=4,top=4,bottom=4}})
local title=frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");title:SetPoint("TOP",0,-16);title:SetText("MRT-CoA Cooldowns")
local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",-3,-3)
local rows={}
for i=1,13 do local t=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");t:SetPoint("TOPLEFT",14,-35-(i-1)*22);t:SetWidth(360);t:SetJustifyH("LEFT");rows[i]=t end
local foot=frame:CreateFontString(nil,"OVERLAY","GameFontDisableSmall");foot:SetPoint("BOTTOM",0,13);foot:SetText("Live timers / DB reference (not verified)")
frame:Hide()
local function update()
 if not frame:IsShown() then return end
 local spells={};local saved=_G.MRTCoASpells
 local key=(UnitName("player") or "Unknown").."-"..(GetRealmName and GetRealmName() or "Unknown")
 local c=saved and saved.characters and saved.characters[key]
 if c and c.specs then
  local spec=c.lastSpec;local entry=c.specs[tostring(spec or 0)]
  if entry and entry.spells then for _,s in ipairs(entry.spells) do
   local ref=db[s.id]
   if ref and ref[1]>=1500 then
    local start,duration,enabled=GetSpellCooldown(s.id)
    local remaining=type(start)=="number" and type(duration)=="number" and start>0 and math.max(0,start+duration-GetTime()) or 0
    spells[#spells+1]={name=s.name or ref[2],remaining=remaining,reference=ref[1]/1000,id=s.id}
   end
  end end
 end
 table.sort(spells,function(a,b) if (a.remaining>0)~=(b.remaining>0) then return a.remaining>0 end return a.name<b.name end)
 for i=1,#rows do local s=spells[i];rows[i]:SetText(s and string.format("%s [%d]  %s  |cff888888DB %.0fs|r",s.name,s.id,s.remaining>0 and string.format("%.0fs left",s.remaining) or "Ready",s.reference) or (i==1 and "Scan spellbook in MRT settings first." or "")) end
end
frame:SetScript("OnShow",update)
local tick=0;frame:SetScript("OnUpdate",function(self,elapsed) tick=tick+elapsed;if tick>0.5 then tick=0;update() end end)
_G.MRT_CoACooldownTracker={Toggle=function() if frame:IsShown() then frame:Hide() else frame:Show() end end,Refresh=update}
SLASH_MRTCOACD1="/mrtcoacd";SlashCmdList.MRTCOACD=function() _G.MRT_CoACooldownTracker.Toggle() end
