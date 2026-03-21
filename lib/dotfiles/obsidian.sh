# lib/dotfiles/obsidian.sh — Obsidian vault structure and templates
OBSIDIAN_VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/PersonalVault"

dotfiles_obsidian_dirs=(
    "$OBSIDIAN_VAULT/Journal"
    "$OBSIDIAN_VAULT/Projects"
    "$OBSIDIAN_VAULT/Goals"
    "$OBSIDIAN_VAULT/Notes"
    "$OBSIDIAN_VAULT/Reference/Recipes"
    "$OBSIDIAN_VAULT/Reference/Manuals"
    "$OBSIDIAN_VAULT/Reference/Home"
    "$OBSIDIAN_VAULT/Archive"
    "$OBSIDIAN_VAULT/Templates"
)

# Map: source template (relative to $DOTFILES_DIR/obsidian/) → destination in vault
# {{year}} is substituted with the current year at install time
dotfiles_obsidian_templates=(
    "templates/journal.md:$OBSIDIAN_VAULT/Templates/journal.md"
    "templates/goals.md:$OBSIDIAN_VAULT/Goals/{{year}}.md"
)
