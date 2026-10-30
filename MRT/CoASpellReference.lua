-- MRT-CoA archived spell reference bridge (WoW 3.3.5a / Lua 5.1).
-- Evidence: MRT/CoACooldownDB.lua, sourced from an Ascension archive.
-- This bridge does NOT assert current Conquest Reborn cooldown correctness.
local A = {}
local db = _G.MRT_CoACooldownDB or {}
local archive = _G.MRT_CoASpellArchiveBuckets or {}
A.schemaVersion = 1
A.source = "Archived Ascension spell recovery-time reference"
A.currentClientVerified = false
local function validID(id)
 return type(id) == "number" and id > 0 and id == math.floor(id)
end
function A.GetSpell(id)
 if not validID(id) then return nil end
 local bucket = archive[math.floor(id / 1000)]
 local item = bucket and bucket[id]
 if item then
  return {id=id,name=item[1],classIds=item[2],candidateSpecIds=item[3],archivedCooldownMs=item[4],hasArchivedDefinition=item[5],cooldownSource="coa-research-archive",currentClientVerified=false}
 end
 local r = db[id]
 if type(r) ~= "table" then
  local bucket = archive[math.floor(id / 1000)]
  local item = bucket and bucket[id]
  if not item then return nil end
  return {id=id,name=item[1],classIds=item[2],candidateSpecIds=item[3],archivedCooldownMs=item[4],hasArchivedDefinition=item[5],cooldownSource="coa-research-archive",currentClientVerified=false}
 end
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
 local seen = {}
 for _,bucket in pairs(archive) do
  for id,item in pairs(bucket) do
   local name = tostring(item[1] or "")
   local classMatch = not filter
   if filter then
    for _,cid in ipairs(item[2] or {}) do if tostring(cid) == filter then classMatch=true;break end end
   end
   if classMatch and (q == "" or tostring(id):find(q,1,true) or name:lower():find(q,1,true)) then
    out[#out+1] = A.GetSpell(id)
    seen[id] = true
   end
  end
 end
 for id, r in pairs(db) do
  if validID(id) and type(r) == "table" and not seen[id] then
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
