#!/usr/bin/env bash
set -e

echo "Installing Gitleaks pre-commit hook..."

HOOK_URL="https://raw.githubusercontent.com/vtomchuk1/kbot/main/pre-commit"

mkdir -p .git/hooks
curl -sL "$HOOK_URL" -o .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 2. Автоматично вмикаємо його в git config
git config hooks.gitleaks true

echo "Pre-commit hook installed and enabled successfully."