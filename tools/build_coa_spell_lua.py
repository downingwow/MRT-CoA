#!/usr/bin/env python3
"""Build partitioned Lua 5.1 CoA spell records from CoA-Research's published index.

Input is an explicitly supplied local JSON export; no dependency on WoW runtime networking.
"""
import argparse
import json
from pathlib import Path

def lua_string(value):
    return '"' + str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\r", " ").replace("\n", " ") + '"'

def generate(source, output):
    data = json.loads(Path(source).read_text(encoding="utf-8"))
    rows = data["records"]
    if len(rows) < 9000:
        raise ValueError("Incomplete source spell index")
    ids = set()
    partitions = {}
    for record in rows:
        sid = record["id"]
        if type(sid) is not int or sid <= 0 or sid in ids:
            raise ValueError("Duplicate or invalid spell ID: " + str(sid))
        ids.add(sid)
        # 1000-ID buckets bound the loaded Lua source size.
        bucket = sid // 1000
        partitions.setdefault(bucket, []).append(record)
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    toc = []
    for bucket, records in sorted(partitions.items()):
        name = "CoASpellData_" + str(bucket) + ".lua"
        toc.append(name)
        lines = ["-- Generated CoA-Research archived spell evidence; NOT verified live Conquest Reborn.",
                 "local t = _G.MRT_CoASpellArchiveBuckets",
                 "if not t then return end",
                 "t[" + str(bucket) + "] = {"]
        for r in sorted(records, key=lambda x: x["id"]):
            class_ids = ",".join(str(i) for i in r.get("c",[]) if type(i) is int)
            spec_ids = ",".join(str(i) for i in r.get("s",[]) if type(i) is int)
            spell_name = lua_string(r.get("n") or "")
            # Do not package descriptions here: avoid heavy 3.3.5a startup memory use.
            cd = r.get("cd")
            cdstr = str(cd) if type(cd) is int else "nil"
            lines.append(" [" + str(r["id"]) + "]={" + spell_name + ",{" + class_ids + "},{" + spec_ids + "}," + cdstr + "," + ("true" if r.get("defined") else "false") + "},")
        lines.append("}")
        (output/name).write_text("\n".join(lines)+"\n", encoding="utf-8")
    manifest = {"schemaVersion":1,"source":"CoA-Research/site/data/spell-search-index.json",
                "status":"archived, not live verified","spellCount":len(rows),
                "bucketCount":len(toc),"files":toc}
    (output/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
    (output/"CoASpellData.toc.inc").write_text("\n".join("CoASpellData\\"+f for f in toc)+"\n",encoding="utf-8")
    print("Generated",len(rows),"spells in",len(toc),"Lua 5.1 buckets")

if __name__ == "__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("source")
    parser.add_argument("output")
    args=parser.parse_args()
    generate(args.source,args.output)
