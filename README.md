# 🤖 Text Summarizer Agent — ADK + Gemini on Cloud Run

A single-purpose AI agent built with **Google Agent Development Kit (ADK)** and **Gemini 2.0 Flash**, deployed on **Google Cloud Run**. The agent performs **text summarization** — it accepts input text via an HTTP endpoint and returns a concise, structured summary.

---

## 📁 Project Structure

```
track 1/
├── summarizer_agent/          # ADK agent package
│   ├── __init__.py            # Package init (imports agent module)
│   └── agent.py               # Agent definition + tools
├── main.py                    # FastAPI entry point for Cloud Run
├── requirements.txt           # Python dependencies
├── Dockerfile                 # Container build instructions
├── .env                       # Environment variables (local dev)
├── .dockerignore              # Files excluded from Docker image
├── .gitignore                 # Files excluded from Git
└── README.md                  # This file
```

---

## 🧠 What the Agent Does

| Capability | Description |
|---|---|
| **Text Summarization** | Summarizes any input text in concise, bullet, or detailed style |
| **Word Count** | Returns word count, character count, and sentence count |
| **Model** | Gemini 2.0 Flash via Google AI Studio or Vertex AI |
| **Framework** | Google ADK (Agent Development Kit) |

---

## 🚀 Quick Start — Local Development

### 1. Create & Activate Virtual Environment

```bash
python -m venv .venv

# Windows PowerShell:
.venv\Scripts\Activate.ps1

# macOS / Linux:
source .venv/bin/activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure API Key

Edit the `.env` file and add your Google API key:

```env
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=your-actual-api-key
```

> Get your API key from [Google AI Studio](https://aistudio.google.com/apikey)

### 4. Run the Agent Locally

**Option A — Using ADK CLI (with web UI):**
```bash
adk web
```

**Option B — Using Python directly:**
```bash
python main.py
```

The agent will start at `http://localhost:8080`.

### 5. Test with cURL

```bash
# List available apps
curl http://localhost:8080/list-apps

# Create a session
curl -X POST http://localhost:8080/apps/summarizer_agent/users/user_1/sessions/session_1 \
  -H "Content-Type: application/json" \
  -d '{}'

# Send a summarization request
curl -X POST http://localhost:8080/run_sse \
  -H "Content-Type: application/json" \
  -d '{
    "app_name": "summarizer_agent",
    "user_id": "user_1",
    "session_id": "session_1",
    "new_message": {
      "role": "user",
      "parts": [{"text": "Summarize this: Artificial intelligence (AI) is intelligence demonstrated by machines, in contrast to the natural intelligence displayed by humans and animals. AI research has been defined as the field of study of intelligent agents, which refers to any device that perceives its environment and takes actions that maximize its chance of successfully achieving its goals."}]
    },
    "streaming": false
  }'
```

---

## ☁️ Deploy to Google Cloud Run

### Prerequisites

1. A **Google Cloud project** with billing enabled
2. **Google Cloud SDK** (`gcloud`) installed and authenticated
3. **APIs enabled**: Cloud Run, Artifact Registry, Cloud Build, Vertex AI
4. A **Google API Key** stored as a Secret in Secret Manager

### Step 1: Authenticate & Set Project

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Step 2: Enable Required APIs

```bash
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com
```

### Step 3: Store API Key as Secret

```bash
echo -n "YOUR_API_KEY" | gcloud secrets create GOOGLE_API_KEY --data-file=-

# Grant the Cloud Run service account access to the secret
gcloud secrets add-iam-policy-binding GOOGLE_API_KEY \
  --role="roles/secretmanager.secretAccessor" \
  --member="serviceAccount:YOUR_PROJECT_NUMBER-compute@developer.gserviceaccount.com"
```

### Step 4: Deploy to Cloud Run

**Option A — Using ADK CLI (recommended):**
```bash
adk deploy cloud_run \
  --project=YOUR_PROJECT_ID \
  --region=us-central1 \
  ./summarizer_agent
```

**Option B — Using gcloud CLI:**
```bash
gcloud run deploy summarizer-agent \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="GOOGLE_GENAI_USE_VERTEXAI=FALSE" \
  --set-secrets="GOOGLE_API_KEY=GOOGLE_API_KEY:latest"
```

### Step 5: Test the Deployed Agent

```bash
# Set your Cloud Run URL
export APP_URL="https://summarizer-agent-XXXXX.a.run.app"

# List apps
curl $APP_URL/list-apps

# Create session
curl -X POST $APP_URL/apps/summarizer_agent/users/user_1/sessions/session_1 \
  -H "Content-Type: application/json" -d '{}'

# Run agent
curl -X POST $APP_URL/run_sse \
  -H "Content-Type: application/json" \
  -d '{
    "app_name": "summarizer_agent",
    "user_id": "user_1",
    "session_id": "session_1",
    "new_message": {
      "role": "user",
      "parts": [{"text": "Summarize: Machine learning is a subset of artificial intelligence that enables systems to learn from data rather than being explicitly programmed. It uses algorithms that improve through experience. Common applications include recommendation systems, image recognition, and natural language processing."}]
    },
    "streaming": false
  }'
```

---

## 🔧 Configuration

| Variable | Description | Default |
|---|---|---|
| `GOOGLE_API_KEY` | Google AI Studio API key | Required |
| `GOOGLE_GENAI_USE_VERTEXAI` | Use Vertex AI instead of AI Studio | `FALSE` |
| `GOOGLE_CLOUD_PROJECT` | GCP Project ID (for Vertex AI) | — |
| `GOOGLE_CLOUD_LOCATION` | GCP Region (for Vertex AI) | `us-central1` |
| `PORT` | Server port (set by Cloud Run) | `8080` |

---

## 📝 License

This project is for educational purposes as part of the ADK + Cloud Run mini-project track.

