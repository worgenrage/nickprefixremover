# Changelog

All notable changes to Nick Prefix Remover are documented in this file.

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
