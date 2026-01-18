# Codex-RS Scripts

This directory contains helper scripts for faster development workflow.

## 🚀 Quick Start

### 1. Install Optimization Tools
```bash
./scripts/install-tools.sh
```

This installs:
- LLVM (lld linker) - 1.5-2x faster linking
- sccache - Compilation caching
- cargo-watch - Auto-reload on file changes
- cargo-nextest - Faster test runner

### 2. Configure Your Shell

Add to `~/.zshrc` or `~/.bashrc`:
```bash
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export RUSTC_WRAPPER=sccache
export RUSTFLAGS="-C link-arg=-fuse-ld=lld"
```

Then reload:
```bash
source ~/.zshrc
```

## 📜 Available Scripts

### Development Scripts

#### `fast-check.sh` - Quick Syntax Check (Recommended)
```bash
./scripts/fast-check.sh
```
- **Speed**: 3-5x faster than build
- **Use case**: Quick validation during development
- **Output**: Compilation errors only, no binary

#### `watch-tui2.sh` - Auto-Reload Development
```bash
./scripts/watch-tui2.sh
```
- **Speed**: 2-3 seconds per check
- **Use case**: Active development
- **Behavior**: Auto-checks on file save

#### `fast-build.sh` - Optimized Build
```bash
./scripts/fast-build.sh
```
- **Speed**: 1.5-2x faster than default
- **Use case**: Before commit/testing
- **Output**: Binary in `target/debug/`

### Testing Scripts

#### `test-tui2.sh` - Run Tests
```bash
./scripts/test-tui2.sh
```
- Uses cargo-nextest if available (faster)
- Falls back to cargo test

### Utility Scripts

#### `clean-tui2.sh` - Clean Build Artifacts
```bash
./scripts/clean-tui2.sh
```
- Removes only tui2 build artifacts
- Use when build cache is corrupted

#### `timing-report.sh` - Analyze Build Time
```bash
./scripts/timing-report.sh
```
- Generates HTML timing report
- Shows which dependencies are slow
- Opens: `target/cargo-timings/cargo-timing.html`

## 🎯 Recommended Workflow

### Daily Development
```bash
# Terminal 1: Auto-check on save
./scripts/watch-tui2.sh

# Terminal 2: Edit code
# Save files and see results in 2-3 seconds!
```

### Before Commit
```bash
# 1. Quick check
./scripts/fast-check.sh

# 2. Full build
./scripts/fast-build.sh

# 3. Run tests
./scripts/test-tui2.sh
```

### Troubleshooting
```bash
# Clean and rebuild
./scripts/clean-tui2.sh
./scripts/fast-build.sh

# Analyze slow compilation
./scripts/timing-report.sh
```

## 📊 Performance Comparison

| Command | Time (First) | Time (Incremental) | Use Case |
|---------|-------------|-------------------|----------|
| `cargo build` | ~30s | ~10s | Full build |
| `./scripts/fast-build.sh` | ~20s | ~6s | Optimized build |
| `./scripts/fast-check.sh` | ~15s | ~3s | Quick validation |
| `./scripts/watch-tui2.sh` | - | ~2s | Auto-reload |

## 🔧 Advanced Usage

### Custom Parallel Jobs
```bash
# Use 4 cores instead of 8
cargo build --package codex-tui2 -j 4
```

### Check Specific Features
```bash
# Check without default features
cargo check --package codex-tui2 --no-default-features

# Check with specific features
cargo check --package codex-tui2 --features "feature-name"
```

### Verbose Output
```bash
# See detailed compilation steps
cargo build --package codex-tui2 -vv
```

## 🐛 Troubleshooting

### lld linker not found
```bash
# Check LLVM installation
brew list llvm

# Add to PATH
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# Verify
which lld
```

### sccache not working
```bash
# Check status
sccache --show-stats

# Restart
sccache --stop-server
sccache --start-server

# Verify environment
echo $RUSTC_WRAPPER
```

### Still slow compilation
```bash
# Check incremental compilation
cargo clean
CARGO_INCREMENTAL=1 cargo build --package codex-tui2

# Reduce parallel jobs if low memory
cargo build --package codex-tui2 -j 2
```

## 💡 Tips

1. **Use `cargo check` for quick validation** - 3-5x faster than build
2. **Use `cargo watch` during development** - Auto-reload on save
3. **Install lld linker** - 1.5-2x faster linking
4. **Use sccache** - Cache compilation results
5. **Keep incremental compilation enabled** - Much faster rebuilds

## 📚 More Information

See `COMPILATION_OPTIMIZATION.md` for detailed optimization guide.

---

*Last Updated: 2026-01-18*
