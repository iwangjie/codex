#!/bin/bash
# Quick test runner for codex-tui2

set -e

echo "🧪 Running tests for codex-tui2..."
echo ""

# Check if nextest is available
if command -v cargo-nextest &> /dev/null; then
    echo "Using cargo-nextest (faster)..."
    time cargo nextest run --package codex-tui2
else
    echo "Using cargo test..."
    echo "💡 Install cargo-nextest for faster tests: cargo install cargo-nextest"
    time cargo test --package codex-tui2
fi

echo ""
echo "✅ Tests completed!"
