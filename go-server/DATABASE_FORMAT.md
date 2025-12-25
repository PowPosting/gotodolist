# Format Database MongoDB untuk Go Todo List

## 📊 Struktur Database

### Database Name
```
gotodolist
```

### Collections

#### 1. todolist (Koleksi utama untuk menyimpan task)

**Field-field:**
```javascript
{
  "_id": ObjectId,           // MongoDB auto-generated ID
  "task": string,            // Deskripsi task
  "status": boolean,         // true = selesai, false = belum selesai
  "createdAt": date,         // Waktu dibuat (optional)
  "updatedAt": date          // Waktu diupdate (optional)
}
```

---

## 📋 Contoh Data

### Task Belum Selesai
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "task": "Belajar Go",
  "status": false,
  "createdAt": ISODate("2025-12-25T10:30:00Z"),
  "updatedAt": ISODate("2025-12-25T10:30:00Z")
}
```

### Task Selesai
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "task": "Setup MongoDB",
  "status": true,
  "createdAt": ISODate("2025-12-25T09:15:00Z"),
  "updatedAt": ISODate("2025-12-25T11:45:00Z")
}
```

---

## 🔄 Operasi Database

### 1. CREATE (Buat Task Baru)
**Endpoint:** `POST /api/task`

**Request Body:**
```json
{
  "task": "Belajar React",
  "status": false
}
```

**MongoDB Command:**
```javascript
db.todolist.insertOne({
  "task": "Belajar React",
  "status": false,
  "createdAt": new Date(),
  "updatedAt": new Date()
})
```

### 2. READ (Ambil Semua Task)
**Endpoint:** `GET /api/task`

**MongoDB Command:**
```javascript
db.todolist.find({})
```

**Response:**
```json
[
  {
    "_id": "507f1f77bcf86cd799439011",
    "task": "Belajar Go",
    "status": false
  },
  {
    "_id": "507f1f77bcf86cd799439012",
    "task": "Setup MongoDB",
    "status": true
  }
]
```

### 3. UPDATE (Tandai Task Selesai)
**Endpoint:** `PUT /api/task/{id}`

**MongoDB Command:**
```javascript
db.todolist.updateOne(
  { "_id": ObjectId("507f1f77bcf86cd799439011") },
  { $set: { "status": true, "updatedAt": new Date() } }
)
```

### 4. UPDATE (Tandai Task Belum Selesai)
**Endpoint:** `PUT /api/undoTask/{id}`

**MongoDB Command:**
```javascript
db.todolist.updateOne(
  { "_id": ObjectId("507f1f77bcf86cd799439011") },
  { $set: { "status": false, "updatedAt": new Date() } }
)
```

### 5. DELETE (Hapus Task Tertentu)
**Endpoint:** `DELETE /api/deleteTask/{id}`

**MongoDB Command:**
```javascript
db.todolist.deleteOne(
  { "_id": ObjectId("507f1f77bcf86cd799439011") }
)
```

### 6. DELETE ALL (Hapus Semua Task)
**Endpoint:** `DELETE /api/deleteAllTask`

**MongoDB Command:**
```javascript
db.todolist.deleteMany({})
```

---

## 🔍 Lihat Data di MongoDB Atlas

### Via MongoDB Compass (GUI)
1. Download [MongoDB Compass](https://www.mongodb.com/products/compass)
2. Paste connection string dari `.env`
3. Browse: `gotodolist` → `todolist`

### Via MongoDB Atlas Web Console
1. Login ke https://www.mongodb.com/cloud/atlas
2. Pilih cluster Anda
3. Klik "Collections"
4. Lihat data di `gotodolist.todolist`

### Via MongoDB Shell (CLI)
```bash
mongosh "mongodb+srv://username:password@cluster.mongodb.net/gotodolist"

# Di dalam shell:
use gotodolist
db.todolist.find()
```

---

## 🗂️ Catatan Implementasi

### Model (Go)
File: `go-server/models/models.go`
```go
type ToDoList struct {
    ID     primitive.ObjectID `json:"_id,omitempty" bson:"_id,omitempty"`
    Task   string             `json:"task,omitempty"`
    Status bool               `json:"status,omitempty"`
}
```

### Database Operations
File: `go-server/middleware/middleware.go`

Fungsi-fungsi utama:
- `getAllTask()` - Ambil semua task dari collection
- `insertOneTask(task ToDoList)` - Tambah task baru
- `taskComplete(id string)` - Update status ke true
- `undoTask(id string)` - Update status ke false
- `deleteOneTask(id string)` - Hapus satu task
- `deleteAllTask()` - Hapus semua task

---

## ⚙️ Konfigurasi Connection

Dari file `.env`:
```env
DB_URI="mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/?appName=Cluster0"
DB_NAME="gotodolist"
DB_COLLECTION_NAME="todolist"
PORT="8080"
```

**Koneksi akan dibuat otomatis ke:**
- Database: `gotodolist`
- Collection: `todolist`
- Host: `cluster0.9fhkkqh.mongodb.net`

Database dan collection akan dibuat otomatis saat pertama kali ada data yang diinsert.

---

## 🎯 Ringkasan

| Aksi | Type | Endpoint | Field |
|------|------|----------|-------|
| Lihat semua | GET | `/api/task` | - |
| Buat baru | POST | `/api/task` | task, status |
| Tandai selesai | PUT | `/api/task/{id}` | status=true |
| Tandai belum | PUT | `/api/undoTask/{id}` | status=false |
| Hapus satu | DELETE | `/api/deleteTask/{id}` | - |
| Hapus semua | DELETE | `/api/deleteAllTask` | - |

---

## 💡 Tips

✅ Database dan collection dibuat otomatis saat `go run main.go` dijalankan
✅ Tidak perlu membuat database manual di MongoDB Atlas
✅ Data akan langsung tersimpan saat API endpoint dipanggil
✅ Field `_id` otomatis di-generate oleh MongoDB

Sekarang tinggal jalankan server dengan `go run main.go` dan test API! 🚀
