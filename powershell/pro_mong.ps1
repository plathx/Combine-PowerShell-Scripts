[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

Clear-Host
Write-Host "1. Install" -ForegroundColor Green
Write-Host "2. Remove" -ForegroundColor Red
$choice1 = Read-Host "เลือกตัวเลือก (1 หรือ 2)"

Clear-Host
Write-Host "1. BlueStacks App Player"
Write-Host "2. MSI App Player x BlueStacks"
$choice2 = Read-Host "เลือกโปรแกรม (1 หรือ 2)"

$path = if ($choice2 -eq "1") { "C:\Program Files\BlueStacks_nxt" } else { "C:\Program Files\BlueStacks_msi5" }
$dllPath = Join-Path $path "opengl32.dll"
$exePath = Join-Path $path "HD-Player.exe"
$downloadUrl = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/opengl32.dll"

function Stop-BS {
    Write-Host "Checking for running processes..." -ForegroundColor Yellow
    $proc = Get-Process -Name "HD-Player" -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "Stopping HD-Player..." -ForegroundColor Yellow
        $proc | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
}

if ($choice1 -eq "1") {
    Stop-BS
    try {
        Write-Host "Downloading..." -ForegroundColor Cyan
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $wc.DownloadFile($downloadUrl, $dllPath)
        Write-Host "ติดตั้งไฟล์สำเร็จ!" -ForegroundColor Green
        
        if (Test-Path $exePath) {
            Write-Host "สถานะ: ติดตั้งเสร็จสิ้น กำลังเปิดโปรแกรม..." -ForegroundColor Green
            Start-Process $exePath
            Write-Host "กดปุ่ม INS เพื่อเปิดเมนูมอง" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "เกิดข้อผิดพลาด: $_" -ForegroundColor Red
    }
}
elseif ($choice1 -eq "2") {
    Stop-BS
    if (Test-Path $dllPath) {
        Remove-Item $dllPath -Force
        Write-Host "ลบไฟล์สำเร็จแล้ว" -ForegroundColor Green
    }
    else {
        Write-Host "ไม่พบไฟล์ที่ต้องการลบ" -ForegroundColor Yellow
    }
}
else {
    Write-Host "เลือกตัวเลือกไม่ถูกต้อง" -ForegroundColor Red
}

Write-Host ""
Read-Host "เสร็จสิ้น! กด Enter เพื่อปิด..."