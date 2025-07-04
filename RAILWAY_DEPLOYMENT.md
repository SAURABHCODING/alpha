# Railway Deployment Guide for Judge0 API

This guide explains how to deploy the Judge0 API application on Railway.

## Prerequisites

1. Railway account (https://railway.app)
2. GitHub account (for code repository)
3. This Judge0 application code

## Deployment Steps

### 1. Prepare Your Repository

1. Push this code to a GitHub repository
2. Ensure all the Railway-specific files are included:
   - `Procfile`
   - `railway.toml`
   - `nixpacks.toml`
   - `.env.railway`

### 2. Create Railway Project

1. Go to Railway (https://railway.app)
2. Click "Start a New Project"
3. Choose "Deploy from GitHub repo"
4. Select your repository with the Judge0 code

### 3. Add Required Services

Your Judge0 API requires these services:

#### PostgreSQL Database
1. In Railway dashboard, click "New Service"
2. Choose "Database" → "PostgreSQL"
3. This will automatically create a PostgreSQL database and provide `DATABASE_URL`

#### Redis Database
1. In Railway dashboard, click "New Service"
2. Choose "Database" → "Redis"
3. This will automatically create a Redis instance and provide `REDIS_URL`

### 4. Configure Environment Variables

In your Railway project settings, add these environment variables:

#### Required Variables:
```
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
RAILS_MAX_THREADS=5
SECRET_KEY_BASE=<generate-a-long-random-string>
```

#### Optional Variables (configure as needed):
```
ALLOW_ORIGIN=https://yourdomain.com
ENABLE_WAIT_RESULT=true
ENABLE_COMPILER_OPTIONS=true
ALLOWED_LANGUAGES_FOR_COMPILER_OPTIONS=44,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84
```

### 5. Generate SECRET_KEY_BASE

You can generate a secure secret key using Ruby:
```bash
ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"
```

### 6. Deploy

1. Railway will automatically deploy when you push to your connected GitHub repository
2. Monitor the build logs in Railway dashboard
3. Once deployed, you'll get a URL like `https://your-app.railway.app`

### 7. Run Database Migrations

After successful deployment, you may need to run database migrations:

1. Go to Railway dashboard
2. Open your service
3. Go to "Settings" → "Variables"
4. Add a one-time deployment command or use Railway CLI:

```bash
railway run bundle exec rails db:migrate
```

## Important Notes

### Worker Processes
- The `Procfile` defines both web and worker processes
- Railway will run the web process automatically
- For background job processing (Resque workers), you may need to scale worker processes in Railway dashboard

### Database Connections
- Railway automatically provides `DATABASE_URL` and `REDIS_URL`
- The application is configured to use these URLs automatically
- No need to manually configure database connection details

### Scaling
- You can scale your application in Railway dashboard
- For Judge0, you may want to scale worker processes for handling code execution queues

### Monitoring
- Use Railway's built-in logging and monitoring
- Monitor both web and worker processes
- Check database connection and Redis connectivity

## Troubleshooting

### Common Issues:

1. **Build Failures**
   - Check Ruby version compatibility (should be 3.2.0)
   - Ensure all dependencies are in Gemfile
   - Review build logs in Railway dashboard

2. **Database Connection Issues**
   - Verify `DATABASE_URL` is automatically provided
   - Check database service is running
   - Run migrations if needed

3. **Redis Connection Issues**
   - Verify `REDIS_URL` is automatically provided
   - Check Redis service is running
   - Monitor worker processes

4. **Port Issues**
   - Railway automatically provides `PORT` environment variable
   - Application is configured to use Railway's assigned port

## File Changes Made for Railway Compatibility

1. **Procfile** - Defines web and worker processes
2. **railway.toml** - Railway-specific configuration
3. **nixpacks.toml** - Build configuration for Nixpacks
4. **config/database.yml** - Updated to use `DATABASE_URL`
5. **config/puma.rb** - Improved configuration for Railway
6. **Gemfile** - Added Ruby version and production optimizations
7. **.env.railway** - Example environment variables for Railway

## Testing Your Deployment

Once deployed, test your API:

```bash
# Basic health check
curl https://your-app.railway.app/

# API endpoints (adjust based on your Judge0 routes)
curl https://your-app.railway.app/languages
curl https://your-app.railway.app/statuses
```

## Support

- Railway Documentation: https://docs.railway.app/
- Judge0 Documentation: https://judge0.com/
- Ruby on Rails Guides: https://guides.rubyonrails.org/
