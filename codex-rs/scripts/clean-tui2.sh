#!/bin/bash
# Clean build artifacts for codex-tui2

set -e

echo "🧹 Cleaning codex-tui2 build artifacts..."
echo ""

# Clean only tui2 package
cargo clean --package codex-tui2

echo "✅ Clean completed!"
echo ""
echo "💡 Next build will be slower (full rebuild)"
echo "   Subsequent builds will be fast again (incremental)"
