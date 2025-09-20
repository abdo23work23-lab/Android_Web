# إعداد SSH لحسابات GitHub المتعددة

## الخطوة 1: إنشاء SSH Key جديد

```bash
# أنشئ SSH key جديد لحساب abdoemad23
ssh-keygen -t ed25519 -C "abdoemad23@example.com" -f ~/.ssh/id_ed25519_abdoemad23
```

## الخطوة 2: إضافة SSH Key إلى GitHub

1. انسخ المفتاح العام:
```bash
cat ~/.ssh/id_ed25519_abdoemad23.pub
```

2. اذهب إلى GitHub > Settings > SSH and GPG keys > New SSH key
3. الصق المفتاح وأضفه

## الخطوة 3: إعداد SSH Config

أنشئ ملف `~/.ssh/config`:

```
# حساب abdoemad23
Host github-abdoemad23
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_abdoemad23

# الحساب الافتراضي
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
```

## الخطوة 4: تغيير Remote URL

```bash
git remote set-url origin git@github-abdoemad23:abdoemad23/Android.git
git push -u origin main
```

