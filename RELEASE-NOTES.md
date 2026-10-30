# MRT-CoA v0.20 — Cooldown integration

- Imports 568 castable, class-assigned spells with positive reference recovery values from the supplied CoA databank.
- Adds a CoA Spellbook settings panel and an observed-spell cooldown window.
- Scan My Spellbook, then Open CoA Cooldowns; `/mrtcoacd` toggles the window.
- Displays learned/scanned spells rather than treating the entire archive as the player's spellbook.

Reference recovery values may differ from live cooldowns due to talents, modifiers and server changes. This is an experimental integration; automatic raid-roster cooldown tracking and complete custom-class coverage are not claimed. Previously reported in-game functionality problems remain unverified by this publishing pass.

Install the MRT folder directly into Interface/AddOns. Retain VMRT and MRTCoASpells SavedVariables.

Maintainer: Uncle Bone — https://github.com/downingwow
