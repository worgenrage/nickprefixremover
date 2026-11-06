# Nick Prefix Remover

Nick Prefix Remover is a World of Warcraft Classic addon that removes nickname prefixes added to incoming chat messages by addons such as Name2Chat and Incognito.

For example, this message:

```text
(krix): Hello guild!
```

is displayed as:

```text
Hello guild!
```

## Supported clients

- World of Warcraft Classic Era (`11508`, `11509`)
- The Burning Crusade Classic Anniversary (`20506`)
- World of Warcraft: Forever (`16001`)

## Installation

1. Download or clone this repository.
2. Copy the `NickPrefixRemover` folder into your WoW `Interface/AddOns` directory.
3. Restart WoW or run `/reload`.
4. Use `/npr config` to open the addon window.

## Configuration

The addon can be configured in either of these places:

- `/npr config` opens the standalone configuration window. Escape closes it.
- `/npr options` or `Options -> AddOns -> Nick Prefix Remover` opens the Blizzard Settings entry.
- On WoW Forever, the minimap addon menu has a Nick Prefix Remover entry that opens or closes the standalone window.

Both views change the same saved settings and apply changes immediately. Slash-command changes also update an open configuration window.

## Slash commands

| Command | Description |
| --- | --- |
| `/npr` or `/npr config` | Open the configuration window. |
| `/npr options` or `/npr settings` | Open the Blizzard Settings page. |
| `/npr on` | Enable prefix removal. |
| `/npr off` | Disable prefix removal. |
| `/npr status` | Show the active channels in chat. |
| `/npr guild` | Toggle filtering in guild chat. |
| `/npr officer` | Toggle filtering in officer chat. |
| `/npr party` | Toggle filtering in party chat, including the party leader's messages. |
| `/npr raid` | Toggle filtering in raid chat, including the raid leader's messages. |
| `/npr instance` | Toggle filtering in instance and battleground chat, including the instance leader's messages. |
| `/npr channel` | Toggle filtering in custom channels. |
| `/npr say` | Toggle filtering in Say. |
| `/npr yell` | Toggle filtering in Yell. |
| `/npr whisper` | Toggle filtering in whispers. |
| `/npr bnwhisper` | Toggle filtering in Battle.net whispers. |
| `/npr communities` | Toggle filtering in community channels. |

`/nickprefix` is available as an alias for `/npr`.

## Recognised prefixes

The prefix must be at the beginning of a message and must be followed by a colon and a space. Name2Chat writes `(Name): `; Incognito writes the name in `()`, `[]`, `{}` or `<>`. The following forms are recognised:

```text
(krix): Hello!
( krix ) : Hello!
(Krix Valami): Hello!
[krix]: Hello!
{krix}: Hello!
<krix>: Hello!
```

Whitespace around the nickname is accepted, and the nickname may contain spaces (for example WoW Forever first and last names). Incognito's class-coloured nicknames are recognised too.

The following are not treated as nickname prefixes and stay visible:

```text
{star}: tank here        raid target markers, also (skull): or {rt8}:
(1): first point         numbers
[WTS]: Arcanite Bar      trade tags (WTS, WTB, WTT, LFM, LFG, LF, LFW)
(krix):                  nothing after the colon
(lol):D                  no space after the colon
```

Links in the brackets and labels longer than 50 bytes are not treated as nicknames either.

## Important limitation

The addon intentionally detects a bracketed label followed by a colon at the very start of a message. In rare cases, an ordinary message can look like a nickname prefix. For example:

```text
(something): I agree
```

would be displayed as:

```text
I agree
```

If that is a problem in a particular chat type, disable filtering for that channel in the Options window.

## Saved variables

Settings are stored per account in `NickPrefixRemoverDB`.

## Credits

The prefix behaviour is designed for messages produced by addons such as [Name2Chat](https://github.com/gOOvER/Name2Chat) and Incognito.

## License

This project is proprietary software. See [LICENSE.md](LICENSE.md) for the permitted use and restrictions.

## Support

If you enjoy this addon, you can support its development with a small [€2 PayPal donation](https://www.paypal.com/paypalme/worgenrage/2EUR). Thank you!
