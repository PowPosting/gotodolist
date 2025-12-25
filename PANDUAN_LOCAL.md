# Panduan Menjalankan Go Todo List Secara Lokal

## 📋 Prasyarat

Sebelum memulai, pastikan Anda telah menginstall:

1. **Go** (versi 1.21 atau lebih tinggi)
   - Download: https://golang.org/dl/
   - Verifikasi: `go version`

2. **Node.js** dan **npm** (untuk React frontend)
   - Download: https://nodejs.org/
   - Verifikasi: `node --version` dan `npm --version`

3. **Git** (untuk version control)
   - Download: https://git-scm.com/

4. **MongoDB Atlas Account** (cloud database)
   - Daftar gratis: https://www.mongodb.com/cloud/atlas

---

## 🔧 Langkah-Langkah Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd gotodolist
```

### 2. Setup Backend (Go Server)

#### A. Masuk ke direktori server
```bash
cd go-server
```

#### B. Buat file `.env` dari template
**Windows (PowerShell):**
```powershell
Copy-Item .env.example -Destination .env
```

**Linux/macOS:**
```bash
cp .env.example .env
```

#### C. Edit file `.env` dengan MongoDB connection string

Buka file `.env` dengan text editor dan isi dengan:
```env
DB_URI="mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority"
DB_NAME="gotodolist"
DB_COLLECTION_NAME="todolist"
PORT="8080"
```

**Cara mendapatkan `DB_URI`:**
1. Login ke [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Buat cluster baru (free tier tersedia)
3. Klik "Connect" pada cluster Anda
4. Pilih "Drivers"
5. Copy connection string dan ganti `<password>` dengan password Anda

#### D. Download dependencies
```bash
go mod download
```

#### E. Jalankan server Go
```bash
go run main.go
```

**Output yang diharapkan:**
```
Connected to MongoDB!
Collection instance created!
Starting server on port 8080...
```

Jika berhasil, server berjalan di: **http://localhost:8080**

---

### 3. Setup Frontend (React Client)

Buka **terminal baru** dan:

#### A. Masuk ke direktori client
```bash
cd client
```

#### B. Install npm dependencies
```bash
npm install
```

#### C. Jalankan React development server
```bash
npm start
```

Aplikasi akan otomatis membuka di browser: **http://localhost:3000**

---

## 🚀 Cek Apakah Semuanya Berjalan

### Test Backend
```bash
curl http://localhost:8080/api/task
```

Atau gunakan Postman/Insomnia untuk test API.

### Test Frontend
Buka browser: http://localhost:3000

Coba:
- ✅ Tambah task baru
- ✅ Tandai task selesai
- ✅ Hapus task

---

## 📁 Struktur File

```
gotodolist/
├── go-server/              # Backend (Go + MongoDB)
│   ├── main.go            # Entry point
│   ├── go.mod             # Go dependencies
│   ├── .env               # Environment variables (git-ignored)
│   ├── .env.example       # Template .env
│   ├── middleware/        # API handlers
│   ├── models/            # Data models
│   └── router/            # Route definitions
│
├── client/                 # Frontend (React)
│   ├── src/
│   │   ├── App.js
│   │   ├── To-Do-List.js
│   │   └── index.js
│   ├── package.json       # Node dependencies
│   └── public/
│
└── README.md              # Original documentation
```

---

## 🆘 Troubleshooting

### Error: "no such host" atau koneksi MongoDB gagal
- ✅ Pastikan internet terhubung
- ✅ Cek `DB_URI` di file `.env` sudah benar
- ✅ Pastikan cluster MongoDB Atlas status "Available"
- ✅ Cek username dan password sudah benar

### Error: "Port 8080 already in use"
**Windows (PowerShell):**
```powershell
Get-Process -Id (Get-NetTCPConnection -LocalPort 8080).OwningProcess | Stop-Process -Force
```

**Linux/macOS:**
```bash
lsof -i :8080 | grep LISTEN | awk '{print $2}' | xargs kill -9
```

Atau ubah PORT di `.env` ke port lain (contoh: 3001)

### Error: "Cannot find module" di Go
```bash
go mod download
go mod tidy
```

### Error: npm install gagal
```bash
# Hapus node_modules dan package-lock.json
rm -r node_modules
rm package-lock.json

# Install ulang
npm install
```

---

## 📝 API Endpoints

Server Go menyediakan endpoint berikut:

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/task` | Ambil semua task |
| POST | `/api/task` | Buat task baru |
| PUT | `/api/task/{id}` | Tandai task selesai |
| PUT | `/api/undoTask/{id}` | Tandai task belum selesai |
| DELETE | `/api/deleteTask/{id}` | Hapus task tertentu |
| DELETE | `/api/deleteAllTask` | Hapus semua task |

---

## 🔒 Keamanan

⚠️ **Penting:**
- File `.env` mengandung credentials sensitif
- File `.env` **TIDAK** boleh di-commit ke git
- Sudah termasuk di `.gitignore`
- Jangan bagikan `.env` ke orang lain

---

## 💡 Tips Development

### Hot Reload untuk Go
Gunakan tool seperti `air` untuk auto-reload:
```bash
go install github.com/cosmtrek/air@latest
air
```

### Hot Reload untuk React
Sudah built-in saat menjalankan `npm start`

### Debug MongoDB Queries
Lihat file `middleware/middleware.go` untuk implementasi database queries.

---

## 📚 Referensi

- [Go Documentation](https://golang.org/doc/)
- [MongoDB Go Driver](https://docs.mongodb.com/drivers/go/)
- [React Documentation](https://react.dev/)
- [Express Router (Gorilla Mux)](https://github.com/gorilla/mux)

---

## 🤝 Bantuan Lebih Lanjut

Jika menemui masalah, silakan:
1. Baca error message dengan seksama
2. Cek bagian Troubleshooting di atas
3. Buka issue di repository
4. Hubungi tim development
