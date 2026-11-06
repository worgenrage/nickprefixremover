# Development Notes

## Target runtime

- World of Warcraft Classic Era (`11508`, `11509`)
- The Burning Crusade Classic Anniversary (`20506`)
- World of Warcraft: Forever (`16001`)
- Blizzard's WoW Lua 5.1 sandbox

Use Lua 5.1-compatible syntax and WoW APIs only. Do not use normal Lua module loading (`require`), `goto`, `_ENV`, `table.pack`, `table.unpack`, or Lua features introduced after Lua 5.1.

The `.toc` file controls Lua file load order. `NickPrefixRemover.lua` must load before `NickPrefixRemoverOptions.lua`, because it creates the private addon API used by the UI.

## Architecture

- `NickPrefixRemover.lua` contains saved settings, chat filters, slash commands, and the private addon API.
- `NickPrefixRemoverOptions.lua` contains the Blizzard Settings panel and standalone configuration window.
- The two Lua files share the private addon table passed through `...`; do not add a global API unless external addons explicitly need one.

## Saved variables

`NickPrefixRemoverDB` is account-wide. Always validate its type and the type of individual settings before use, because SavedVariables can persist across addon upgrades or be manually edited.

## Chat-filter rules

- Register incoming message filters with `ChatFrameUtil.AddMessageEventFilter`, falling back to `ChatFrame_AddMessageEventFilter` (Classic Era 1.15.8 has a `ChatFrameUtil` table without this function).
- A filter must return `false, newMessage, author, ...` when changing a message so the remaining event arguments are preserved.
- Keep the filter free of side effects: WoW can run it once for every relevant chat frame.
- Do not remove and re-add filters when a user toggles a channel; that can change its position relative to filters installed by other chat addons.

## Validation

Before release:

1. Run a WoW Lua language-server or linter configured for the target Classic client.
2. Run `git diff --check`.
3. Test `/reload`, `/npr status`, and `/npr config`.
4. Test a `(name): message` prefix in enabled guild chat, then toggle the channel off and confirm it remains visible.
5. Test the standalone window and `Options -> AddOns -> Nick Prefix Remover` on each supported client.
