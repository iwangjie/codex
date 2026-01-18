#!/bin/bash
# Show compilation timing information

set -e

echo "⏱️  Building with timing information..."
echo ""

# Build with timing report
cargo build --package codex-tui2 --timings

echo ""
echo "✅ Build completed!"
echo ""
echo "📊 Timing report generated:"
echo "   Open: target/cargo-timings/cargo-timing.html"
echo ""
echo "💡 This shows which dependencies take longest to compile"
