#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NODE_RED_DIR="${1:-${NODE_RED_HOME:-$HOME/.node-red}}"

command -v node >/dev/null 2>&1 || { echo "Error: Node.js is not installed or not in PATH." >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "Error: npm is not installed or not in PATH." >&2; exit 1; }

NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]")"
if (( NODE_MAJOR < 26 )); then
  echo "Error: Node.js 26 or newer is required; found $(node --version)." >&2
  exit 1
fi

mkdir -p "$NODE_RED_DIR"
if [[ ! -f "$NODE_RED_DIR/package.json" ]]; then
  printf '{\n  "name": "node-red-project",\n  "version": "0.0.1",\n  "private": true\n}\n' > "$NODE_RED_DIR/package.json"
fi

echo "Installing node-red-contrib-mcprotocol from: $SCRIPT_DIR"
echo "Node-RED user directory: $NODE_RED_DIR"
npm install --prefix "$NODE_RED_DIR" "$SCRIPT_DIR"

echo
echo "Installation complete. Restart Node-RED, then refresh the editor."
echo "Verify with: cd \"$NODE_RED_DIR\" && npm list node-red-contrib-mcprotocol"
