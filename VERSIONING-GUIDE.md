# Git Tags & Versioning Guide

## Current Tags

```bash
# Lihat semua tags
git tag -l

# Output:
# v1.0.0 - Initial release
# v1.1.0 - MongoDB Atlas integration, nginx proxy, production ready
```

---

## Cara Membuat Tag Baru

### Format Semantic Versioning: `vMAJOR.MINOR.PATCH`

- **MAJOR** (v2.0.0): Breaking changes, tidak backward compatible
- **MINOR** (v1.1.0): New features, backward compatible
- **PATCH** (v1.0.1): Bug fixes

### Workflow Tagging

```bash
# 1. Setelah commit perubahan
git add .
git commit -m "Feature: Add user authentication"

# 2. Buat tag
git tag -a v1.2.0 -m "Release v1.2.0: Add user authentication"

# 3. Push tag ke GitHub
git push origin v1.2.0

# 4. Lihat semua tags
git tag -l
```

---

## Cara Rollback ke Tag/Versi Tertentu

### Opsi 1: Temporary Checkout (Lihat saja, tidak permanent)

```bash
# Checkout ke tag tertentu (read-only mode)
git checkout v1.0.0

# Lihat-lihat aja, test
docker-compose up -d --build

# Kembali ke latest
git checkout main
```

### Opsi 2: Permanent Rollback (Recommended - Safe)

**Di Local:**

```bash
# 1. Lihat tag yang tersedia
git tag -l

# 2. Buat branch baru dari tag
git checkout -b rollback-v1.0.0 v1.0.0

# 3. Merge ke main
git checkout main
git merge rollback-v1.0.0

# 4. Push
git push origin main
```

**Di VM:**

```bash
cd ~/gotodolist
git pull origin main
docker-compose down
docker-compose up -d --build
```

### Opsi 3: Hard Reset to Tag (DANGER!)

```bash
# Reset main branch ke tag tertentu
git checkout main
git reset --hard v1.0.0

# Force push (WARNING: Hapus history!)
git push origin main --force
```

---

## Workflow Production dengan Tags

### 1. Development → Testing → Production

```bash
# Di local: development
git checkout -b feature/new-feature
# ... coding ...
git commit -m "Feature: New feature"

# Merge ke main
git checkout main
git merge feature/new-feature

# Test di local
docker-compose up -d --build

# Kalau OK, buat tag
git tag -a v1.2.0 -m "Release v1.2.0: New feature"
git push origin main
git push origin v1.2.0
```

### 2. Deploy ke Production

**Di VM:**

```bash
cd ~/gotodolist

# Pull tag tertentu
git fetch --tags
git checkout v1.2.0

# Deploy
docker-compose down
docker-compose up -d --build
```

### 3. Rollback Jika Ada Bug

**Di VM (Emergency):**

```bash
cd ~/gotodolist

# Rollback ke tag stabil sebelumnya
git fetch --tags
git checkout v1.1.0

# Rebuild
docker-compose down
docker-compose up -d --build
```

---

## Lihat Info Tag

```bash
# Lihat semua tags
git tag -l

# Lihat detail tag tertentu
git show v1.1.0

# Lihat tags dengan pattern
git tag -l "v1.*"

# Lihat tag di GitHub
https://github.com/PowPosting/gotodolist/tags
```

---

## Delete Tag (Kalau Salah)

```bash
# Delete tag local
git tag -d v1.2.0

# Delete tag di GitHub
git push origin --delete v1.2.0
```

---

## Best Practices

### 1. Tag Setiap Production Deploy

```bash
# Sebelum deploy production
git tag -a v1.x.x -m "Production release: description"
git push origin v1.x.x
```

### 2. Gunakan Annotated Tags (bukan Lightweight)

```bash
# ✅ Good: Annotated tag (ada metadata)
git tag -a v1.0.0 -m "Release message"

# ❌ Bad: Lightweight tag (hanya pointer)
git tag v1.0.0
```

### 3. Consistent Naming

```bash
# Format: vMAJOR.MINOR.PATCH
v1.0.0  # Initial release
v1.0.1  # Bug fix
v1.1.0  # New feature
v2.0.0  # Breaking change
```

### 4. Changelog di Tag Message

```bash
git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Add user authentication
- Add email notifications

Bug Fixes:
- Fix task deletion bug
- Fix mobile responsiveness
"
```

---

## Quick Reference

```bash
# Create & push tag
git tag -a v1.x.x -m "Message"
git push origin v1.x.x

# List tags
git tag -l

# Checkout tag
git checkout v1.x.x

# Delete tag
git tag -d v1.x.x
git push origin --delete v1.x.x

# View tag details
git show v1.x.x
```

---

## Current Version

**Latest Stable**: v1.1.0  
**Features**:
- MongoDB Atlas integration
- Nginx reverse proxy
- Production-ready deployment
- Docker containerization

**View all releases**: https://github.com/PowPosting/gotodolist/tags
