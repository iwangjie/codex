#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_RS_DIR="${SCRIPT_DIR}/codex-rs"

# Check if codex-rs directory exists
if [ ! -d "$CODEX_RS_DIR" ]; then
    print_error "codex-rs directory not found at: $CODEX_RS_DIR"
    exit 1
fi

print_info "Building Codex release version..."
print_info "Working directory: $CODEX_RS_DIR"
echo ""

# Change to codex-rs directory
cd "$CODEX_RS_DIR"

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    print_error "cargo not found. Please install Rust toolchain first."
    print_info "Run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# Show Rust version
print_info "Rust version: $(rustc --version)"
print_info "Cargo version: $(cargo --version)"
echo ""

# Build release version
print_info "Starting release build (this may take a few minutes)..."
echo ""

if cargo build --release --bin codex; then
    echo ""
    print_success "Build completed successfully!"
    echo ""

    # Get binary info
    BINARY_PATH="${CODEX_RS_DIR}/target/release/codex"

    if [ -f "$BINARY_PATH" ]; then
        BINARY_SIZE=$(du -h "$BINARY_PATH" | cut -f1)
        print_info "Binary location: $BINARY_PATH"
        print_info "Binary size: $BINARY_SIZE"
        echo ""

        # Show how to run
        print_success "You can now run codex with:"
        echo "  $BINARY_PATH"
        echo ""
        echo "Or install it to your PATH:"
        echo "  cp $BINARY_PATH /usr/local/bin/codex"
        echo ""
    else
        print_warning "Binary not found at expected location: $BINARY_PATH"
    fi
else
    echo ""
    print_error "Build failed!"
    exit 1
fi
