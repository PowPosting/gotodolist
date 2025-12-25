# Panduan Import Data ke MongoDB

Ada beberapa cara untuk import data ke collection `todolist`. Pilih salah satu sesuai kebutuhan Anda.

---

## 1️⃣ Via API dengan cURL (Paling Mudah)

### Prasyarat
- Server Go sudah running (`go run main.go`)
- Server berjalan di `http://localhost:8080`

### Single Task

```bash
curl -X POST http://localhost:8080/api/task \
  -H "Content-Type: application/json" \
  -d '{
    "task": "Belajar Go",
    "status": false
  }'
```

### Multiple Tasks

```bash
# Task 1
curl -X POST http://localhost:8080/api/task \
  -H "Content-Type: application/json" \
  -d '{"task": "Belajar Go", "status": false}'

# Task 2
curl -X POST http://localhost:8080/api/task \
  -H "Content-Type: application/json" \
  -d '{"task": "Setup MongoDB", "status": true}'

# Task 3
curl -X POST http://localhost:8080/api/task \
  -H "Content-Type: application/json" \
  -d '{"task": "Deploy ke Cloud", "status": false}'
```

### Windows PowerShell
```powershell
$headers = @{
    "Content-Type" = "application/json"
}

$body = @{
    task = "Belajar Go"
    status = $false
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8080/api/task `
  -Method POST `
  -Headers $headers `
  -Body $body
```

---

## 2️⃣ Via Postman (GUI - Paling Praktis)

### Setup
1. Download [Postman](https://www.postman.com/downloads/)
2. Buka Postman
3. Klik "+" untuk tab baru

### Langkah-Langkah

**A. Setup Request**
- Pilih method: **POST**
- URL: `http://localhost:8080/api/task`
- Tab "Headers":
  - Key: `Content-Type`
  - Value: `application/json`

**B. Input Data (Tab Body)**
- Pilih: **raw** → **JSON**
- Copy-paste data:
```json
{
  "task": "Belajar Go",
  "status": false
}
```

**C. Klik Send**

**Contoh Response:**
```json
{
  "_id": "6789abcdef123456",
  "task": "Belajar Go",
  "status": false
}
```

### Import Multiple dengan Collection
1. Buat folder baru di Postman
2. Buat request untuk setiap task
3. Simpan dalam folder
4. Run semuanya dengan "Run Collection"

---

## 3️⃣ Via MongoDB Atlas Web UI

### Langkah-Langkah

1. **Login ke MongoDB Atlas**
   - Buka: https://www.mongodb.com/cloud/atlas
   - Login ke akun Anda

2. **Pilih Database**
   - Klik cluster Anda
   - Klik tab "Collections"

3. **Masuk ke Collection**
   - Pilih database: `gotodolist`
   - Pilih collection: `todolist`

4. **Insert Document**
   - Klik tombol "Insert Document" (hijau)
   - Pilih JSON view
   - Paste data:
```json
{
  "task": "Belajar Go",
  "status": false
}
```
   - Klik "Insert"

5. **Ulangi untuk data lain**

---

## 4️⃣ Via MongoDB Shell

### Setup
```bash
# Install MongoDB Tools
# Di Windows: Download dari https://www.mongodb.com/try/download/shell

# Atau gunakan mongosh jika sudah ada
mongosh
```

### Connect ke Database
```bash
mongosh "mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/gotodolist"
```

### Insert Single Document
```javascript
db.todolist.insertOne({
  "task": "Belajar Go",
  "status": false
})
```

### Insert Multiple Documents
```javascript
db.todolist.insertMany([
  { "task": "Belajar Go", "status": false },
  { "task": "Setup MongoDB", "status": true },
  { "task": "Deploy ke Cloud", "status": false },
  { "task": "Belajar React", "status": false },
  { "task": "Test API", "status": true }
])
```

### Lihat Hasil
```javascript
db.todolist.find()
```

---

## 5️⃣ Via MongoDB Compass (Desktop App)

### Install
1. Download: https://www.mongodb.com/products/compass
2. Install dan buka

### Connect
1. Klik "New Connection"
2. Paste connection string dari `.env`:
```
mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/?appName=Cluster0
```
3. Klik "Connect"

### Insert Data
1. Navigate ke: `gotodolist` → `todolist`
2. Klik tombol "Insert Document" (+)
3. Isi JSON:
```json
{
  "task": "Belajar Go",
  "status": false
}
```
4. Klik "Insert"

---

## 6️⃣ Import dari File JSON

### A. Via MongoDB Tools (mongoimport)

**Step 1: Siapkan file `data.json`**
```json
[
  { "task": "Belajar Go", "status": false },
  { "task": "Setup MongoDB", "status": true },
  { "task": "Deploy ke Cloud", "status": false },
  { "task": "Belajar React", "status": false },
  { "task": "Test API", "status": true }
]
```

**Step 2: Import ke database**
```bash
mongoimport \
  --uri="mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/gotodolist" \
  --collection=todolist \
  --file=data.json \
  --jsonArray
```

### B. Via MongoDB Compass
1. Klik collection `todolist`
2. Klik tombol "Import Data" (panah masuk)
3. Pilih file `data.json`
4. Klik "Import"

---

## 7️⃣ Import dari CSV

### Step 1: Siapkan file `data.csv`
```csv
task,status
Belajar Go,false
Setup MongoDB,true
Deploy ke Cloud,false
Belajar React,false
Test API,true
```

### Step 2: Convert ke JSON (Windows PowerShell)
```powershell
$csv = Import-Csv data.csv
$csv | ConvertTo-Json | Out-File data.json
```

### Step 3: Import JSON ke MongoDB
```bash
mongoimport \
  --uri="mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/gotodolist" \
  --collection=todolist \
  --file=data.json \
  --jsonArray
```

---

## 📊 Sample Data untuk Testing

Jika ingin test dengan banyak data, gunakan script Go ini:

**File: `insert-sample-data.go`**
```go
package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	godotenv.Load(".env")

	connectionString := os.Getenv("DB_URI")
	dbName := os.Getenv("DB_NAME")
	collName := os.Getenv("DB_COLLECTION_NAME")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(connectionString))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect(ctx)

	collection := client.Database(dbName).Collection(collName)

	sampleData := []interface{}{
		bson.M{"task": "Belajar Go", "status": false},
		bson.M{"task": "Setup MongoDB", "status": true},
		bson.M{"task": "Deploy ke Cloud", "status": false},
		bson.M{"task": "Belajar React", "status": false},
		bson.M{"task": "Test API", "status": true},
		bson.M{"task": "Code Review", "status": false},
		bson.M{"task": "Fix Bugs", "status": true},
		bson.M{"task": "Write Documentation", "status": false},
	}

	result, err := collection.InsertMany(ctx, sampleData)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Inserted %d documents\n", len(result.InsertedIDs))
}
```

**Jalankan:**
```bash
go run insert-sample-data.go
```

---

## ✅ Verify Import Success

### Via cURL
```bash
curl http://localhost:8080/api/task
```

### Via MongoDB Atlas
1. Login ke https://www.mongodb.com/cloud/atlas
2. Pilih cluster → Collections
3. Lihat `gotodolist.todolist`
4. Hitung jumlah documents

### Via MongoDB Shell
```bash
mongosh "mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/gotodolist"
db.todolist.countDocuments()
```

---

## 🎯 Rekomendasi Metode

| Metode | Kemudahan | Speed | Terbaik Untuk |
|--------|-----------|-------|---------------|
| API + cURL | ⭐⭐ | Cepat | Sedikit data |
| Postman | ⭐⭐⭐ | Cepat | Development |
| MongoDB Atlas UI | ⭐⭐⭐ | Sedang | Learning |
| MongoDB Shell | ⭐⭐ | Cepat | Batch import |
| MongoDB Compass | ⭐⭐⭐ | Sedang | Desktop GUI |
| File Import | ⭐ | Cepat | Banyak data |
| Go Script | ⭐⭐ | Cepat | Testing |

---

## 🆘 Troubleshooting

### Error: Connection Timeout
- ✅ Pastikan internet terhubung
- ✅ Cek connection string benar
- ✅ Cek MongoDB Atlas cluster status aktif

### Error: Authentication Failed
- ✅ Cek username dan password
- ✅ Cek IP whitelist di MongoDB Atlas

### Error: Collection Not Found
- Database dan collection dibuat otomatis saat insert pertama
- Jika belum ada, jalankan `go run main.go` terlebih dahulu

### Command Not Found (mongoimport)
- Install MongoDB Database Tools: https://www.mongodb.com/try/download/database-tools

---

Pilih metode yang paling sesuai dengan workflow Anda! 🚀
