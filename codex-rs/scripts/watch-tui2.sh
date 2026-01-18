#!/bin/bash
# Watch codex-tui2 for changes and auto-check
# Requires: cargo install cargo-watch

set -e

# Check if cargo-watch is installed
if ! command -v cargo-watch &> /dev/null; then
    echo "❌ cargo-watch not found!"
    echo ""
    echo "Install it with:"
    echo "  cargo install cargo-watch"
    echo ""
    exit 1
fi

echo "👀 Watching codex-tui2 for changes..."
echo "💡 Save any file to trigger auto-check"
echo "🛑 Press Ctrl+C to stop"
echo ""

# Watch and auto-check on file changes
# -c: clear screen before each run
# -q: quiet mode (less output)
cargo watch -x 'check --package codex-tui2' -c -q
