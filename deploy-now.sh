#!/bin/bash
# Deploy to Netlify using the API directly (no CLI needed)

set -e

NETLIFY_TOKEN="nfp_CfGtguxoEhNMxwAVEsfaoCfWcNWXvnzba817"
PROJECT_DIR="/Users/rajatsable/Documents/web development/video downloader"

cd "$PROJECT_DIR"

echo "🚀 Deploying Video Downloader to Netlify..."
echo ""

# Create deployment package
echo "📦 Creating deployment package..."
rm -f frontend.zip
zip -r frontend.zip frontend/ -x "frontend/node_modules/*" "frontend/.git/*" > /dev/null 2>&1 || true

# Get file size
FILE_SIZE=$(stat -f%z frontend.zip 2>/dev/null || stat -c%s frontend.zip 2>/dev/null)
echo "   Package size: $(($FILE_SIZE / 1024)) KB"

echo ""
echo "🔍 Checking for existing sites..."

# List existing sites
SITES=$(curl -s -H "Authorization: Bearer $NETLIFY_TOKEN" \
  https://api.netlify.com/api/v1/sites | \
  jq -r '.[].name' 2>/dev/null || echo "")

if [ -z "$SITES" ]; then
    echo "   No existing sites found"
    SITE_ID=""
else
    echo "   Found sites:"
    echo "$SITES"
fi

echo ""
echo "📤 Deploying to Netlify..."

# Create or update site
if [ -z "$SITE_ID" ]; then
    echo "   Creating new site..."
    RESPONSE=$(curl -s -X POST \
      -H "Authorization: Bearer $NETLIFY_TOKEN" \
      -F "files=@frontend.zip" \
      https://api.netlify.com/api/v1/sites)
    
    SITE_ID=$(echo "$RESPONSE" | jq -r '.site_id' 2>/dev/null || echo "")
    SITE_URL=$(echo "$RESPONSE" | jq -r '.url' 2>/dev/null || echo "")
else
    echo "   Updating existing site..."
    RESPONSE=$(curl -s -X POST \
      -H "Authorization: Bearer $NETLIFY_TOKEN" \
      -F "files=@frontend.zip" \
      https://api.netlify.com/api/v1/sites/$SITE_ID/deploys)
    
    SITE_URL=$(echo "$RESPONSE" | jq -r '.url' 2>/dev/null || echo "")
fi

echo ""
if [ ! -z "$SITE_ID" ] && [ ! -z "$SITE_URL" ]; then
    echo "✅ Frontend deployed successfully!"
    echo ""
    echo "📊 Deployment Details:"
    echo "   Site ID:  $SITE_ID"
    echo "   Site URL: $SITE_URL"
    echo ""
    
    # Save credentials
    mkdir -p "$PROJECT_DIR/.netlify"
    cat > "$PROJECT_DIR/.netlify/site-info.txt" << EOF
SITE_ID=$SITE_ID
SITE_URL=$SITE_URL
DEPLOYED_AT=$(date)
EOF
    
    echo "💾 Saved to .netlify/site-info.txt"
else
    echo "❌ Deployment failed"
    echo "   Response: $RESPONSE"
fi

# Cleanup
rm -f frontend.zip

echo ""
echo "=========================================="
echo "  NEXT: Deploy Backend to Heroku"
echo "=========================================="
echo ""
echo "To complete the setup, we need to:"
echo "1. Deploy the backend API to Heroku"
echo "2. Get the backend URL"
echo "3. Set environment variable on Netlify"
echo ""
