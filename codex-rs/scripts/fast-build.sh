#!/bin/bash
# Fast build for codex-tui2
# Uses optimized settings for faster compilation

set -e

echo "🔨 Fast building codex-tui2..."
echo ""

# Build with parallel jobs
time cargo build --package codex-tui2 -j 8

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📦 Binary location: target/debug/"
