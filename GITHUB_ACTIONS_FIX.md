# 🔧 Fix GitHub Actions Deployment Permissions

## 🚨 **The Problem**
GitHub Actions is failing with permission error:
```
Permission to abdo23work23-lab/Android_Web.git denied to github-actions[bot]
Error: Action failed with "The process '/usr/bin/git' failed with exit code 128"
```

## ✅ **Solution Steps**

### 1. Enable GitHub Actions Permissions
1. Go to your repository: https://github.com/abdo23work23-lab/Android_Web
2. Click **Settings** tab
3. In the left sidebar, click **Actions** → **General**
4. Under **Workflow permissions**:
   - Select **"Read and write permissions"**
   - Check **"Allow GitHub Actions to create and approve pull requests"**
   - Click **Save**

### 2. Alternative: Use GITHUB_TOKEN (Recommended)
Update your workflow file (`.github/workflows/deploy.yml`) to use GITHUB_TOKEN:

```yaml
- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./build/web
```

### 3. Check Repository Settings
1. Go to **Settings** → **Pages**
2. Ensure **Source** is set to **"Deploy from a branch"**
3. Select **gh-pages** branch
4. Select **/ (root)** folder
5. Click **Save**

## 🔄 **Quick Fix Commands**

Run these commands to update your workflow:

1. **Create the workflow directory** (if not exists):
```bash
mkdir -p .github/workflows
```

2. **Update workflow file** with correct permissions

3. **Commit and push**:
```bash
git add .
git commit -m "Fix GitHub Actions permissions"
git push
```

## ⚡ **Manual Deployment Alternative**

If GitHub Actions continues to fail, you can deploy manually:

```bash
# Build with correct base href
$env:PATH = "D:\untitled1\flutter\bin;$env:PATH"
flutter build web --release --base-href /Android_Web/

# Deploy to gh-pages branch
git checkout --orphan gh-pages
git rm -rf .
cp -r build/web/* .
git add .
git commit -m "Deploy Flutter web app"
git push origin gh-pages --force
```

## 🎯 **Expected Result**
After fixing permissions, GitHub Actions will:
- ✅ Automatically build your Flutter app
- ✅ Create/update the gh-pages branch
- ✅ Deploy to GitHub Pages
- ✅ Your app will be live at: https://abdo23work23-lab.github.io/Android_Web/

## 📝 **Notes**
- The workflow creates a separate `gh-pages` branch for deployment
- Your main code stays on the `main` branch
- GitHub Pages serves from the `gh-pages` branch
- Each push to `main` triggers automatic deployment