# Backend & Frontend Production Deployment Guide

## Quick Summary
- **Frontend**: Already deployed to Netlify ✅ https://video-dl-1770468858.netlify.app
- **Backend**: Needs to be deployed to Railway, Render, or Heroku
- **What you need to do**: Deploy backend, get URL, update frontend config, redeploy

---

## ⚡ FASTEST WAY: Deploy Backend to Railway (Recommended)

### Step 1: Go to Railway
1. Open https://railway.app/new
2. Click "Deploy from GitHub repo"
3. Authorize and select your repo: `dadasdawqwe/download`

### Step 2: Configure
1. Railway will auto-detect the Dockerfile ✅
2. It will also auto-detect environment variables
3. No config needed - just click "Deploy"

### Step 3: Get Your Backend URL
1. Once deployed, click your service
2. Go to "Settings" → "Service"
3. Copy the **Service URL** - looks like: `https://video-downloader-backend-production-xxxx.railway.app`

### Step 4: Update Frontend & Redeploy
1. Copy the backend URL from Railway
2. Update this file: `frontend/env.js`
   ```javascript
   window.__API_URL__='https://your-railway-backend-url.railway.app'
   ```
3. Update `netlify.toml`:
   ```toml
   [context.production.environment]
     VITE_API_URL = "https://your-railway-backend-url.railway.app"
   ```
4. Push to GitHub: `git add -A && git commit -m "Update backend URL" && git push`
5. Netlify will auto-redeploy! 🚀

---

## Alternative: Render.com

### Step 1: Create Web Service
1. Go to https://dashboard.render.com
2. Click "New" → "Web Service"
3. Select "Public Git repository"
4. Paste: `https://github.com/dadasdawqwe/download`
5. Click "Connect"

### Step 2: Configure
- **Name**: `video-downloader-backend`
- **Runtime**: `Python 3.11`
- **Build Command**: `pip install -r backend/requirements.txt`
- **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- **Plan**: Free

### Step 3: Deploy & Get URL
- Click "Create Web Service"
- Wait 5-10 minutes
- Your URL will be: `https://video-downloader-backend.onrender.com`

### Step 4: Update Frontend
Same as Railway above, but use your Render URL

---

## Alternative: Heroku

### Step 1: Deploy via Heroku CLI
```bash
npm install -g heroku
heroku login
heroku create video-downloader-api-YOUR-UNIQUE-NAME
git push heroku main
```

### Step 2: Get Your URL
```bash
heroku info
```
URL will be: `https://video-downloader-api-YOUR-UNIQUE-NAME.herokuapp.com`

### Step 3: Update Frontend
Same as above

---

## Testing Checklist

- [ ] Backend deployed and running
- [ ] Backend URL copied
- [ ] frontend/env.js updated with backend URL
- [ ] netlify.toml VITE_API_URL updated
- [ ] Changes pushed to GitHub
- [ ] Netlify redeployed (should happen auto)
- [ ] Open https://video-dl-1770468858.netlify.app
- [ ] Try downloading a video from YouTube

---

## Troubleshooting

### "Failed to reach API"
- Check backend URL is correct (no typos)
- Make sure backend is actually running
- Check CORS is enabled (it is in our code ✅)

### "CORS Error"
- Our backend allows all origins ✅
- Check backend is responding: visit your backend URL in browser
- You should see FastAPI docs at `/docs`

### Backend taking too long to start
- First boot on free tier can take 30-60 seconds
- Keep the page open and refresh

---

## Your Deployment Repos & Links

```
GitHub: https://github.com/dadasdawqwe/download
Netlify Frontend: https://video-dl-1770468858.netlify.app
Backend: [TO BE DEPLOYED - pick Railway/Render/Heroku above]
```
