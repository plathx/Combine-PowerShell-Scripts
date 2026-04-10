[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Windows.Forms

Checkpoint-Computer -Description "Before Defender Removal" -RestorePointType "MODIFY_SETTINGS"

function Check-Defender {
    $status = Get-MpComputerStatus
    return $status.RealTimeProtectionEnabled
}

if (Check-Defender) {
    while (Check-Defender) {
        Write-Host "กรุณาปิด Windows Defender ให้หมดทุกอัน" -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        Start-Process "windowsdefender://threatsettings"
        
        while (Check-Defender) {
            Start-Sleep -Seconds 3
        }
        Stop-Process -Name "SystemSettings" -ErrorAction SilentlyContinue
    }
}
Write-Host "ปิด Defender เรียบร้อยแล้ว" -ForegroundColor Green

Write-Host "--------------------------------------------------------" -ForegroundColor White
Write-Host "คำเตือน: นี่คือการลบ Windows Defender แบบถาวร!" -ForegroundColor Red
Write-Host "หากต้องการกู้คืนในภายหลัง ให้ทำการ System Restore กลับไป" -ForegroundColor Yellow
Read-Host "กดปุ่ม [Enter] เพื่อเริ่มขั้นตอนการลบถาวร..."
Write-Host "--------------------------------------------------------" -ForegroundColor White

$dir = "C:\phwyverysad"
if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory }
Add-MpPreference -ExclusionPath $dir

$url = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/DefenderRemover.exe"
$file = "$dir\DefenderRemover.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $file)

$process = Start-Process $file -PassThru
Start-Sleep -Seconds 3

[System.Windows.Forms.SendKeys]::SendWait("y")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

while (Get-Process -Name "DefenderRemover" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 5
}

Remove-Item -Path $dir -Recurse -Force
Write-Host "กระบวนการเสร็จสิ้น ลบไฟล์ชั่วคราวและลบ Defender เรียบร้อยแล้ว" -ForegroundColor Green