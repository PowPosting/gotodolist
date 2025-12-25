# Setup CI/CD untuk Auto Deploy ke GCP

## 1. Buat Service Account di GCP

Jalankan di Cloud Shell:

```bash
# Buat service account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Deployer"

# Berikan permission untuk App Engine dan Cloud Run
gcloud projects add-iam-policy-binding tugas-cc-480903 \
  --member="serviceAccount:github-actions@tugas-cc-480903.iam.gserviceaccount.com" \
  --role="roles/appengine.appAdmin"

gcloud projects add-iam-policy-binding tugas-cc-480903 \
  --member="serviceAccount:github-actions@tugas-cc-480903.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding tugas-cc-480903 \
  --member="serviceAccount:github-actions@tugas-cc-480903.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding tugas-cc-480903 \
  --member="serviceAccount:github-actions@tugas-cc-480903.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Buat JSON key
gcloud iam service-accounts keys create ~/github-actions-key.json \
  --iam-account=github-actions@tugas-cc-480903.iam.gserviceaccount.com

# Tampilkan isi key (copy ini untuk GitHub Secret)
cat ~/github-actions-key.json
```

## 2. Tambahkan Secret di GitHub

1. Buka https://github.com/PowPosting/gotodolist/settings/secrets/actions
2. Click **"New repository secret"**
3. Name: `GCP_SA_KEY`
4. Value: Paste seluruh isi JSON key dari langkah 1
5. Click **"Add secret"**

## 3. Cara Kerja

Setelah setup selesai:

### Backend (Go Server)
```bash
# Edit file backend
cd c:\Users\AdmiN\go-to-do-app\go-server
# ... edit main.go atau file lain ...

# Commit dan push
git add go-server/
git commit -m "Update backend: deskripsi perubahan"
git push origin main
```
✅ **Otomatis deploy ke App Engine!**

### Frontend (React)
```bash
# Edit file frontend
cd c:\Users\AdmiN\go-to-do-app\client
# ... edit src/To-Do-List.js atau file lain ...

# Commit dan push
git add client/
git commit -m "Update frontend: deskripsi perubahan"
git push origin main
```
✅ **Otomatis build & deploy ke Cloud Run!**

## 4. Monitor Deployment

Cek status deployment di:
- GitHub Actions: https://github.com/PowPosting/gotodolist/actions
- App Engine: https://console.cloud.google.com/appengine
- Cloud Run: https://console.cloud.google.com/run

## 5. Rollback (jika perlu)

### Backend:
```bash
gcloud app versions list
gcloud app services set-traffic default --splits=VERSION_ID=1
```

### Frontend:
```bash
gcloud run revisions list --service=gotodolist-frontend --region=asia-southeast2
gcloud run services update-traffic gotodolist-frontend \
  --to-revisions=REVISION_NAME=100 \
  --region=asia-southeast2
```
