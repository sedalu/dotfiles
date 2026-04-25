# macos/settings.caladan.sh — macOS settings for machine: caladan

defaults write io.tailscale.ipn.macsys HideDockIcon -bool true

# --- Appearance ---
# Use 24-hour time system-wide.
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
# Always show scrollbars (overrides default "Automatic").
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Finder sidebar icon size: small (1=small, 2=medium, 3=large).
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# --- Menubar ---
# Show date in menu bar clock.
defaults write com.apple.menuextra.clock ShowDate -bool true
# Hide day of week in menu bar clock.
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool false
# Digital clock (not analog).
defaults write com.apple.menuextra.clock IsAnalog -bool false
# Flash the colon separator each second.
defaults write com.apple.menuextra.clock FlashDateSeparators -bool true
# Do not show seconds.
defaults write com.apple.menuextra.clock ShowSeconds -bool false

# --- Passwords ---
# Show Passwords in the menu bar.
defaults write com.apple.Passwords EnableMenuBarExtra -bool true

# --- Safari ---
# Enable the Develop menu in Safari.
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

# --- Tips ---
# TODO: suppress Tips notifications entirely via launchctl (not defaults):
#   launchctl disable gui/501/com.apple.tipsd
#   launchctl bootout gui/501/com.apple.tipsd
# This needs to run after login; consider a launch agent or post-install script.

# --- Mail ---
# These are per-account settings stored in Mail's sandboxed container; no defaults write equivalent exists.
# Must be configured manually in Mail.app → Settings → Accounts → [account] → Mailbox Behaviors:
#   - Erase junk messages: after one week
#   - Erase deleted messages: after one month
# And in Mail.app → Settings → Junk Mail:
#   - Enable junk mail filtering: ON
#   - Move junk mail to the Junk mailbox

# --- Spotlight ---
# Disable "Help Apple Improve Search" (Search Queries Data Sharing Status: 2 = opted out).
defaults write com.apple.assistant.support "Search Queries Data Sharing Status" -int 2
# Spotlight disabled search categories (EnabledPreferenceRules is an array; set manually via UI).
# Disabled: System.menuItems (Menu Items)
# Full list at time of capture (all others enabled):
#   com.apple.AppStore, com.apple.iBooksX, com.apple.calculator, com.apple.iCal,
#   com.apple.AddressBook, com.apple.Dictionary, com.apple.games, com.apple.mail,
#   com.apple.MobileSMS, com.apple.Notes, com.apple.iWork.Numbers, com.apple.mobilephone,
#   com.apple.Photos, com.apple.podcasts, com.apple.reminders, com.apple.Safari,
#   com.apple.shortcuts, com.apple.systempreferences, com.apple.tips, com.apple.VoiceMemos,
#   System.menuItems
