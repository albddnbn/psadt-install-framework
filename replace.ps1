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

## Change conflicting_processes in config.ps1 file:
Write-host "For example, the applicaion executable for VS Code is code.exe"
$process_name = Read-Host "Enter the application .exe / process name."
if ($process_name -like "*.exe") {
    $process_name = $process_name -replace ".exe", ""
}

Write-Host "Enter names of any other processes that need to be closed before install/uninstall."
do {
    $additional_process = Read-Host "Enter process name. Press Enter to finish."
    if ($additional_process) {
        $conflicting_processes += ",$additional_process"
    }
} until (-not $additional_process)

$conflicting_process_list = "$process_name$conflicting_processes"

$content = Get-Content -Path $filePath

$updatedContent = $content -replace '\(\(\$conflicting_processes\$\)\)', $conflicting_process_list

$updatedContent | Set-Content -Path $filePath

## Set Source file destination
Write-host "Reply of C:\ will cause C:\$input folder to be created. This is where application files will be stored."
$source_folder_dest = Read-Host "Enter source folder destination."

$content = Get-Content -Path $filePath

$updatedContent = $content -replace '\(\(\$source_destination\$\)\)', $source_folder_dest

$updatedContent | Set-Content -Path $filePath

## Create 'Files' directory for application files:
New-Item -Path ".\AppName\Files" -ItemType Directory -Force | Out-Null

## Rename the Deploy-AppName.ps1 file:
Rename-Item -Path ".\AppName\Deploy-AppName.ps1" -NewName "Deploy-$input.ps1" -Force

## Rename the AppName directory:
Rename-Item -Path ".\AppName" -NewName $input -Force



