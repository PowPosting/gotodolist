# :memo: Go To Do App

This is a to-do list application with CI/CD deployment to Google Cloud Platform.

**Server:** Golang  
**Client:** React, semantic-ui-react  
**Database:** MongoDB  
**Deployment:** Docker + GCP VM + GitHub Actions CI/CD

---

## :rocket: Quick Start

### Local Development with Docker

```bash
# Clone repository
git clone <your-repo-url>
cd go-to-do-app

# Run with Docker Compose
docker-compose up --build

# Access:
# Frontend: http://localhost:3000
# Backend:  http://localhost:8080
```

### Or use Makefile commands:
```bash
make build    # Build Docker images
make run      # Run application
make logs     # View logs
make stop     # Stop containers
make help     # See all available commands
```

---

## :cloud: CI/CD Deployment to GCP VM

### Automated Deployment Flow
```
Local Development → Push to GitHub → GitHub Actions → Deploy to GCP VM
```

Every push to `main` branch automatically:
1. Builds Docker images for backend and frontend
2. Pushes images to Google Container Registry
3. Deploys to VM using Docker containers

### Setup CI/CD (First Time)

#### Option 1: Automated Setup (Windows)
```bash
setup-cicd.bat
```

#### Option 2: Automated Setup (Linux/Mac)
```bash
chmod +x setup-cicd.sh
./setup-cicd.sh
```

#### Option 3: Manual Setup
See detailed instructions in [SETUP-CI-CD.md](SETUP-CI-CD.md) or [QUICK-START.md](QUICK-START.md)

### Required GitHub Secrets
Add these in **Settings > Secrets and variables > Actions**:
- `GCP_SA_KEY`: Service account JSON key
- `GCP_PROJECT_ID`: Your GCP project ID
- `GCP_VM_NAME`: VM instance name
- `GCP_VM_ZONE`: VM zone (e.g., us-central1-a)
- `GCP_VM_IP`: VM external IP address

### After Setup
```bash
# Make changes to your code
git add .
git commit -m "Your changes"
git push origin main

# GitHub Actions will automatically deploy!
```

---

## :label: Version Management

### Quick Versioning

```bash
# Bump version (Windows)
version.bat patch "Bug fixes"
version.bat minor "New feature"
version.bat major "Breaking changes"

# Or use Makefile
make version-patch    # 1.0.0 → 1.0.1
make version-minor    # 1.0.0 → 1.1.0
make version-major    # 1.0.0 → 2.0.0
make version-show     # Show current version
```

### Release with Versioning

```bash
# 1. Update version
make version-minor "Add filtering feature"

# 2. Push release
make release

# GitHub Actions will:
# - Build images with version tag (e.g., 1.1.0)
# - Deploy to VM
# - Create GitHub Release automatically
```

See [VERSIONING.md](VERSIONING.md) for complete version management guide.

---

## :books: Documentation

- [SETUP-CI-CD.md](SETUP-CI-CD.md) - Complete CI/CD setup guide
- [VERSIONING.md](VERSIONING.md) - Version management guide
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Troubleshooting guide
- [CHANGELOG.md](CHANGELOG.md) - Version history

---

## :hammer_and_wrench: Development

### Backend (Go)
```bash
cd go-server
go mod download
go run main.go
```

### Frontend (React)
```bash
cd client
npm install
npm start
```

### Environment Variables

**Backend** (`go-server/.env`):
```env
PORT=8080
MONGODB_URI=mongodb://your-mongodb-uri
```

**Frontend** (`client/.env`):
```env
REACT_APP_API_URL=http://localhost:8080
```

---

## :whale: Docker Architecture

```
┌─────────────────┐     ┌─────────────────┐
│   Frontend      │     │    Backend      │
│   (React)       │────▶│    (Go)         │
│   Port: 80      │     │    Port: 8080   │
│   nginx         │     │                 │
└─────────────────┘     └─────────────────┘
```

---

## :wrench: Available Commands

```bash
# Docker Compose
docker-compose up          # Run app
docker-compose down        # Stop app
docker-compose logs -f     # View logs

# Makefile
make build                 # Build images
make run                   # Run in foreground
make run-detached         # Run in background
make logs                  # View all logs
make logs-backend         # View backend logs
make logs-frontend        # View frontend logs
make stop                  # Stop containers
make clean                # Remove containers & images
make test                  # Run tests
make help                  # Show all commands

# Development
make dev-backend          # Run backend locally
make dev-frontend         # Run frontend locally
make install              # Install all dependencies
```

---

## :page_facing_up: Project Structure

```
go-to-do-app/
├── client/                 # React frontend
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── go-server/             # Go backend
│   ├── middleware/
│   ├── models/
│   ├── router/
│   ├── Dockerfile
│   ├── main.go
│   └── go.mod
├── .github/
│   └── workflows/
│       └── deploy.yml     # CI/CD pipeline
├── docker-compose.yml
├── Makefile
├── setup-cicd.sh         # Linux/Mac setup
├── setup-cicd.bat        # Windows setup
└── README.md
```

---

## :link: Links

- **Original Tutorial:** [Build a To-Do App](https://schadokar.dev/posts/build-a-todo-app-in-golang-mongodb-and-react/)
- **GitHub Actions:** Monitor deployments in Actions tab
- **Docker Hub:** [Docker Documentation](https://docs.docker.com/)
- **GCP:** [Google Cloud Platform](https://cloud.google.com/)

---

## :page_with_curl: License

See [LICENSE](LICENSE) file for details.

---

## Deploy to Google Cloud Platform (GCP) - Legacy

### Prerequisites
1. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed
2. [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli) installed: `npm install -g firebase-tools`
3. GCP project created with Firebase enabled
4. MongoDB Atlas account (for cloud database)

### Setup Steps

#### 1. Configure Database Connection
Update [go-server/app.yaml](go-server/app.yaml) with your MongoDB connection string:
```yaml
env_variables:
  DB_URI: "your-mongodb-atlas-connection-string"
  DB_NAME: "divadb"
  DB_COLLECTION_NAME: "todolist"
```

#### 2. Deploy Backend to App Engine
```bash
# Login to Google Cloud
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Deploy backend
cd go-server
gcloud app deploy

# Get backend URL (e.g., https://YOUR_PROJECT_ID.appspot.com)
gcloud app browse
```

#### 3. Update Frontend API URL
Update [client/.env.production](client/.env.production) with your backend URL:
```
REACT_APP_API_URL=https://YOUR_PROJECT_ID.appspot.com
```

#### 4. Deploy Frontend to Firebase Hosting
```bash
# Login to Firebase
firebase login

# Build React app
cd client
npm install
npm run build

# Deploy to Firebase Hosting
cd ..
firebase deploy --only hosting

# Your app will be live at: https://YOUR_PROJECT_ID.web.app
```

### Quick Deploy Commands
```bash
# Backend
cd ~/gotodolist/go-server && gcloud app deploy

# Frontend
cd ~/gotodolist/client && npm run build && cd .. && firebase deploy --only hosting
```

### Architecture
```
User → Firebase Hosting (Frontend React)
         ↓ API calls
       App Engine (Backend Go)
         ↓
       MongoDB Atlas (Database)
```

### GitHub Repository
:link: https://github.com/PowPosting/gotodolist

---

# Highlights

1. DB connection string, name and collection name moved to `.env` file as environment variable. Using `github.com/joho/godotenv` to read the environment variables.
2. [feature/cloud-native-deployment](https://github.com/abdennour/go-to-do-app/tree/feature/cloud-native-deployment) provided by [abdennour](https://github.com/abdennour). Thank you [@abdennour](https://github.com/abdennour) to dockerize it. His features supports both Docker and Kubernetes.

## Application Requirement

### golang server requirement

1. golang https://golang.org/dl/
2. gorilla/mux package for router `go get -u github.com/gorilla/mux`
3. mongo-driver package to connect with mongoDB `go get go.mongodb.org/mongo-driver`
4. github.com/joho/godotenv to access the environment variable.

### react client

From the Application directory

`create-react-app client`

## :computer: Start the application

1. Make sure your mongoDB is started
2. Create a `.env` file inside the `go-server` and copy the keys from `.env.example` and update the DB connection string.
3. From go-server directory, open a terminal and run
   `go run main.go`
4. From client directory,  
   a. install all the dependencies using `npm install`  
   b. start client `npm start`

## :panda_face: Walk through the application

Open application at http://localhost:3000

### Index page

![](https://github.com/schadokar/go-to-do-app/blob/master/images/index.PNG)

### Create task

Enter a task and Enter

![](https://github.com/schadokar/go-to-do-app/blob/master/images/createTask.PNG)

### Task Complete

On completion of a task, click "done" Icon of the respective task card.

![](https://github.com/schadokar/go-to-do-app/blob/master/images/taskComplete.PNG)

You'll notice on completion of task, card's bottom line color changed from yellow to green.

### Undo a task

To undone a task, click on "undo" Icon,

![](https://github.com/schadokar/go-to-do-app/blob/master/images/createTask.PNG)

You'll notice on completion of task, card's bottom line color changed from green to yellow.

### Delete a task

To delete a task, click on "delete" Icon.

![](https://github.com/schadokar/go-to-do-app/blob/master/images/deletetask.PNG)

---

## Author

#### :sun_with_face: Shubham Kumar Chadokar

I am software engineer and love to write articles and tutorials on golang, blockchain, and nodejs.  
Please checkout my other articles on :link: https://schadokar.dev :tada:

# References

https://godoc.org/go.mongodb.org/mongo-driver/mongo  
https://www.mongodb.com/blog/post/mongodb-go-driver-tutorial  
https://vkt.sh/go-mongodb-driver-cookbook/

# License

MIT License

Copyright (c) 2019 Shubham Chadokar
