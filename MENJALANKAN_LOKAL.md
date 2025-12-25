# Tutorial Menjalankan Aplikasi Go Todo List Secara Lokal

Selamat! Data sudah ada di MongoDB. Sekarang jalankan aplikasinya! 🚀

---

## 📋 Struktur Lengkap

```
gotodolist/
├── go-server/          ← Backend (Go + MongoDB)
│   ├── main.go
│   ├── go.mod
│   ├── .env            ← ✅ Sudah ada
│   ├── middleware/     ← API handlers
│   ├── models/         ← Data models
│   └── router/         ← Routes
│
└── client/             ← Frontend (React)
    ├── src/
    ├── package.json
    └── public/
```

---

## 🔧 Setup & Jalankan Backend (Go Server)

### Step 1: Buka Terminal Pertama

Windows PowerShell atau Command Prompt:
```powershell
cd "C:\Tugas CC\gotodolist\go-server"
```

### Step 2: Download Dependencies (Jika Belum)

```powershell
go mod download
```

**Output:**
```
go: downloading ...
go: downloading ...
```

### Step 3: Jalankan Server

```powershell
go run main.go
```

**Output yang Diharapkan:**
```
Connected to MongoDB!
Collection instance created!
Starting server on port 8080...
```

✅ **Server Go berjalan di: http://localhost:8080**

⚠️ **JANGAN tutup terminal ini!** Biarkan server terus berjalan.

---

## ⚛️ Setup & Jalankan Frontend (React)

### Step 1: Buka Terminal BARU (Jangan close yang lama)

Ctrl+Shift+N di Windows PowerShell untuk terminal baru, atau buka terminal baru.

```powershell
cd "C:\Tugas CC\gotodolist\client"
```

### Step 2: Install Dependencies

```powershell
npm install
```

**Output:**
```
added XXX packages in XXs
```

### Step 3: Jalankan React Development Server

```powershell
npm start
```

**Output:**
```
Compiled successfully!
You can now view client in the browser.
  Local:            http://localhost:3000
  On Your Network:  http://192.168.x.x:3000
```

✅ **Browser akan otomatis membuka: http://localhost:3000**

---

## 🎮 Testing Aplikasi

### Test di Browser

Browser sudah membuka `http://localhost:3000`. Coba:

1. **Lihat daftar task** - Semua data dari MongoDB harus terlihat
2. **Tambah task baru**
   - Isi form "Masukkan tugas"
   - Klik "Tambah"
3. **Tandai task selesai**
   - Klik checkbox pada task
   - Task akan berubah status
4. **Hapus task**
   - Klik tombol X (delete)
   - Task akan hilang

### Test API via Terminal (Optional)

Buka terminal baru dan test:

```powershell
# Lihat semua task
curl http://localhost:8080/api/task

# Tambah task baru
curl -X POST http://localhost:8080/api/task `
  -H "Content-Type: application/json" `
  -d '{
    "task": "Task baru via API",
    "status": false
  }'

# Lihat task lagi
curl http://localhost:8080/api/task
```

---

## 📊 Verifikasi Semuanya Berjalan

### Checklist ✅

- [ ] Terminal 1: Server Go berjalan (port 8080)
- [ ] Terminal 2: React app berjalan (port 3000)
- [ ] Browser bisa akses `http://localhost:3000`
- [ ] Data dari MongoDB terlihat di aplikasi
- [ ] Bisa tambah/edit/hapus task

---

## 🌐 Arsitektur Aplikasi

```
┌─────────────────────────────────────────────┐
│  Browser (React)                            │
│  http://localhost:3000                      │
│                                             │
│  ┌─────────────────────────────────────┐  │
│  │  To-Do-List Component               │  │
│  │  - Tampilkan task                   │  │
│  │  - Form tambah task                 │  │
│  │  - Checkbox mark complete           │  │
│  │  - Delete button                    │  │
│  └─────────────────────────────────────┘  │
└──────────────────┬──────────────────────────┘
                   │
                   │ API Call (HTTP)
                   ↓
┌──────────────────────────────────────────────┐
│  Backend (Go Server)                         │
│  http://localhost:8080                       │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  Router (Gorilla Mux)                │   │
│  │  - GET /api/task                     │   │
│  │  - POST /api/task                    │   │
│  │  - PUT /api/task/{id}                │   │
│  │  - DELETE /api/deleteTask/{id}       │   │
│  └──────────────────────────────────────┘   │
│                   ↓                          │
│  ┌──────────────────────────────────────┐   │
│  │  Middleware (Handlers)               │   │
│  │  - GetAllTask()                      │   │
│  │  - CreateTask()                      │   │
│  │  - TaskComplete()                    │   │
│  │  - DeleteTask()                      │   │
│  └──────────────────────────────────────┘   │
│                   ↓                          │
│  ┌──────────────────────────────────────┐   │
│  │  MongoDB Driver                      │   │
│  │  - Collection: todolist              │   │
│  └──────────────────────────────────────┘   │
└──────────────────┬───────────────────────────┘
                   │
                   │ MongoDB Protocol
                   ↓
┌──────────────────────────────────────────────┐
│  MongoDB Atlas (Cloud)                       │
│  Database: gotodolist                        │
│  Collection: todolist                        │
│                                              │
│  Document 1: { task: "...", status: false } │
│  Document 2: { task: "...", status: true }  │
│  Document 3: { task: "...", status: false } │
└──────────────────────────────────────────────┘
```

---

## 🚀 Data Flow

### 1. Saat Aplikasi Loading
```
React App Start
    ↓
GET /api/task
    ↓
Server Fetch dari MongoDB
    ↓
Return JSON array
    ↓
React Render di UI
```

### 2. Saat Tambah Task
```
User Klik "Tambah"
    ↓
POST /api/task { task, status }
    ↓
Server Insert ke MongoDB
    ↓
Return created document
    ↓
React Add ke list dan update UI
```

### 3. Saat Mark Complete
```
User Klik Checkbox
    ↓
PUT /api/task/{id}
    ↓
Server Update status = true
    ↓
Return updated document
    ↓
React Update UI
```

### 4. Saat Delete
```
User Klik Delete
    ↓
DELETE /api/deleteTask/{id}
    ↓
Server Delete dari MongoDB
    ↓
Return status
    ↓
React Remove dari list dan update UI
```

---

## 🆘 Troubleshooting

### Go Server Error: "no such host"
```
Error: no such host
```
**Solusi:**
- ✅ Check internet connection
- ✅ Check `.env` file DB_URI benar
- ✅ Check MongoDB Atlas cluster aktif

### Go Server Error: "port already in use"
```
Error: listen tcp :8080: bind: An attempt was made to use a port in a way forbidden
```
**Solusi:**
```powershell
# Kill process di port 8080
Get-Process -Id (Get-NetTCPConnection -LocalPort 8080).OwningProcess | Stop-Process -Force

# Atau ubah PORT di .env ke 3001
```

### React: "Cannot GET /"
Browser error saat akses localhost:3000
**Solusi:**
- ✅ Check `npm start` sudah dijalankan
- ✅ Check port 3000 tidak digunakan program lain
- ✅ Wait 10 detik untuk compile React

### React: API 404 Not Found
```
GET http://localhost:8080/api/task 404
```
**Solusi:**
- ✅ Check Go server berjalan (`go run main.go`)
- ✅ Check URL benar: `http://localhost:8080` (bukan 3000)
- ✅ Check CORS di server (sudah dikonfigurasi)

### Cannot Find Module "mongodb"
```
Cannot find module 'mongodb' ...
```
**Solusi:**
```powershell
# Di folder go-server, jalankan:
go mod download
go mod tidy
```

### npm ERR! code ERESOLVE
```
npm ERR! code ERESOLVE
```
**Solusi:**
```powershell
npm install --legacy-peer-deps
```

---

## 📝 File-File Penting

### Backend (Go)

| File | Fungsi |
|------|--------|
| `main.go` | Entry point, setup server |
| `.env` | Konfigurasi database |
| `router/router.go` | Definisi routes |
| `middleware/middleware.go` | API handlers & database operations |
| `models/models.go` | Struktur data ToDoList |

### Frontend (React)

| File | Fungsi |
|------|--------|
| `src/index.js` | Entry point React |
| `src/App.js` | Main component |
| `src/To-Do-List.js` | To-do list component |
| `src/App.css` | Styling |

---

## 💡 Tips Development

### Hot Reload untuk Go
```powershell
go install github.com/cosmtrek/air@latest
air
```

### Hot Reload untuk React
Sudah built-in. File auto-reload saat ada perubahan.

### Debug di Browser
1. Buka DevTools: F12
2. Tab "Network" - lihat API calls
3. Tab "Console" - lihat errors

---

## ✨ Selesai!

Aplikasi Go Todo List sudah berjalan! 🎉

**Dua Terminal Harus Tetap Terbuka:**
- Terminal 1: `go run main.go` (Backend)
- Terminal 2: `npm start` (Frontend)

**URL Aplikasi:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080/api/task

Happy coding! 🚀
