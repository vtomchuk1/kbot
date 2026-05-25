#!/usr/bin/env bash

GITLEAKS_ENABLED=$(git config --bool hooks.gitleaks 2>/dev/null || echo "false")
if [ "$GITLEAKS_ENABLED" != "true" ]; then
    exit 0
fi

install_gitleaks() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    if [ "$ARCH" = "x86_64" ]; then
        ARCH="x64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        ARCH="arm64"
    fi

    LATEST_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    VERSION_NUM=${LATEST_VERSION#v}

    if [ -z "$LATEST_VERSION" ]; then
        echo "Error: Failed to fetch Gitleaks version." >&2
        exit 1
    fi

    LOCAL_BIN="$HOME/.local/bin"
    mkdir -p "$LOCAL_BIN"
    URL="https://github.com/gitleaks/gitleaks/releases/download/${LATEST_VERSION}/gitleaks_${VERSION_NUM}_${OS}_${ARCH}.tar.gz"
    
    if ! curl -sL "$URL" | tar -xz -C "$LOCAL_BIN" gitleaks; then
        echo "Error: Failed to download Gitleaks." >&2
        exit 1
    fi
    chmod +x "$LOCAL_BIN/gitleaks"
}

if ! command -v gitleaks &> /dev/null && ! command -v "$HOME/.local/bin/gitleaks" &> /dev/null; then
    install_gitleaks
fi

export PATH="$HOME/.local/bin:$PATH"

gitleaks protect --staged --verbose
GITLEAKS_STATUS=$?

if [ $GITLEAKS_STATUS -ne 0 ]; then
    echo "COMMIT REJECTED: Secrets detected." >&2
    exit 1
fi

exit 0