-- MRT-CoA archived spell reference bridge (WoW 3.3.5a / Lua 5.1).
-- Evidence: MRT/CoACooldownDB.lua, sourced from an Ascension archive.
-- This bridge does NOT assert current Conquest Reborn cooldown correctness.
local A = {}
local db = _G.MRT_CoACooldownDB or {}
A.schemaVersion = 1
A.source = "Archived Ascension spell recovery-time reference"
A.currentClientVerified = false
local function validID(id)
 return type(id) == "number" and id > 0 and id == math.floor(id)
end
function A.GetSpell(id)
 if not validID(id) then return nil end
 local r = db[id]
 if type(r) ~= "table" then return nil end
 return {
  id = id,
  name = type(r[2]) == "string" and r[2] or nil,
  classKey = type(r[3]) == "string" and r[3] or nil,
  archivedCooldownMs = type(r[1]) == "number" and r[1] or nil,
  cooldownSource = "archived-database",
  currentClientVerified = false,
 }
end
function A.Search(query, classKey, limit)
 local q = tostring(query or ""):lower()
 local filter = classKey and tostring(classKey):lower() or nil
 local max = math.min(math.max(tonumber(limit) or 50, 1), 200)
 local out = {}
 for id, r in pairs(db) do
  if validID(id) and type(r) == "table" then
   local name = tostring(r[2] or "")
   local cls = tostring(r[3] or "")
   if (not filter or cls:lower() == filter) and
      (q == "" or tostring(id):find(q, 1, true) or name:lower():find(q, 1, true)) then
    out[#out+1] = A.GetSpell(id)
   end
  end
 end
 table.sort(out, function(a,b)
  if a.name == b.name then return a.id < b.id end
  return (a.name or "") < (b.name or "")
 end)
 while #out > max do table.remove(out) end
 return out
end
function A.GetLiveCooldown(id)
 if not validID(id) or type(GetSpellCooldown) ~= "function" then return nil end
 local start, duration, enabled = GetSpellCooldown(id)
 if type(start) ~= "number" or type(duration) ~= "number" then return nil end
 return {start=start, duration=duration, enabled=enabled,
         source="current-client", isReady=(start==0 or duration==0)}
end
_G.MRT_CoASpellReference = A
