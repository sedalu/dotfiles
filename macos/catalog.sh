# macos/catalog.sh — catalog of macOS defaults to scan
#
# Format: "domain|key|type|description"
# Types:  bool (1/0), int, float, string
#
# Used by: mise run dotfiles:scan:macos

_macos_catalog=(
    # --- Finder ---
    "com.apple.finder|ShowPathbar|bool|Show path bar in Finder windows"
    "com.apple.finder|ShowStatusBar|bool|Show status bar in Finder windows"
    "com.apple.finder|ShowTabView|bool|Show tab bar in Finder windows"
    "com.apple.finder|FXPreferredViewStyle|string|Default view (clmv=column, icnv=icon, Nlsv=list, Flwv=gallery)"
    "com.apple.finder|FXDefaultSearchScope|string|Default search scope (SCcf=current folder, SCev=everywhere)"
    "com.apple.finder|FXEnableExtensionChangeWarning|bool|Warn when changing file extension"
    "com.apple.finder|_FXShowPosixPathInTitle|bool|Show full POSIX path in Finder title bar"
    "com.apple.finder|AppleShowAllFiles|bool|Show hidden files in Finder"
    "com.apple.finder|ShowExternalHardDrivesOnDesktop|bool|Show external drives on desktop"
    "com.apple.finder|ShowHardDrivesOnDesktop|bool|Show internal drives on desktop"
    "com.apple.finder|ShowRemovableMediaOnDesktop|bool|Show removable media on desktop"
    "com.apple.finder|ShowMountedServersOnDesktop|bool|Show mounted servers on desktop"
    "com.apple.finder|FXRemoveOldTrashItems|bool|Remove items from Trash after 30 days"
    "com.apple.finder|WarnOnEmptyTrash|bool|Warn before emptying Trash"

    # --- Dock ---
    "com.apple.dock|autohide|bool|Auto-hide the Dock"
    "com.apple.dock|autohide-delay|float|Delay before Dock auto-hides (seconds)"
    "com.apple.dock|autohide-time-modifier|float|Duration of Dock hide/show animation (seconds)"
    "com.apple.dock|tilesize|int|Dock icon size (pixels)"
    "com.apple.dock|magnification|bool|Enable Dock magnification"
    "com.apple.dock|largesize|int|Dock magnified icon size (pixels)"
    "com.apple.dock|mineffect|string|Window minimize effect (genie or scale)"
    "com.apple.dock|minimize-to-application|bool|Minimize windows into application icon"
    "com.apple.dock|show-recents|bool|Show recent apps in Dock"
    "com.apple.dock|mru-spaces|bool|Automatically rearrange Spaces based on recent use"
    "com.apple.dock|orientation|string|Dock position (bottom, left, right)"

    # --- Appearance ---
    "NSGlobalDomain|AppleInterfaceStyle|string|Appearance (Dark; delete key entirely for Light)"
    "NSGlobalDomain|AppleReduceDesktopTinting|bool|Reduce desktop tinting in windows"
    "NSGlobalDomain|AppleMiniaturizeOnDoubleClick|bool|Minimize window on title bar double-click"
    "NSGlobalDomain|AppleShowScrollBars|string|When to show scroll bars (WhenScrolling, Automatic, Always)"
    "NSGlobalDomain|NSWindowResizeTime|float|Window resize animation duration (seconds)"
    "NSGlobalDomain|NSAutomaticWindowAnimationsEnabled|bool|Enable window open/close animations"

    # --- Keyboard / Input ---
    "NSGlobalDomain|InitialKeyRepeat|int|Delay before key repeat starts (lower=faster, default=68)"
    "NSGlobalDomain|KeyRepeat|int|Key repeat rate (lower=faster, default=6)"
    "NSGlobalDomain|AppleKeyboardUIMode|int|Full keyboard access (0=standard, 3=all controls)"
    "NSGlobalDomain|NSAutomaticCapitalizationEnabled|bool|Auto-capitalize words"
    "NSGlobalDomain|NSAutomaticPeriodSubstitutionEnabled|bool|Insert period with double-space"
    "NSGlobalDomain|NSAutomaticQuoteSubstitutionEnabled|bool|Use smart quotes"
    "NSGlobalDomain|NSAutomaticDashSubstitutionEnabled|bool|Use smart dashes"
    "NSGlobalDomain|NSAutomaticSpellingCorrectionEnabled|bool|Auto-correct spelling"

    # --- Trackpad ---
    "NSGlobalDomain|com.apple.trackpad.forceClick|bool|Enable Force Click on trackpad"
    "NSGlobalDomain|com.apple.swipescrolldirection|bool|Natural scroll direction"

    # --- Sound / Visual ---
    "NSGlobalDomain|com.apple.sound.beep.flash|int|Flash screen for alerts (0=off)"
    "NSGlobalDomain|com.apple.springing.enabled|bool|Enable spring-loading for folders"
    "NSGlobalDomain|com.apple.springing.delay|float|Spring-loading delay (seconds)"

    # --- Screenshots ---
    "com.apple.screencapture|location|string|Screenshot save location"
    "com.apple.screencapture|type|string|Screenshot format (png, jpg, pdf, tiff)"
    "com.apple.screencapture|disable-shadow|bool|Disable window shadow in screenshots"
    "com.apple.screencapture|include-date|bool|Include date in screenshot filename"

    # --- Safari ---
    "com.apple.Safari|ShowFullURLInSmartSearchField|bool|Show full URL in address bar"
    "com.apple.Safari|AutoOpenSafeDownloads|bool|Auto-open safe downloads"
)
