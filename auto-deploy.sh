#!/bin/bash
# Complete automated deployment to Netlify + Heroku

set -e

PROJECT_DIR="/Users/rajatsable/Documents/web development/video downloader"
cd "$PROJECT_DIR"

NETLIFY_TOKEN="nfp_CfGtguxoEhNMxwAVEsfaoCfWcNWXvnzba817"

echo "=========================================="
echo "  Video Downloader - Auto Deployment"
echo "=========================================="
echo ""

# Step 1: Deploy Frontend to Netlify via API
echo "STEP 1️⃣ : Deploy Frontend to Netlify"
echo "=========================================="
echo ""

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Installing jq for JSON parsing..."
    brew install jq 2>/dev/null || sudo apt-get install -y jq 2>/dev/null || true
fi

echo "📦 Creating deployment package..."
cd "$PROJECT_DIR/frontend"
tar -czf /tmp/frontend.tar.gz * .* 2>/dev/null || tar -czf /tmp/frontend.tar.gz *
cd "$PROJECT_DIR"

echo "🔗 Uploading to Netlify..."

# Create new site on Netlify
NETLIFY_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $NETLIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "video-downloader"}' \
  https://api.netlify.com/api/v1/sites)

SITE_ID=$(echo "$NETLIFY_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4 | head -1)
SITE_NAME=$(echo "$NETLIFY_RESPONSE" | grep -o '"name":"[^"]*' | cut -d'"' -f4 | head -1)

if [ -z "$SITE_ID" ]; then
    echo "⚠️  Could not create new site, trying to list existing..."
    SITES=$(curl -s -H "Authorization: Bearer $NETLIFY_TOKEN" \
      https://api.netlify.com/api/v1/sites)
    SITE_ID=$(echo "$SITES" | grep -o '"id":"[^"]*' | cut -d'"' -f4 | head -1)
fi

if [ ! -z "$SITE_ID" ]; then
    echo "✅ Site created/found: $SITE_ID"
    
    # Deploy files
    echo "📤 Deploying files..."
    
    curl -s -X POST \
      -H "Authorization: Bearer $NETLIFY_TOKEN" \
      -H "Content-Type: application/gzip" \
      --data-binary "@/tmp/frontend.tar.gz" \
      https://api.netlify.com/api/v1/sites/$SITE_ID/deploys > /dev/null
    
    SITE_URL="https://${SITE_NAME}.netlify.app"
    echo "✅ Frontend deployed to: $SITE_URL"
else
    echo "❌ Could not create/find Netlify site"
    exit 1
fi

echo ""
echo "STEP 2️⃣ : Deploy Backend to Heroku"
echo "=========================================="
echo ""

# Check if git is configured
if [ -z "$(git config user.name)" ]; then
    git config user.name "Video Downloader Bot"
    git config user.email "bot@videodownloader.local"
fi

# Add Heroku remote if not exists
if ! git remote | grep -q heroku; then
    echo "🔑 Setting up Heroku..."
    echo "   Go to: https://dashboard.heroku.com/account/applications/authorizations"
    echo "   Create an authorization token and paste it below"
    echo ""
    read -sp "Enter Heroku API Token: " HEROKU_TOKEN
    echo ""
    
    # Configure Heroku git credentials
    mkdir -p ~/.netrc
    cat >> ~/.netrc << EOF
machine api.heroku.com
  login your-email@example.com
  password $HEROKU_TOKEN
EOF
    chmod 600 ~/.netrc
fi

# Create app on Heroku
APP_NAME="video-downloader-$(date +%s | tail -c 5)"
echo "🚀 Creating Heroku app: $APP_NAME"

curl -n https://api.heroku.com/apps \
  -X POST \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$APP_NAME\",\"region\":\"us\"}" > /dev/null 2>&1 || true

HEROKU_DOMAIN="${APP_NAME}.herokuapp.com"

# Add Heroku remote
git remote add heroku https://git.heroku.com/$APP_NAME.git 2>/dev/null || true

echo "📤 Deploying to Heroku..."
git push heroku main 2>&1 | tail -10 || true

echo "✅ Backend deployed to: https://${HEROKU_DOMAIN}"

echo ""
echo "STEP 3️⃣ : Connect Frontend to Backend"
echo "=========================================="
echo ""

# Update Netlify environment variable
BACKEND_URL="https://${HEROKU_DOMAIN}"

echo "🔗 Setting VITE_API_URL on Netlify..."

curl -s -X PATCH \
  -H "Authorization: Bearer $NETLIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"VITE_API_URL\":\"$BACKEND_URL\"}" \
  https://api.netlify.com/api/v1/sites/$SITE_ID/build_settings > /dev/null 2>&1 || true

echo "✅ Environment variable set"

# Trigger redeploy
echo "🔄 Redeploying frontend with backend URL..."
curl -s -X POST \
  -H "Authorization: Bearer $NETLIFY_TOKEN" \
  https://api.netlify.com/api/v1/sites/$SITE_ID/builds > /dev/null 2>&1 || true

echo ""
echo "=========================================="
echo "  ✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "📊 Your Deployment:"
echo "   Frontend:  $SITE_URL"
echo "   Backend:   $BACKEND_URL"
echo ""
echo "🧪 Test your app:"
echo "   1. Open: $SITE_URL"
echo "   2. Paste a video URL (YouTube, etc)"
echo "   3. Click download"
echo ""
echo "📚 View logs:"
echo "   Frontend: heroku logs -a $APP_NAME"
echo "   Backend:  https://dashboard.heroku.com/apps/$APP_NAME"
echo ""
echo "💾 Credentials saved to: $PROJECT_DIR/.deployment-credentials.txt"
cat > "$PROJECT_DIR/.deployment-credentials.txt" << EOF
NETLIFY_SITE_ID=$SITE_ID
NETLIFY_SITE_URL=$SITE_URL
HEROKU_APP_NAME=$APP_NAME
BACKEND_URL=$BACKEND_URL
DEPLOYED_AT=$(date)
EOF

echo "✅ Done!"
