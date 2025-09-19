# تعليمات رفع المشروع على GitHub

## المشكلة الحالية
يوجد مشكلة في الصلاحيات عند محاولة رفع المشروع على GitHub. الخطأ يشير إلى:
```
Permission to abdoemad23/Android.git denied to abdo2233work2233-ui
```

## الحلول المطلوبة

### الحل الأول: استخدام Personal Access Token
1. اذهب إلى GitHub.com وادخل إلى حسابك
2. اذهب إلى Settings > Developer settings > Personal access tokens > Tokens (classic)
3. اضغط على "Generate new token (classic)"
4. اختر الصلاحيات المطلوبة (على الأقل: repo, workflow)
5. انسخ الـ token
6. استخدم الأمر التالي:
```bash
git remote set-url origin https://YOUR_TOKEN@github.com/abdoemad23/Android.git
git push -u origin main
```

### الحل الثاني: استخدام SSH
1. أنشئ SSH key:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```
2. أضف المفتاح إلى GitHub:
   - انسخ محتوى `~/.ssh/id_ed25519.pub`
   - اذهب إلى GitHub > Settings > SSH and GPG keys > New SSH key
3. غير الـ remote URL:
```bash
git remote set-url origin git@github.com:abdoemad23/Android.git
git push -u origin main
```

### الحل الثالث: إنشاء repository جديد
إذا لم تكن تملك الصلاحيات على الـ repository الحالي:
1. اذهب إلى GitHub وأنشئ repository جديد باسم "parking-management-app"
2. استخدم الأمر:
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/parking-management-app.git
git push -u origin main
```

## بعد الرفع الناجح

1. اذهب إلى GitHub repository
2. اذهب إلى Settings > Pages
3. اختر "GitHub Actions" كمصدر للـ deployment
4. سيتم تشغيل الـ workflow تلقائياً
5. بعد اكتمال الـ build، سيكون الموقع متاح على:
   `https://YOUR_USERNAME.github.io/REPOSITORY_NAME/`

## ملاحظات مهمة
- تأكد من أن الـ repository ليس فارغاً قبل الرفع
- تأكد من تفعيل GitHub Pages في إعدادات الـ repository
- الـ workflow سيعمل تلقائياً عند كل push جديد
