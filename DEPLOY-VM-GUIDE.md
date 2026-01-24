# Tutorial Deploy Go-To-Do App ke Google Cloud VM

Panduan lengkap setup aplikasi dari awal sampai production-ready.

---

## 📋 Prerequisites

- Akun Google Cloud Platform (GCP)
- Git terinstall di komputer local
- Akses ke repository GitHub

---

## 1️⃣ Setup Google Cloud VM

### A. Buat VM Instance

**Via gcloud CLI (Recommended):**

```bash
gcloud compute instances create todo-app-vm \
  --zone=asia-southeast2-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=http-server,https-server
```

**Via Console:**

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. **Compute Engine** → **VM instances** → **CREATE INSTANCE**
3. Konfigurasi:
   - **Name**: `todo-app-vm`
   - **Region**: `asia-southeast2` (Jakarta)
   - **Zone**: `asia-southeast2-a`
   - **Machine type**: `e2-medium` (2 vCPU, 4 GB memory)
   - **Boot disk**: Ubuntu 22.04 LTS, 20 GB
   - **Firewall**: 
     - ☑️ Allow HTTP traffic
     - ☑️ Allow HTTPS traffic
4. Klik **CREATE**

### B. SSH ke VM

```bash
gcloud compute ssh todo-app-vm --zone=asia-southeast2-a
```

---

## 2️⃣ Install Docker di VM

**Setelah SSH masuk ke VM, jalankan:**

```bash
# Update package list
sudo apt-get update

# Install Docker & Docker Compose
sudo apt-get install -y docker.io docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Tambahkan user ke docker group (agar tidak perlu sudo)
sudo usermod -aG docker $USER

# Apply group changes (logout & login kembali, atau jalankan)
newgrp docker

# Verifikasi instalasi
docker --version
docker-compose --version
```

**Output yang diharapkan:**
```
Docker version 24.x.x
docker-compose version 1.29.x
```

---

## 3️⃣ Clone Repository

```bash
# Clone dari GitHub
git clone https://github.com/PowPosting/gotodolist.git

# Masuk ke directory
cd gotodolist

# Cek struktur project
ls -la
```

**File penting yang harus ada:**
- `docker-compose.yml`
- `client/Dockerfile`
- `go-server/Dockerfile`
- `client/nginx.conf`

---

## 4️⃣ Setup Firewall Rules

### Opsi A: Via gcloud CLI (dari komputer local)

```bash
# Buat firewall rule untuk port 3000 (frontend)
gcloud compute firewall-rules create allow-todo-app \
  --allow=tcp:3000 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server \
  --description="Allow access to Todo App on port 3000"

# Pastikan VM punya tag http-server
gcloud compute instances add-tags todo-app-vm \
  --tags=http-server \
  --zone=asia-southeast2-a
```

### Opsi B: Via Console

1. Buka [Firewall Rules](https://console.cloud.google.com/networking/firewalls/list)
2. Klik **CREATE FIREWALL RULE**
3. Konfigurasi:
   - **Name**: `allow-todo-app`
   - **Direction**: Ingress
   - **Targets**: Specified target tags
   - **Target tags**: `http-server`
   - **Source IPv4 ranges**: `0.0.0.0/0`
   - **Protocols and ports**: 
     - ☑️ Specified protocols and ports
     - **TCP**: `3000`
4. Klik **CREATE**

5. Edit VM untuk tambahkan network tag:
   - Buka VM instance → Klik **EDIT**
   - **Network tags**: tambahkan `http-server`
   - **SAVE**

---

## 5️⃣ Build & Run Aplikasi

**Di VM (masih di directory `~/gotodolist`):**

```bash
# Build dan jalankan semua containers
docker-compose up -d --build

# Tunggu 3-5 menit untuk build selesai
# Cek status containers
docker-compose ps
```

**Output yang diharapkan:**
```
    Name                  Command               State                        Ports                      
--------------------------------------------------------------------------------------------------------
go-server      ./main                           Up      0.0.0.0:8080->8080/tcp
mongodb        docker-entrypoint.sh mongod      Up      0.0.0.0:27017->27017/tcp
react-client   /docker-entrypoint.sh ngin ...   Up      0.0.0.0:3000->8080/tcp
```

Semua status harus **Up** ✅

### Troubleshooting Build

Kalau ada container yang error atau restart terus:

```bash
# Cek logs
docker-compose logs -f

# Atau cek logs per service
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mongo
```

---

## 6️⃣ Dapatkan External IP VM

**Di VM:**

```bash
curl -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip
```

**Atau dari komputer local:**

```bash
gcloud compute instances describe todo-app-vm \
  --zone=asia-southeast2-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

**Simpan IP ini** (contoh: `34.128.86.73`)

---

## 7️⃣ Test Aplikasi

Buka browser dan akses:

```
http://YOUR_EXTERNAL_IP:3000
```

Contoh: `http://34.128.86.73:3000`

**Test Functionality:**
1. ✅ Halaman muncul dengan judul "Aplikasi To Do List 2"
2. ✅ Input box untuk "Create Task"
3. ✅ Tambah task baru → muncul di list
4. ✅ Edit task → berhasil update
5. ✅ Delete task → hilang dari list
6. ✅ Refresh browser → data tetap ada (tersimpan di MongoDB)

---

## 8️⃣ Monitoring & Maintenance

### Cek Status Containers

```bash
cd ~/gotodolist
docker-compose ps
```

### Cek Logs

```bash
# Semua containers
docker-compose logs -f

# Specific container
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f mongo
```

### Restart Containers

```bash
# Restart semua
docker-compose restart

# Restart specific
docker-compose restart frontend
```

### Stop Aplikasi

```bash
docker-compose down
```

### Start Aplikasi

```bash
docker-compose up -d
```

---

## 9️⃣ Update Aplikasi (Workflow)

Ketika ada perubahan code di local:

### Di Komputer Local (Windows):

```bash
cd c:\Users\AdmiN\go-to-do-app

# 1. Edit file yang diperlukan
# 2. Test (optional)
docker-compose up -d --build

# 3. Commit & Push
git add .
git commit -m "Update: deskripsi perubahan"
git push origin main
```

### Di VM:

```bash
cd ~/gotodolist

# Pull update terbaru
git pull origin main

# Rebuild dan restart
docker-compose down
docker-compose up -d --build

# Cek logs
docker-compose logs -f
```

### Buat Script Auto-Update (Recommended)

```bash
# Buat script update.sh
cat > ~/gotodolist/update.sh << 'EOF'
#!/bin/bash
cd ~/gotodolist
echo "🔄 Pulling latest code..."
git pull origin main
echo "🛑 Stopping containers..."
docker-compose down
echo "🔨 Building and starting..."
docker-compose up -d --build
echo "✅ Update complete!"
docker-compose ps
EOF

# Buat executable
chmod +x ~/gotodolist/update.sh
```

**Setiap update tinggal jalankan:**

```bash
~/gotodolist/update.sh
```

---

## 🔟 Tips & Best Practices

### A. Backup MongoDB Data

```bash
# Backup
docker exec mongodb mongodump --out /data/backup

# Copy ke host
docker cp mongodb:/data/backup ./mongodb-backup-$(date +%Y%m%d)
```

### B. Cleanup Docker

```bash
# Hapus unused images & containers
docker system prune -a

# Hapus volumes (HATI-HATI: data MongoDB akan hilang!)
docker volume prune
```

### C. Monitor Resource Usage

```bash
# Cek resource per container
docker stats

# Cek disk usage
df -h
docker system df
```

### D. Auto-start on VM Reboot

```bash
# Buat systemd service
sudo cat > /etc/systemd/system/todoapp.service << 'EOF'
[Unit]
Description=Todo App Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/YOUR_USERNAME/gotodolist
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=YOUR_USERNAME

[Install]
WantedBy=multi-user.target
EOF

# Ganti YOUR_USERNAME dengan username VM Anda
# Enable service
sudo systemctl enable todoapp.service
sudo systemctl start todoapp.service
```

---

## ⚠️ Troubleshooting

### Problem: Container keeps restarting

```bash
# Cek logs untuk error
docker-compose logs backend
docker-compose logs frontend

# Rebuild tanpa cache
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Problem: Cannot access from browser

```bash
# 1. Cek firewall rule exists
gcloud compute firewall-rules list | grep allow-todo-app

# 2. Cek VM punya network tag
gcloud compute instances describe todo-app-vm \
  --zone=asia-southeast2-a \
  --format='get(tags.items)'

# 3. Cek container running
docker-compose ps

# 4. Test dari VM
curl http://localhost:3000
```

### Problem: CORS Error / localhost:8080

```bash
# Rebuild frontend dengan no-cache
cd ~/gotodolist
docker-compose down
docker rmi go-to-do-client:latest -f
docker system prune -a -f
docker-compose build --no-cache frontend
docker-compose up -d

# Verify di browser dengan Incognito mode
```

### Problem: MongoDB data hilang setelah restart

```bash
# Pastikan volume tetap ada
docker volume ls | grep mongo

# Cek docker-compose.yml punya volume mapping
cat docker-compose.yml | grep -A 5 "mongo-data"
```

---

## 📊 Arsitektur Aplikasi

```
┌─────────────────────────────────────────────────┐
│              Google Cloud VM                     │
│  ┌───────────────────────────────────────────┐  │
│  │         Docker Compose Network            │  │
│  │                                            │  │
│  │  ┌──────────┐  ┌──────────┐  ┌─────────┐ │  │
│  │  │  Nginx   │  │ Go Server│  │ MongoDB │ │  │
│  │  │ (React)  │◄─┤ (Backend)│◄─┤  (DB)   │ │  │
│  │  │          │  │          │  │         │ │  │
│  │  │ Port 3000│  │ Port 8080│  │Port 27017│ │  │
│  │  └────┬─────┘  └──────────┘  └─────────┘ │  │
│  │       │                                    │  │
│  │       │ /api/* → proxy ke backend         │  │
│  │       │ /*     → serve React static       │  │
│  └───────┼────────────────────────────────────┘  │
│          │                                        │
│  Port 3000 (Firewall: allow-todo-app)           │
└──────────┼─────────────────────────────────────┘
           │
      Internet
           │
    ┌──────▼──────┐
    │   Browser   │
    │ (Users)     │
    └─────────────┘
```

---

## 🎯 Checklist Deploy

- [ ] VM Created & SSH access OK
- [ ] Docker & Docker Compose installed
- [ ] Repository cloned
- [ ] Firewall rules configured
- [ ] VM has network tag `http-server`
- [ ] `docker-compose up -d --build` running
- [ ] All containers status: **Up**
- [ ] External IP obtained
- [ ] Application accessible from browser
- [ ] Can create/edit/delete tasks
- [ ] Data persists after browser refresh
- [ ] Update script created (`update.sh`)

---

## 📚 Useful Commands Reference

```bash
# Container Management
docker-compose ps                    # Status
docker-compose logs -f               # Logs (all)
docker-compose logs -f frontend      # Logs (specific)
docker-compose restart               # Restart all
docker-compose down                  # Stop all
docker-compose up -d                 # Start all

# Update Workflow
git pull origin main                 # Pull updates
docker-compose down                  # Stop
docker-compose up -d --build         # Rebuild & start

# Cleanup
docker system prune -a               # Remove unused
docker volume prune                  # Remove unused volumes
docker-compose down -v               # Stop & remove volumes

# Debugging
docker exec -it react-client sh      # Shell into container
docker exec -it go-server sh
docker inspect <container_name>      # Inspect container
```

---

## 🔗 Links

- **Repository**: https://github.com/PowPosting/gotodolist
- **GCP Console**: https://console.cloud.google.com/
- **Firewall Rules**: https://console.cloud.google.com/networking/firewalls/list
- **VM Instances**: https://console.cloud.google.com/compute/instances

---

## 📞 Support

Kalau ada masalah, cek:
1. Logs: `docker-compose logs -f`
2. Container status: `docker-compose ps`
3. Firewall: Port 3000 terbuka?
4. VM Tag: `http-server` sudah ada?
5. Browser: Coba Incognito mode

---

**Created**: January 2026  
**Last Updated**: January 2026
