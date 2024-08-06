# Run function to replace appname variable in config.ps1 file
$config_ps1_file = Get-ChildItem -Path "." -Filter "config.ps1" -Recurse -File -ErrorAction SilentlyContinue
if (-not $config_ps1_file) {
    Write-Host "config.ps1 file not found" -Foregroundcolor Red
    return
}

$filepath = $config_ps1_file.FullName

$input = Read-Host "Enter appname value"

$content = Get-Content -Path $filePath

$updatedContent = $content -replace '\(\(\$appname\$\)\)', $input

$updatedContent | Set-Content -Path $filePath

Write-Host "Replaced (($appname$)) with $input in $filePath"

## Create 'Files' directory for application files:
New-Item -Path ".\AppName\Files" -ItemType Directory -Force | Out-Null

## Rename the Deploy-AppName.ps1 file:
Rename-Item -Path ".\AppName\Deploy-AppName.ps1" -NewName "Deploy-$input.ps1" -Force

## Rename the AppName directory:
Rename-Item -Path ".\AppName" -NewName $input -Force


