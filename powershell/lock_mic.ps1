if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Elevating privileges..." -ForegroundColor Yellow
    try {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -ErrorAction Stop
    } catch {
        Write-Host "Failed: Please run as Administrator." -ForegroundColor Red
        Pause
    }
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "     Microphone Volume Lock Manager V1.0      " -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "  1. Install   (Setup Lock & Persistence)" -ForegroundColor Green
    Write-Host "  2. Uninstall (Remove Lock & Cleanup)" -ForegroundColor Yellow
    Write-Host "  3. Exit" -ForegroundColor Red
    Write-Host "==============================================" -ForegroundColor Cyan
}

function Install-MicLock {
    $tempDir = "C:\phwyverysad"
    $zipUrl = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/lock_mic_volume.zip"
    $zipFile = Join-Path $tempDir "lock_mic_volume.zip"

    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    Write-Host "`n[*] Downloading resources..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -TimeoutSec 60
    } catch {
        Write-Host "[!] Download failed: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    Write-Host "[*] Extracting files..." -ForegroundColor Cyan
    try {
        Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
    } catch {
        Write-Host "[!] Extraction failed!" -ForegroundColor Red
        return
    }
    
    $validChoice = $false
    while (-not $validChoice) {
        Write-Host "`nSelect Microphone Volume Lock Level:" -ForegroundColor Cyan
        Write-Host "  1) 100%"
        Write-Host "  2) 75%"
        Write-Host "  3) 50%"
        Write-Host "  4) 25%"
        $volChoice = Read-Host "Choice (1-4)"

        $folderName = switch ($volChoice) {
            "1" { "100%"; $validChoice = $true }
            "2" { "75%"; $validChoice = $true }
            "3" { "50%"; $validChoice = $true }
            "4" { "25%"; $validChoice = $true }
            Default { Write-Host "[!] Invalid choice, please try again." -ForegroundColor Red }
        }
    }

    Write-Host "[*] Searching for configuration files..." -ForegroundColor Yellow
    $targetFolder = Get-ChildItem -Path $tempDir -Recurse -Directory | Where-Object { $_.Name -eq $folderName } | Select-Object -First 1

    if ($targetFolder) {
        $targetBatch = Join-Path $targetFolder.FullName "Run_atomatically.bat"

        if (Test-Path $targetBatch) {
            Write-Host "[*] Executing configuration for $folderName..." -ForegroundColor Green
            Write-Host "[*] Waiting for Run_atomatically.bat to close..." -ForegroundColor DarkGray
            
            $batProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$targetBatch`"" -WorkingDirectory $targetFolder.FullName -PassThru
            
            while (-not $batProcess.HasExited) {
                Start-Sleep -Milliseconds 500 # เช็คทุกๆ 0.5 วินาที
            }
            
            Write-Host "[*] Deleting C:\phwyverysad..." -ForegroundColor Yellow
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            
            Write-Host "[+] Installation Complete!" -ForegroundColor Green
            
            Write-Host "`nPress any key to close..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit
            
        } else {
            Write-Host "[!] Error: 'Run_atomatically.bat' not found inside $folderName folder." -ForegroundColor Red
        }
    } else {
        Write-Host "[!] Error: Folder '$folderName' not found in the extracted Zip." -ForegroundColor Red
    }
}

function Uninstall-MicLock {
    Write-Host "`n[*] Stopping active processes..." -ForegroundColor Yellow
    Stop-Process -Name "nircmdc" -Force -ErrorAction SilentlyContinue

    $winPath = $env:WINDIR
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

    $filesToRemove = @(
        "$winPath\lock_mic_vol.bat",
        "$winPath\hide_cmd_window2.vbs",
        "$winPath\nircmdc.exe",
        "$startupPath\start_lock_mic_vol.bat"
    )

    $removedCount = 0
    foreach ($file in $filesToRemove) {
        if (Test-Path $file) {
            Remove-Item $file -Force -ErrorAction SilentlyContinue
            Write-Host "  [-] Removed: $file" -ForegroundColor Gray
            $removedCount++
        }
    }

    if (Test-Path "C:\phwyverysad") {
        Remove-Item "C:\phwyverysad" -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($removedCount -eq 0) {
        Write-Host "[!] No files found to remove. It might already be uninstalled." -ForegroundColor Yellow
    } else {
        Write-Host "[+] Uninstallation Complete!" -ForegroundColor Green
    }
    
    Write-Host "`nPress any key to close..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Show-Menu
$choice = Read-Host "Select an option"
switch ($choice) {
    "1" { Install-MicLock }
    "2" { Uninstall-MicLock }
    "3" { Write-Host "Exiting..."; exit }
    Default { Write-Host "[!] Invalid option. Exiting..." -ForegroundColor Red; Start-Sleep -Seconds 2; exit }
}