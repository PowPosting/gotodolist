# Troubleshooting Guide

## Common Issues and Solutions

### 1. GitHub Actions Issues

#### Error: "Permission denied" saat SSH ke VM
**Solution:**
```bash
# Add SSH key to VM metadata
gcloud compute config-ssh

# Or manually add service account SSH access
gcloud compute instances add-iam-policy-binding YOUR_VM_NAME \
  --zone=YOUR_ZONE \
  --member=serviceAccount:github-actions@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/compute.osLogin
```

#### Error: "Cannot pull image from GCR"
**Solution:**
```bash
# SSH to VM
gcloud compute ssh YOUR_VM_NAME --zone=YOUR_ZONE

# Configure Docker authentication
gcloud auth configure-docker

# Test pull
docker pull gcr.io/YOUR_PROJECT_ID/go-server:latest
```

#### Error: Build fails with "No space left on device"
**Solution:**
```bash
# SSH to VM and clean up Docker
docker system prune -a -f
docker volume prune -f
```

---

### 2. Docker Issues

#### Port already in use
**Solution:**
```bash
# Find process using port
# Linux/Mac:
sudo lsof -i :8080
sudo lsof -i :3000

# Windows:
netstat -ano | findstr :8080
netstat -ano | findstr :3000

# Kill process or change port in docker-compose.yml
```

#### Container keeps restarting
**Solution:**
```bash
# Check logs
docker logs go-server
docker logs react-client

# Common causes:
# - MongoDB connection failed
# - Port already in use
# - Missing environment variables
```

#### Cannot connect to MongoDB
**Solution:**
```bash
# Check environment variable
docker exec go-server env | grep MONGODB_URI

# Update docker-compose.yml or add .env file
# Ensure MongoDB URI is correct and accessible
```

---

### 3. Frontend Issues

#### API calls fail with CORS error
**Solution:**
Update [go-server/middleware/middleware.go](go-server/middleware/middleware.go) to allow your frontend domain:
```go
w.Header().Set("Access-Control-Allow-Origin", "http://YOUR_VM_IP")
```

Or allow all (not recommended for production):
```go
w.Header().Set("Access-Control-Allow-Origin", "*")
```

#### Environment variable not working
**Solution:**
```bash
# React environment variables must start with REACT_APP_
# They are set at BUILD time, not runtime

# Rebuild with correct variable
docker build -t react-client \
  --build-arg REACT_APP_API_URL=http://YOUR_VM_IP:8080 \
  ./client
```

#### White screen or blank page
**Solution:**
```bash
# Check nginx logs
docker logs react-client

# Verify build directory exists
docker exec react-client ls -la /usr/share/nginx/html

# Rebuild if necessary
cd client
npm install
npm run build
```

---

### 4. Backend Issues

#### MongoDB connection timeout
**Solution:**
```bash
# Check if MongoDB URI is set
echo $MONGODB_URI

# Test connection from server
cd go-server
go run main.go

# Common fixes:
# - Whitelist VM IP in MongoDB Atlas
# - Use correct connection string with credentials
# - Ensure MongoDB is running
```

#### "Go mod download" fails
**Solution:**
```bash
# Clear cache and retry
go clean -modcache
go mod download

# Or use proxy (if in restricted network)
export GOPROXY=https://goproxy.io,direct
go mod download
```

---

### 5. VM Issues

#### Cannot SSH to VM
**Solution:**
```bash
# Reset SSH
gcloud compute config-ssh

# Or use browser SSH
gcloud compute ssh YOUR_VM_NAME --zone=YOUR_ZONE --tunnel-through-iap

# Check firewall
gcloud compute firewall-rules list
```

#### VM runs out of disk space
**Solution:**
```bash
# SSH to VM
gcloud compute ssh YOUR_VM_NAME --zone=YOUR_ZONE

# Check disk usage
df -h

# Clean up Docker
docker system prune -a -f
docker volume prune -f

# Or resize disk
gcloud compute disks resize YOUR_VM_NAME \
  --size=30GB \
  --zone=YOUR_ZONE
```

#### VM has high CPU/Memory usage
**Solution:**
```bash
# Check Docker stats
docker stats

# Limit container resources in docker-compose.yml:
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

---

### 6. Network Issues

#### Cannot access app from browser
**Solution:**
```bash
# Check if containers are running
docker ps

# Check firewall rules
gcloud compute firewall-rules list

# Ensure ports are exposed
# - Port 80 for frontend
# - Port 8080 for backend

# Test from VM
curl http://localhost:80
curl http://localhost:8080

# Get external IP
gcloud compute instances describe YOUR_VM_NAME \
  --zone=YOUR_ZONE \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

#### Frontend can't reach backend
**Solution:**
```bash
# Ensure REACT_APP_API_URL is correct
# Should be: http://VM_EXTERNAL_IP:8080

# Rebuild frontend with correct URL
docker build -t react-client \
  --build-arg REACT_APP_API_URL=http://YOUR_VM_IP:8080 \
  ./client

# Or update in docker-compose.yml
```

---

### 7. CI/CD Pipeline Issues

#### Workflow not triggering
**Solution:**
```bash
# Check if workflow file is in correct location
# Should be: .github/workflows/deploy.yml

# Verify branch name in workflow matches your push
# Default is 'main', yours might be 'master'

# Check Actions tab in GitHub for errors
```

#### Secrets not found
**Solution:**
```bash
# Verify all required secrets are set in GitHub:
# Settings > Secrets and variables > Actions

# Required secrets:
# - GCP_SA_KEY
# - GCP_PROJECT_ID  
# - GCP_VM_NAME
# - GCP_VM_ZONE
# - GCP_VM_IP
```

#### Deployment succeeds but app not updated
**Solution:**
```bash
# SSH to VM
gcloud compute ssh YOUR_VM_NAME --zone=YOUR_ZONE

# Check if new images were pulled
docker images | grep gcr.io

# Manually pull and restart
docker pull gcr.io/YOUR_PROJECT_ID/go-server:latest
docker pull gcr.io/YOUR_PROJECT_ID/react-client:latest

docker restart go-server react-client
```

---

### 8. Local Development Issues

#### "docker-compose: command not found"
**Solution:**
```bash
# Install Docker Compose
# Linux:
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Mac: Included with Docker Desktop
# Windows: Included with Docker Desktop
```

#### Changes not reflecting
**Solution:**
```bash
# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up

# Or force recreate
docker-compose up --build --force-recreate
```

---

### 9. Database Issues

#### "No documents found"
**Solution:**
```bash
# Check MongoDB connection
# Verify database name and collection name match in code

# Test MongoDB connection
mongo "YOUR_MONGODB_URI"

# In MongoDB Atlas:
# - Check Network Access (whitelist VM IP)
# - Check Database Access (verify user credentials)
```

---

### 10. Performance Issues

#### Slow API responses
**Solution:**
```bash
# Add indexes to MongoDB
# Check database query performance
# Consider caching

# Monitor with:
docker stats
```

#### High memory usage
**Solution:**
```bash
# Limit container memory in docker-compose.yml
# Use alpine-based images (already implemented)
# Clean up unused images
docker image prune -a
```

---

## Getting Help

If you encounter issues not covered here:

1. **Check Logs:**
   ```bash
   # GitHub Actions logs
   # GitHub > Your Repo > Actions > Select workflow run
   
   # Docker logs
   docker logs go-server
   docker logs react-client
   
   # VM system logs
   gcloud logging read "resource.type=gce_instance"
   ```

2. **Debug Mode:**
   ```bash
   # Run containers in foreground to see output
   docker-compose up
   
   # Or attach to running container
   docker attach go-server
   ```

3. **Check Status:**
   ```bash
   # VM status
   gcloud compute instances list
   
   # Container status
   docker ps -a
   
   # Network status
   docker network ls
   ```

4. **Reset Everything:**
   ```bash
   # Stop and remove all containers
   docker-compose down -v
   
   # Remove all images
   docker rmi $(docker images -q)
   
   # Start fresh
   docker-compose up --build
   ```

---

## Useful Commands

```bash
# Check VM resource usage
gcloud compute ssh YOUR_VM_NAME --zone=YOUR_ZONE --command "top -bn1"

# Check container resource usage
docker stats --no-stream

# View all Docker networks
docker network ls

# Inspect container
docker inspect go-server

# Execute command in container
docker exec -it go-server sh

# Copy files from container
docker cp go-server:/root/main ./

# View container processes
docker top go-server
```
