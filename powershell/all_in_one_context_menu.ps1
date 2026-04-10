if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Run-Silent {
    param([string]$BatCode)
    $tempBat = Join-Path $env:TEMP "Setup_Payload_$([guid]::NewGuid()).bat"
    [System.IO.File]::WriteAllText($tempBat, "@echo off`r`n$BatCode", [System.Text.Encoding]::UTF8)
    $process = Start-Process "cmd.exe" -ArgumentList "/c `"$tempBat`"" -WindowStyle Hidden -Wait -PassThru
    Remove-Item -Path $tempBat -Force -ErrorAction SilentlyContinue
    return $process.ExitCode
}

$Install_Py2Exe = @'
set "SCRIPT_PATH=C:\scripts"
set "PS_FILE=%SCRIPT_PATH%\compile_python.ps1"
set "ICON_FILE=%SCRIPT_PATH%\python.ico"
if not exist "%SCRIPT_PATH%" mkdir "%SCRIPT_PATH%"
if not exist "%ICON_FILE%" (
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/python/cpython/main/PC/icons/python.ico' -OutFile '%ICON_FILE%'" >nul 2>&1
)
> "%PS_FILE%" echo $GatherPath = "$env:TEMP\py_compile_list.txt"
>> "%PS_FILE%" echo $files = $args
>> "%PS_FILE%" echo if ($files) { $files ^| Out-File -Append -FilePath $GatherPath -Encoding UTF8 }
>> "%PS_FILE%" echo $mutex = New-Object System.Threading.Mutex($false, "Py2ExeMutex2")
>> "%PS_FILE%" echo if (!$mutex.WaitOne(0, $false)) { exit }
>> "%PS_FILE%" echo Start-Sleep -Milliseconds 600
>> "%PS_FILE%" echo $files = Get-Content $GatherPath -ErrorAction SilentlyContinue ^| Select-Object -Unique ^| Where-Object { $_ -match '\S' }
>> "%PS_FILE%" echo Remove-Item $GatherPath -ErrorAction SilentlyContinue
>> "%PS_FILE%" echo if (-not $files) { $mutex.ReleaseMutex(); exit }
>> "%PS_FILE%" echo Add-Type -AssemblyName System.Windows.Forms
>> "%PS_FILE%" echo Add-Type -AssemblyName System.Drawing
>> "%PS_FILE%" echo $code = 'using System; using System.Runtime.InteropServices; public class Exp_Py2Exe { [DllImport("shell32.dll")] public static extern int SHOpenFolderAndSelectItems(IntPtr p, uint c, IntPtr[] a, uint f); [DllImport("shell32.dll", CharSet = CharSet.Unicode)] public static extern IntPtr ILCreateFromPath(string p); [DllImport("shell32.dll")] public static extern void ILFree(IntPtr p); public static void S(string d, string[] fs) { IntPtr pd = ILCreateFromPath(d); IntPtr[] pfa = new IntPtr[fs.Length]; for(int i=0; i ^< fs.Length; i++) pfa[i] = ILCreateFromPath(fs[i]); SHOpenFolderAndSelectItems(pd, (uint)fs.Length, pfa, 0); ILFree(pd); for(int i=0; i ^< fs.Length; i++) ILFree(pfa[i]); } }'
>> "%PS_FILE%" echo if (-not ([System.Management.Automation.PSTypeName]'Exp_Py2Exe').Type) { Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue }
>> "%PS_FILE%" echo function Check-Python {
>> "%PS_FILE%" echo     $py = Get-Command py -ErrorAction SilentlyContinue
>> "%PS_FILE%" echo     if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
>> "%PS_FILE%" echo     return $py
>> "%PS_FILE%" echo }
>> "%PS_FILE%" echo $pyCmd = Check-Python
>> "%PS_FILE%" echo if (-not $pyCmd) {
>> "%PS_FILE%" echo     $msixUrl = "https://github.com/phwyverysad/-/releases/download/%%E0%%B8%%88%%E0%%B8%%B9%%E0%%B8%%99%%E0%%B8%%84%%E0%%B8%%AD%%E0%%B8%%A1/python-manager-26.0.msix"
>> "%PS_FILE%" echo     $msixPath = "$env:TEMP\python-manager-26.0.msix"
>> "%PS_FILE%" echo     [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
>> "%PS_FILE%" echo     Invoke-WebRequest -Uri $msixUrl -OutFile $msixPath -UseBasicParsing
>> "%PS_FILE%" echo     Add-AppxPackage -Path $msixPath -ErrorAction SilentlyContinue
>> "%PS_FILE%" echo     Remove-Item $msixPath -Force -ErrorAction SilentlyContinue
>> "%PS_FILE%" echo     $pyCmd = Check-Python
>> "%PS_FILE%" echo     if (-not $pyCmd) { $mutex.ReleaseMutex(); exit 1 }
>> "%PS_FILE%" echo }
>> "%PS_FILE%" echo $pyExe = $pyCmd.Source
>> "%PS_FILE%" echo $installed = ^& $pyExe -m pip show pyinstaller 2^>$null
>> "%PS_FILE%" echo if (-not $installed) { ^& $pyExe -m pip install pyinstaller --quiet }
>> "%PS_FILE%" echo $form = New-Object System.Windows.Forms.Form
>> "%PS_FILE%" echo $form.Text = "py to exe"
>> "%PS_FILE%" echo $form.Size = New-Object System.Drawing.Size(650, 450)
>> "%PS_FILE%" echo $form.StartPosition = "CenterScreen"
>> "%PS_FILE%" echo $form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
>> "%PS_FILE%" echo $form.ForeColor = [System.Drawing.Color]::White
>> "%PS_FILE%" echo $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
>> "%PS_FILE%" echo $form.FormBorderStyle = "FixedDialog"
>> "%PS_FILE%" echo $form.MaximizeBox = $false
>> "%PS_FILE%" echo $panel = New-Object System.Windows.Forms.Panel
>> "%PS_FILE%" echo $panel.Size = New-Object System.Drawing.Size(610, 320)
>> "%PS_FILE%" echo $panel.Location = New-Object System.Drawing.Point(10, 10)
>> "%PS_FILE%" echo $panel.AutoScroll = $true
>> "%PS_FILE%" echo $form.Controls.Add($panel)
>> "%PS_FILE%" echo $progressBars = @()
>> "%PS_FILE%" echo $labelPairs = @()
>> "%PS_FILE%" echo $yPos = 10
>> "%PS_FILE%" echo foreach ($f in $files) {
>> "%PS_FILE%" echo     if (-not (Test-Path $f)) { continue }
>> "%PS_FILE%" echo     $fn = [System.IO.Path]::GetFileName($f)
>> "%PS_FILE%" echo     $fd = [System.IO.Path]::GetDirectoryName($f)
>> "%PS_FILE%" echo     $fsz = [math]::Round((Get-Item $f).Length / 1MB, 2)
>> "%PS_FILE%" echo     if ($fsz -eq 0) { $fsz = [math]::Round((Get-Item $f).Length / 1KB, 2); $fszStr = "$fsz KB" } else { $fszStr = "$fsz MB" }
>> "%PS_FILE%" echo     $lblName = New-Object System.Windows.Forms.Label
>> "%PS_FILE%" echo     $lblName.Text = "[$fd] $fn ($fszStr)"
>> "%PS_FILE%" echo     $lblName.Location = New-Object System.Drawing.Point(0, $yPos)
>> "%PS_FILE%" echo     $lblName.Size = New-Object System.Drawing.Size(590, 20)
>> "%PS_FILE%" echo     $panel.Controls.Add($lblName)
>> "%PS_FILE%" echo     $yPos += 22
>> "%PS_FILE%" echo     $pb = New-Object System.Windows.Forms.ProgressBar
>> "%PS_FILE%" echo     $pb.Location = New-Object System.Drawing.Point(0, $yPos)
>> "%PS_FILE%" echo     $pb.Size = New-Object System.Drawing.Size(500, 18)
>> "%PS_FILE%" echo     $pb.Style = "Continuous"
>> "%PS_FILE%" echo     $panel.Controls.Add($pb)
>> "%PS_FILE%" echo     $lblPct = New-Object System.Windows.Forms.Label
>> "%PS_FILE%" echo     $lblPct.Text = "0%%"
>> "%PS_FILE%" echo     $lblPct.Location = New-Object System.Drawing.Point(510, $yPos)
>> "%PS_FILE%" echo     $lblPct.Size = New-Object System.Drawing.Size(60, 18)
>> "%PS_FILE%" echo     $lblPct.ForeColor = [System.Drawing.Color]::LightGreen
>> "%PS_FILE%" echo     $panel.Controls.Add($lblPct)
>> "%PS_FILE%" echo     $progressBars += $pb
>> "%PS_FILE%" echo     $labelPairs += $lblPct
>> "%PS_FILE%" echo     $yPos += 30
>> "%PS_FILE%" echo }
>> "%PS_FILE%" echo $lblStatus = New-Object System.Windows.Forms.Label
>> "%PS_FILE%" echo $lblStatus.Text = "Ready"
>> "%PS_FILE%" echo $lblStatus.Location = New-Object System.Drawing.Point(10, 340)
>> "%PS_FILE%" echo $lblStatus.Size = New-Object System.Drawing.Size(600, 22)
>> "%PS_FILE%" echo $lblStatus.ForeColor = [System.Drawing.Color]::Cyan
>> "%PS_FILE%" echo $form.Controls.Add($lblStatus)
>> "%PS_FILE%" echo $btnRun = New-Object System.Windows.Forms.Button
>> "%PS_FILE%" echo $btnRun.Text = "Convert"
>> "%PS_FILE%" echo $btnRun.Location = New-Object System.Drawing.Point(10, 365)
>> "%PS_FILE%" echo $btnRun.Size = New-Object System.Drawing.Size(120, 32)
>> "%PS_FILE%" echo $btnRun.BackColor = [System.Drawing.Color]::FromArgb(40, 167, 69)
>> "%PS_FILE%" echo $btnRun.FlatStyle = "Flat"
>> "%PS_FILE%" echo $form.Controls.Add($btnRun)
>> "%PS_FILE%" echo $btnRun.Add_Click({
>> "%PS_FILE%" echo     $btnRun.Enabled = $false
>> "%PS_FILE%" echo     $convertedExes = @()
>> "%PS_FILE%" echo     if ($progressBars.Count -eq 0) { $form.Close(); return }
>> "%PS_FILE%" echo     for ($i = 0; $i -lt $progressBars.Count; $i++) {
>> "%PS_FILE%" echo         $f = $files[$i]
>> "%PS_FILE%" echo         $fn = [System.IO.Path]::GetFileNameWithoutExtension($f)
>> "%PS_FILE%" echo         $fd = [System.IO.Path]::GetDirectoryName($f)
>> "%PS_FILE%" echo         $lblStatus.Text = "Compiling: $fn.py"
>> "%PS_FILE%" echo         $progressBars[$i].Value = 10
>> "%PS_FILE%" echo         $labelPairs[$i].Text = "10%%"
>> "%PS_FILE%" echo         $form.Refresh()
>> "%PS_FILE%" echo         $proc = Start-Process $pyExe -ArgumentList "-m PyInstaller --onefile --noconfirm --clean --distpath `"$fd`" --workpath `"$env:TEMP\PyInstallerWork`" --specpath `"$env:TEMP\PyInstallerWork`" `"$f`"" -WorkingDirectory $fd -WindowStyle Hidden -PassThru
>> "%PS_FILE%" echo         $pct = 10
>> "%PS_FILE%" echo         while (-not $proc.HasExited) {
>> "%PS_FILE%" echo             Start-Sleep -Milliseconds 300
>> "%PS_FILE%" echo             [System.Windows.Forms.Application]::DoEvents()
>> "%PS_FILE%" echo             if ($pct -lt 95) { $pct += 2 }
>> "%PS_FILE%" echo             $progressBars[$i].Value = $pct
>> "%PS_FILE%" echo             $labelPairs[$i].Text = "$pct%%"
>> "%PS_FILE%" echo         }
>> "%PS_FILE%" echo         $exePath = Join-Path $fd "$fn.exe"
>> "%PS_FILE%" echo         $progressBars[$i].Value = 100
>> "%PS_FILE%" echo         $labelPairs[$i].Text = "100%%"
>> "%PS_FILE%" echo         $form.Refresh()
>> "%PS_FILE%" echo         if (Test-Path $exePath) {
>> "%PS_FILE%" echo             $convertedExes += $exePath
>> "%PS_FILE%" echo         }
>> "%PS_FILE%" echo     }
>> "%PS_FILE%" echo     $lblStatus.Text = "Done! Opening folder..."
>> "%PS_FILE%" echo     $form.Refresh()
>> "%PS_FILE%" echo     Start-Sleep -Milliseconds 500
>> "%PS_FILE%" echo     if ($convertedExes.Count -gt 0) {
>> "%PS_FILE%" echo         $grouped = $convertedExes ^| Group-Object { [System.IO.Path]::GetDirectoryName($_) }
>> "%PS_FILE%" echo         foreach ($g in $grouped) {
>> "%PS_FILE%" echo             $exes = [string[]]$g.Group
>> "%PS_FILE%" echo             [Exp_Py2Exe]::S($g.Name, $exes)
>> "%PS_FILE%" echo         }
>> "%PS_FILE%" echo     }
>> "%PS_FILE%" echo     $form.Close()
>> "%PS_FILE%" echo })
>> "%PS_FILE%" echo $form.ShowDialog() ^| Out-Null
>> "%PS_FILE%" echo $mutex.ReleaseMutex()

reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /ve /t REG_SZ /d "py to exe" /f >nul
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /v "MultiSelectModel" /t REG_SZ /d "Player" /f >nul
if exist "%ICON_FILE%" ( reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /v "Icon" /t REG_SZ /d "\"%ICON_FILE%\"" /f >nul ) else ( reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /v "Icon" /t REG_SZ /d "cmd.exe" /f >nul )
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy\command" /ve /t REG_SZ /d "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File \"C:\scripts\compile_python.ps1\" \"%%1\"" /f >nul
ie4uinit.exe -show >nul 2>&1
'@

$Uninstall_Py2Exe = @'
reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy" /f >nul 2>&1
set "SCRIPT_PATH=C:\scripts"
set "PS_FILE=%SCRIPT_PATH%\compile_python.ps1"
set "ICON_FILE=%SCRIPT_PATH%\python.ico"
if exist "%PS_FILE%" del "%PS_FILE%" /f /q
if exist "%ICON_FILE%" del "%ICON_FILE%" /f /q
if exist "%SCRIPT_PATH%" rd "%SCRIPT_PATH%" 2>nul
ie4uinit.exe -show >nul 2>&1
'@

$Install_Gofile = @'
set "SCRIPT_PATH=C:\GofileScript"
set "PS_FILE=%SCRIPT_PATH%\upload_to_gofile.ps1"
if not exist "%SCRIPT_PATH%" mkdir "%SCRIPT_PATH%"

> "%PS_FILE%" echo $filePath = $args[0]
>> "%PS_FILE%" echo if (-not $filePath) { exit }
>> "%PS_FILE%" echo $Host.UI.RawUI.WindowTitle = "Gofile Upload"
>> "%PS_FILE%" echo try {
>> "%PS_FILE%" echo     Write-Host "Connecting to Gofile..." -ForegroundColor Cyan
>> "%PS_FILE%" echo     $serverInfo = Invoke-RestMethod -Uri "https://api.gofile.io/servers"
>> "%PS_FILE%" echo     $server = $serverInfo.data.servers[0].name
>> "%PS_FILE%" echo     Write-Host "Uploading..." -ForegroundColor Yellow
>> "%PS_FILE%" echo     $uploadResponse = curl.exe -s -F "file=@$filePath" "https://$server.gofile.io/contents/uploadfile"
>> "%PS_FILE%" echo     $response = $uploadResponse ^| ConvertFrom-Json
>> "%PS_FILE%" echo     if ($response.status -eq "ok") {
>> "%PS_FILE%" echo         $link = $response.data.downloadPage
>> "%PS_FILE%" echo         $link ^| Set-Clipboard
>> "%PS_FILE%" echo         Write-Host ""
>> "%PS_FILE%" echo         Write-Host "successfully" -ForegroundColor Green
>> "%PS_FILE%" echo         Write-Host "Copied successfully: $link" -ForegroundColor Green
>> "%PS_FILE%" echo         Write-Host ""
>> "%PS_FILE%" echo     } else {
>> "%PS_FILE%" echo         Write-Host "Upload Failed!" -ForegroundColor Red
>> "%PS_FILE%" echo     }
>> "%PS_FILE%" echo } catch {
>> "%PS_FILE%" echo     Write-Host "Error: $_" -ForegroundColor Red
>> "%PS_FILE%" echo }
>> "%PS_FILE%" echo Write-Host "Press any key to exit..." -ForegroundColor Gray
>> "%PS_FILE%" echo $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

reg delete "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /ve /t REG_SZ /d "Get Gofile Link" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /v "Icon" /t REG_SZ /d "imageres.dll,-1024" /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\GofileUpload\command" /ve /t REG_SZ /d "powershell.exe -ExecutionPolicy Bypass -File \"%PS_FILE%\" \"%%1\"" /f >nul
'@

$Uninstall_Gofile = @'
set "SCRIPT_PATH=C:\GofileScript"
reg delete "HKEY_CLASSES_ROOT\*\shell\GofileUpload" /f >nul 2>&1
if exist "%SCRIPT_PATH%" rd /s /q "%SCRIPT_PATH%"
'@

$Install_Smart7z = @'
set "SEVENZ_PATH=C:\Program Files\7-Zip\7z.exe"
set "SEVENZ_FM=C:\Program Files\7-Zip\7zFM.exe"
if exist "%SEVENZ_PATH%" goto :ALREADY_INSTALLED
powershell -Command "Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z2409-x64.exe' -OutFile '%TEMP%\7z_setup.exe'" >nul 2>&1
if not exist "%TEMP%\7z_setup.exe" goto :EOF
"%TEMP%\7z_setup.exe" /S
del "%TEMP%\7z_setup.exe" /f /q

:ALREADY_INSTALLED
set "SCRIPT_PATH=C:\scripts"
set "BAT_EXTRACT=%SCRIPT_PATH%\smart_extract.bat"
set "BAT_COMPRESS=%SCRIPT_PATH%\smart_compress.bat"
set "PS_PWDEXTRACT=%SCRIPT_PATH%\smart_extract_pwd.ps1"

if not exist "%SCRIPT_PATH%" mkdir "%SCRIPT_PATH%"

> "%BAT_EXTRACT%" echo @echo off
>> "%BAT_EXTRACT%" echo chcp 65001 ^>nul
>> "%BAT_EXTRACT%" echo set "SEVENZ=C:\Program Files\7-Zip\7z.exe"
>> "%BAT_EXTRACT%" echo if not exist "%%SEVENZ%%" exit /b
>> "%BAT_EXTRACT%" echo set "FILE=%%~1"
>> "%BAT_EXTRACT%" echo set "FOLDER=%%~dpn1"
>> "%BAT_EXTRACT%" echo "%%SEVENZ%%" x -y -p"DUMMYTEST123" -mx=0 "%%FILE%%" -o"%%FOLDER%%" ^>nul 2^>^&1
>> "%BAT_EXTRACT%" echo if not errorlevel 1 exit /b
>> "%BAT_EXTRACT%" echo powershell -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File "C:\scripts\smart_extract_pwd.ps1" "%%FILE%%"

> "%PS_PWDEXTRACT%" echo param([string]$archivePath)
>> "%PS_PWDEXTRACT%" echo Add-Type -AssemblyName System.Windows.Forms
>> "%PS_PWDEXTRACT%" echo Add-Type -AssemblyName System.Drawing
>> "%PS_PWDEXTRACT%" echo $sevenz = "C:\Program Files\7-Zip\7z.exe"
>> "%PS_PWDEXTRACT%" echo $fi = Get-Item $archivePath
>> "%PS_PWDEXTRACT%" echo $fileName = $fi.Name
>> "%PS_PWDEXTRACT%" echo $fileSize = [math]::Round($fi.Length / 1MB, 2)
>> "%PS_PWDEXTRACT%" echo $folderOut = [System.IO.Path]::Combine($fi.DirectoryName, $fi.BaseName)
>> "%PS_PWDEXTRACT%" echo $form = New-Object System.Windows.Forms.Form
>> "%PS_PWDEXTRACT%" echo $form.Text = "Extract"
>> "%PS_PWDEXTRACT%" echo $form.Size = New-Object System.Drawing.Size(420, 180)
>> "%PS_PWDEXTRACT%" echo $form.StartPosition = "CenterScreen"
>> "%PS_PWDEXTRACT%" echo $form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
>> "%PS_PWDEXTRACT%" echo $form.ForeColor = [System.Drawing.Color]::White
>> "%PS_PWDEXTRACT%" echo $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
>> "%PS_PWDEXTRACT%" echo $form.FormBorderStyle = "FixedDialog"
>> "%PS_PWDEXTRACT%" echo $form.MaximizeBox = $false
>> "%PS_PWDEXTRACT%" echo $lblFile = New-Object System.Windows.Forms.Label
>> "%PS_PWDEXTRACT%" echo $lblFile.Text = "$fileName ($fileSize MB)"
>> "%PS_PWDEXTRACT%" echo $lblFile.Location = New-Object System.Drawing.Point(20, 15)
>> "%PS_PWDEXTRACT%" echo $lblFile.Size = New-Object System.Drawing.Size(370, 22)
>> "%PS_PWDEXTRACT%" echo $lblFile.ForeColor = [System.Drawing.Color]::Cyan
>> "%PS_PWDEXTRACT%" echo $form.Controls.Add($lblFile)
>> "%PS_PWDEXTRACT%" echo $lblPwd = New-Object System.Windows.Forms.Label
>> "%PS_PWDEXTRACT%" echo $lblPwd.Text = "Password:"
>> "%PS_PWDEXTRACT%" echo $lblPwd.Location = New-Object System.Drawing.Point(20, 50)
>> "%PS_PWDEXTRACT%" echo $lblPwd.Size = New-Object System.Drawing.Size(80, 22)
>> "%PS_PWDEXTRACT%" echo $form.Controls.Add($lblPwd)
>> "%PS_PWDEXTRACT%" echo $txtPwd = New-Object System.Windows.Forms.TextBox
>> "%PS_PWDEXTRACT%" echo $txtPwd.Location = New-Object System.Drawing.Point(105, 48)
>> "%PS_PWDEXTRACT%" echo $txtPwd.Size = New-Object System.Drawing.Size(285, 22)
>> "%PS_PWDEXTRACT%" echo $txtPwd.UseSystemPasswordChar = $false
>> "%PS_PWDEXTRACT%" echo $txtPwd.PasswordChar = [char]0
>> "%PS_PWDEXTRACT%" echo $txtPwd.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
>> "%PS_PWDEXTRACT%" echo $txtPwd.ForeColor = [System.Drawing.Color]::White
>> "%PS_PWDEXTRACT%" echo $form.Controls.Add($txtPwd)
>> "%PS_PWDEXTRACT%" echo $lblErr = New-Object System.Windows.Forms.Label
>> "%PS_PWDEXTRACT%" echo $lblErr.Text = ""
>> "%PS_PWDEXTRACT%" echo $lblErr.Location = New-Object System.Drawing.Point(105, 75)
>> "%PS_PWDEXTRACT%" echo $lblErr.Size = New-Object System.Drawing.Size(285, 20)
>> "%PS_PWDEXTRACT%" echo $lblErr.ForeColor = [System.Drawing.Color]::Red
>> "%PS_PWDEXTRACT%" echo $form.Controls.Add($lblErr)
>> "%PS_PWDEXTRACT%" echo $btnOk = New-Object System.Windows.Forms.Button
>> "%PS_PWDEXTRACT%" echo $btnOk.Text = "Extract"
>> "%PS_PWDEXTRACT%" echo $btnOk.Location = New-Object System.Drawing.Point(105, 100)
>> "%PS_PWDEXTRACT%" echo $btnOk.Size = New-Object System.Drawing.Size(120, 32)
>> "%PS_PWDEXTRACT%" echo $btnOk.BackColor = [System.Drawing.Color]::FromArgb(40, 167, 69)
>> "%PS_PWDEXTRACT%" echo $btnOk.ForeColor = [System.Drawing.Color]::White
>> "%PS_PWDEXTRACT%" echo $btnOk.FlatStyle = "Flat"
>> "%PS_PWDEXTRACT%" echo $form.AcceptButton = $btnOk
>> "%PS_PWDEXTRACT%" echo $form.Controls.Add($btnOk)
>> "%PS_PWDEXTRACT%" echo $btnOk.Add_Click({
>> "%PS_PWDEXTRACT%" echo     $pwd = $txtPwd.Text
>> "%PS_PWDEXTRACT%" echo     $btnOk.Enabled = $false
>> "%PS_PWDEXTRACT%" echo     $txtPwd.Enabled = $false
>> "%PS_PWDEXTRACT%" echo     $lblErr.Text = "Extracting..."
>> "%PS_PWDEXTRACT%" echo     $lblErr.ForeColor = [System.Drawing.Color]::Yellow
>> "%PS_PWDEXTRACT%" echo     $form.Refresh()
>> "%PS_PWDEXTRACT%" echo     $p = Start-Process $sevenz -ArgumentList "x `"$archivePath`" -o`"$folderOut`" -p`"$pwd`" -y -mx=0" -WindowStyle Hidden -Wait -PassThru
>> "%PS_PWDEXTRACT%" echo     if ($p.ExitCode -eq 0) {
>> "%PS_PWDEXTRACT%" echo         $form.Close()
>> "%PS_PWDEXTRACT%" echo     } else {
>> "%PS_PWDEXTRACT%" echo         $btnOk.Enabled = $true
>> "%PS_PWDEXTRACT%" echo         $txtPwd.Enabled = $true
>> "%PS_PWDEXTRACT%" echo         $lblErr.Text = "Wrong password. Please try again."
>> "%PS_PWDEXTRACT%" echo         $lblErr.ForeColor = [System.Drawing.Color]::Red
>> "%PS_PWDEXTRACT%" echo         $txtPwd.Clear()
>> "%PS_PWDEXTRACT%" echo         $txtPwd.Focus()
>> "%PS_PWDEXTRACT%" echo     }
>> "%PS_PWDEXTRACT%" echo })
>> "%PS_PWDEXTRACT%" echo $txtPwd.Focus()
>> "%PS_PWDEXTRACT%" echo $form.ShowDialog() ^| Out-Null

> "%BAT_COMPRESS%" echo @echo off
>> "%BAT_COMPRESS%" echo chcp 65001 ^>nul
>> "%BAT_COMPRESS%" echo set "FORMAT=%%~1"
>> "%BAT_COMPRESS%" echo set "TARGET=%%~2"
>> "%BAT_COMPRESS%" echo set "TARGET_DIR=%%~dp2"
>> "%BAT_COMPRESS%" echo set "SEVENZ=C:\Program Files\7-Zip\7z.exe"
>> "%BAT_COMPRESS%" echo set "SAFE_DIR=%%TARGET_DIR:\=_%%"
>> "%BAT_COMPRESS%" echo set "SAFE_DIR=%%SAFE_DIR::=_%%"
>> "%BAT_COMPRESS%" echo set "SAFE_DIR=%%SAFE_DIR: =_%%"
>> "%BAT_COMPRESS%" echo set "LIST_FILE=%%TEMP%%\7z_list_%%SAFE_DIR%%%%FORMAT%%.txt"
>> "%BAT_COMPRESS%" echo set "FINAL_LIST=%%TEMP%%\7z_final_%%SAFE_DIR%%%%FORMAT%%.txt"
>> "%BAT_COMPRESS%" echo set "LOCK_DIR=%%TEMP%%\7z_lock_%%SAFE_DIR%%%%FORMAT%%"
>> "%BAT_COMPRESS%" echo echo "%%~2"^>^>"%%LIST_FILE%%"
>> "%BAT_COMPRESS%" echo md "%%LOCK_DIR%%" 2^>nul
>> "%BAT_COMPRESS%" echo if errorlevel 1 exit /b
>> "%BAT_COMPRESS%" echo ping 127.0.0.1 -n 2 ^>nul
>> "%BAT_COMPRESS%" echo set "ITEM_COUNT=0"
>> "%BAT_COMPRESS%" echo set "FIRST_ITEM="
>> "%BAT_COMPRESS%" echo for /f "usebackq delims=" %%%%A in ("%%LIST_FILE%%") do (
>> "%BAT_COMPRESS%" echo     if not defined FIRST_ITEM set "FIRST_ITEM=%%%%A"
>> "%BAT_COMPRESS%" echo     set /a ITEM_COUNT+=1
>> "%BAT_COMPRESS%" echo )
>> "%BAT_COMPRESS%" echo if exist "%%FINAL_LIST%%" del "%%FINAL_LIST%%"
>> "%BAT_COMPRESS%" echo if %%ITEM_COUNT%% GTR 1 (
>> "%BAT_COMPRESS%" echo     for /f "usebackq delims=" %%%%A in ("%%LIST_FILE%%") do echo "%%%%~A"^>^>"%%FINAL_LIST%%"
>> "%BAT_COMPRESS%" echo ) else (
>> "%BAT_COMPRESS%" echo     for /f "usebackq delims=" %%%%A in ("%%LIST_FILE%%") do (
>> "%BAT_COMPRESS%" echo         if exist "%%%%~A\*" (
>> "%BAT_COMPRESS%" echo             echo "%%%%~A\*"^>^>"%%FINAL_LIST%%"
>> "%BAT_COMPRESS%" echo         ) else (
>> "%BAT_COMPRESS%" echo             echo "%%%%~A"^>^>"%%FINAL_LIST%%"
>> "%BAT_COMPRESS%" echo         )
>> "%BAT_COMPRESS%" echo     )
>> "%BAT_COMPRESS%" echo )
>> "%BAT_COMPRESS%" echo for %%%%I in (%%FIRST_ITEM%%) do set "ARCHIVE_NAME=%%%%~nI"
>> "%BAT_COMPRESS%" echo "%%SEVENZ%%" a -t%%FORMAT%% -mx=1 "%%TARGET_DIR%%%%ARCHIVE_NAME%%.%%FORMAT%%" @"%%FINAL_LIST%%" -scsUTF-8 -y ^>nul 2^>^&1
>> "%BAT_COMPRESS%" echo del "%%LIST_FILE%%" 2^>nul
>> "%BAT_COMPRESS%" echo del "%%FINAL_LIST%%" 2^>nul
>> "%BAT_COMPRESS%" echo rd "%%LOCK_DIR%%" 2^>nul

reg delete "HKEY_CLASSES_ROOT\*\shell\SmartExtract" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\*\shell\SmartCompress" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress" /f >nul 2>&1
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
'@

$Uninstall_Smart7z = @'
reg delete "HKEY_CLASSES_ROOT\*\shell\SmartExtract" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\*\shell\SmartCompress" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Directory\shell\SmartCompress" /f >nul 2>&1
set "SCRIPT_PATH=C:\scripts"
if exist "%SCRIPT_PATH%\smart_extract.bat" del "%SCRIPT_PATH%\smart_extract.bat" /f /q
if exist "%SCRIPT_PATH%\smart_compress.bat" del "%SCRIPT_PATH%\smart_compress.bat" /f /q
if exist "%SCRIPT_PATH%\smart_extract_pwd.ps1" del "%SCRIPT_PATH%\smart_extract_pwd.ps1" /f /q
if exist "%SCRIPT_PATH%" rd "%SCRIPT_PATH%" 2>nul
ie4uinit.exe -show >nul 2>&1
'@

$Host.UI.RawUI.WindowTitle = "Unified Context Menu Installer"

while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host "  [ INSTALL ]" -ForegroundColor Green
    Write-Host "     1. Install: Python to EXE"
    Write-Host "     2. Install: Get Gofile Link"
    Write-Host "     3. Install: Smart 7-Zip Extract"
    Write-Host "     4. Install: ALL OF THE ABOVE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ UNINSTALL ]" -ForegroundColor Red
    Write-Host "     5. Uninstall: Python to EXE"
    Write-Host "     6. Uninstall: Get Gofile Link"
    Write-Host "     7. Uninstall: Smart 7-Zip Extract"
    Write-Host "     8. Uninstall: ALL OF THE ABOVE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "     0. Exit"
    Write-Host ""

    $choice = Read-Host "  Select an option (0-8)"

    switch ($choice) {
        '1' { Run-Silent $Install_Py2Exe | Out-Null }
        '2' { Run-Silent $Install_Gofile | Out-Null }
        '3' { Run-Silent $Install_Smart7z | Out-Null }
        '4' {
            Run-Silent $Install_Py2Exe | Out-Null
            Run-Silent $Install_Gofile | Out-Null
            Run-Silent $Install_Smart7z | Out-Null
        }
        '5' { Run-Silent $Uninstall_Py2Exe | Out-Null }
        '6' { Run-Silent $Uninstall_Gofile | Out-Null }
        '7' { Run-Silent $Uninstall_Smart7z | Out-Null }
        '8' {
            Run-Silent $Uninstall_Py2Exe | Out-Null
            Run-Silent $Uninstall_Gofile | Out-Null
            Run-Silent $Uninstall_Smart7z | Out-Null
        }
        '0' { exit }
    }
}