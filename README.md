# MRT-CoA — Raid Coordination for Conquest Reborn

> **[⬇ Download v0.20]( https://github.com/downingwow/MRT-CoA/releases/download/v0.20/MRT-CoA-v0.20.zip )**


## Current release

# MRT-CoA v0.20 — Cooldown integration

- Imports 568 castable, class-assigned spells with positive reference recovery values from the supplied CoA databank.
- Adds a CoA Spellbook settings panel and an observed-spell cooldown window.
- Scan My Spellbook, then Open CoA Cooldowns; `/mrtcoacd` toggles the window.
- Displays learned/scanned spells rather than treating the entire archive as the player's spellbook.

Reference recovery values may differ from live cooldowns due to talents, modifiers and server changes. This is an experimental integration; automatic raid-roster cooldown tracking and complete custom-class coverage are not claimed. Previously reported in-game functionality problems remain unverified by this publishing pass.

Install the MRT folder directly into Interface/AddOns. Retain VMRT and MRTCoASpells SavedVariables.

Maintainer: Uncle Bone — https://github.com/downingwow


Method Raid Tools adapted for the legacy Ascension Conquest of Azeroth client. It brings a raid toolbox into one addon: shared raid notes, cooldown and interrupt displays, reminders, ready/raid checks, group and invitation tools, marks, timers, attendance and encounter/loot history modules.

## CoA adaptation

- Legacy-client API compatibility helpers and custom-class support.
- A CoA cooldown/class browser and saved spell records.
- Spellbook scanning tools for investigating custom classes and spells.
- UI and load-order changes for the 3.3.5a client.

The current **v0.20 cooldown-integration build is experimental**. Inclusion of a module does not guarantee its modern-client behavior is supported. Custom cooldown coverage depends on validated spell data; a spellbook scan is not a finished cooldown database. DragonUI need not be disabled; default UI behavior remains a supported testing path.

## Installation and commands

Download the installable ZIP from [Releases](https://github.com/downingwow/MRT-CoA/releases). Extract the `MRT` folder directly into `Interface/AddOns`, replacing the previous folder after backing it up. Keep `VMRT` and `MRTCoASpells` SavedVariables.

- `/mrt` — raid tools and settings.
- `/mrtcoascanbook` or `/mrtbook` — scan the spellbook.
- `/mrtcoaspells` or `/mrtspelllist` — list saved spell records.
- `/mrtcoatools` — CoA tools.

Based on Method Raid Tools by ExoJdi and its contributors. Modern MRT features remain subject to legacy-client limitations.

## Compatibility and support

Target: Ascension Conquest of Azeroth / Conquest Reborn, legacy WoW 3.3.5a (Interface 30300). Source and package checks do not establish live realm compatibility. Report the addon version, UI addons, and full Lua error when filing an issue. Preserve your WTF SavedVariables when updating.

Maintainer: **Uncle Bone** · [GitHub support](https://github.com/downingwow). This is a community-maintained adaptation. Original authors retain their credits; bundled license and third-party attribution notices remain applicable.

