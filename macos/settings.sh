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
    "com.apple.ActivityMonitor:Activity Monitor"
    "com.apple.universalaccess:Finder"
    "com.apple.menuextra.clock:SystemUIServer"
    "com.apple.MobileSMS:Messages"
    "com.apple.Music:Music"
    "com.apple.spaces:SystemUIServer"
    "com.apple.Terminal:Terminal"
    "com.apple.Safari:Safari"
    "com.apple.screencapture:SystemUIServer"
    "com.apple.TextEdit:TextEdit"
    "com.apple.dt.Xcode:Xcode"
)

# --- Dock ---
# Set the Dock position
# https://macos-defaults.com/dock/orientation.html
defaults write com.apple.dock "orientation" -string "bottom"
# Set the icon size of Dock items in pixels.
# https://macos-defaults.com/dock/tilesize.html
defaults write com.apple.dock "tilesize" -int "36"
# Autohides the Dock. You can toggle the Dock using ⌥⌘d.
# https://macos-defaults.com/dock/autohide.html
defaults write com.apple.dock "autohide" -bool "true"
# Change the Dock opening and closing animation times.
# https://macos-defaults.com/dock/autohide-time-modifier.html
defaults write com.apple.dock "autohide-time-modifier" -float "0"
# Change the Dock opening delay.
# https://macos-defaults.com/dock/autohide-delay.html
defaults write com.apple.dock "autohide-delay" -float "0"
# Show recently used apps in a separate section of the Dock.
# https://macos-defaults.com/dock/show-recents.html
defaults delete com.apple.dock "show-recents"
# Change the Dock minimize animation.
# https://macos-defaults.com/dock/mineffect.html
defaults delete com.apple.dock "mineffect"
# Only show opened apps in Dock.
# https://macos-defaults.com/dock/static-only.html
defaults delete com.apple.dock "static-only"
# Scroll up on a Dock icon to show all Space's opened windows for an app, or open stack.
# https://macos-defaults.com/dock/scroll-to-open.html
defaults delete com.apple.dock "scroll-to-open"

# --- Finder ---
# View style: clmv=column, icnv=icon, Nlsv=list, Flwv=gallery
# https://macos-defaults.com/finder/fxpreferredviewstyle.html
defaults write com.apple.finder FXPreferredViewStyle -string clmv
# https://macos-defaults.com/desktop/showexternalharddrivesondesktop.html
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
# https://macos-defaults.com/desktop/showharddrivesondesktop.html
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
# https://macos-defaults.com/desktop/showremovablemediaondesktop.html
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Automatically adjust column widths in column view to fit content.
# https://macos-defaults.com/finder/_fxenablecolumnautosizing.html
defaults delete com.apple.finder "_FXEnableColumnAutoSizing"
# Keep folders on top when sorting by name
# https://macos-defaults.com/finder/_fxsortfoldersfirst.html
defaults delete com.apple.finder "_FXSortFoldersFirst"
# Show all file extensions in the Finder.
# https://macos-defaults.com/finder/appleshowallextensions.html
defaults delete NSGlobalDomain "AppleShowAllExtensions"
# Show hidden files in the Finder. You can toggle the value using `⌘ cmd`+`⇧ shift`+`.`.
# https://macos-defaults.com/finder/appleshowallfiles.html
defaults delete com.apple.finder "AppleShowAllFiles"
# Set whether folders open in a new tab or a new window
# https://macos-defaults.com/finder/finderspawntab.html
defaults delete com.apple.finder "FinderSpawnTab"
# Set the default search scope when performing a search
# https://macos-defaults.com/finder/fxdefaultsearchscope.html
defaults delete com.apple.finder "FXDefaultSearchScope"
# Choose whether to display a warning when changing a file extension.
# https://macos-defaults.com/finder/fxenableextensionchangewarning.html
defaults delete com.apple.finder "FXEnableExtensionChangeWarning"
# Remove items in the bin after 30 days
# https://macos-defaults.com/finder/fxremoveoldtrashitems.html
defaults delete com.apple.finder "FXRemoveOldTrashItems"
# Choose whether the default file save location is on disk or iCloud
# https://macos-defaults.com/finder/nsdocumentsavenewdocumentstocloud.html
defaults delete NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud"
# Choose the size of Finder sidebar icons
# https://macos-defaults.com/finder/nstableviewdefaultsizemode.html
defaults delete NSGlobalDomain "NSTableViewDefaultSizeMode"
# Choose the delay of the auto-hidden document-proxy icon.
# https://macos-defaults.com/finder/nstoolbartitleviewrolloverdelay.html
defaults delete NSGlobalDomain "NSToolbarTitleViewRolloverDelay"
# Add a quit option to the Finder. Behaves strangely when activated, would not recommend.
# https://macos-defaults.com/finder/quitmenuitem.html
defaults delete com.apple.finder "QuitMenuItem"
# Show path bar in the bottom of the Finder windows
# https://macos-defaults.com/finder/showpathbar.html
defaults delete com.apple.finder "ShowPathbar"
# Show status bar in the bottom of the Finder windows
# https://macos-defaults.com/finder/showstatusbar.html
defaults delete com.apple.finder "ShowStatusBar"
# Always show folder icon before title in the title bar
# https://macos-defaults.com/finder/showwindowtitlebaricons.html
defaults delete com.apple.universalaccess "showWindowTitlebarIcons"

# --- Appearance ---
# stale: defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# --- Input ---
# stale: defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
# https://macos-defaults.com/keyboard/applekeyboardaddperiodwithdoublespace.html
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
# stale: defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true

# --- Behavior ---
# stale: defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0.5
# stale: defaults write NSGlobalDomain com.apple.sound.beep.flash -int 0
# https://macos-defaults.com/keyboard/applekeyboardfnstate.html
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# --- Activity Monitor ---
# Choose what information should be shown in the app's Dock icon, if any.
# https://macos-defaults.com/activity-monitor/icontype.html
defaults delete com.apple.ActivityMonitor "IconType"
# How frequently Activity Monitor should update its data, in seconds.
# https://macos-defaults.com/activity-monitor/updateperiod.html
defaults delete com.apple.ActivityMonitor "UpdatePeriod"

# --- Desktop ---
# Keep folders on top when sorting
# https://macos-defaults.com/desktop/_fxsortfoldersfirstondesktop.html
defaults delete com.apple.finder "_FXSortFoldersFirstOnDesktop"
# Hide all icons on desktop
# https://macos-defaults.com/desktop/createdesktop.html
defaults delete com.apple.finder "CreateDesktop"
# Show connected servers on desktop
# https://macos-defaults.com/desktop/showmountedserversondesktop.html
defaults delete com.apple.finder "ShowMountedServersOnDesktop"

# --- Feedback Assistant ---
# Choose whether to autogather large files when submitting a feedback report. Can result in a slow Mac and important upload metrics.
# https://macos-defaults.com/feedback-assistant/autogather.html
defaults delete com.apple.appleseed.FeedbackAssistant "Autogather"

# --- Keyboard ---
# Choose what happens when you press the Fn or 🌐︎ key on the keyboard.
# https://macos-defaults.com/keyboard/applefnusagetype.html
defaults delete com.apple.HIToolbox AppleFnUsageType
# Choose whether to enable moving focus with Tab and Shift Tab.
# https://macos-defaults.com/keyboard/applekeyboarduimode.html
defaults delete NSGlobalDomain AppleKeyboardUIMode
# Allows you to select the behavior when a key is held down for a long time.
# https://macos-defaults.com/keyboard/applepressandholdenabled.html
defaults delete NSGlobalDomain "ApplePressAndHoldEnabled"
# Toggle the language indicator visibility while switching input sources.
# https://macos-defaults.com/keyboard/toggle-language-indicator.html
defaults delete kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled

# --- Menubar ---
# This setting configures the time and date format for the Menu Bar digital clock.
# https://macos-defaults.com/menubar/dateformat.html
defaults delete com.apple.menuextra.clock "DateFormat"
# When enabled, the clock indicator (which by default is the colon) will flash on and off each second.
# https://macos-defaults.com/menubar/flashdateseparators.html
defaults delete com.apple.menuextra.clock "FlashDateSeparators"

# --- Messages ---
# Show the subject field which appears above the iMessage/Text Message field in Messages. Text entered in the subject field will be sent in bold (unless there is no text in the iMessage/Text Message field; in this case, the text in the subject field will be sent without the bold effect).
# https://macos-defaults.com/messages/show-subject-field.html
defaults delete com.apple.MobileSMS "MMSShowSubject"

# --- Misc ---
# Toggle Apple Intelligence from command line interface.
# https://macos-defaults.com/misc/apple-intelligence.html
defaults delete com.apple.CloudSubscriptionFeatures.optIn "545129924"
# Clear all recently used time zones from the time zone selector in Calendar when time zone support is enabled (Calendar → Settings → Advanced → Turn on time zone support).
# https://macos-defaults.com/misc/calendar-timezones.html
defaults delete com.apple.iCal "RecentlyUsedTimeZones"
# Choose whether the Help Menu should be always-on-top.
# https://macos-defaults.com/misc/devmode.html
defaults delete com.apple.helpviewer "DevMode"
# Drag a file over an icon in the Dock, hover, and the application will open. The behaviour is unchanged if the app is already open. This behaviour has been observed with Preview, Quicktime, and iWork (Keynote, Pages, Numbers).
# https://macos-defaults.com/misc/enable-spring-load-actions-on-all-items.html
defaults delete com.apple.dock "enable-spring-load-actions-on-all-items"
# Turn off the “Application Downloaded from Internet” quarantine warning.
# https://macos-defaults.com/misc/lsquarantine.html
defaults delete com.apple.LaunchServices "LSQuarantine"
# Should you be asked to keep changes when closing documents or just have changes saved automatically.
# https://macos-defaults.com/misc/nsclosealwaysconfirmschanges.html
defaults delete NSGlobalDomain "NSCloseAlwaysConfirmsChanges"
# When enabled, open documents and windows will be restored when you re-open an application.
# https://macos-defaults.com/misc/nsquitalwayskeepwindows.html
defaults delete NSGlobalDomain "NSQuitAlwaysKeepsWindow"
# Display a notification when a new song starts in the Music app.
# https://macos-defaults.com/misc/userwantsplaybacknotifications.html
defaults delete com.apple.Music "userWantsPlaybackNotifications"

# --- Mission Control ---
# When switching to an app, switch to a space with open windows for this app.
# https://macos-defaults.com/mission-control/applespacesswitchonactivate.html
defaults delete NSGlobalDomain "AppleSpacesSwitchOnActivate"
# If you have several windows from multiple apps open simultaneously, have the windows organised by app in Mission Control.
# https://macos-defaults.com/mission-control/expose-group-apps.html
defaults delete com.apple.dock "expose-group-apps"
# Choose whether to rearrange Spaces automatically.
# https://macos-defaults.com/mission-control/mru-spaces.html
defaults delete com.apple.dock "mru-spaces"
# Set up separate spaces for each display (if you use Spaces and have multiple displays).
# https://macos-defaults.com/mission-control/spans-displays.html
defaults delete com.apple.spaces "spans-displays"

# --- Mouse ---
# Focus of the Terminal windows when the mouse cursor hovers over them. The focus change only works between the Terminal windows.
# https://macos-defaults.com/mouse/focusfollowsmouse.html
defaults delete com.apple.Terminal "FocusFollowsMouse"
# Disable mouse acceleration.
# https://macos-defaults.com/mouse/linear.html
defaults delete NSGlobalDomain com.apple.mouse.linear
# Set movement speed of the mouse cursor.
# https://macos-defaults.com/mouse/scaling.html
defaults delete NSGlobalDomain com.apple.mouse.scaling

# --- Safari ---
# Show full website address.
# https://macos-defaults.com/safari/showfullurlinsmartsearchfield.html
defaults delete com.apple.Safari "ShowFullURLInSmartSearchField"

# --- Screenshots ---
# Disable screenshot shadow when capturing an app (`⌘ cmd`+`⇧ shift`+`4` then `space`).
# https://macos-defaults.com/screenshots/disable-shadow.html
defaults delete com.apple.screencapture "disable-shadow"
# Include date and time in screenshot filenames.
# https://macos-defaults.com/screenshots/include-date.html
defaults delete com.apple.screencapture "include-date"
# Set default screenshot location.
# https://macos-defaults.com/screenshots/location.html
defaults delete com.apple.screencapture "location"
# Choose whether to display a thumbnail after taking a screenshot.
# https://macos-defaults.com/screenshots/show-thumbnail.html
defaults delete com.apple.screencapture "show-thumbnail"
# Choose the screenshots image format.
# https://macos-defaults.com/screenshots/type.html
defaults delete com.apple.screencapture "type"

# --- Simulator ---
# Set default location for Simulator screenshots. Note that the folder has to exist in the filesystem.
# https://macos-defaults.com/simulator/screenshotsavelocation.html
defaults delete com.apple.iphonesimulator "ScreenShotSaveLocation"

# --- Textedit ---
# Set default document format as rich text (.rtf) or plain text (.txt).
# https://macos-defaults.com/textedit/richtext.html
defaults delete com.apple.TextEdit "RichText"
# Set if quotation marks should be converted from neutral form to opening/closing variants.
# https://macos-defaults.com/textedit/smartquotes.html
defaults delete com.apple.TextEdit "SmartQuotes"

# --- Timemachine ---
# Prevent Time Machine from prompting to use newly connected storage as backup volumes.
# https://macos-defaults.com/timemachine/donotoffernewdisksforbackup.html
defaults delete com.apple.TimeMachine "DoNotOfferNewDisksForBackup"

# --- Trackpad ---
# Mutually exclusive with `DragLock` and `TrackpadThreeFingerDrag`.
# https://macos-defaults.com/trackpad/dragging.html
defaults delete com.apple.AppleMultitouchTrackpad "Dragging"
# Mutually exclusive with `Dragging` and `TrackpadThreeFingerDrag`.
# https://macos-defaults.com/trackpad/draglock.html
defaults delete com.apple.AppleMultitouchTrackpad "DragLock"
# Choose between Light/Medium/Firm.
# https://macos-defaults.com/trackpad/firstclickthreshold.html
defaults delete com.apple.AppleMultitouchTrackpad "FirstClickThreshold"
# Mutually exclusive with `Dragging` and `DragLock`.
# https://macos-defaults.com/trackpad/trackpadthreefingerdrag.html
defaults delete com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag"

# --- Xcode ---
# Add additional counterpart suffixes that Xcode should consider in the "Related Items > Counterparts" menu.
# https://macos-defaults.com/xcode/ideadditionalcounterpartsuffixes.html
defaults delete com.apple.dt.Xcode "IDEAdditionalCounterpartSuffixes"
# Show build durations in the Activity Viewer in Xcode's toolbar at the top of the workspace window.
# https://macos-defaults.com/xcode/showbuildoperationduration.html
defaults delete com.apple.dt.Xcode "ShowBuildOperationDuration"
