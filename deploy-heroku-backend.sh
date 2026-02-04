#!/bin/bash
# Deploy backend to Heroku (simplest option)

set -e

echo "🚀 Deploying backend to Heroku..."
echo ""

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "📥 Installing Heroku CLI..."
    npm install -g heroku
fi

echo "🔑 Login to Heroku"
heroku login

echo ""
echo "📱 Create a new Heroku app"
echo "Enter your desired app name (e.g., video-downloader-api):"
read -p "App name: " APP_NAME

heroku create $APP_NAME

echo ""
echo "📤 Deploying application..."
git push heroku main

echo ""
echo "🌐 Getting your backend URL..."
BACKEND_URL=$(heroku apps:info $APP_NAME -s | grep web_url | cut -d= -f2 | head -1)

echo ""
echo "✅ Backend deployed successfully!"
echo ""
echo "📋 Backend API URL: $BACKEND_URL"
echo ""
echo "📝 Next steps:"
echo "1. Go to your Netlify site settings"
echo "2. Set environment variable VITE_API_URL = $BACKEND_URL"
echo "3. Trigger a redeploy on Netlify"
echo ""
echo "💡 View logs: heroku logs --tail -a $APP_NAME"
