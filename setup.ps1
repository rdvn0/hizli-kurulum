<#
.SYNOPSIS
    VDS Hızlı Kurulum Scripti
.DESCRIPTION
    Windows VDS ve format sonrası otomatik program kurulum aracı.
#>

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Yönetici izni alınıyor..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$ErrorActionPreference = "Stop"
$TempDir = "$env:TEMP\VDS_Installer"


if (!(Test-Path -Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir | Out-Null
}

$SoftwareDB = @{
    1  = @{Name="Google Chrome";     Url="https://dl.google.com/chrome/install/standalonesetup64.exe"; Args="/silent /install"}
    2  = @{Name="Mozilla Firefox";   Url="https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=tr"; Args="-ms"}
    3  = @{Name="Brave Browser";     Url="https://laptop-updates.brave.com/latest/winx64"; Args="--silent"}
    4  = @{Name="Notepad++";         Url="https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.9.1/npp.8.9.1.Installer.exe"; Args="/S"}
    5  = @{Name="Sublime Text";      Url="https://download.sublimetext.com/Sublime%20Text%20Build%203211%20x64%20Setup.exe"; Args="/VERYSILENT"}
    6  = @{Name="WinRAR";            Url="https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-700tr.exe"; Args="/S"}
    7  = @{Name="7-Zip";             Url="https://www.7-zip.org/a/7z2301-x64.exe"; Args="/S"}
    8  = @{Name="Temurin JDK 25 (LTS)"; Url="https://api.adoptium.net/v3/binary/latest/25/ga/windows/x64/jdk/hotspot/normal/eclipse"; Args="ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"}
    9  = @{Name="Temurin JDK 21 (LTS)";  Url="https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jdk/hotspot/normal/eclipse"; Args="ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"}
    10 = @{Name="Temurin JDK 17 (LTS)";  Url="https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse"; Args="ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"}
    11 = @{Name="Temurin JDK 8";         Url="https://api.adoptium.net/v3/binary/latest/8/ga/windows/x64/jdk/hotspot/normal/eclipse";  Args="ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"}
    12 = @{Name="Node.js (LTS)";     Url="https://nodejs.org/dist/latest/node-v25.6.0-x64.msi"; Args="/quiet"}
    13 = @{Name="Python 3.12";       Url="https://www.python.org/ftp/python/3.15.0/python-3.15.0a5-amd64.exe"; Args="/quiet InstallAllUsers=1 PrependPath=1"}
    14 = @{Name="Git (Version Ctrl)";Url="https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.1/Git-2.53.0-64-bit.exe"; Args="/VERYSILENT /NORESTART"}
    15 = @{Name="XAMPP";             Url="https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.4/xampp-windows-x64-8.2.4-0-VS16-installer.exe/download"; Args="--mode unattended"}
    16 = @{Name="WampServer";        Url="https://wampserver.aviatechno.net/files/wampserver3.3.2_x64.exe"; Args="/VERYSILENT"}
    17 = @{Name="AppServ";           Url="https://sourceforge.net/projects/appserv/files/AppServ%20Open%20Project/9.3.0/AppServ-x64-9.3.0.exe/download"; Args="/S"}
    18 = @{Name="FileZilla";         Url="https://download.filezilla-project.org/client/FileZilla_3.66.4_win64_setup.exe"; Args="/S /user=all"}
    19 = @{Name="Discord";           Url="https://discord.com/api/download?platform=win"; Args=""}
    20 = @{Name="Telegram";          Url="https://telegram.org/dl/desktop/win64"; Args="/VERYSILENT"}
}

function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "     VDS HIZLI KURULUM (POWERSHELL)       " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    
    $SoftwareDB.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Host " [$($_.Name)] $($_.Value.Name)" -ForegroundColor Green
    }
    
    Write-Host "------------------------------------------"
    Write-Host " Kullanim: 1,2,14 (Virgulle ayir) veya 'all'" -ForegroundColor Yellow
}

Show-Menu
$InputStr = Read-Host " Seciminiz"

$SelectedIDs = @()

if ($InputStr -eq "all") {
    $SelectedIDs = $SoftwareDB.Keys
} else {
    $Parts = $InputStr -split ","
    foreach ($Part in $Parts) {
        $ID = [int]$Part.Trim()
        if ($SoftwareDB.ContainsKey($ID)) {
            $SelectedIDs += $ID
        }
    }
}

if ($SelectedIDs.Count -eq 0) {
    Write-Host "Secim yapilmadi, cikiliyor..." -ForegroundColor Red
    Start-Sleep -Seconds 2
    Exit
}

Write-Host "`nToplam $($SelectedIDs.Count) program kurulacak. Basliyoruz...`n" -ForegroundColor Cyan

foreach ($ID in $SelectedIDs) {
    $App = $SoftwareDB[$ID]
    $FileName = "install_$ID.exe"
    if ($App.Url -match ".msi") { $FileName = "install_$ID.msi" }
    $SavePath = Join-Path $TempDir $FileName

    Write-Host "-> Indiriliyor: $($App.Name)..." -ForegroundColor Yellow
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $App.Url -OutFile $SavePath -UseBasicParsing
    }
    catch {
        Write-Host "HATA: $($App.Name) indirilemedi! ($($_))" -ForegroundColor Red
        continue
    }

    Write-Host "   Kuruluyor: $($App.Name)..." -ForegroundColor Magenta
    try {
        if ($SavePath -match ".msi") {
            $ArgsList = "/i `"$SavePath`" $($App.Args)"
            Start-Process "msiexec.exe" -ArgumentList $ArgsList -Wait -NoNewWindow
        } else {
            Start-Process -FilePath $SavePath -ArgumentList $App.Args -Wait -NoNewWindow
        }
        Write-Host "   TAMAMLANDI." -ForegroundColor Green
    }
    catch {
        Write-Host "   KURULUM HATASI!" -ForegroundColor Red
    }
    Write-Host "------------------------------------------"
}

Write-Host "`nISLEM BITTI! Gecmis olsun." -ForegroundColor Cyan
Write-Host "Temp dosyalari temizleniyor..."
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
Read-Host "Cikmak icin Enter'a basin..."