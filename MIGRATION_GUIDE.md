# Migration Guide: Hermes → Iris

This guide helps you migrate from Hermes to Iris after the rename.

## What Changed

- **Binary name**: `hermes` → `iris`
- **History file**: `~/.hermes_history` → `~/.iris_history`
- **Temp files**: `/tmp/hermes_*.json` → `/tmp/iris_*.json`
- **Homebrew formula**: Install as `iris` instead of `hermes`
- **Repository name**: Stays as `hermes` (unchanged)

## Migration Steps

### 1. Using the Rename Script (Recommended)

Run the automated rename script:

```bash
./scripts/rename-to-iris.sh
```

This will:
- Rename `bin/hermes` → `bin/iris`
- Update all references in code
- Create `Formula/iris.rb`
- Update all documentation
- Keep repository URLs as `hermes`

### 2. Manual Migration

If you prefer manual migration:

#### A. Binary Rename
```bash
mv bin/hermes bin/iris
```

#### B. Update Binary Content
Replace in `bin/iris`:
- `Hermes` → `Iris`
- `hermes_history` → `iris_history`
- `hermes_realtime` → `iris_realtime`

#### C. Update Formula
```bash
cp Formula/hermes.rb Formula/iris.rb
# Edit Formula/iris.rb to update class name, binary path, etc.
```

#### D. Update Documentation
```bash
# Update all .md files
find . -name "*.md" -exec sed -i '' 's/hermes/iris/g' {} \;
find . -name "*.md" -exec sed -i '' 's/Hermes/Iris/g' {} \;
# Fix repo URLs back to hermes
find . -name "*.md" -exec sed -i '' 's|github.com/mwangiiharun/iris|github.com/mwangiiharun/hermes|g' {} \;
```

### 3. Prepare New Release

After renaming, prepare the release:

```bash
./scripts/prepare-release.sh v5.2
```

This will:
- Update version numbers
- Create release notes
- Update Homebrew formula
- Prepare everything for tagging

### 4. User Migration

Users who have Hermes installed should:

#### A. Uninstall Hermes
```bash
brew uninstall hermes
```

#### B. Install Iris
```bash
brew tap mwangiiharun/homebrew-iris
brew install iris
```

#### C. Migrate History (Optional)
```bash
mv ~/.hermes_history ~/.iris_history
```

#### D. Update Scripts
If you have scripts using `hermes`, update them:
```bash
# Before
hermes --json > results.json

# After
iris --json > results.json
```

## Homebrew Tap Setup

### For Tap Maintainers

1. **Tap repository name**: `homebrew-iris` (new tap name)
2. **Formula name**: Use `iris.rb`
3. **Install command**: `brew install iris`

### Example Tap Structure

```
homebrew-iris/
├── README.md
└── Formula/
    └── iris.rb
```

## Version History

- **v5.1 and earlier**: Named "Hermes"
- **v5.2+**: Renamed to "Iris"

## Compatibility

- ✅ All functionality remains the same
- ✅ Command-line options unchanged
- ✅ Output formats unchanged
- ✅ History file format unchanged
- ⚠️ Binary name changed (hermes → iris)
- ⚠️ Configuration file location changed

## Rollback

If you need to rollback:

```bash
git checkout <previous-commit>
# Or rename back
mv bin/iris bin/hermes
```

## Questions?

- Repository: https://github.com/mwangiiharun/hermes
- Issues: https://github.com/mwangiiharun/hermes/issues

