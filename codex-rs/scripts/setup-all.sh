#!/bin/bash
# Complete setup script - Run this to set up everything at once

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   🚀 Codex-TUI2 编译优化 - 完整设置                           ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Check prerequisites
echo "📋 Step 1/4: Checking prerequisites..."
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust/Cargo not found!"
    exit 1
fi
echo "✅ Rust/Cargo found"
echo ""

# Step 2: Install tools (optional)
echo "📦 Step 2/4: Installing optimization tools (optional)..."
echo "This will install: LLVM (lld), sccache, cargo-watch, cargo-nextest"
read -p "Install tools? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/install-tools.sh
else
    echo "⏭️  Skipping tool installation"
fi
echo ""

# Step 3: Configure environment
echo "⚙️  Step 3/4: Configuring environment..."
echo ""
echo "Add these lines to your ~/.zshrc or ~/.bashrc:"
echo ""
echo "  export PATH=\"/opt/homebrew/opt/llvm/bin:\$PATH\""
echo "  export RUSTC_WRAPPER=sccache"
echo ""
read -p "Add to ~/.zshrc now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "" >> ~/.zshrc
    echo "# Rust compilation optimization" >> ~/.zshrc
    echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc
    echo 'export RUSTC_WRAPPER=sccache' >> ~/.zshrc
    echo "✅ Added to ~/.zshrc"
    echo "⚠️  Run 'source ~/.zshrc' to apply changes"
else
    echo "⏭️  Skipping environment configuration"
fi
echo ""

# Step 4: Test the setup
echo "🧪 Step 4/4: Testing the setup..."
echo ""
echo "Running fast-check to verify configuration..."
./scripts/fast-check.sh
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║   ✅ 设置完成！                                               ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "🎯 下一步:"
echo ""
echo "1. 重新加载环境变量:"
echo "   source ~/.zshrc"
echo ""
echo "2. 开始使用自动重载:"
echo "   ./scripts/watch-tui2.sh"
echo ""
echo "3. 或使用快速检查:"
echo "   ./scripts/fast-check.sh"
echo ""
echo "📚 查看文档:"
echo "   cat OPTIMIZATION_SUMMARY.md"
echo ""
echo "🎉 享受更快的编译速度！"
