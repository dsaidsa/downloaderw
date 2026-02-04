# Netlify Deployment Guide

## Overview
This project has two parts:
1. **Frontend** (HTML/CSS/JS) - deploys on Netlify
2. **Backend** (FastAPI Python) - needs separate hosting

## Step 1: Deploy Frontend to Netlify

### Option A: Using Netlify CLI (Recommended)

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Login to Netlify:**
   ```bash
   netlify login
   ```

3. **Deploy the frontend:**
   ```bash
   netlify deploy --prod --dir=frontend
   ```

### Option B: Connect GitHub to Netlify (Auto-Deployment)

1. Go to [netlify.com](https://netlify.com) and sign up/login
2. Click "New site from Git"
3. Select GitHub and authorize
4. Select your repository: `dadasdawqwe/download`
5. Configure build settings:
   - **Base directory**: (leave empty)
   - **Build command**: `bash -lc "echo \"window.__API_URL__='${VITE_API_URL}'\" > frontend/env.js"`
   - **Publish directory**: `frontend`
6. Click "Deploy site"

## Step 2: Deploy Backend

Choose one of these options:

### Option 1: Heroku (Easiest for Python)
```bash
# Install Heroku CLI
npm install -g heroku

# Login and create app
heroku login
heroku create your-app-name

# Deploy
git push heroku main
```

### Option 2: Railway (Simple and Free-Tier Friendly)
1. Go to [railway.app](https://railway.app)
2. Connect your GitHub repo
3. Select your project and deploy

### Option 3: Render (Full-Stack Friendly)
1. Go to [render.com](https://render.com)
2. Create new Web Service
3. Connect GitHub repo
4. Set start command: `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### Option 4: Google Cloud Run (Serverless)
```bash
# Build Docker image
docker build -t gcr.io/PROJECT_ID/video-downloader ./backend

# Deploy
gcloud run deploy video-downloader --image gcr.io/PROJECT_ID/video-downloader --platform managed
```

## Step 3: Connect Frontend to Backend

After deploying backend, update Netlify environment:

1. Go to Netlify site settings
2. Build & Deploy → Environment
3. Add environment variable:
   - **Key**: `VITE_API_URL`
   - **Value**: `https://your-backend-url.com` (e.g., `https://video-downloader-xyz.herokuapp.com`)

4. Trigger a redeploy on Netlify

## Step 4: Configure CORS on Backend

The backend is already configured with CORS for all origins:
```python
CORSMiddleware(allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
```

This allows the frontend to call the backend API from any domain.

## Troubleshooting

### Frontend can't reach backend
- Check `VITE_API_URL` environment variable is set correctly
- Open browser DevTools → Network tab
- Verify backend is running and accessible

### Backend upload/download limits
- Netlify has file size limits for deployments
- For large video downloads, use cloud storage (GCS, S3)
- Set `STORAGE_TYPE=gcs` and `GCS_BUCKET=your-bucket`

### Dependencies not installed
- Ensure `requirements.txt` is in backend folder
- Backend service should auto-install from `pip install -r requirements.txt`

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_URL` | Backend API URL | `https://api.example.com` |
| `DOWNLOAD_DIR` | Download storage path | `/tmp/downloads` |
| `STORAGE_TYPE` | Storage backend | `local` or `gcs` |
| `GCS_BUCKET` | Google Cloud Storage bucket | `my-bucket-name` |

## Next Steps

1. Deploy frontend: `netlify deploy --prod --dir=frontend`
2. Choose & deploy backend service
3. Update `VITE_API_URL` on Netlify
4. Test the full application

## Support

- [Netlify Docs](https://docs.netlify.com)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Docker Deployment Guide](https://docs.docker.com/language/python/)
