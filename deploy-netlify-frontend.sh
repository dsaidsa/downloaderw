#!/bin/bash
# Deploy frontend to Netlify using CLI

set -e

echo "📦 Installing Netlify CLI..."
if ! command -v netlify &> /dev/null; then
    npm install -g netlify-cli
fi

echo "🔑 Logging in to Netlify..."
netlify login

echo "📤 Deploying frontend to Netlify..."
netlify deploy --prod --dir=frontend

echo "✅ Frontend deployed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Note your Netlify site URL"
echo "2. Deploy the backend (see NETLIFY_DEPLOYMENT.md)"
echo "3. Update VITE_API_URL environment variable on Netlify"
echo "4. Redeploy to connect frontend to backend"
