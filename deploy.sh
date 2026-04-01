#!/bin/bash
# ============================================
# ADK Summarizer Agent - Cloud Run Deploy Script
# Run this in Google Cloud Shell or any terminal with gcloud
# ============================================

set -e

echo "🚀 ADK Summarizer Agent — Cloud Run Deployment"
echo "================================================"

# --- CONFIGURATION (EDIT THESE) ---
PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-$(gcloud config get-value project 2>/dev/null)}"
REGION="us-central1"
SERVICE_NAME="summarizer-agent"

echo ""
echo "📋 Configuration:"
echo "   Project:  $PROJECT_ID"
echo "   Region:   $REGION"
echo "   Service:  $SERVICE_NAME"
echo ""

# Step 1: Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  --project="$PROJECT_ID"

echo "✅ APIs enabled!"

# Step 2: Check if GOOGLE_API_KEY secret exists
echo ""
echo "🔑 Checking for GOOGLE_API_KEY secret..."
if gcloud secrets describe GOOGLE_API_KEY --project="$PROJECT_ID" 2>/dev/null; then
  echo "✅ Secret already exists."
else
  echo "⚠️  Secret not found. Please create it:"
  echo '   echo -n "YOUR_API_KEY" | gcloud secrets create GOOGLE_API_KEY --data-file=-'
  echo ""
  read -p "Enter your Google API Key: " API_KEY
  echo -n "$API_KEY" | gcloud secrets create GOOGLE_API_KEY --data-file=- --project="$PROJECT_ID"
  echo "✅ Secret created!"
fi

# Step 3: Grant service account access to the secret
echo ""
echo "🔐 Granting secret access to Cloud Run service account..."
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
SA_EMAIL="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

gcloud secrets add-iam-policy-binding GOOGLE_API_KEY \
  --role="roles/secretmanager.secretAccessor" \
  --member="serviceAccount:${SA_EMAIL}" \
  --project="$PROJECT_ID" 2>/dev/null || true

echo "✅ Permissions set!"

# Step 4: Deploy to Cloud Run
echo ""
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy "$SERVICE_NAME" \
  --source . \
  --region "$REGION" \
  --allow-unauthenticated \
  --set-env-vars="GOOGLE_GENAI_USE_VERTEXAI=FALSE" \
  --set-secrets="GOOGLE_API_KEY=GOOGLE_API_KEY:latest" \
  --project="$PROJECT_ID" \
  --memory=512Mi \
  --timeout=300

# Step 5: Get the URL
echo ""
echo "================================================"
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --format="value(status.url)" --project="$PROJECT_ID")
echo "✅ DEPLOYMENT COMPLETE!"
echo ""
echo "🌐 Your public Cloud Run URL:"
echo "   $SERVICE_URL"
echo ""
echo "📝 Test with:"
echo "   curl $SERVICE_URL/list-apps"
echo ""
echo "================================================"
