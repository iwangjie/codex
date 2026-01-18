#!/bin/bash
# Install compilation optimization tools

set -e

echo "🚀 Installing Rust compilation optimization tools..."
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found!"
    echo "Install it from: https://brew.sh"
    exit 1
fi

echo "📦 Installing LLVM (includes lld linker)..."
brew install llvm || echo "LLVM already installed"

echo ""
echo "📦 Installing sccache (compilation cache)..."
brew install sccache || echo "sccache already installed"

echo ""
echo "📦 Installing cargo-watch..."
cargo install cargo-watch || echo "cargo-watch already installed"

echo ""
echo "📦 Installing cargo-nextest (faster test runner)..."
cargo install cargo-nextest || echo "cargo-nextest already installed"

echo ""
echo "✅ All tools installed!"
echo ""
echo "📝 Next steps:"
echo "1. Add to your ~/.zshrc or ~/.bashrc:"
echo '   export PATH="/opt/homebrew/opt/llvm/bin:$PATH"'
echo '   export RUSTC_WRAPPER=sccache'
echo '   export RUSTFLAGS="-C link-arg=-fuse-ld=lld"'
echo ""
echo "2. Reload your shell:"
echo "   source ~/.zshrc"
echo ""
echo "3. Test the setup:"
echo "   ./scripts/fast-check.sh"
