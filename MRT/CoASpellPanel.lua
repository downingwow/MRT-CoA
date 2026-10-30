-- MRT-CoA integrated spellbook collector (WoW 3.3.5a-compatible controls)
local addonName, MRT = ...
if not MRT or not MRT.Options or not MRT.Options.Add then return end
local page = MRT.Options:Add("CoA Spellbook","|cff33ff99CoA Spellbook|r")
local function label(parent,text,x,y,width)
 local t=parent:CreateFontString(nil,"OVERLAY","GameFontNormal")
 t:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
 t:SetWidth(width or 620)
 t:SetJustifyH("LEFT")
 t:SetText(text)
 return t
end
label(page,"Conquest Reborn - Spellbook Discovery",22,-28,600)
label(page,"Scan the currently learned spells for your active class and specialization.",22,-64,620)
label(page,"The collector saves spell IDs, names and icons. It does not guess base cooldowns.",22,-88,620)
local status=label(page,"Status: Ready",22,-184,620)
local summary=label(page,"Saved spellbook: Not yet checked",22,-215,620)
local function getSaved()
 local db = MRTCoASpells
 if type(db)~="table" or type(db.characters)~="table" then return nil end
 local key=(UnitName("player") or "Unknown").."-"..(GetRealmName and GetRealmName() or "Unknown")
 local c=db.characters[key]
 if not c or type(c.specs)~="table" then return nil end
 return c
end
local function refresh()
 local c=getSaved()
 if not c then summary:SetText("Saved spellbook: No scans yet for this character");return end
 local specs,spells=0,0
 for _,data in pairs(c.specs) do
  specs=specs+1
  spells=spells+(data.spells and #data.spells or 0)
 end
 summary:SetText("Saved spellbook: "..specs.." specialization(s), "..spells.." spell entries")
end
local function button(text,x,y,width,click)
 local b=CreateFrame("Button",nil,page,"UIPanelButtonTemplate")
 b:SetSize(width or 160,26)
 b:SetPoint("TOPLEFT",page,"TOPLEFT",x,y)
 b:SetText(text)
 b:SetScript("OnClick",click)
 return b
end
button("Scan My Spellbook",22,-125,180,function()
 local scanner=_G.MRT_CoASpellScan
 if not scanner or type(scanner.Scan)~="function" then
  status:SetText("Status: Scanner unavailable - check addon load errors")
  return
 end
 local ok,result=pcall(scanner.Scan)
 if not ok then
  status:SetText("Scan error: "..tostring(result))
 elseif type(result)=="table" then
  status:SetText("Scan complete: "..#result.." learned spells recorded")
 else
  status:SetText("Scan completed - see chat for details")
 end
 refresh()
end)
button("Refresh Saved Data",212,-125,180,function()
 refresh()
 status:SetText("Status: Saved data refreshed")
end)
page:SetScript("OnShow",refresh)

button("Open CoA Cooldowns",22,-260,190,function() if _G.MRT_CoACooldownTracker then _G.MRT_CoACooldownTracker.Toggle() end end)
label(page,"DB recovery times are reference values; live timers come from your client.",22,-302,620)
