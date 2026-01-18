# Version Management Guide

## Semantic Versioning

Aplikasi ini menggunakan [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH (contoh: 1.2.3)
```

- **MAJOR** (1.x.x): Breaking changes - perubahan yang tidak kompatibel
- **MINOR** (x.1.x): New features - fitur baru yang kompatibel
- **PATCH** (x.x.1): Bug fixes - perbaikan bug

---

## 📋 Cara Mengatur Versi

### Method 1: Manual Tagging (Recommended)

```bash
# 1. Pastikan semua perubahan sudah di-commit
git add .
git commit -m "Add new feature"

# 2. Buat tag versi
git tag -a v1.0.0 -m "Release version 1.0.0"

# 3. Push tag ke GitHub
git push origin v1.0.0

# Atau push semua tags
git push --tags
```

### Method 2: Automated dengan Script

```bash
# Patch version (1.0.0 → 1.0.1)
./version.sh patch "Bug fixes"

# Minor version (1.0.1 → 1.1.0)
./version.sh minor "Add new feature"

# Major version (1.1.0 → 2.0.0)
./version.sh major "Breaking changes"
```

### Method 3: GitHub Release

1. Buka repository di GitHub
2. Klik **Releases** → **Create a new release**
3. Klik **Choose a tag** → Ketik `v1.0.0` → **Create new tag**
4. Isi:
   - **Release title**: `Version 1.0.0`
   - **Description**: Changelog dan fitur baru
5. Klik **Publish release**

---

## 🔄 Automated Versioning di CI/CD

### Trigger Deployment berdasarkan Tag

Push tag akan otomatis trigger deployment:

```bash
# Buat dan push tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# GitHub Actions akan otomatis:
# 1. Build dengan version tag
# 2. Deploy ke VM
# 3. Create GitHub Release
```

### Deploy Specific Version

```bash
# Deploy versi tertentu
git checkout v1.0.0
git push origin main --force

# Atau rollback ke versi sebelumnya
git checkout v0.9.0
```

---

## 📝 Version File

### Backend (Go)
File [go-server/version.go](go-server/version.go):
```go
package main

const Version = "1.0.0"
```

### Frontend (React)
File [client/package.json](client/package.json):
```json
{
  "version": "1.0.0"
}
```

### Docker Image Tags
```bash
# Build dengan version tag
docker build -t go-server:1.0.0 ./go-server
docker build -t react-client:1.0.0 ./client

# Tag sebagai latest
docker tag go-server:1.0.0 go-server:latest
```

---

## 🏷️ Tag Naming Convention

### Production Releases
```bash
v1.0.0          # Production release
v1.0.1          # Patch release
v2.0.0          # Major release
```

### Pre-releases
```bash
v1.0.0-alpha    # Alpha version
v1.0.0-beta     # Beta version
v1.0.0-rc.1     # Release candidate
```

### Development
```bash
v1.0.0-dev      # Development version
```

---

## 📊 Version History

### Melihat Semua Versi

```bash
# List semua tags
git tag

# List tags dengan pattern
git tag -l "v1.*"

# Show tag detail
git show v1.0.0

# List tags dengan tanggal
git log --tags --simplify-by-decoration --pretty="format:%ai %d"
```

### Membandingkan Versi

```bash
# Compare dua versi
git diff v1.0.0 v1.1.0

# Show changes in specific version
git show v1.0.0

# List commits between versions
git log v1.0.0..v1.1.0 --oneline
```

---

## 🔖 Changelog Management

### Generate Changelog Otomatis

```bash
# Install changelog generator
npm install -g conventional-changelog-cli

# Generate CHANGELOG.md
conventional-changelog -p angular -i CHANGELOG.md -s

# Atau manual update CHANGELOG.md
```

### Format Changelog

```markdown
# Changelog

## [1.1.0] - 2026-01-18

### Added
- New todo filtering feature
- Export to PDF functionality

### Changed
- Improved UI responsiveness
- Updated dependencies

### Fixed
- Fixed delete button bug
- Fixed API timeout issue

## [1.0.0] - 2026-01-01

### Added
- Initial release
- Basic CRUD operations
- Docker support
```

---

## 🚀 Release Workflow

### 1. Development
```bash
# Feature branch
git checkout -b feature/new-feature
# ... develop ...
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

### 2. Merge to Main
```bash
# Create PR and merge
# Or direct merge
git checkout main
git merge feature/new-feature
git push origin main
```

### 3. Create Release
```bash
# Update version
./version.sh minor "Add new feature"

# Or manual
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0
```

### 4. Verify Deployment
```bash
# Check GitHub Actions
# Check VM: curl http://VM_IP/version
```

---

## 🔧 Version Commands

### Git Tag Commands

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0"

# Create lightweight tag
git tag v1.0.0

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0
# Or
git push origin --delete v1.0.0

# Push specific tag
git push origin v1.0.0

# Push all tags
git push --tags

# Fetch all tags
git fetch --tags

# Checkout specific version
git checkout v1.0.0

# Create branch from tag
git checkout -b hotfix-1.0.1 v1.0.0
```

---

## 📦 Docker Image Versioning

### Build dengan Version

```bash
# Set version
export VERSION=1.0.0

# Build dengan version tag
docker build -t gcr.io/PROJECT_ID/go-server:$VERSION ./go-server
docker build -t gcr.io/PROJECT_ID/go-server:latest ./go-server

docker build -t gcr.io/PROJECT_ID/react-client:$VERSION ./client
docker build -t gcr.io/PROJECT_ID/react-client:latest ./client

# Push both tags
docker push gcr.io/PROJECT_ID/go-server:$VERSION
docker push gcr.io/PROJECT_ID/go-server:latest
```

### Deploy Specific Version

```bash
# Deploy specific version
docker pull gcr.io/PROJECT_ID/go-server:1.0.0
docker run -d -p 8080:8080 gcr.io/PROJECT_ID/go-server:1.0.0
```

---

## 🎯 Best Practices

### 1. **Always Tag Releases**
```bash
# Bad
git push origin main

# Good
git push origin main
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 2. **Use Semantic Versioning**
- Breaking change → bump MAJOR
- New feature → bump MINOR
- Bug fix → bump PATCH

### 3. **Write Good Release Notes**
```bash
# Bad
git tag -a v1.0.0 -m "new version"

# Good
git tag -a v1.0.0 -m "Release v1.0.0: Add filtering, improve performance, fix bugs"
```

### 4. **Keep CHANGELOG.md Updated**
- Document all changes
- Group by type (Added, Changed, Fixed, etc.)
- Include issue/PR references

### 5. **Test Before Release**
```bash
# Test locally
docker-compose up --build

# Run tests
make test

# Then release
git tag -a v1.0.0 -m "Release v1.0.0"
git push --tags
```

---

## 📱 Version Display

### Show Version di Aplikasi

**Backend API Endpoint:**
```go
// GET /api/version
{
  "version": "1.0.0",
  "build": "2026-01-18T10:30:00Z",
  "commit": "abc1234"
}
```

**Frontend UI:**
```jsx
// Footer component
<footer>
  App Version: {process.env.REACT_APP_VERSION}
</footer>
```

---

## 🔄 Version Rollback

### Rollback ke Versi Sebelumnya

```bash
# 1. Checkout ke versi lama
git checkout v1.0.0

# 2. Create rollback tag
git tag -a v1.0.1-rollback -m "Rollback to v1.0.0"

# 3. Push and deploy
git push origin v1.0.1-rollback

# Atau deploy langsung di VM
gcloud compute ssh VM_NAME --command "
  docker pull gcr.io/PROJECT_ID/go-server:1.0.0 &&
  docker stop go-server &&
  docker rm go-server &&
  docker run -d -p 8080:8080 --name go-server gcr.io/PROJECT_ID/go-server:1.0.0
"
```

---

## 📋 Checklist Release

- [ ] All tests passing
- [ ] Code reviewed
- [ ] CHANGELOG.md updated
- [ ] Version bumped in package.json
- [ ] Documentation updated
- [ ] Tagged in git
- [ ] GitHub Release created
- [ ] Deployed to production
- [ ] Verified deployment
- [ ] Announced to team

---

## 🛠️ Tools

### Recommended Tools
- **Git**: Version control dan tagging
- **GitHub Releases**: Release management
- **Conventional Commits**: Commit message standard
- **semantic-release**: Automated versioning
- **CHANGELOG**: Change documentation

### Install Tools
```bash
# Conventional Changelog
npm install -g conventional-changelog-cli

# Semantic Release
npm install -g semantic-release
```

---

## 📚 Resources

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Git Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
