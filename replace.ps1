<#
.SYNOPSIS
    Script to configure the file/directory structure for application deployment using PSADT.

.DESCRIPTION
    This script prompts the user for a few values:
    1. Application Name - replaces the AppName folder and AppName in Deploy-AppName.ps1.
                          Application Name is also used as a variable throughout the deployment script.
                          Used to create the name of the destination folder for source files on target system.
    2. Application Process - the main application process / executable that is closed down before the installation or
                             uninstall occurs.
    3. Additional Processes - any other processes that need to be closed before the installation or uninstall occurs.
                          Processes are added in a comma-separated list / closed down at beginning of Deploy-AppName.ps1.
    4. Source Folder Destination - the destination folder for the source files, combined with Application Name to create
                          the complete source file destination.

.EXAMPLE
    Powershell.exe -ExecutionPolicy Bypass .\replace.ps1

.NOTES
    File Name  : replace.ps1
    Author     : Alex B.
    Created    : 2024-08-15
    Version    : 1.0
    Description: Configures most/all values for PSADT script.

#>

## Ensures the configuration file (config.ps1) is available.
$config_ps1_file = Get-ChildItem -Path "." -Filter "config.ps1" -Recurse -File -ErrorAction SilentlyContinue
if (-not $config_ps1_file) {
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] :: " -NoNewline
    Write-Host "Error: " -NoNewLine -Foregroundcolor Red
    Write-Host "config.ps1 file not found"
    Read-Host "Press enter to exit.."
    return
}
$filepath = $config_ps1_file.FullName

## Application Name, $APPLICATION_NAME, (($appname$))
$app_name = Read-Host "Enter Application Name value"
$content = Get-Content -Path $filePath
$updatedContent = $content -replace '\(\(\$appname\$\)\)', $app_name
$updatedContent | Set-Content -Path $filePath
Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] :: Replaced ((`$appname$)) with $app_name in $filePath`n"

## Application Process, part of $conflicting_processes
Write-host "Example: " -Nonewline
Write-Host "Application executable for VS Code is code.exe." -ForegroundColor Yellow
$process_name = Read-Host "Enter the application executable / process name."
if ($process_name -like "*.exe") {
    $process_name = $process_name -replace ".exe", ""
}

## Continue to prompt for any more conflicting processes, until the user submits blank line
Write-Host "`nEnter names of any other processes that need to be closed before install/uninstall." -ForegroundColor Yellow
do {
    $additional_process = Read-Host "Enter process name. Press Enter to finish."
    if ($additional_process) {
        $conflicting_processes += ",$additional_process"
    }
} until (-not $additional_process)

## Combine main app executable with rest of conflicting processes list.
$conflicting_process_list = "$process_name$conflicting_processes"

## Target config.ps1 and replace the (($conflicting_processes$)) string with the comma-separated list that was just
## submitted.
$content = Get-Content -Path $filePath
$updatedContent = $content -replace '\(\(\$conflicting_processes\$\)\)', $conflicting_process_list
$updatedContent | Set-Content -Path $filePath
Write-Host "Replaced ((`$conflicting_processes$)) with $conflicting_process_list in $filePath`n"

## This sets the target of the shortcuts that are created (they all need to target the same executable)
## System install shortcut targets are explicitly set.
## User install shortcut targets are set using the $env:USERNAME variable
$content = Get-Content -Path $filePath
$updatedContent = $content -replace '\(\(\$app_exe\$\)\)', $process_name
$updatedContent | Set-Content -Path $filePath
Write-Host "Replaced ((`$app_exe$)) with $process_name in $filePath`n"

## $source_destination --> Remove the Application Name from the end if submitted that way**
Write-host "Reply of C:\ will cause C:\$app_name folder to be created. This is where application files will be stored."
$source_folder_dest = Read-Host "Enter source folder destination."
## **Make sure user didn't include app_name folder at end of source_destination
if ($($source_folder_dest | split-path -leaf) -eq "$app_name") {
    $source_folder_dest = $source_folder_dest | split-path -parent
}
$content = Get-Content -Path $filePath
$updatedContent = $content -replace '\(\(\$source_destination\$\)\)', $source_folder_dest
$updatedContent | Set-Content -Path $filePath
Write-Host "Replaced ((`$source_destination$)) with $source_folder_dest in $filePath`n"

## USER/SYSTEM INSTALL?
## USER INSTALL: copies source files to source_destination, also copies them to existing user's home drives.
##               Creates shortcuts for each user in start menu/desktop targeting their personal executable.
## SYSTEM INSTALL: copies source files to single source_destination, creates shortcuts in start menu and public desktop
##               available to all users, targeting the same executable.
Write-Host "Would you like this to be a user install?" -Foregroundcolor Yellow
Write-Host "A user install will still copy source files to source_destination, but will also copy files to user's home `
             drives and create desktop/start menu shortcuts pointing to the user's copy of the executable."
Write-Host "A " -NoNewline
Write-Host "SCHEDULED TASK " -Foregroundcolor yellow -NoNewline
Write-Host "will be created to perform the copy / shortcut creation operations for future users logged in to the system."
do {
    $user_install_directive = Read-Host "Enter user install directive (y/n)"
} until ($user_install_directive.tolower() -in "y", "n")

if ($user_install_directive.tolower() -eq "y") {
    $content = Get-Content -Path $filePath
    $updatedContent = $content -replace '\(\(\$user_install_directive\$\)\)', "yes"
    $updatedContent | Set-Content -Path $filePath
    Write-Host "Replaced ((`$user_install_directive$)) with 'yes' in $filePath`n"

    ## Set default TargetFolder parameter in user_install.ps1:
    $full_Targetfolder_path = Join-Path "$source_folder_dest" "$app_name"

    $content = Get-Content -Path '.\AppName\user_install.ps1'
    $updatedContent = $content -replace '\(\(\$default_path\$\)\)', $full_Targetfolder_path
    $updatedContent | Set-Content -Path '.\AppName\user_install.ps1'
    Write-Host "Replaced ((`$default_path$)) with $full_Targetfolder_path in .\AppNAme\user_install.ps1`n"
}
else {
    $content = Get-Content -Path $filePath
    $updatedContent = $content -replace '\(\(\$user_install_directive\$\)\)', "no"
    $updatedContent | Set-Content -Path $filePath
    Write-Host "Replaced ((`$user_install_directive$)) with 'no' in $filePath`n"
}

## DIRECTORY STRUCTURE CREATION:

## Create 'Files' directory for application files:
New-Item -Path ".\AppName\Files" -ItemType Directory -Force | Out-Null

## Rename the Deploy-AppName.ps1 file:
Rename-Item -Path ".\AppName\Deploy-AppName.ps1" -NewName "Deploy-$app_name.ps1" -Force

## Rename the AppName directory:
Rename-Item -Path ".\AppName" -NewName $app_name -Force



