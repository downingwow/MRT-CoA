-- MRT-CoA spellbook discovery, independent of the Wrath cooldown tables.
-- Spell data comes from the active client's spellbook; never fabricate spell IDs.
local registry = _G.MRT_CoAClasses
local addon = CreateFrame("Frame")
local function say(s) DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99MRT-CoA|r "..s) end
local function current()
 local token = select(2,UnitClass("player"))
 local spec = registry and registry.current and registry.current.specID
 if _G.C_CharacterAdvancement and type(C_CharacterAdvancement.GetActiveChrSpec)=="function" then
  local ok,value=pcall(C_CharacterAdvancement.GetActiveChrSpec)
  if ok and type(value)=="number" then spec=value end
 end
 local family = registry and registry.customSpecByID and registry.customSpecByID[spec]
 return token,spec,family
end
local function store()
 MRTCoASpells = MRTCoASpells or {version=1,characters={}}
 MRTCoASpells.characters=MRTCoASpells.characters or {}
 return MRTCoASpells
end
local function scan()
 local token,spec,family=current()
 local player=UnitName("player") or "Unknown"
 local realm=GetRealmName and GetRealmName() or "Unknown"
 local key=player.."-"..realm
 local db=store()
 local c=db.characters[key] or {specs={}}
 c.specs=c.specs or {}
 c.familyToken=family and family.familyToken or token
 c.className=family and family.className or select(1,UnitClass("player"))
 c.lastSpec=spec
 local spells,seen={},{}
 local tabs=GetNumSpellTabs and GetNumSpellTabs() or 0
 for tab=1,math.min(tabs,30) do
  local _,_,offset,count=GetSpellTabInfo(tab)
  if type(offset)=="number" and type(count)=="number" then
   for index=offset+1,math.min(offset+count,offset+600) do
    local typ,id=GetSpellBookItemInfo(index,BOOKTYPE_SPELL or "spell")
    if typ=="SPELL" and type(id)=="number" and id>0 and not seen[id] then
     local name,_,icon=GetSpellInfo(id)
     if name then
      seen[id]=true
      local start,duration,enabled=GetSpellCooldown(id)
      local ref=_G.MRT_CoACooldownDB and _G.MRT_CoACooldownDB[id]
      spells[#spells+1]={id=id,name=name,icon=icon,observedCooldown=type(duration)=="number" and duration or nil,enabled=enabled,referenceCooldownMs=ref and ref[1] or nil,referenceClasses=ref and ref[3] or nil}
     end
    end
   end
  end
 end
 table.sort(spells,function(a,b) return a.name<b.name end)
 c.specs[tostring(spec or 0)]={specID=spec,familyToken=c.familyToken,specName=family and family.specName or "Unknown",spells=spells}
 db.characters[key]=c
 say("Scanned "..#spells.." learned spells for "..c.className.." / "..(family and family.specName or "unknown spec")..". Saved in MRTCoASpells.")
 say("Cooldown observations are current remaining timers, NOT verified base cooldowns.")
 return spells
end
local function list()
 local token,spec=current()
 local key=(UnitName("player") or "Unknown").."-"..(GetRealmName and GetRealmName() or "Unknown")
 local c=store().characters[key]
 local data=c and c.specs and c.specs[tostring(spec or 0)]
 if not data then say("No saved spellbook for current spec. Use /mrtcoascanbook") return end
 local count=0
 for _,s in ipairs(data.spells) do
  if s.observedCooldown and s.observedCooldown>1.5 then
   count=count+1
   say(s.name.." ["..s.id.."] currently "..math.floor(s.observedCooldown+0.5).."s")
   if count>=30 then break end
  end
 end
 say("Listed "..count.." active cooldowns; use /mrtcoascanbook after changing spec to collect its spells.")
end
local function registerCommands()
  SLASH_MRTBOOK1 = "/mrtbook"
  SlashCmdList["MRTBOOK"] = scan
  SLASH_MRTSPELLLIST1 = "/mrtspelllist"
  SlashCmdList["MRTSPELLLIST"] = list
  SLASH_MRTCOASCANBOOK1 = "/mrtcoascanbook"
  SlashCmdList["MRTCOASCANBOOK"] = scan
  SLASH_MRTCOASPELLS1 = "/mrtcoaspells"
  SlashCmdList["MRTCOASPELLS"] = list
end
registerCommands()
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_TALENT_UPDATE")
addon:RegisterEvent("SPELLS_CHANGED")
local pending=false
addon:SetScript("OnEvent",function(self,event)
 if event=="PLAYER_LOGIN" then
  registerCommands()
  say("Spellbook collector ready: /mrtcoascanbook, /mrtcoaspells")
 elseif event=="SPELLS_CHANGED" or event=="PLAYER_TALENT_UPDATE" then
  -- Avoid scanning repeatedly during initial spellbook population or talent updates.
  pending=true
 end
end)
_G.MRT_CoASpellScan={Scan=scan,GetData=store}

-- Secondary registration after the addon finishes loading, with a single dispatcher.
SLASH_MRTCOATOOLS1 = "/mrtcoatools"
SlashCmdList["MRTCOATOOLS"] = function(msg)
 local cmd = (msg or ""):match("^(%S+)") or ""
 if cmd == "scan" then scan()
 elseif cmd == "list" then list()
 else say("Commands: /mrtcoatools scan, /mrtcoatools list, /mrtbook, /mrtspelllist") end
end
