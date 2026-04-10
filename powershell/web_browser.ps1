Write-Host "======================================" -ForegroundColor Cyan
Write-Host "      Select Browser to Install       " -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "1. Google Chrome"
Write-Host "2. Microsoft Edge"
Write-Host "3. Brave"
Write-Host "4. Mozilla Firefox"
Write-Host "5. Opera GX"
Write-Host "======================================"

$choice = Read-Host "Enter your choice (1-5)"

$p = "C:\phwyverysad"
$oldP = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

switch ($choice) {
    "1" { 
        $name = "Google Chrome"
        $u = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/ChromeSetup.exe"
        $f = "$p\ChromeSetup.exe"
        $args = "/silent","/install"
    }
    "2" { 
        $name = "Microsoft Edge"
        $u = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/MicrosoftEdgeSetup.exe"
        $f = "$p\MicrosoftEdgeSetup.exe"
        $args = "/silent","/install"
    }
    "3" { 
        $name = "Brave"
        $u = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/BraveBrowserSetup-BRV010.exe"
        $f = "$p\BraveBrowserSetup-BRV010.exe"
        $args = "/silent","/install"
    }
    "4" { 
        $name = "Mozilla Firefox"
        $u = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/Firefox.Installer.exe"
        $f = "$p\Firefox.Installer.exe"
        $args = "-ms"
    }
    "5" { 
        $name = "Opera GX"
        $u = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/OperaGXSetup.exe"
        $f = "$p\OperaGXSetup.exe"
        $args = "/silent","/install","/launchbrowser=0"
    }
    Default { 
        Write-Host "Invalid selection. Exiting..." -ForegroundColor Red
        return
    }
}

if(!(Test-Path $p)){ New-Item -Path $p -ItemType Directory -Force | Out-Null }

try {
    Write-Host "Downloading $name..." -ForegroundColor Yellow
    (New-Object System.Net.WebClient).DownloadFile($u, $f)
    
    if(Test-Path $f) {
        Write-Host "Installing $name..." -ForegroundColor Yellow
        Start-Process -FilePath $f -ArgumentList $args -Wait
        Write-Host "$name installed successfully!" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
finally {
    Write-Host "Cleaning up..." -ForegroundColor Gray
    Start-Sleep -Seconds 3
    if(Test-Path $p){ Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue }
    $ProgressPreference = $oldP
    Write-Host "Done." -ForegroundColor Cyan
}