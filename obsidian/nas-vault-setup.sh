#!/usr/bin/env bash
# Sets up a bare Git repo on your NAS for Obsidian vault backup.
# Run this once from your MacBook Pro.
#
# Usage:
#   chmod +x nas-vault-setup.sh
#   ./nas-vault-setup.sh
#
# Adjust NAS_HOST, NAS_USER, NAS_REPO_PATH, and VAULT_PATH to match your setup.

set -euo pipefail

NAS_HOST="nas.local"          # hostname or IP of your NAS
NAS_USER="seth"               # your NAS username
NAS_REPO_PATH="/volume1/repos/personal-vault.git"
VAULT_PATH="/Users/seth/Library/Mobile Documents/iCloud~md~obsidian/Documents/PersonalVault"

echo "==> Creating bare repo on NAS..."
ssh "${NAS_USER}@${NAS_HOST}" "git init --bare ${NAS_REPO_PATH}"

echo "==> Initialising local vault as a Git repo (if not already)..."
cd "${VAULT_PATH}"

if [ ! -d ".git" ]; then
  git init
  git checkout --orphan main
fi

echo "==> Writing .gitignore..."
cat > .gitignore << 'EOF'
# Obsidian workspace state
.obsidian/workspace.json
.obsidian/workspace-mobile.json

# OS noise
.DS_Store

# Sync conflict files (iCloud)
*.icloud
EOF

echo "==> Staging and making initial commit..."
git add --all
git commit --message "initial vault commit"

echo "==> Adding NAS as remote and pushing..."
git remote add origin "ssh://${NAS_USER}@${NAS_HOST}${NAS_REPO_PATH}"
git push --set-upstream origin main

echo ""
echo "Done. Add this remote URL to the Obsidian Git plugin settings:"
echo "  ssh://${NAS_USER}@${NAS_HOST}${NAS_REPO_PATH}"
