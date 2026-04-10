$pythonCheck = Get-Command python -ErrorAction SilentlyContinue

if (-not $pythonCheck) {
    Write-Host "Python is not installed. Preparing to install..." -ForegroundColor Yellow
    
    $psFolder = ".\powershell"
    if (-not (Test-Path $psFolder)) {
        New-Item -ItemType Directory -Path $psFolder | Out-Null
    }

    $downloadUrl = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/python-manager-26.0.msix"
    $installerPath = "$psFolder\python-manager-26.0.msix"
    
    Write-Host "Downloading Python Manager..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    Write-Host "Installing Python silently..." -ForegroundColor Cyan
    Add-AppxPackage -Path $installerPath

    Write-Host "Python installation complete!" -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "Python is already installed. Skipping installation." -ForegroundColor Green
}

Write-Host "Checking/Installing PyInstaller..." -ForegroundColor Cyan
python -m pip install --upgrade pip --quiet
python -m pip install pyinstaller --quiet

Add-Type -AssemblyName System.Windows.Forms

while ($true) {
    Clear-Host
    Write-Host "=== Python to EXE Converter ===" -ForegroundColor Cyan
    
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Python Files (*.py)|*.py"
    $fileDialog.Title = "Select your Python file to convert"
    
    $dummyForm = New-Object System.Windows.Forms.Form
    $dummyForm.TopMost = $true

    $dialogResult = $fileDialog.ShowDialog($dummyForm)
    
    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $fileDialog.FileName
        $parentDir = Split-Path $selectedPath
        $fileName = Split-Path $selectedPath -Leaf
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($selectedPath)

        Write-Host "Selected: $fileName" -ForegroundColor Green
        
        Set-Location $parentDir

        $arguments = "-m PyInstaller --onefile --noconfirm `"$fileName`""
        $process = Start-Process -FilePath "python" -ArgumentList $arguments -WindowStyle Hidden -PassThru

        $progress = 0
        while (-not $process.HasExited) {
            $progress += 2
            if ($progress -ge 99) { $progress = 99 }
            Write-Progress -Activity "Converting $fileName to EXE" -Status "$progress% (Please wait...)" -PercentComplete $progress
            Start-Sleep -Milliseconds 500
        }
        
        Write-Progress -Activity "Converting $fileName to EXE" -Status "100% Complete!" -PercentComplete 100
        Start-Sleep -Seconds 1
        Write-Progress -Activity "Converting $fileName to EXE" -Completed

        $distExePath = Join-Path $parentDir "dist\$baseName.exe"
        $finalExePath = Join-Path $parentDir "$baseName.exe"
        $specFilePath = Join-Path $parentDir "$baseName.spec"
        
        if (Test-Path $distExePath) {
            Move-Item -Path $distExePath -Destination $finalExePath -Force
        }

        if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force }
        if (Test-Path "build") { Remove-Item -Path "build" -Recurse -Force }
        if (Test-Path $specFilePath) { Remove-Item -Path $specFilePath -Force }

        explorer.exe /select, "$finalExePath"

        Write-Host ""
        Write-Host "Success." -ForegroundColor Green
    } else {
        Write-Host "No file selected." -ForegroundColor Yellow
    }

    Write-Host ""
    $response = Read-Host "Press Enter to convert another file (or type 'exit' to quit)"
    if ($response -match "^exit$") {
        break
    }
}
