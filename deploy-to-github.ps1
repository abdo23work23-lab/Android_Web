# Flutter Web Deployment Script for GitHub Pages
# Run this script in PowerShell to deploy your Flutter web app

Write-Host "=== Flutter Web to GitHub Pages Deployment ===" -ForegroundColor Green
Write-Host ""

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
}

# Build the Flutter web app
Write-Host "Building Flutter web app..." -ForegroundColor Yellow
$env:PATH = "D:\untitled1\flutter\bin;$env:PATH"
flutter build web --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Flutter build successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Flutter build failed!" -ForegroundColor Red
    exit 1
}

# Copy web files to root directory for GitHub Pages
Write-Host "Copying web files to root directory..." -ForegroundColor Yellow
Copy-Item -Path "build\web\*" -Destination "." -Recurse -Force

# Stage all files
Write-Host "Staging files for commit..." -ForegroundColor Yellow
git add .

# Commit changes
$commitMessage = "Deploy Flutter web app - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMessage

Write-Host "✅ Files committed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Add your GitHub repository as remote:" -ForegroundColor White
Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Push to GitHub:" -ForegroundColor White
Write-Host "   git push -u origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Enable GitHub Pages in repository settings" -ForegroundColor White
Write-Host ""
Write-Host "4. Your app will be available at:" -ForegroundColor White
Write-Host "   https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/" -ForegroundColor Gray