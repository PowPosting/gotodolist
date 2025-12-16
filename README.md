# :memo: Go To Do App

This is a to-do list application. The complete tutorial is published on [my blog](https://schadokar.dev/posts/build-a-todo-app-in-golang-mongodb-and-react/).

**Server: Golang  
Client: React, semantic-ui-react  
Database: MongoDB**

The offline version of application `Get Shit Done` is hosted at

:link: https://schadokar.github.io/go-to-do-app/

:link: http://getshitdone.surge.sh

> Offline to-do app instruction. [here](https://codesource.io/building-an-offline-to-do-app-with-react/)
---

# :rocket: Deployment

## Deploy to Google Cloud Platform (GCP)

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
