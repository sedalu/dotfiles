# macos/settings.sh — macOS defaults settings
#
# Format: "domain key type value"
# Types:  bool (1/0), int, float, string
# Apply:  mise run dotfiles:install:macos
# Check:  mise run dotfiles:doctor:macos
# Scan:   mise run dotfiles:scan:macos

dotfiles_macos_settings=(
    # --- Finder ---
    # View style: clmv=column, icnv=icon, Nlsv=list, Flwv=gallery
    "com.apple.finder FXPreferredViewStyle string clmv"
    # Desktop icons
    "com.apple.finder ShowExternalHardDrivesOnDesktop bool 1"
    "com.apple.finder ShowHardDrivesOnDesktop bool 0"
    "com.apple.finder ShowRemovableMediaOnDesktop bool 1"

    # --- Appearance ---
    "NSGlobalDomain AppleInterfaceStyle string Dark"
    "NSGlobalDomain AppleMiniaturizeOnDoubleClick bool 0"

    # --- Input ---
    "NSGlobalDomain NSAutomaticCapitalizationEnabled bool 1"
    "NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled bool 1"
    "NSGlobalDomain com.apple.trackpad.forceClick bool 1"

    # --- Behavior ---
    "NSGlobalDomain com.apple.springing.enabled bool 1"
    "NSGlobalDomain com.apple.springing.delay float 0.5"
    "NSGlobalDomain com.apple.sound.beep.flash int 0"
    "com.apple.dock autohide bool 1"
    "NSGlobalDomain com.apple.keyboard.fnState bool 1"
)

# Machine-specific settings (e.g., macos/settings.caladan.sh)
_machine_macos="$DOTFILES_DIR/macos/settings.${DOTFILES_MACHINE}.sh"
if [[ -f "$_machine_macos" ]]; then
    # shellcheck source=/dev/null
    . "$_machine_macos"
    dotfiles_macos_settings+=("${dotfiles_machine_macos_settings[@]}")
fi
unset _machine_macos
