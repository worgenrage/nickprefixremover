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

- World of Warcraft Classic Era (`11509`)
- The Burning Crusade Classic (`20506`)

## Installation

1. Download or clone this repository.
2. Copy the `NickPrefixRemover` folder into your WoW `Interface/AddOns` directory.
3. Restart WoW or run `/reload`.
4. Use `/npr config` to open the addon window.

## Configuration

The addon can be configured in either of these places:

- `/npr config` opens the standalone configuration window.
- `Options -> AddOns -> Nick Prefix Remover` opens the Blizzard Settings entry.

Both views change the same saved settings and apply changes immediately.

## Slash commands

| Command | Description |
| --- | --- |
| `/npr` or `/npr config` | Open the configuration window. |
| `/npr on` | Enable prefix removal. |
| `/npr off` | Disable prefix removal. |
| `/npr status` | Show the active channels in chat. |
| `/npr guild` | Toggle filtering in guild chat. |
| `/npr officer` | Toggle filtering in officer chat. |
| `/npr party` | Toggle filtering in party chat. |
| `/npr raid` | Toggle filtering in raid chat. |
| `/npr instance` | Toggle filtering in instance and battleground chat. |
| `/npr channel` | Toggle filtering in custom channels. |
| `/npr say` | Toggle filtering in Say. |
| `/npr yell` | Toggle filtering in Yell. |
| `/npr whisper` | Toggle filtering in whispers. |
| `/npr bnwhisper` | Toggle filtering in Battle.net whispers. |
| `/npr communities` | Toggle filtering in community channels. |

`/nickprefix` is available as an alias for `/npr`.

## Recognised prefixes

The prefix must be at the beginning of a message and must be followed by a colon. The following forms are recognised:

```text
(krix): Hello!
( krix ) : Hello!
[krix]: Hello!
{krix}: Hello!
<krix>: Hello!
```

Whitespace around the nickname and colon is accepted.

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
