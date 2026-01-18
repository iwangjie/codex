#!/bin/bash
# Fast check for codex-tui2
# This only checks if the code compiles without generating binaries (3-5x faster)

set -e

echo "🔍 Fast checking codex-tui2..."
echo ""

# Use cargo check which is much faster than build
time cargo check --package codex-tui2

echo ""
echo "✅ Check completed successfully!"
echo ""
echo "💡 Tip: Use 'cargo watch -x \"check --package codex-tui2\"' for auto-reload"
