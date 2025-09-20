# GitHub Pages Deployment Guide for Flutter Web App

## Overview
Your Flutter app has been successfully built for web deployment. This guide will help you deploy it to GitHub Pages so you can include the link in your CV.

## Files Ready for Deployment
The web build is located in the `build/web/` directory and contains all necessary files for deployment.

## Step-by-Step Deployment Instructions

### 1. Create a New GitHub Repository
1. Go to [GitHub.com](https://github.com) and sign in
2. Click the "+" icon in the top right and select "New repository"
3. Name your repository (e.g., "my-flutter-app" or "parking-management-app")
4. Make sure it's set to **Public** (required for GitHub Pages on free accounts)
5. Don't initialize with README, .gitignore, or license (we'll push existing files)
6. Click "Create repository"

### 2. Prepare Your Local Repository
Open PowerShell in your project directory and run these commands:

```powershell
# Initialize git repository (if not already done)
git init

# Add all files to staging
git add .

# Make initial commit
git commit -m "Initial commit: Flutter web app ready for deployment"

# Add your GitHub repository as remote (replace with your actual repository URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY_NAME.git

# Push to GitHub
git push -u origin main
```

### 3. Set Up GitHub Pages
1. Go to your repository on GitHub
2. Click on "Settings" tab
3. Scroll down to "Pages" in the left sidebar
4. Under "Source", select "Deploy from a branch"
5. Choose "main" branch
6. Select "/ (root)" folder
7. Click "Save"

### 4. Configure for GitHub Pages
Since GitHub Pages serves from the root directory but your Flutter web files are in `build/web/`, you need to:

**Option A: Move files to root (Recommended)**
```powershell
# Copy all files from build/web to root directory
Copy-Item -Path "build\web\*" -Destination "." -Recurse -Force

# Add and commit the changes
git add .
git commit -m "Move web files to root for GitHub Pages"
git push
```

**Option B: Use GitHub Actions (Advanced)**
- Create `.github/workflows/deploy.yml` for automated deployment
- This automatically builds and deploys on every push

### 5. Access Your Deployed App
After a few minutes, your app will be available at:
```
https://YOUR_USERNAME.github.io/YOUR_REPOSITORY_NAME/
```

## Important Notes

### Firebase Configuration
Your app uses Firebase services. For production deployment:
1. Update Firebase configuration in `lib/firebase_options.dart`
2. Add your domain to Firebase Console > Project Settings > Authorized domains
3. Configure Firebase Hosting rules if needed

### Asset Paths
If you encounter asset loading issues:
- Ensure all asset paths in your code are relative
- Check that assets folder is included in the build
- Verify `pubspec.yaml` asset declarations

### Domain Setup (Optional)
To use a custom domain:
1. Add a `CNAME` file to your repository root
2. Add your domain name in the file
3. Configure DNS settings with your domain provider

### Troubleshooting
- **404 Error**: Check if files are in the correct location
- **Blank Page**: Check browser console for JavaScript errors
- **Assets Not Loading**: Verify asset paths and Firebase configuration
- **Build Issues**: Ensure all dependencies are compatible with web

## Updating Your App
To update your deployed app:
1. Make changes to your Flutter code
2. Rebuild for web: `flutter build web --release`
3. Copy new files to root (if using Option A)
4. Commit and push changes

## For Your CV
Once deployed, you can include this link in your CV:
```
Live Demo: https://YOUR_USERNAME.github.io/YOUR_REPOSITORY_NAME/
```

## Additional Resources
- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Firebase Hosting Guide](https://firebase.google.com/docs/hosting)