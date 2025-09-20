# إدارة حسابات GitHub المتعددة

## الطريقة الأولى: استخدام Git Credential Manager

1. **امسح بيانات الاعتماد المحفوظة:**
```bash
git config --global --unset credential.helper
git credential-manager-core erase
```

2. **عند الرفع، سيطلب منك بيانات الاعتماد:**
```bash
git push -u origin main
```

3. **أدخل بيانات حساب `abdoemad23`:**
   - Username: `abdoemad23`
   - Password: استخدم Personal Access Token (ليس كلمة المرور العادية)

## الطريقة الثانية: إعداد Git محلياً للمشروع فقط

```bash
# إعداد Git للمشروع الحالي فقط
git config user.name "abdoemad23"
git config user.email "abdoemad23@example.com"

# استخدام Personal Access Token
git remote set-url origin https://YOUR_TOKEN@github.com/abdoemad23/Android.git
git push -u origin main
```

## الطريقة الثالثة: إنشاء repository جديد

إذا لم تكن تملك الصلاحيات على `abdoemad23/Android`:

```bash
# أنشئ repository جديد باسم مختلف
git remote set-url origin https://github.com/abdoemad23/parking-management-app.git
git push -u origin main
```

