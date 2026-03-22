# macos/settings.sh — macOS defaults inventory
#
# Full catalog of tracked macOS defaults from macos-defaults.com
# Values are either our preference or the expected macOS default.
# Apply:  mise run dotfiles:install:macos
# Check:  mise run dotfiles:doctor:macos

# --- Restart targets ---
# Maps domains to the app that must be restarted when settings change.
# Format: "domain:target" — install task only killalls targets whose domains changed.
killall_targets=(
    "com.apple.dock:Dock"
    "com.apple.finder:Finder"
)

# --- Dock ---
# Set the Dock position
defaults write com.apple.dock "orientation" -string "bottom" # default: bottom
# Set the icon size of Dock items in pixels.
defaults write com.apple.dock "tilesize" -int "36" # default: 48
# Autohides the Dock. You can toggle the Dock using ⌥⌘d.
defaults write com.apple.dock "autohide" -bool "true" # default: false
# Change the Dock opening and closing animation times.
defaults write com.apple.dock "autohide-time-modifier" -float "0" # default: 0.5
# Change the Dock opening delay.
defaults write com.apple.dock "autohide-delay" -float "0" # default: 0.2
# Show recently used apps in a separate section of the Dock.
defaults write com.apple.dock "show-recents" -bool "true" # default: true
# Change the Dock minimize animation.
defaults write com.apple.dock "mineffect" -string "genie" # default: genie
# Only show opened apps in Dock.
defaults write com.apple.dock "static-only" -bool "false" # default: false
# Scroll up on a Dock icon to show all Space's opened windows for an app, or open stack.
defaults delete com.apple.dock "scroll-to-open" # default: false

# --- Finder ---
# View style: clmv=column, icnv=icon, Nlsv=list, Flwv=gallery
defaults write com.apple.finder FXPreferredViewStyle -string clmv
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# --- Appearance ---
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# --- Input ---
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true

# --- Behavior ---
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0.5
defaults write NSGlobalDomain com.apple.sound.beep.flash -int 0
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
