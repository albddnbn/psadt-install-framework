## Script will help to configure the PSADT folder for a new application deployment.

## Ensures the configuration file (config.ps1) is available.
$config_ps1_file = Get-ChildItem -Path "." -Filter "config.ps1" -Recurse -File -ErrorAction SilentlyContinue
if (-not $config_ps1_file) {
    Write-Host "config.ps1 file not found" -Foregroundcolor Red
    Read-Host "Press enter to exit.."
    return
}
$filepath = $config_ps1_file.FullName

## Set Application Name, (($appname$)) in config.ps1 file:
$app_name = Read-Host "Enter Application Name value"
$content = Get-Content -Path $filePath
$updatedContent = $content -replace '\(\(\$appname\$\)\)', $app_name
$updatedContent | Set-Content -Path $filePath
Write-Host "Replaced ((`$appname$)) with $app_name in $filePath`n"

## Set conflicting_processes, (($conflicting_processes$)) in config.ps1 file:
## By collecting the main application .exe/process name, then any other processes that will need to be closed.
Write-host "Example: " -Nonewline
Write-Host "Application executable for VS Code is code.exe." -ForegroundColor Yellow
$process_name = Read-Host "Enter the application executable / process name."
if ($process_name -like "*.exe") {
    $process_name = $process_name -replace ".exe", ""
}

Write-Host "`nEnter names of any other processes that need to be closed before install/uninstall." -ForegroundColor Yellow
do {
    $additional_process = Read-Host "Enter process name. Press Enter to finish."
    if ($additional_process) {
        $conflicting_processes += ",$additional_process"
    }
} until (-not $additional_process)

## Combine main app executable with rest of conflicting processes list.
$conflicting_process_list = "$process_name$conflicting_processes"

$content = Get-Content -Path $filePath
$updatedContent = $content -replace '\(\(\$conflicting_processes\$\)\)', $conflicting_process_list
$updatedContent | Set-Content -Path $filePath
Write-Host "Replaced ((`$conflicting_processes$)) with $conflicting_process_list in $filePath`n"


## Set Source file destination
Write-host "Reply of C:\ will cause C:\$app_name folder to be created. This is where application files will be stored."
$source_folder_dest = Read-Host "Enter source folder destination."
## Make sure user didn't include app_name folder at end of source_destination
if ($($source_folder_dest | split-path -leaf) -eq "$app_name") {
    $source_folder_dest = $source_folder_dest | split-path -parent
}
$content = Get-Content -Path $filePath
$updatedContent = $content -replace '\(\(\$source_destination\$\)\)', $source_folder_dest
$updatedContent | Set-Content -Path $filePath
Write-Host "Replaced ((`$source_destination$)) with $source_folder_dest in $filePath`n"


## Create 'Files' directory for application files:
New-Item -Path ".\AppName\Files" -ItemType Directory -Force | Out-Null

## Rename the Deploy-AppName.ps1 file:
Rename-Item -Path ".\AppName\Deploy-AppName.ps1" -NewName "Deploy-$input.ps1" -Force

## Rename the AppName directory:
Rename-Item -Path ".\AppName" -NewName $input -Force



