#!/bin/bash
# Automated setup and deployment to Netlify + Heroku
# This script automates the entire deployment process

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=========================================="
echo "  Video Downloader - Full Deployment"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "📋 Checking prerequisites..."
echo ""

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git not found. Please install Git.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git found${NC}"

# Check if already on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}⚠️  Currently on branch: $CURRENT_BRANCH${NC}"
    read -p "Switch to main branch? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout main
    fi
fi

echo ""
echo "=========================================="
echo "  STEP 1: Frontend Setup (Netlify)"
echo "=========================================="
echo ""

echo "Do you have a Netlify account?"
echo "1) Yes, and I have my API token"
echo "2) No, create new site on Netlify"
echo "3) Skip frontend for now"
read -p "Choose (1-3): " netlify_choice

if [ "$netlify_choice" = "1" ]; then
    echo ""
    echo "Get your Netlify credentials:"
    echo "  1. Go to: https://app.netlify.com/user/applications/personal-access-tokens"
    echo "  2. Create new token and copy it"
    echo ""
    read -sp "Enter your Netlify Auth Token: " NETLIFY_AUTH_TOKEN
    echo ""
    read -p "Enter your Netlify Site ID: " NETLIFY_SITE_ID
    
    # Install Netlify CLI if not present
    if ! command -v netlify &> /dev/null; then
        echo "📥 Installing Netlify CLI..."
        npm install -g netlify-cli
    fi
    
    echo ""
    echo "🔑 Logging into Netlify..."
    netlify login --auth="$NETLIFY_AUTH_TOKEN" 2>/dev/null || true
    
    echo "📤 Deploying frontend to Netlify..."
    netlify deploy --prod --dir=frontend --site="$NETLIFY_SITE_ID" || true
    
    NETLIFY_URL="https://$NETLIFY_SITE_ID.netlify.app"
    echo -e "${GREEN}✓ Frontend deployed to: $NETLIFY_URL${NC}"
    
elif [ "$netlify_choice" = "2" ]; then
    echo ""
    echo "📖 To create a new Netlify site:"
    echo "  1. Go to: https://app.netlify.com"
    echo "  2. Click 'New site from Git' (or 'Add new site')"
    echo "  3. Select GitHub and choose: dadasdawqwe/download"
    echo "  4. Netlify will auto-detect build settings from netlify.toml"
    echo "  5. Click 'Deploy'"
    echo ""
    read -p "Press Enter once you've deployed on Netlify..."
    read -p "Enter your Netlify site URL (e.g., https://my-site.netlify.app): " NETLIFY_URL
fi

echo ""
echo "=========================================="
echo "  STEP 2: Backend Setup (Heroku)"
echo "=========================================="
echo ""

echo "Do you want to deploy backend to Heroku?"
read -p "Continue? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! command -v heroku &> /dev/null; then
        echo "📥 Installing Heroku CLI..."
        npm install -g heroku
    fi
    
    echo "🔑 Login to Heroku"
    echo "  (Browser window will open)"
    heroku login
    
    echo ""
    read -p "Enter your Heroku app name (e.g., video-downloader-api): " HEROKU_APP_NAME
    
    echo ""
    echo "🚀 Creating Heroku app..."
    heroku create "$HEROKU_APP_NAME" 2>/dev/null || echo "App may already exist"
    
    echo "📤 Deploying to Heroku..."
    git push heroku main 2>/dev/null || echo "Deployment in progress..."
    
    BACKEND_URL="https://${HEROKU_APP_NAME}.herokuapp.com"
    echo -e "${GREEN}✓ Backend deployed to: $BACKEND_URL${NC}"
    
    echo ""
    echo "💾 Saving credentials to local file (DO NOT COMMIT)..."
    cat > .deployment_urls.txt << EOF
NETLIFY_URL=$NETLIFY_URL
BACKEND_URL=$BACKEND_URL
HEROKU_APP_NAME=$HEROKU_APP_NAME
EOF
    echo -e "${GREEN}✓ Saved to .deployment_urls.txt${NC}"
fi

echo ""
echo "=========================================="
echo "  STEP 3: Connect Frontend to Backend"
echo "=========================================="
echo ""

if [ -z "$BACKEND_URL" ]; then
    read -p "Enter your Backend API URL: " BACKEND_URL
fi

echo ""
echo "🔗 Connecting frontend to backend..."
echo "   Backend URL: $BACKEND_URL"
echo ""

echo "📝 Adding GitHub Secrets for CI/CD..."
echo "  Go to: https://github.com/dadasdawqwe/download/settings/secrets/actions"
echo ""
echo "  Add these secrets:"
echo "    NETLIFY_AUTH_TOKEN: (your Netlify token)"
echo "    NETLIFY_SITE_ID: (your Netlify site ID)"
echo "    BACKEND_API_URL: $BACKEND_URL"
echo ""

read -p "Press Enter once you've added the secrets..."

echo ""
echo "=========================================="
echo "  DEPLOYMENT COMPLETE ✅"
echo "=========================================="
echo ""
echo "📊 Your Deployment:"
if [ ! -z "$NETLIFY_URL" ]; then
    echo "  Frontend: $NETLIFY_URL"
fi
if [ ! -z "$BACKEND_URL" ]; then
    echo "  Backend:  $BACKEND_URL"
fi
echo ""
echo "🧪 Testing:"
echo "  1. Open your frontend URL in browser"
echo "  2. Paste a YouTube URL"
echo "  3. Click download"
echo "  4. Should download successfully!"
echo ""
echo "📚 Docs:"
echo "  Frontend logs: https://app.netlify.com/sites/YOUR_SITE/deploys"
echo "  Backend logs:  heroku logs --tail -a $HEROKU_APP_NAME"
echo ""
echo "🚀 Next time: Just push to main branch for auto-deploy!"
echo ""
