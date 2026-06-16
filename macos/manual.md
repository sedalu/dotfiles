# macOS manual configuration

Settings that have no `defaults write` equivalent
and must be applied by hand.

For comparison, the automatable layers are:

- **Preferences** — scalar `defaults write` values,
  in `[bootstrap.macos.defaults]`
  (`mise/config.toml` plus per-machine `mise/config.<machine>.toml`),
  applied by `mise run install:macos`.
- **Reset-catalog** — keys tracked at their macOS default (`defaults delete`),
  in `macos/settings.sh`.

## caladan

### Tips

Suppress Tips notifications entirely via `launchctl` (not `defaults`):

```sh
launchctl disable gui/501/com.apple.tipsd
launchctl bootout gui/501/com.apple.tipsd
```

This needs to run after login —
consider a launch agent or post-install script.

### Mail

Per-account settings stored in Mail's sandboxed container;
no `defaults` equivalent exists.

Configure in **Mail.app → Settings → Accounts → [account] → Mailbox Behaviors**:

- Erase junk messages: after one week
- Erase deleted messages: after one month

And in **Mail.app → Settings → Junk Mail**:

- Enable junk mail filtering: ON
- Move junk mail to the Junk mailbox

### Spotlight

`EnabledPreferenceRules` is an array —
set manually via **System Settings → Spotlight → Search Results**.

Disabled categories (all others enabled):

- System.menuItems (Menu Items)

Full category list at time of capture:
`com.apple.AppStore`, `com.apple.iBooksX`, `com.apple.calculator`,
`com.apple.iCal`, `com.apple.AddressBook`, `com.apple.Dictionary`,
`com.apple.games`, `com.apple.mail`, `com.apple.MobileSMS`, `com.apple.Notes`,
`com.apple.iWork.Numbers`, `com.apple.mobilephone`, `com.apple.Photos`,
`com.apple.podcasts`, `com.apple.reminders`, `com.apple.Safari`,
`com.apple.shortcuts`, `com.apple.systempreferences`, `com.apple.tips`,
`com.apple.VoiceMemos`, `System.menuItems`.
