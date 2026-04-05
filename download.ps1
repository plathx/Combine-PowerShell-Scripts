[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = "C:\ProgramData\CombinePS"
$exe = "$dir\app.exe"
$proto = "combineps"

# ใช้ URL ของ raw.githubusercontent.com โดยตรง
$url = "https://github.com/phwyverysad/Scripts-PowerShell/releases/download/websiteapp/app.exe"

New-Item -ItemType Directory -Force -Path $dir | Out-Null
Write-Host "กำลังดาวน์โหลดโปรแกรม..." -ForegroundColor Cyan

# เพิ่ม -UserAgent และ -UseBasicParsing เพื่อป้องกันการโดนบล็อกและลดปัญหาใน PowerShell เวอร์ชั่นเก่า
Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ตรวจสอบว่าดาวน์โหลดไฟล์สำเร็จหรือไม่
if (Test-Path $exe) {
    $regPath = "HKCU:\Software\Classes\$proto"
    New-Item -Path $regPath -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "(Default)" -Value "URL:CombinePS Protocol" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null

    $cmdPath = "$regPath\shell\open\command"
    New-Item -Path $cmdPath -Force | Out-Null
    Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value "`"$exe`" `"%1`""

    Write-Host "ติดตั้งสำเร็จ! ตอนนี้ปุ่มในหน้าเว็บของคุณพร้อมใช้งานแล้ว" -ForegroundColor Green
} else {
    Write-Host "ดาวน์โหลดไม่สำเร็จ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตหรือ URL" -ForegroundColor Red
}
