#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <git-remote-ssh-url> <github-email> <branch-name>"
  echo "Example: $0 git@github.com:kerenberdugo/FINAL-PROJECT-17.11.git katz.shani@gmail.com added-corr-section"
  exit 1
fi

REMOTE_URL="$1"
EMAIL="$2"
BRANCH="$3"
KEY_PATH="$HOME/.ssh/id_ed25519"

echo "1) Generating SSH key (skip if it already exists)…"
if [[ -f "${KEY_PATH}" ]]; then
  echo "   Key ${KEY_PATH} already exists; skipping generation."
else
  ssh-keygen -t ed25519 -C "${EMAIL}" -f "${KEY_PATH}" -N ""
fi

echo "2) Starting ssh-agent and adding key…"
# shellcheck disable=SC2046
eval "$(ssh-agent -s)"
ssh-add "${KEY_PATH}"

echo "3) Copy this public key into GitHub → Settings → SSH keys:"
cat "${KEY_PATH}.pub"
echo "   (Press Enter after you paste the key in GitHub and click Save)"
read -r

echo "4) Switching remote to SSH…"
git remote set-url origin "${REMOTE_URL}"
git remote -v

echo "5) Testing SSH connection to GitHub…"
ssh -T git@github.com || true

echo "6) Pushing branch ${BRANCH}…"
git push --set-upstream origin "${BRANCH}"

echo "Done!"
