# Insert Data Langsung ke MongoDB

## 🔌 Connect ke MongoDB

```bash
mongosh "mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/gotodolist"
```

Setelah terkoneksi, Anda akan masuk ke shell MongoDB.

---

## ✅ Insert Single Document

```javascript
db.todolist.insertOne({
  "task": "Belajar Go",
  "status": false
})
```

**Output:**
```
{
  acknowledged: true,
  insertedId: ObjectId("...")
}
```

---

## ✅ Insert Multiple Documents (Recommended)

Copy-paste semua ini sekaligus di MongoDB Shell:

```javascript
db.todolist.insertMany([
  { "task": "Belajar Go", "status": false },
  { "task": "Setup MongoDB", "status": true },
  { "task": "Deploy ke Cloud", "status": false },
  { "task": "Belajar React", "status": false },
  { "task": "Test API", "status": true },
  { "task": "Code Review", "status": false },
  { "task": "Fix Bugs", "status": true },
  { "task": "Write Documentation", "status": false },
  { "task": "Setup CI/CD", "status": false },
  { "task": "Database Optimization", "status": true }
])
```

**Output:**
```
{
  acknowledged: true,
  insertedIds: [
    ObjectId("..."),
    ObjectId("..."),
    ...
  ]
}
```

---

## 📊 Lihat Data yang Sudah Diinsert

```javascript
// Lihat semua data
db.todolist.find()

// Lihat dengan format rapi
db.todolist.find().pretty()

// Hitung jumlah data
db.todolist.countDocuments()

// Lihat data yang statusnya true (selesai)
db.todolist.find({ "status": true })

// Lihat data yang statusnya false (belum selesai)
db.todolist.find({ "status": false })
```

---

## 🗑️ Delete Data (Jika Perlu)

```javascript
// Hapus satu data
db.todolist.deleteOne({ "_id": ObjectId("...") })

// Hapus semua data
db.todolist.deleteMany({})
```

---

## 🔄 Update Data

```javascript
// Ubah status menjadi true (selesai)
db.todolist.updateOne(
  { "task": "Belajar Go" },
  { $set: { "status": true } }
)

// Ubah task description
db.todolist.updateOne(
  { "_id": ObjectId("...") },
  { $set: { "task": "Belajar Golang Advanced" } }
)
```

---

## 📋 Sample Data Lengkap

Siap copy-paste untuk testing:

```javascript
use gotodolist

db.todolist.insertMany([
  { "task": "Belajar Go", "status": false },
  { "task": "Setup MongoDB", "status": true },
  { "task": "Deploy ke Cloud", "status": false },
  { "task": "Belajar React", "status": false },
  { "task": "Test API", "status": true },
  { "task": "Code Review", "status": false },
  { "task": "Fix Bugs", "status": true },
  { "task": "Write Documentation", "status": false },
  { "task": "Setup CI/CD", "status": false },
  { "task": "Database Optimization", "status": true },
  { "task": "Performance Testing", "status": false },
  { "task": "Security Audit", "status": true },
  { "task": "Backup System", "status": false },
  { "task": "Logging Setup", "status": true },
  { "task": "Monitoring Setup", "status": false }
])

// Verify
db.todolist.find().pretty()
db.todolist.countDocuments()
```

---

## 🎯 Quick Steps

1. **Buka Terminal/PowerShell**

2. **Connect ke MongoDB:**
   ```bash
   mongosh "mongodb+srv://revandaagastar_db_user:T7WLF7EbGVutxvI0@cluster0.9fhkkqh.mongodb.net/gotodolist"
   ```

3. **Paste data insert commands** di atas

4. **Tekan Enter**

5. **Lihat hasil:**
   ```javascript
   db.todolist.find().pretty()
   ```

6. **Exit:**
   ```javascript
   exit
   ```

---

## ✨ Tips

✅ Data akan otomatis tersimpan di database `gotodolist` collection `todolist`
✅ Field `_id` akan otomatis di-generate oleh MongoDB
✅ Tidak perlu field `createdAt` atau `updatedAt` untuk basic usage
✅ Jika ada typo, gunakan `db.todolist.deleteMany({})` untuk clear semua dan insert ulang

---

## 🔗 Hubungkan ke Frontend

Setelah insert data, akses dari aplikasi React:
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:8080`

Data akan langsung terlihat di aplikasi! ✅
