#!/bin/bash

# Script untuk setup CI/CD pertama kali

echo "=========================================="
echo "Setup CI/CD untuk Go To-Do App"
echo "=========================================="
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Please install it first:"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo "✅ gcloud CLI found"
echo ""

# Get project ID
read -p "Enter your GCP Project ID: " PROJECT_ID
gcloud config set project $PROJECT_ID

# Get VM details
read -p "Enter VM name (default: todo-app-vm): " VM_NAME
VM_NAME=${VM_NAME:-todo-app-vm}

read -p "Enter VM zone (default: us-central1-a): " VM_ZONE
VM_ZONE=${VM_ZONE:-us-central1-a}

echo ""
echo "=========================================="
echo "Step 1: Creating Service Account"
echo "=========================================="

# Create service account
gcloud iam service-accounts create github-actions \
    --display-name="GitHub Actions Service Account" \
    --quiet

echo "✅ Service account created"

# Add roles
echo "Adding IAM roles..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.admin" \
    --quiet

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin.v1" \
    --quiet

echo "✅ IAM roles added"

# Generate key
echo "Generating service account key..."
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@${PROJECT_ID}.iam.gserviceaccount.com

echo "✅ Service account key saved to key.json"
echo "⚠️  DO NOT COMMIT THIS FILE TO GIT!"

echo ""
echo "=========================================="
echo "Step 2: Creating/Checking VM Instance"
echo "=========================================="

# Check if VM exists
if gcloud compute instances describe $VM_NAME --zone=$VM_ZONE &> /dev/null; then
    echo "✅ VM $VM_NAME already exists"
else
    echo "Creating VM instance..."
    gcloud compute instances create $VM_NAME \
        --zone=$VM_ZONE \
        --machine-type=e2-medium \
        --image-family=ubuntu-2004-lts \
        --image-project=ubuntu-os-cloud \
        --boot-disk-size=20GB \
        --tags=http-server,https-server
    
    echo "✅ VM instance created"
fi

# Get VM IP
VM_IP=$(gcloud compute instances describe $VM_NAME \
    --zone=$VM_ZONE \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo "VM External IP: $VM_IP"

echo ""
echo "=========================================="
echo "Step 3: Setting up Firewall Rules"
echo "=========================================="

# Create firewall rules
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --target-tags http-server \
    --quiet 2>/dev/null || echo "Firewall rule 'allow-http' already exists"

gcloud compute firewall-rules create allow-backend \
    --allow tcp:8080 \
    --target-tags http-server \
    --quiet 2>/dev/null || echo "Firewall rule 'allow-backend' already exists"

echo "✅ Firewall rules configured"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Copy the content of key.json and add it to GitHub Secrets as GCP_SA_KEY"
echo ""
echo "2. Add these secrets to GitHub (Settings > Secrets and variables > Actions):"
echo "   - GCP_SA_KEY: (content of key.json)"
echo "   - GCP_PROJECT_ID: $PROJECT_ID"
echo "   - GCP_VM_NAME: $VM_NAME"
echo "   - GCP_VM_ZONE: $VM_ZONE"
echo "   - GCP_VM_IP: $VM_IP"
echo ""
echo "3. SSH to VM and install Docker:"
echo "   gcloud compute ssh $VM_NAME --zone=$VM_ZONE"
echo "   Then run: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
echo "   Then run: sudo usermod -aG docker \$USER"
echo "   Then run: gcloud auth configure-docker"
echo ""
echo "4. Push to GitHub:"
echo "   git add ."
echo "   git commit -m 'Setup CI/CD'"
echo "   git push origin main"
echo ""
echo "Your app will be available at:"
echo "   Frontend: http://$VM_IP"
echo "   Backend:  http://$VM_IP:8080"
echo ""
