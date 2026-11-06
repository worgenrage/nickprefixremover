# Changelog

All notable changes to Nick Prefix Remover are documented in this file.

## 1.1.0 - 2026-11-06

### Added

- WoW Forever (`16001`) and Classic Era 1.15.8 (`11508`) in the TOC interface list.
- `/npr options` (alias `/npr settings`) opens the addon's page in the Blizzard Settings window.
- The standalone configuration window closes with Escape.
- WoW Forever addon compartment entry: clicking Nick Prefix Remover in the minimap addon menu
  opens or closes the configuration window.
- Addon icon (`NickPrefixRemover-Icon.tga`, 64×64) shown in the addon list and the addon
  compartment, set with `IconTexture` in the TOC.
- Filtering of messages from party, raid and instance leaders (`CHAT_MSG_PARTY_LEADER`,
  `CHAT_MSG_RAID_LEADER`, `CHAT_MSG_INSTANCE_CHAT_LEADER`) under the existing Party, Raid and
  Instance settings. These messages previously kept their nickname prefix.

### Changed

- Chat filters are registered with `ChatFrameUtil.AddMessageEventFilter` where it exists
  (Classic Era 1.15.9, TBC Anniversary, WoW Forever), with `ChatFrame_AddMessageEventFilter`
  as the fallback for Classic Era 1.15.8. The addon no longer depends on the
  `loadDeprecationFallbacks` setting.
- The options window uses `UICheckButtonTemplate` instead of the deprecated
  `InterfaceOptionsCheckButtonTemplate`.
- Removed the unused `InterfaceOptions_AddCategory` fallback; every supported client has the
  Settings API.
- Stricter nickname recognition: the nickname may not contain brackets or a colon, a space
  must follow the colon, and the rest of the message may not be empty. Incognito's
  class-coloured nicknames are still recognised.
- Secret chat values on WoW Forever are left untouched.

### Fixed

- Raid target markers such as `{star}: tank here` or `(skull): kill first` are no longer
  removed as nicknames.
- Numbered lines such as `(1): first point`, trade tags such as `[WTS]: …`, links in brackets,
  and labels longer than 50 bytes are no longer removed.
- A message consisting only of a prefix, such as `(krix):`, no longer becomes an empty line.
- Checkboxes in an open configuration window now update when a setting is changed with a
  slash command.

## 1.0.2 - 2026-09-05

### Added

- New **Use optimized prefix detection** option in the configuration window.
- Optimized prefix detection is enabled by default for new and existing settings.

### Changed

- Added a lightweight prefix pre-check before full nickname matching.
  The addon first checks whether an incoming message begins, after optional whitespace,
  with one of the supported opening characters: `(`, `[`, `{`, or `<`.
- Messages that do not begin with one of these characters skip the full prefix-pattern
  checks, reducing unnecessary processing for ordinary chat messages.
- Disabling **Use optimized prefix detection** restores the previous matching path.
  Recognised nickname-prefix formats and displayed chat output remain unchanged.

## 1.0.1 - 2026-09-03

### Added

- A standalone, movable configuration window opened with `/npr config`.
- A matching entry in `Options -> AddOns -> Nick Prefix Remover`.
- Options and README pages in both configuration views.
- A standard Blizzard-style Close button in the standalone window.
- README documentation for installation, slash commands, recognised formats, and limitations.
- Development notes documenting the target Lua runtime, addon architecture, chat-filter rules, and release validation.

### Changed

- Reworked the configuration layout for clearer spacing and larger text.
- Replaced the original tab artwork with compact Blizzard panel buttons for page navigation.
- Expanded the prefix parser to accept whitespace around a nickname and its colon.
- Optimised chat filtering by reusing the event lookup and prefix pattern tables.
- Kept chat-filter registration order stable when channel settings are toggled, improving coexistence with other chat-filter addons.
- Added `LoadSavedVariablesFirst` to the addon TOC metadata.
- Replaced the global options API with the private addon namespace shared through the TOC loader.
- Consolidated recurring UI construction into label, value, and button helper functions.

### Fixed

- Fixed the configuration panel's access to the main addon's database and filter-refresh functions.
- Fixed Settings UI opening by using Blizzard's numeric category ID instead of a string ID.
- Fixed filtering for nickname formats such as `( krix ) : message`.
- Fixed SavedVariables initialization so an invalid database value or invalid setting type is restored to a safe default.

## 1.0.0

### Added

- Initial Classic addon release.
- Incoming nickname-prefix removal for configurable chat channels.
- Support for parenthesis, square bracket, curly brace, and angle bracket prefixes.
- Slash-command configuration and account-wide saved settings.
