# Setup CI/CD untuk Deploy ke GCP VM dengan Docker

## Prasyarat

1. **GitHub Repository** - Repository sudah dibuat dan kode sudah dipush
2. **Google Cloud Platform Account** - Akun GCP dengan project yang aktif
3. **VM Instance di GCP** - VM sudah dibuat dan berjalan
4. **Docker terinstall di VM** - Docker dan Docker Compose terinstall di VM

---

## Langkah 1: Setup Google Cloud

### 1.1 Buat Service Account
```bash
# Login ke GCP
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Buat service account
gcloud iam service-accounts create github-actions \
    --display-name="GitHub Actions Service Account"

# Berikan permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin.v1"

# Generate key
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 1.2 Setup VM Instance
```bash
# Buat VM instance (jika belum ada)
gcloud compute instances create todo-app-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=http-server,https-server

# Setup firewall rules
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --target-tags http-server

gcloud compute firewall-rules create allow-backend \
    --allow tcp:8080 \
    --target-tags http-server

# SSH ke VM dan install Docker
gcloud compute ssh todo-app-vm --zone=us-central1-a
```

### 1.3 Install Docker di VM
```bash
# Update system
sudo apt-get update

# Install Docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Google Cloud SDK di VM (jika belum ada)
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init

# Tambahkan user ke docker group
sudo usermod -aG docker $USER

# Reboot VM
sudo reboot
```

---

## Langkah 2: Setup GitHub Secrets

1. Buka repository di GitHub
2. Klik **Settings** > **Secrets and variables** > **Actions**
3. Tambahkan secrets berikut:

| Secret Name | Deskripsi | Contoh Value |
|------------|-----------|--------------|
| `GCP_SA_KEY` | Isi dari file `key.json` yang didownload | `{"type":"service_account",...}` |
| `GCP_PROJECT_ID` | ID Project GCP Anda | `my-project-123456` |
| `GCP_VM_NAME` | Nama VM instance | `todo-app-vm` |
| `GCP_VM_ZONE` | Zone VM instance | `us-central1-a` |
| `GCP_VM_IP` | External IP VM | `34.123.45.67` |

### Cara mendapatkan External IP VM:
```bash
gcloud compute instances describe todo-app-vm \
    --zone=us-central1-a \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

---

## Langkah 3: Test Local dengan Docker Compose

```bash
# Build dan jalankan aplikasi
docker-compose up --build

# Test
# Backend: http://localhost:8080
# Frontend: http://localhost:3000
```

---

## Langkah 4: Push ke GitHub dan Deploy

```bash
# Add semua file
git add .

# Commit
git commit -m "Setup CI/CD with Docker"

# Push ke main branch
git push origin main
```

GitHub Actions akan otomatis:
1. Build Docker images untuk backend dan frontend
2. Push images ke Google Container Registry
3. SSH ke VM dan deploy containers

---

## Langkah 5: Verifikasi Deployment

1. **Check GitHub Actions**
   - Buka tab **Actions** di repository GitHub
   - Lihat status workflow yang berjalan

2. **Check Aplikasi**
   - Backend: `http://<VM_IP>:8080`
   - Frontend: `http://<VM_IP>`

3. **Check Logs di VM**
   ```bash
   # SSH ke VM
   gcloud compute ssh todo-app-vm --zone=us-central1-a
   
   # Check running containers
   docker ps
   
   # Check logs
   docker logs go-server
   docker logs react-client
   ```

---

## Troubleshooting

### Error: Permission denied saat SSH
```bash
# Tambahkan SSH key ke metadata VM
gcloud compute config-ssh
```

### Error: Docker command not found di VM
```bash
# Install Docker di VM (lihat langkah 1.3)
```

### Error: Cannot pull image from GCR
```bash
# SSH ke VM dan authenticate
gcloud auth configure-docker
```

### Container tidak bisa berkomunikasi
Pastikan environment variable `REACT_APP_API_URL` sudah benar di frontend:
- Update di `.github/workflows/deploy.yml` pada build argument
- Atau set di docker-compose.yml untuk local development

---

## Monitoring dan Maintenance

### Check Status Container
```bash
docker ps
docker stats
```

### Update Application
Cukup push ke GitHub, CI/CD akan otomatis update:
```bash
git add .
git commit -m "Update feature"
git push origin main
```

### Restart Containers
```bash
docker restart go-server react-client
```

### Clean Up Old Images
```bash
docker image prune -f
```

---

## Alur CI/CD

```
Local Development
    ↓
    ↓ (git push)
    ↓
GitHub Repository
    ↓
    ↓ (trigger)
    ↓
GitHub Actions
    ↓
    ├── Build Docker Images
    ├── Push to GCR
    └── Deploy to VM
        ↓
        ├── Pull Images
        ├── Stop Old Containers
        ├── Run New Containers
        └── Clean Up
            ↓
Application Running on VM
```

---

## Environment Variables

### Backend (.env - optional)
```env
PORT=8080
MONGODB_URI=mongodb://your-mongodb-uri
```

### Frontend
```env
REACT_APP_API_URL=http://YOUR_VM_IP:8080
```

---

## Tips

1. **Use External IP yang Static** - Agar IP VM tidak berubah saat restart
2. **Setup SSL/TLS** - Gunakan Let's Encrypt untuk HTTPS
3. **Add Monitoring** - Setup Google Cloud Monitoring untuk alert
4. **Backup Database** - Jika menggunakan MongoDB, setup backup rutin
5. **Use Docker Networks** - Untuk komunikasi antar container yang lebih aman

---

## Next Steps

1. Setup domain name dan SSL certificate
2. Implement database backup strategy
3. Add health checks di Dockerfile
4. Setup monitoring dan alerting
5. Implement rolling updates untuk zero-downtime deployment
