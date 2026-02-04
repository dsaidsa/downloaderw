# Netlify Deployment with Your Token

Your Netlify token has been securely received. Here's how to deploy manually in 5 minutes:

## Option 1: Deploy via Netlify Web UI (Easiest)

1. Go to https://app.netlify.com
2. Click **"Add new site"** → **"Deploy manually"**
3. Drag and drop the `frontend` folder
4. Site will be created instantly with URL like: `https://xxx.netlify.app`

## Option 2: Deploy via Netlify CLI

```bash
# Install CLI
npm install -g netlify-cli

# Deploy (will prompt you to login with your token)
netlify deploy --prod --dir=frontend
```

## Step 1: Deploy Frontend (Choose One Above)

After deploying, you'll get a URL like:
```
https://your-site-name.netlify.app
```

Save this URL!

---

## Step 2: Deploy Backend to Heroku

### Prerequisites
- Heroku account (free tier available)
- Heroku CLI installed

### Deployment Steps

```bash
# 1. Install Heroku CLI (if not already installed)
brew install heroku/brew/heroku

# 2. Login to Heroku
heroku login

# 3. Create a new app
heroku create video-downloader-YOUR_NAME

# 4. Add Heroku remote to git
heroku git:remote -a video-downloader-YOUR_NAME

# 5. Deploy (from project root)
git push heroku main

# 6. View logs
heroku logs --tail -a video-downloader-YOUR_NAME
```

After deployment, Heroku will give you a URL like:
```
https://video-downloader-your-name.herokuapp.com
```

Save this URL!

---

## Step 3: Connect Frontend to Backend

1. Go back to your Netlify site: https://app.netlify.com
2. Select your deployed site
3. Go to **Site settings** → **Build & deploy** → **Environment**
4. Add environment variable:
   - **Key:** `VITE_API_URL`
   - **Value:** `https://video-downloader-your-name.herokuapp.com`

5. Click **Trigger deploy** to redeploy with the backend URL

---

## Test Your App

1. Open your Netlify frontend URL
2. Paste a YouTube URL (or any supported video URL)
3. Select format and quality
4. Click **Download**
5. File should download successfully! 🎉

---

## Troubleshooting

**Frontend can't reach backend?**
- Check `VITE_API_URL` is set correctly in Netlify environment
- Verify backend is running: `heroku logs --tail -a your-app-name`
- Check browser DevTools → Network tab for CORS errors

**Backend errors?**
- View logs: `heroku logs --tail -a your-app-name`
- Check Heroku dashboard: https://dashboard.heroku.com

**File uploads failing?**
- Netlify has 30MB limit for serverless functions
- For larger files, configure cloud storage (GCS, S3)

---

## Commands Summary

```bash
# Local testing
./start.sh  # Starts local server on :8000

# Redeploy frontend
netlify deploy --prod --dir=frontend

# Redeploy backend
git push heroku main

# View logs
heroku logs --tail -a video-downloader-YOUR_NAME
```

---

Done! Your app is now deployed and fully functional! 🚀
