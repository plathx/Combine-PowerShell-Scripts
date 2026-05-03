# =======================================================================
# Check Administrator Rights
# =======================================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# =======================================================================
# Function to execute raw Batch code perfectly without modifying it
# =======================================================================
function Show-ProgressBar {
    param([int]$Percent, [string]$Status, [int]$BarWidth = 40)
    
    $filled = [math]::Floor($BarWidth * $Percent / 100)
    $empty = $BarWidth - $filled
    $bar = "[" + ("=" * $filled) + (" " * $empty) + "]"
    $percentStr = "{0,3}%" -f $Percent
    
    Write-Host "`r  $bar $percentStr $Status" -NoNewline -ForegroundColor Cyan
}

function Run-BatchPayload {
    param([string]$BatCode, [string]$Title)
    
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║  $Title" -ForegroundColor Yellow -NoNewline
    Write-Host "$(' ' * (43 - $Title.Length))" -NoNewline
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "  ╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    $tempBat = Join-Path $env:TEMP "Setup_Payload_$([guid]::NewGuid()).bat"
    
    # Save as UTF-8 (Support Thai characters in Smart 7-zip script)
    [System.IO.File]::WriteAllText($tempBat, "@echo off`r`nsetlocal enabledelayedexpansion`r`n$BatCode", [System.Text.Encoding]::UTF8)
    
    # Create progress simulation
    $steps = @("Initializing...", "Processing...", "Configuring...", "Finalizing...")
    $stepIndex = 0
    $progress = 0
    
    # Run the bat file in background
    $process = Start-Process "cmd.exe" -ArgumentList "/c `"$tempBat`"" -WindowStyle Hidden -PassThru
    
    # Show progress bar while process is running
    while (-not $process.HasExited) {
        Start-Sleep -Milliseconds 200
        $progress += 2
        if ($progress -gt 95) { $progress = 95 }
        if ($progress % 25 -eq 0 -and $stepIndex -lt $steps.Count - 1) { $stepIndex++ }
        Show-ProgressBar -Percent $progress -Status $steps[$stepIndex]
    }
    
    # Complete progress
    Show-ProgressBar -Percent 100 -Status "Complete!"
    Write-Host "" # New line
    
    # Cleanup
    Remove-Item -Path $tempBat -Force -ErrorAction SilentlyContinue
}

# =======================================================================
# ORIGINAL BATCH CODES (Unmodified Logic)
# =======================================================================

$Install_Py2Exe = @'
set "SCRIPT_PATH=C:\scripts"
set "PS_FILE=%SCRIPT_PATH%\compile_python.ps1"
set "ICON_FILE=%SCRIPT_PATH%\python.ico"

if not exist "%SCRIPT_PATH%" (
    mkdir "%SCRIPT_PATH%"
    echo [OK] Folder C:\scripts created.
) else (
    echo [OK] Folder C:\scripts already exists.
)

echo [OK] Downloading official Python Icon...
if not exist "%ICON_FILE%" (
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/python/cpython/main/PC/icons/python.ico' -OutFile '%ICON_FILE%'" >nul 2>&1
)

echo [OK] Creating PowerShell script file...
> "%PS_FILE%" echo $filePath = $args[0]
>> "%PS_FILE%" echo if ^(-not $filePath^) { exit }
>> "%PS_FILE%" echo $fileDir = [System.IO.Path]::GetDirectoryName^($filePath^)
>> "%PS_FILE%" echo $fileName = [System.IO.Path]::GetFileNameWithoutExtension^($filePath^)
>> "%PS_FILE%" echo Set-Location -Path $fileDir
>> "%PS_FILE%" echo Write-Host "Compiling $fileName.py to EXE..." -ForegroundColor Cyan
>> "%PS_FILE%" echo Write-Host "Command: py -m PyInstaller --onefile --noconfirm --clean `"$filePath`"" -ForegroundColor DarkGray
>> "%PS_FILE%" echo Write-Host "--------------------------------------------------"
>> "%PS_FILE%" echo py -m PyInstaller --onefile --noconfirm --clean $filePath
>> "%PS_FILE%" echo $exePath = Join-Path -Path $fileDir -ChildPath "dist\$fileName.exe"
>> "%PS_FILE%" echo if ^(Test-Path $exePath^) {
>> "%PS_FILE%" echo     Write-Host "--------------------------------------------------"
>> "%PS_FILE%" echo     Write-Host "BUILD COMPLETE!" -ForegroundColor Green
>> "%PS_FILE%" echo     Write-Host "Opening folder and highlighting the EXE file..." -ForegroundColor Cyan
>> "%PS_FILE%" echo     Start-Process explorer.exe -ArgumentList "/select,`"$exePath`""
>> "%PS_FILE%" echo     Start-Sleep -Seconds 3
>> "%PS_FILE%" echo } else {
>> "%PS_FILE%" echo     Write-Host "--------------------------------------------------"
>> "%PS_FILE%" echo     Write-Host "Build failed! EXE file not found." -ForegroundColor Red
>> "%PS_FILE%" echo     pause
>> "%PS_FILE%" echo }

echo [OK] Setting up Context Menu Registry...
reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /ve /t REG_SZ /d "py to exe" /f >nul

if exist "%ICON_FILE%" (
    reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /v "Icon" /t REG_SZ /d "\"%ICON_FILE%\"" /f >nul
) else (
    reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /v "Icon" /t REG_SZ /d "cmd.exe" /f >nul
)

reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy\command" /ve /t REG_SZ /d "powershell.exe -ExecutionPolicy Bypass -NoProfile -File \"C:\scripts\compile_python.ps1\" \"%%1\"" /f >nul

ie4uinit.exe -show >nul 2>&1
echo --------------------------------------------------
echo DONE! Setup completed successfully.
echo --------------------------------------------------
'@

$Uninstall_Py2Exe = @'
echo [OK] Removing Context Menu from Registry...
reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /f >nul 2>&1

echo [OK] Removing script files...
set "SCRIPT_PATH=C:\scripts"
set "PS_FILE=%SCRIPT_PATH%\compile_python.ps1"
set "ICON_FILE=%SCRIPT_PATH%\python.ico"

if exist "%PS_FILE%" del "%PS_FILE%" /f /q
if exist "%ICON_FILE%" del "%ICON_FILE%" /f /q
if exist "%SCRIPT_PATH%" rd "%SCRIPT_PATH%" 2>nul

ie4uinit.exe -show >nul 2>&1

echo --------------------------------------------------
echo DONE! Uninstallation completed.
echo --------------------------------------------------
'@

$Install_Gofile = @'
set "SCRIPT_PATH=C:\GofileScript"
set "PS_FILE=%SCRIPT_PATH%\upload_to_gofile.ps1"
set "VBS_FILE=%SCRIPT_PATH%\upload_to_gofile.vbs"
if not exist "%SCRIPT_PATH%" mkdir "%SCRIPT_PATH%"

echo [1/3] Creating PowerShell script...
echo $filePath = $args[0] > "%PS_FILE%"
echo if (-not $filePath) { exit } >> "%PS_FILE%"
echo try { >> "%PS_FILE%"
echo     [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] ^| Out-Null >> "%PS_FILE%"
echo     [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] ^| Out-Null >> "%PS_FILE%"
echo     $serverInfo = Invoke-RestMethod -Uri "https://api.gofile.io/servers" >> "%PS_FILE%"
echo     $server = $serverInfo.data.servers[0].name >> "%PS_FILE%"
echo     $fileItem = Get-Item $filePath >> "%PS_FILE%"
echo     $fileSize = [math]::Round($fileItem.Length / 1MB, 2) >> "%PS_FILE%"
echo     $fileName = $fileItem.Name >> "%PS_FILE%"
echo     $uploadResponse = curl.exe -s -F "file=@$filePath" "https://$server.gofile.io/contents/uploadfile" >> "%PS_FILE%"
echo     $response = $uploadResponse ^| ConvertFrom-Json >> "%PS_FILE%"
echo     if ($response.status -eq "ok") { >> "%PS_FILE%"
echo         $link = $response.data.downloadPage >> "%PS_FILE%"
echo         $link ^| Set-Clipboard >> "%PS_FILE%"
echo         $xmlString = @" >> "%PS_FILE%"
echo ^<toast^>^<visual^>^<binding template="ToastGeneric"^>^<text^>Gofile Upload Complete!^</text^>^<text^>File: $fileName ($fileSize MB)^</text^>^<text^>Link copied to clipboard: $link^</text^>^<text placement="attribution"^>Gofile Upload Service^</text^>^</binding^>^</visual^>^</toast^> >> "%PS_FILE%"
echo "@ >> "%PS_FILE%"
echo         $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new() >> "%PS_FILE%"
echo         $toastXml.LoadXml($xmlString) >> "%PS_FILE%"
echo         $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml) >> "%PS_FILE%"
echo         $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("GofileUpload") >> "%PS_FILE%"
echo         $notifier.Show($toast) >> "%PS_FILE%"
echo     } else { >> "%PS_FILE%"
echo         $xmlString = "^<toast^>^<visual^>^<binding template=\"ToastGeneric\"^>^<text^>Gofile Upload Failed!^</text^>^<text^>Please try again later.^</text^>^</binding^>^</visual^>^</toast^>" >> "%PS_FILE%"
echo         $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new() >> "%PS_FILE%"
echo         $toastXml.LoadXml($xmlString) >> "%PS_FILE%"
echo         $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml) >> "%PS_FILE%"
echo         $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("GofileUpload") >> "%PS_FILE%"
echo         $notifier.Show($toast) >> "%PS_FILE%"
echo     } >> "%PS_FILE%"
echo } catch { } >> "%PS_FILE%"

echo [2/3] Creating VBS wrapper...
echo Set WshShell = CreateObject("WScript.Shell") ^> "%VBS_FILE%"
echo WshShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File ""%PS_FILE%"" ""%%1""", 0, False ^>^> "%VBS_FILE%"
echo Set WshShell = Nothing ^>^> "%VBS_FILE%"

echo [3/3] Updating Registry...
reg delete "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /ve /t REG_SZ /d "Get Gofile Link" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /v "Icon" /t REG_SZ /d "imageres.dll,-1024" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\GofileUpload\command" /ve /t REG_SZ /d "wscript.exe \"%VBS_FILE%\" \"%%1\"" /f >nul

echo --------------------------------------------------
echo DONE! Setup completed successfully.
echo --------------------------------------------------
'@

$Uninstall_Gofile = @'
set "SCRIPT_PATH=C:\GofileScript"
reg delete "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /f >nul 2>&1
if exist "%SCRIPT_PATH%" rd /s /q "%SCRIPT_PATH%"
echo --------------------------------------------------
echo DONE! Uninstallation completed.
echo --------------------------------------------------
'@

$Install_Smart7z = @'
:: 1. Silent Install 7-Zip
set "SEVENZ_PATH=C:\Program Files\7-Zip\7z.exe"
set "SEVENZ_FM=C:\Program Files\7-Zip\7zFM.exe"

if exist "%SEVENZ_PATH%" (
    echo [OK] 7-Zip is already installed.
) else (
    echo [..] 7-Zip not found. Downloading and installing silently...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z2409-x64.exe' -OutFile '%TEMP%\7z_setup.exe'" >nul 2>&1
    if exist "%TEMP%\7z_setup.exe" (
        "%TEMP%\7z_setup.exe" /S
        del "%TEMP%\7z_setup.exe" /f /q
        echo [OK] 7-Zip installed successfully.
    ) else (
        echo [ERROR] Failed to download 7-Zip. Please check your internet.
        goto :EOF
    )
)

:: 2. Create Helper Scripts
set "SCRIPT_PATH=C:\scripts"
set "BAT_EXTRACT=%SCRIPT_PATH%\smart_extract.bat"
set "BAT_COMPRESS=%SCRIPT_PATH%\smart_compress.bat"

if not exist "%SCRIPT_PATH%" mkdir "%SCRIPT_PATH%"

echo [OK] Creating extraction logic script...
> "%BAT_EXTRACT%" echo @echo off
>> "%BAT_EXTRACT%" echo chcp 65001 ^>nul
>> "%BAT_EXTRACT%" echo set "SEVENZ=C:\Program Files\7-Zip\7z.exe"
>> "%BAT_EXTRACT%" echo if not exist "%%SEVENZ%%" exit /b
>> "%BAT_EXTRACT%" echo set "FILE=%%~1"
>> "%BAT_EXTRACT%" echo set "FOLDER=%%~dpn1"
>> "%BAT_EXTRACT%" echo.
>> "%BAT_EXTRACT%" echo "%%SEVENZ%%" x "%%FILE%%" -o"%%FOLDER%%" -y

echo [OK] Creating compression logic script...
> "%BAT_COMPRESS%" echo @echo off
>> "%BAT_COMPRESS%" echo chcp 65001 ^>nul
>> "%BAT_COMPRESS%" echo set "FORMAT=%%~1"
>> "%BAT_COMPRESS%" echo set "TARGET=%%~2"
>> "%BAT_COMPRESS%" echo set "TARGET_DIR=%%~dp2"
>> "%BAT_COMPRESS%" echo set "SEVENZ=C:\Program Files\7-Zip\7z.exe"
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: สร้างตัวแปรจำเพาะสำหรับ Lock ระบบ
>> "%BAT_COMPRESS%" echo set "SAFE_DIR=%%TARGET_DIR:\=_%%"
>> "%BAT_COMPRESS%" echo set "SAFE_DIR=%%SAFE_DIR::=_%%"
>> "%BAT_COMPRESS%" echo set "SAFE_DIR=%%SAFE_DIR: =_%%"
>> "%BAT_COMPRESS%" echo set "LIST_FILE=%%TEMP%%\7z_list_%%SAFE_DIR%%%%FORMAT%%.txt"
>> "%BAT_COMPRESS%" echo set "FINAL_LIST=%%TEMP%%\7z_final_%%SAFE_DIR%%%%FORMAT%%.txt"
>> "%BAT_COMPRESS%" echo set "LOCK_DIR=%%TEMP%%\7z_lock_%%SAFE_DIR%%%%FORMAT%%"
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: 1. บันทึกไฟล์ลง List
>> "%BAT_COMPRESS%" echo ^>^>"%%LIST_FILE%%" echo "%%~2"
>> "%BAT_COMPRESS%" echo md "%%LOCK_DIR%%" 2^>nul
>> "%BAT_COMPRESS%" echo if errorlevel 1 exit /b
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: 2. หน่วงเวลา 1 วินาที เพื่อกวาดไฟล์ทั้งหมดที่ถูกคลุมดำ
>> "%BAT_COMPRESS%" echo ping 127.0.0.1 -n 2 ^>nul
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: 3. นับจำนวนไฟล์และคัดลอกรายชื่อ
>> "%BAT_COMPRESS%" echo set "ITEM_COUNT=0"
>> "%BAT_COMPRESS%" echo set "FIRST_ITEM="
>> "%BAT_COMPRESS%" echo for /f "usebackq delims=" %%%%A in ("%%LIST_FILE%%") do (
>> "%BAT_COMPRESS%" echo     if not defined FIRST_ITEM set "FIRST_ITEM=%%%%A"
>> "%BAT_COMPRESS%" echo     set /a ITEM_COUNT+=1
>> "%BAT_COMPRESS%" echo )
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: 4. ลอจิกป้องกัน Double Folder
>> "%BAT_COMPRESS%" echo if exist "%%FINAL_LIST%%" del "%%FINAL_LIST%%"
>> "%BAT_COMPRESS%" echo if %%ITEM_COUNT%% GTR 1 (
>> "%BAT_COMPRESS%" echo     for /f "usebackq delims=" %%%%A in ("%%LIST_FILE%%") do ^>^>"%%FINAL_LIST%%" echo "%%%%~A"
>> "%BAT_COMPRESS%" echo ) else (
>> "%BAT_COMPRESS%" echo     for /f "usebackq delims=" %%%%A in ("%%LIST_FILE%%") do (
>> "%BAT_COMPRESS%" echo         if exist "%%%%~A\*" (
>> "%BAT_COMPRESS%" echo             ^>^>"%%FINAL_LIST%%" echo "%%%%~A\*"
>> "%BAT_COMPRESS%" echo         ) else (
>> "%BAT_COMPRESS%" echo             ^>^>"%%FINAL_LIST%%" echo "%%%%~A"
>> "%BAT_COMPRESS%" echo         )
>> "%BAT_COMPRESS%" echo     )
>> "%BAT_COMPRESS%" echo )
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: 5. ดึงชื่อไฟล์แรกที่ถูกเลือก มาตั้งเป็นชื่อไฟล์บีบอัด
>> "%BAT_COMPRESS%" echo for %%%%I in (%%FIRST_ITEM%%) do set "ARCHIVE_NAME=%%%%~nI"
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: 6. สั่ง 7-Zip บีบอัดตามฟอร์แมตที่เลือกแท้ๆ
>> "%BAT_COMPRESS%" echo "%%SEVENZ%%" a -t%%FORMAT%% "%%TARGET_DIR%%%%ARCHIVE_NAME%%.%%FORMAT%%" @"%%FINAL_LIST%%" -scsUTF-8 -y
>> "%BAT_COMPRESS%" echo.
>> "%BAT_COMPRESS%" echo :: ล้างไฟล์ขยะ
>> "%BAT_COMPRESS%" echo del "%%LIST_FILE%%" 2^>nul
>> "%BAT_COMPRESS%" echo del "%%FINAL_LIST%%" 2^>nul
>> "%BAT_COMPRESS%" echo rd "%%LOCK_DIR%%" 2^>nul

echo [OK] Adding context menus to Registry...
call :REMOVE_REGISTRY_KEYS

reg add "HKEY_CLASSES_ROOT\*\shell\SmartExtract" /ve /t REG_SZ /d "Smart Extract Here" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\SmartExtract" /v "Icon" /t REG_SZ /d "\"%SEVENZ_FM%\",0" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\SmartExtract\command" /ve /t REG_SZ /d "\"C:\scripts\smart_extract.bat\" \"%%1\"" /f >nul

reg add "HKEY_CLASSES_ROOT\*\shell\SmartCompress" /v "MUIVerb" /t REG_SZ /d "Smart Compress >" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\SmartCompress" /v "Icon" /t REG_SZ /d "\"%SEVENZ_FM%\",0" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\SmartCompress" /v "SubCommands" /t REG_SZ /d "" /f >nul

reg add "HKEY_CLASSES_ROOT\*\shell\SmartCompress\shell\1_7z" /v "MUIVerb" /t REG_SZ /d "*.7z" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\SmartCompress\shell\1_7z\command" /ve /t REG_SZ /d "\"C:\scripts\smart_compress.bat\" \"7z\" \"%%1\"" /f >nul

reg add "HKEY_CLASSES_ROOT\*\shell\SmartCompress\shell\2_zip" /v "MUIVerb" /t REG_SZ /d "*.zip" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\SmartCompress\shell\2_zip\command" /ve /t REG_SZ /d "\"C:\scripts\smart_compress.bat\" \"zip\" \"%%1\"" /f >nul

reg add "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress" /v "MUIVerb" /t REG_SZ /d "Smart Compress >" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress" /v "Icon" /t REG_SZ /d "\"%SEVENZ_FM%\",0" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress" /v "SubCommands" /t REG_SZ /d "" /f >nul

reg add "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress\shell\1_7z" /v "MUIVerb" /t REG_SZ /d "*.7z" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress\shell\1_7z\command" /ve /t REG_SZ /d "\"C:\scripts\smart_compress.bat\" \"7z\" \"%%1\"" /f >nul

reg add "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress\shell\2_zip" /v "MUIVerb" /t REG_SZ /d "*.zip" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress\shell\2_zip\command" /ve /t REG_SZ /d "\"C:\scripts\smart_compress.bat\" \"zip\" \"%%1\"" /f >nul

ie4uinit.exe -show >nul 2>&1

echo --------------------------------------------------
echo DONE! Setup completed successfully.
echo --------------------------------------------------
goto :EOF

:REMOVE_REGISTRY_KEYS
reg delete "HKEY_CLASSES_ROOT\*\shell\SmartExtract" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\*\shell\SmartCompress" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress" /f >nul 2>&1
exit /b
'@

$Uninstall_Smart7z = @'
echo [OK] Removing Menu from Registry...
call :REMOVE_REGISTRY_KEYS

echo [OK] Removing script files...
set "SCRIPT_PATH=C:\scripts"
if exist "%SCRIPT_PATH%\smart_extract.bat" del "%SCRIPT_PATH%\smart_extract.bat" /f /q
if exist "%SCRIPT_PATH%\smart_compress.bat" del "%SCRIPT_PATH%\smart_compress.bat" /f /q
if exist "%SCRIPT_PATH%" rd "%SCRIPT_PATH%" 2>nul

ie4uinit.exe -show >nul 2>&1

echo --------------------------------------------------
echo DONE! Uninstallation completed.
echo --------------------------------------------------
goto :EOF

:REMOVE_REGISTRY_KEYS
reg delete "HKEY_CLASSES_ROOT\*\shell\SmartExtract" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\*\shell\SmartCompress" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress" /f >nul 2>&1
exit /b
'@

$Install_ClearMemory = @'
set "TASK_FOLDER=C:\ProgramData\ClearMemoryTask"
set "PS_FILE=%TASK_FOLDER%\ClearMemory.ps1"
set "VBS_FILE=%TASK_FOLDER%\ClearMemory.vbs"
if not exist "%TASK_FOLDER%" mkdir "%TASK_FOLDER%"

echo [OK] Creating PowerShell script...
> "%PS_FILE%" echo # Measure free RAM before clearing
>> "%PS_FILE%" echo $MemBefore = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
>> "%PS_FILE%" echo.
>> "%PS_FILE%" echo $exe = "C:\Windows\System32\EmptyStandbyList.exe"
>> "%PS_FILE%" echo if (Test-Path $exe) {
>> "%PS_FILE%" echo     Start-Process -FilePath $exe -ArgumentList "workingsets" -Wait -WindowStyle Hidden
>> "%PS_FILE%" echo     Start-Process -FilePath $exe -ArgumentList "standbylist" -Wait -WindowStyle Hidden
>> "%PS_FILE%" echo     Start-Process -FilePath $exe -ArgumentList "modifiedpagelist" -Wait -WindowStyle Hidden
>> "%PS_FILE%" echo }
>> "%PS_FILE%" echo.
>> "%PS_FILE%" echo Start-Sleep -Seconds 1
>> "%PS_FILE%" echo.
>> "%PS_FILE%" echo $MemAfter = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
>> "%PS_FILE%" echo $ClearedKB = $MemAfter - $MemBefore
>> "%PS_FILE%" echo if ($ClearedKB -lt 0) { $ClearedKB = 0 }
>> "%PS_FILE%" echo $ClearedMB = [math]::Round($ClearedKB / 1024, 0)
>> "%PS_FILE%" echo $ClearedGB = [math]::Round($ClearedMB / 1024, 2)
>> "%PS_FILE%" echo.
>> "%PS_FILE%" echo [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] ^| Out-Null
>> "%PS_FILE%" echo [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] ^| Out-Null
>> "%PS_FILE%" echo.
>> "%PS_FILE%" echo $xmlString = @"
>> "%PS_FILE%" echo ^<toast^>^<visual^>^<binding template="ToastGeneric"^>^<text^>Clear Memory Complete!^</text^>^<text^>RAM Freed: $ClearedMB MB ($ClearedGB GB)^</text^>^<text placement="attribution"^>System Memory Optimizer^</text^>^</binding^>^</visual^>^</toast^>
>> "%PS_FILE%" echo "@
>> "%PS_FILE%" echo.
>> "%PS_FILE%" echo $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
>> "%PS_FILE%" echo $toastXml.LoadXml($xmlString)
>> "%PS_FILE%" echo $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml)
>> "%PS_FILE%" echo $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("ClearMemory")
>> "%PS_FILE%" echo $notifier.Show($toast)

echo [OK] Creating VBS wrapper...
echo Set UAC = CreateObject("Shell.Application") ^> "%VBS_FILE%"
echo UAC.ShellExecute "powershell.exe", "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""%PS_FILE%""", "", "runas", 0 ^>^> "%VBS_FILE%"
echo Set UAC = Nothing ^>^> "%VBS_FILE%"

echo [OK] Adding registry entries...
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\ClearMemoryCommand" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shell\ClearMemoryCommand" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Drive\shell\ClearMemoryCommand" /f >nul 2>&1

reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\ClearMemoryCommand" /ve /t REG_SZ /d "Clear Memory (Standby List)" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\ClearMemoryCommand" /v "Icon" /t REG_SZ /d "C:\Windows\System32\cmd.exe" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\ClearMemoryCommand" /v "HasLUAShield" /t REG_SZ /d "" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\ClearMemoryCommand\command" /ve /t REG_SZ /d "wscript.exe ""%VBS_FILE%""" /f >nul

reg add "HKEY_CLASSES_ROOT\Directory\shell\ClearMemoryCommand" /ve /t REG_SZ /d "Clear Memory (Standby List)" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\ClearMemoryCommand" /v "Icon" /t REG_SZ /d "C:\Windows\System32\cmd.exe" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\ClearMemoryCommand" /v "HasLUAShield" /t REG_SZ /d "" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\ClearMemoryCommand\command" /ve /t REG_SZ /d "wscript.exe ""%VBS_FILE%""" /f >nul

reg add "HKEY_CLASSES_ROOT\Drive\shell\ClearMemoryCommand" /ve /t REG_SZ /d "Clear Memory (Standby List)" /f >nul
reg add "HKEY_CLASSES_ROOT\Drive\shell\ClearMemoryCommand" /v "Icon" /t REG_SZ /d "C:\Windows\System32\cmd.exe" /f >nul
reg add "HKEY_CLASSES_ROOT\Drive\shell\ClearMemoryCommand" /v "HasLUAShield" /t REG_SZ /d "" /f >nul
reg add "HKEY_CLASSES_ROOT\Drive\shell\ClearMemoryCommand\command" /ve /t REG_SZ /d "wscript.exe ""%VBS_FILE%""" /f >nul

ie4uinit.exe -show >nul 2>&1

echo --------------------------------------------------
echo DONE! Setup completed successfully.
echo --------------------------------------------------
'@

$Uninstall_ClearMemory = @'
echo [OK] Removing registry entries...
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\ClearMemoryCommand" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shell\ClearMemoryCommand" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Drive\shell\ClearMemoryCommand" /f >nul 2>&1

echo [OK] Removing script files...
set "TASK_FOLDER=C:\ProgramData\ClearMemoryTask"
if exist "%TASK_FOLDER%\ClearMemory.ps1" del "%TASK_FOLDER%\ClearMemory.ps1" /f /q
if exist "%TASK_FOLDER%\ClearMemory.vbs" del "%TASK_FOLDER%\ClearMemory.vbs" /f /q
if exist "%TASK_FOLDER%" rd "%TASK_FOLDER%" 2>nul

ie4uinit.exe -show >nul 2>&1

echo --------------------------------------------------
echo DONE! Uninstallation completed.
echo --------------------------------------------------
'@

# =======================================================================
# UNIFIED MAIN MENU
# =======================================================================
$Host.UI.RawUI.WindowTitle = "Unified Context Menu Installer"

while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host "  [ INSTALL ]" -ForegroundColor Green
    Write-Host "     1. Install: Python to EXE"
    Write-Host "     2. Install: Get Gofile Link"
    Write-Host "     3. Install: Smart 7-Zip Extract"
    Write-Host "     4. Install: Clear Memory (Standby List)"
    Write-Host "     5. Install: ALL OF THE ABOVE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ UNINSTALL ]" -ForegroundColor Red
    Write-Host "     6. Uninstall: Python to EXE"
    Write-Host "     7. Uninstall: Get Gofile Link"
    Write-Host "     8. Uninstall: Smart 7-Zip Extract"
    Write-Host "     9. Uninstall: Clear Memory (Standby List)"
    Write-Host "    10. Uninstall: ALL OF THE ABOVE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "     0. Exit"
    Write-Host ""
    
    $choice = Read-Host "  Select an option (0-10)"

    switch ($choice) {
        '1' { Run-BatchPayload $Install_Py2Exe "INSTALLING: Python to EXE"; Pause }
        '2' { Run-BatchPayload $Install_Gofile "INSTALLING: Get Gofile Link"; Pause }
        '3' { Run-BatchPayload $Install_Smart7z "INSTALLING: Smart 7-Zip Extract"; Pause }
        '4' { Run-BatchPayload $Install_ClearMemory "INSTALLING: Clear Memory (Standby List)"; Pause }
        '5' { 
            Run-BatchPayload $Install_Py2Exe "INSTALLING (1/4): Python to EXE"
            Run-BatchPayload $Install_Gofile "INSTALLING (2/4): Get Gofile Link"
            Run-BatchPayload $Install_Smart7z "INSTALLING (3/4): Smart 7-Zip Extract"
            Run-BatchPayload $Install_ClearMemory "INSTALLING (4/4): Clear Memory (Standby List)"
            Pause 
        }
        '6' { Run-BatchPayload $Uninstall_Py2Exe "UNINSTALLING: Python to EXE"; Pause }
        '7' { Run-BatchPayload $Uninstall_Gofile "UNINSTALLING: Get Gofile Link"; Pause }
        '8' { Run-BatchPayload $Uninstall_Smart7z "UNINSTALLING: Smart 7-Zip Extract"; Pause }
        '9' { Run-BatchPayload $Uninstall_ClearMemory "UNINSTALLING: Clear Memory (Standby List)"; Pause }
        '10' { 
            Run-BatchPayload $Uninstall_Py2Exe "UNINSTALLING (1/4): Python to EXE"
            Run-BatchPayload $Uninstall_Gofile "UNINSTALLING (2/4): Get Gofile Link"
            Run-BatchPayload $Uninstall_Smart7z "UNINSTALLING (3/4): Smart 7-Zip Extract"
            Run-BatchPayload $Uninstall_ClearMemory "UNINSTALLING (4/4): Clear Memory (Standby List)"
            Pause 
        }
        '0' { exit }
        default { 
            Write-Host "  Invalid option, please try again." -ForegroundColor Yellow
            Start-Sleep -Seconds 2 
        }
    }
}
