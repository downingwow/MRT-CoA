-- MRT-CoA v0.3: safe class/spec diagnostics (3.3.5a Lua compatible).
local R = {current={},specs={},classes={},specByID={},observed={},roster={}}
-- Confirmed in-game from Primalist / Wildwalker; 31 is a client UnitClass ID,
-- NOT a verified parent-class database ID.
R.classes.PRIMALIST = {name="Primalist", clientID=31, parentDBID=nil, specs={
 {id=59,name="Wildwalker",file="PRIMAL"},
 {id=58,name="Grovekeeper",file="LIFE"},
 {id=60,name="Mountain King",file="MOUNTAINKING"},
 {id=95,name="Geomancy",file="GEOMANCY"},
}}
for _,spec in ipairs(R.classes.PRIMALIST.specs) do
 R.specByID[spec.id]={class="PRIMALIST",name=spec.name,file=spec.file}
end
-- Client-observed spec IDs (user scan), player-facing names from Ascension Sidekick.
-- Do not treat these family tokens as verified parent class database IDs.
R.familyByToken = {}
R.customSpecByID = {}
R.familyByToken["FLESHWARDEN"]={name="Knight of Xoroth",specs={{id=17,name="Defiance"},{id=16,name="Hellfire"},{id=18,name="War"}}}
R.familyByToken["TINKER"]={name="Tinker",specs={{id=49,name="Demolition"},{id=51,name="Invention"},{id=50,name="Mechanics"}}}
R.familyByToken["PROPHET"]={name="Venomancer",specs={{id=52,name="Fortitude"},{id=54,name="Rot"},{id=53,name="Stalking"},{id=101,name="Vizier"}}}
R.familyByToken["RANGER"]={name="Ranger",specs={{id=28,name="Archery"},{id=30,name="Brigand"},{id=29,name="Farstrider"}}}
R.familyByToken["NECROMANCER"]={name="Necromancer",specs={{id=35,name="Animation"},{id=34,name="Death"},{id=36,name="Rime"}}}
R.familyByToken["WILDWALKER"]={name="Primalist",specs={{id=95,name="Geomancy"},{id=58,name="Grovekeeper"},{id=60,name="Mountain King"},{id=59,name="Wildwalker"}}}
R.familyByToken["CULTIST"]={name="Cultist",specs={{id=41,name="Corruption"},{id=96,name="Dreadnought"},{id=42,name="Godblade"},{id=40,name="Heretic"}}}
R.familyByToken["GUARDIAN"]={name="Guardian",specs={{id=19,name="Gladiator"},{id=20,name="Inspiration"},{id=21,name="Vanguard"}}}
R.familyByToken["SUNCLERIC"]={name="Sun Cleric",specs={{id=98,name="Blessings"},{id=46,name="Piety"},{id=48,name="Seraphim"},{id=47,name="Valkyrie"}}}
R.familyByToken["MONK"]={name="Templar",specs={{id=24,name="Crusader"},{id=22,name="Oathkeeper"},{id=23,name="Zealot"}}}
R.familyByToken["BARBARIAN"]={name="Barbarian",specs={{id=3,name="Ancestry"},{id=2,name="Brutality"},{id=1,name="Headhunting"}}}
R.familyByToken["STORMBRINGER"]={name="Stormbringer",specs={{id=15,name="Lightning"},{id=14,name="Maelstrom"},{id=13,name="Wind"}}}
R.familyByToken["SPIRITMAGE"]={name="Runemaster",specs={{id=61,name="Engravement"},{id=62,name="Glyphic"},{id=63,name="Riftblade"}}}
R.familyByToken["WITCHDOCTOR"]={name="Witch Doctor",specs={{id=6,name="Brewing"},{id=4,name="Shadowhunting"},{id=5,name="Voodoo"}}}
R.familyByToken["PYROMANCER"]={name="Pyromancer",specs={{id=39,name="Draconic"},{id=37,name="Flameweaving"},{id=38,name="Incineration"}}}
R.familyByToken["REAPER"]={name="Reaper",specs={{id=57,name="Domination"},{id=56,name="Harvest"},{id=55,name="Soul"}}}
R.familyByToken["DEMONHUNTER"]={name="Felsworn",specs={{id=7,name="Infernal"},{id=8,name="Slayer"},{id=9,name="Tyrant"}}}
R.familyByToken["STARCALLER"]={name="Starcaller",specs={{id=100,name="Moon Guard"},{id=43,name="Moon Priest"},{id=44,name="Sentinel"},{id=45,name="Warden"}}}
R.familyByToken["WITCHHUNTER"]={name="Witch Hunter",specs={{id=97,name="Black Knight"},{id=10,name="Boltslinger"},{id=11,name="Houndmaster"},{id=12,name="Inquisition"}}}
R.familyByToken["SONOFARUGAL"]={name="Bloodmage",specs={{id=27,name="Accursed"},{id=99,name="Eternal"},{id=25,name="Fleshweaver"},{id=26,name="Sanguine"}}}
R.familyByToken["CHRONOMANCER"]={name="Chronomancer",specs={{id=33,name="Artificer"},{id=32,name="Infinite"},{id=31,name="Time"}}}
for token,family in pairs(R.familyByToken) do for _,spec in ipairs(family.specs) do R.customSpecByID[spec.id]={familyToken=token,className=family.name,specName=spec.name} end end
_G.MRT_CoAClasses = R
local function safe(fn,...)
 if type(fn) ~= "function" then return nil end
 local ok,a,b,c = pcall(fn,...)
 if ok then return a,b,c end
end
local function refresh()
 R.current={}; R.specs={}
 local c=R.current
 c.displayName,c.unitToken,c.unitID=UnitClass("player")
 local adv=_G.C_CharacterAdvancement
 c.specID=adv and safe(adv.GetActiveChrSpec)
 local api=_G.C_ClassInfo
 local info=api and c.specID and safe(api.GetSpecInfoByID,c.specID)
 if type(info)=="table" then
  c.specName=info.Name or info.name
  c.parentFile=info.Class or info.class
  c.specFile=info.Spec or info.spec
 end
 local util=_G.CharacterAdvancementUtil
 local dbc=util and c.parentFile and safe(util.GetClassDBCByFile,c.parentFile)
 if type(dbc)=="table" then
  c.parentName=dbc.Name or dbc.name or dbc.ClassName
  c.parentID=dbc.ID or dbc.Id or dbc.id or dbc.ClassID
 end
 -- UnitClass returns a localized class display name on this client.
 c.parentName=c.parentName or c.displayName
 -- Apply only a verified family mapping, without modifying WoW global class APIs.
 local mapped=R.customSpecByID[c.specID]
 if mapped then c.parentName=mapped.className;c.registryClass=mapped.familyToken;c.registrySpec=mapped.specName end
 local known=R.specByID[c.specID]
 if known and known.class and not mapped then
  c.registryClass=known.class
  c.parentName=R.classes[known.class].name
  c.registrySpec=known.name
 end
 local lookup=c.unitToken
 local specs=api and lookup and safe(api.GetAllSpecs,lookup)
 if type(specs)=="table" then
  for _,s in pairs(specs) do
   local si=api and safe(api.GetSpecInfo,lookup,s)
   if type(si)=="table" then
    R.specs[#R.specs+1]={name=si.Name or si.name or tostring(s),id=si.ID or si.Id or si.id,file=si.Spec or si.spec}
   else
    R.specs[#R.specs+1]={name=tostring(s)}
   end
  end
 end
end
-- Non-invasive raid roster discovery. We never replace Blizzard class APIs.
local function observe(unit)
 if not UnitExists or not UnitExists(unit) then return end
 local name,token,id=UnitClass(unit)
 if type(token)~="string" or token=="" then return end
 local item=R.observed[token] or {token=token}
 item.name=name or item.name
 item.clientID=id or item.clientID
 R.observed[token]=item
 local player=UnitName(unit)
 if player then R.roster[player]={token=token,name=name,id=id} end
end
local function scanRoster()
 R.roster={}
 observe("player")
 if GetNumRaidMembers and GetNumRaidMembers()>0 then
  for i=1,GetNumRaidMembers() do observe("raid"..i) end
 elseif GetNumPartyMembers then
  for i=1,GetNumPartyMembers() do observe("party"..i) end
 end
end
R.scanRoster=scanRoster
local function recordSpec(info)
 if type(info)~="table" then return end
 local id=tonumber(info.ID or info.Id or info.id)
 if not id then return end
 local name=info.Name or info.name
 local parent=info.Class or info.class
 local file=info.Spec or info.spec
 local entry=R.specByID[id] or {}
 entry.name=name or entry.name;entry.file=file or entry.file
 entry.parentFile=parent or entry.parentFile
 R.specByID[id]=entry
end
-- Explicit, bounded scan only. Some Ascension client APIs are native and
-- may be unsafe with arbitrary IDs, so this is intentionally opt-in.
local function scanSpecIDs()
 local api=_G.C_ClassInfo
 if not api or type(api.GetSpecInfoByID)~="function" then return 0 end
 local count=0
 for id=1,150 do
  local info=safe(api.GetSpecInfoByID,id)
  if type(info)=="table" then recordSpec(info);count=count+1 end
 end
 return count
end
R.scanSpecIDs=scanSpecIDs
local function registeredCount()
 local n=0 for _ in pairs(R.specByID) do n=n+1 end return n
end
R.refresh=refresh
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:SetScript("OnEvent",function(self,event)
 if event=="PLAYER_LOGIN" then refresh() end
 scanRoster()
end)
SLASH_MRTCOA1="/mrtcoa"
SlashCmdList.MRTCOA=function()
 refresh()
 scanRoster()
 local c=R.current
 local function say(s) DEFAULT_CHAT_FRAME:AddMessage("MRT-CoA: "..s) end
 say("Parent class: "..tostring(c.parentName).." | class file: "..tostring(c.parentFile or "unknown").." | parent ID: "..tostring(c.parentID or "unknown"))
 say("Specialization: "..tostring(c.specName or "unknown").." | spec file: "..tostring(c.specFile or "unknown").." | spec ID: "..tostring(c.specID or "unknown"))
 say("UnitClass token: "..tostring(c.unitToken).." | client ID: "..tostring(c.unitID).." | specs found: "..#R.specs)
 for i,s in ipairs(R.specs) do
  say("Spec "..i..": "..tostring(s.name).." | ID "..tostring(s.id or "unknown").." | file "..tostring(s.file or "unknown"))
 end
 say("Registry family: "..tostring(c.registryClass or "not mapped").." | verified spec: "..tostring(c.registrySpec or "not mapped"))
 say("Static registry: 21 custom class families / 70 specializations (client scan + Sidekick names).")
 local n=0 for _ in pairs(R.observed) do n=n+1 end
 say("Observed roster tokens: "..n.." | registered specialization IDs: "..registeredCount())
 say("Use /mrtcoaroster for observed group classes; /mrtcoascan for opt-in ID scan.")
 say("MRT cooldown filters are unchanged; no unverified class IDs are injected.")
end

SLASH_MRTCOAROSTER1="/mrtcoaroster"
SlashCmdList.MRTCOAROSTER=function()
 scanRoster()
 for name,entry in pairs(R.roster) do
  DEFAULT_CHAT_FRAME:AddMessage("MRT-CoA roster: "..name.." / "..tostring(entry.name).." / "..tostring(entry.token).." / ID "..tostring(entry.id))
 end
end
SLASH_MRTCOASCAN1="/mrtcoascan"
SlashCmdList.MRTCOASCAN=function()
 local count=scanSpecIDs()
 DEFAULT_CHAT_FRAME:AddMessage("MRT-CoA: API returned "..count.." specs from IDs 1-150; registry contains "..registeredCount().." unique spec IDs.")
 local families={}
 for id,entry in pairs(R.specByID) do
  if entry.parentFile then
   local family=families[entry.parentFile] or {}
   family[#family+1]=tostring(entry.name or "?").." ("..id..")"
   families[entry.parentFile]=family
  end
 end
 for key,specs in pairs(families) do
  table.sort(specs)
  DEFAULT_CHAT_FRAME:AddMessage("MRT-CoA family "..key..": "..table.concat(specs,", "))
 end
end

SLASH_MRTCOALIST1="/mrtcoalist"
SlashCmdList.MRTCOALIST=function()
 local keys={} for token in pairs(R.familyByToken) do keys[#keys+1]=token end
 table.sort(keys)
 DEFAULT_CHAT_FRAME:AddMessage("MRT-CoA: 21 custom class families, 70 specializations in static registry.")
 for _,token in ipairs(keys) do
  local family=R.familyByToken[token]
  DEFAULT_CHAT_FRAME:AddMessage("MRT-CoA: "..family.name.." ["..token.."] ("..#family.specs.." specs)")
 end
end
