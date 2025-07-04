#!/bin/bash

# Prepare Judge0 for Railway Deployment
echo "🚀 Preparing Judge0 for Railway deployment..."

# Check if we're in the right directory
if [ ! -f "Gemfile" ] || [ ! -f "config.ru" ]; then
    echo "❌ Error: This doesn't appear to be a Rails application directory"
    echo "Please run this script from the root of your Judge0 application"
    exit 1
fi

# Create backup of original files
echo "📦 Creating backup of original files..."
mkdir -p .railway_backup
cp Gemfile .railway_backup/ 2>/dev/null || true
cp config/database.yml .railway_backup/ 2>/dev/null || true
cp config/puma.rb .railway_backup/ 2>/dev/null || true

# Update bundle
echo "💎 Installing gems..."
bundle install

# Generate secret key base if not set
if [ -z "$SECRET_KEY_BASE" ]; then
    echo "🔑 Generating SECRET_KEY_BASE..."
    SECRET_KEY=$(ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")
    echo "SECRET_KEY_BASE=$SECRET_KEY" >> .env.railway
    echo "✅ SECRET_KEY_BASE generated and added to .env.railway"
fi

# Set proper permissions
echo "🔧 Setting permissions..."
mkdir -p tmp log
chmod -R 755 tmp log

# Verify important files exist
echo "✅ Verifying Railway files..."
required_files=("Procfile" "railway.toml" "nixpacks.toml" ".env.railway" "RAILWAY_DEPLOYMENT.md")

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file - Found"
    else
        echo "❌ $file - Missing"
    fi
done

echo ""
echo "🎉 Railway preparation complete!"
echo ""
echo "Next steps:"
echo "1. Commit all changes to your Git repository"
echo "2. Push to GitHub"
echo "3. Connect your repository to Railway"
echo "4. Add PostgreSQL and Redis services in Railway"
echo "5. Set environment variables from .env.railway"
echo "6. Deploy!"
echo ""
echo "📖 See RAILWAY_DEPLOYMENT.md for detailed instructions"