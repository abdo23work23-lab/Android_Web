# استخدام Personal Access Token

بعد إنشاء الـ token، استخدم هذا الأمر:

```bash
git remote set-url origin https://YOUR_TOKEN@github.com/abdoemad23/Android.git
git push -u origin main
```

استبدل `YOUR_TOKEN` بالـ token الذي نسخته من GitHub.

مثال:
```bash
git remote set-url origin https://ghp_xxxxxxxxxxxxxxxxxxxx@github.com/abdoemad23/Android.git
git push -u origin main
```

