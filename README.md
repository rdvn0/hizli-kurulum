# 🚀 VDS & Windows Hızlı Kurulum Scripti (PowerShell)

Yeni alınan VDS sunucular veya format atılmış Windows bilgisayarlar için **tek komutla** çalışan kurulum otomasyonu.

> **Özellik:** Windows'un kendi PowerShell'i ile çalışır.

## ⚡ Hızlı Başlangıç (Tek Komut)

VDS içinde PowerShell'i açın ve şu komutu yapıştırın. Dosya indirmenize gerek kalmadan menü açılacaktır:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rdvn0/hizli-kurulum/main/setup.ps1'))
```
# 📦 Desteklenen Yazılımlar
* Tarayıcılar: Chrome, Firefox, Brave
* Geliştirici: VS Code, Notepad++, Sublime Text, Git
* Diller:      Python 3, Node.js (LTS), Temurin JDK (8, 17, 21, 25)
* Sunucu:      XAMPP, WampServer, AppServ
* Araçlar:     WinRAR, 7-Zip, FileZilla, Discord, Telegram


# ⚠️ Uyarı
Bu script indirme ve kurulum işlemleri için Yönetici (Administrator) yetkisine ihtiyaç duyar.
