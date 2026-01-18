@echo off
REM Script untuk setup CI/CD pertama kali di Windows

echo ==========================================
echo Setup CI/CD untuk Go To-Do App
echo ==========================================
echo.

REM Check if gcloud is installed
where gcloud >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo gcloud CLI not found. Please install it first:
    echo https://cloud.google.com/sdk/docs/install
    exit /b 1
)

echo gcloud CLI found
echo.

REM Get project ID
set /p PROJECT_ID="Enter your GCP Project ID: "
gcloud config set project %PROJECT_ID%

REM Get VM details
set /p VM_NAME="Enter VM name (default: todo-app-vm): "
if "%VM_NAME%"=="" set VM_NAME=todo-app-vm

set /p VM_ZONE="Enter VM zone (default: us-central1-a): "
if "%VM_ZONE%"=="" set VM_ZONE=us-central1-a

echo.
echo ==========================================
echo Step 1: Creating Service Account
echo ==========================================

REM Create service account
gcloud iam service-accounts create github-actions --display-name="GitHub Actions Service Account" --quiet

echo Service account created

REM Add roles
echo Adding IAM roles...
gcloud projects add-iam-policy-binding %PROJECT_ID% --member="serviceAccount:github-actions@%PROJECT_ID%.iam.gserviceaccount.com" --role="roles/storage.admin" --quiet

gcloud projects add-iam-policy-binding %PROJECT_ID% --member="serviceAccount:github-actions@%PROJECT_ID%.iam.gserviceaccount.com" --role="roles/compute.instanceAdmin.v1" --quiet

echo IAM roles added

REM Generate key
echo Generating service account key...
gcloud iam service-accounts keys create key.json --iam-account=github-actions@%PROJECT_ID%.iam.gserviceaccount.com

echo Service account key saved to key.json
echo DO NOT COMMIT THIS FILE TO GIT!

echo.
echo ==========================================
echo Step 2: Creating/Checking VM Instance
echo ==========================================

REM Check if VM exists
gcloud compute instances describe %VM_NAME% --zone=%VM_ZONE% >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo VM %VM_NAME% already exists
) else (
    echo Creating VM instance...
    gcloud compute instances create %VM_NAME% --zone=%VM_ZONE% --machine-type=e2-medium --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud --boot-disk-size=20GB --tags=http-server,https-server
    echo VM instance created
)

REM Get VM IP
for /f "delims=" %%i in ('gcloud compute instances describe %VM_NAME% --zone=%VM_ZONE% --format="get(networkInterfaces[0].accessConfigs[0].natIP)"') do set VM_IP=%%i

echo VM External IP: %VM_IP%

echo.
echo ==========================================
echo Step 3: Setting up Firewall Rules
echo ==========================================

REM Create firewall rules
gcloud compute firewall-rules create allow-http --allow tcp:80 --target-tags http-server --quiet 2>nul
gcloud compute firewall-rules create allow-backend --allow tcp:8080 --target-tags http-server --quiet 2>nul

echo Firewall rules configured

echo.
echo ==========================================
echo Setup Complete!
echo ==========================================
echo.
echo Next steps:
echo.
echo 1. Copy the content of key.json and add it to GitHub Secrets as GCP_SA_KEY
echo.
echo 2. Add these secrets to GitHub (Settings ^> Secrets and variables ^> Actions):
echo    - GCP_SA_KEY: (content of key.json)
echo    - GCP_PROJECT_ID: %PROJECT_ID%
echo    - GCP_VM_NAME: %VM_NAME%
echo    - GCP_VM_ZONE: %VM_ZONE%
echo    - GCP_VM_IP: %VM_IP%
echo.
echo 3. SSH to VM and install Docker:
echo    gcloud compute ssh %VM_NAME% --zone=%VM_ZONE%
echo    Then run: curl -fsSL https://get.docker.com -o get-docker.sh ^&^& sh get-docker.sh
echo    Then run: sudo usermod -aG docker $USER
echo    Then run: gcloud auth configure-docker
echo.
echo 4. Push to GitHub:
echo    git add .
echo    git commit -m "Setup CI/CD"
echo    git push origin main
echo.
echo Your app will be available at:
echo    Frontend: http://%VM_IP%
echo    Backend:  http://%VM_IP%:8080
echo.

pause
