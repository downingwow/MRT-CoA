local GlobalAddonName, ExRT = ...
ExRT.Options.Changelog = [=[
MRT-CoA v0.18\n* Spellbook scanner now probes actual slots when tab data is empty or unusable.\n* Displays API diagnostics and protects previously saved spells from empty scans.\n* Compatible with DragonUI and the default interface without requiring either.\n\nMRT-CoA v0.17
* Scan using legacy GetSpellName and GetSpellLink with spell ID fallback.
* Report examined spellbook slots, tabs, and resolved IDs.

MRT-CoA v0.16
* Spellbook settings scan now runs directly without scanner module dependency.
* Keeps spell IDs and names from the active game client.

MRT-CoA v0.15
* Registered CoA Spellbook directly in MRT Options.
* Removed duplicate standalone panel registration.
* Corrected changelog line breaks.

MRT-CoA v0.14
* Added CoA Spellbook page in MRT settings with Scan and Refresh buttons.
* Scan results and saved spell counts are displayed in the settings panel.

MRT-CoA v0.13
* Added short slash command aliases and a fallback dispatcher.
* Restored MRT internal numeric version for module compatibility.

MRT-CoA v0.12
* Fixed spellbook command registration and addon loading order.
* Updated in-game version, changelog, and addon metadata.
* Maintainer: Uncle Bone; contact: github.com/downingwow/MRT-CoA.

MRT-CoA v0.11
* Added Conquest spellbook discovery and per-character saved spell data.
* Added spell scan and saved spell listing commands.

MRT-CoA v0.10
* Added Conquest class categories to the Raid Cooldowns browser.

MRT-CoA v0.9
* Fixed missing specialization table crash in Raid Cooldowns.

MRT-CoA v0.8
* Integrated custom classes and specializations with shared MRT UI lists.

MRT-CoA v0.7
* Repaired main-window button artwork and adjusted broken UI decorations.
* Added Uncle Bone maintainer and GitHub contact branding.

MRT-CoA v0.6
* Registered 21 Conquest class families and 70 specializations.
]=]
