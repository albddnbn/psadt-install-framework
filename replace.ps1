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
function Get-InstalledApp {
    # param(
    #     [string]$ApplicationName
    # )
    Write-Host "Script will search registry for any installed applications containing search string."
    $ApplicationName = Read-Host "Enter application name:"
    # Define the registry paths for uninstall information
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    # Loop through each registry path and retrieve the list of subkeys
    foreach ($path in $registryPaths) {
        $uninstallKeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        # Skip if the registry path doesn’t exist
        if (-not $uninstallKeys) {
            continue
        }
        # Loop through each uninstall key and display the properties
        foreach ($key in $uninstallKeys) {
            $keyPath = Join-Path -Path $path -ChildPath $key.PSChildName
            $displayName = (Get-ItemProperty -Path $keyPath -Name "DisplayName" -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*$ApplicationName*") {
                # write-host $keypath
                $uninstallString = (Get-ItemProperty -Path $keyPath -Name "UninstallString" -ErrorAction SilentlyContinue).UninstallString
                # $version = (Get-ItemProperty -Path $keyPath -Name "DisplayVersion" -ErrorAction SilentlyContinue).DisplayVersion
                # $publisher = (Get-ItemProperty -Path $keyPath -Name "Publisher" -ErrorAction SilentlyContinue).Publisher
                # $installLocation = (Get-ItemProperty -Path $keyPath -Name "InstallLocation" -ErrorAction SilentlyContinue).InstallLocation
                # $productcode = (Get-ItemProperty -Path $keyPath -Name "productcode" -ErrorAction SilentlyContinue).productcode
                $installdate = (Get-ItemProperty -Path $keyPath -Name "installdate" -ErrorAction SilentlyContinue).installdate
                $App
                if ($displayName) {
                    Write-Host "DisplayName: $displayName"
                    Write-Host "UninstallString: $uninstallString"
                    # Write-Host "Version: $version"
                    # Write-Host "Publisher: $publisher"
                    # Write-Host "InstallLocation: $installLocation"
                    # write-host "product code: $productcode"
                    write-host "installdate: $installdate"
                    Write-Host "`n"
                }
            }
        }
    }

}


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
    $updatedContent = $content -replace '\(\(\$user_install_directive\$\)\)', "y"
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
    $updatedContent = $content -replace '\(\(\$user_install_directive\$\)\)', "n"
    $updatedContent | Set-Content -Path $filePath
    Write-Host "Replaced ((`$user_install_directive$)) with 'no' in $filePath`n"
}

## Dependencies = $DEPENDENCIES_LIST
$reply = ""
do {
    $reply = Read-Host "Does the $app_name application have any dependencies? (y/n)"
} until ($reply.tolower() -in @("y", "n"))

if ($reply.tolower() -eq 'y') {
    ## get content of config.ps1:
    $content = Get-Content -Path $filePath

    ## each dependency in the config is structured like this:
    #     # [pscustomobject]@{
    #     #     File           = "vcredist_2022.x64.exe"
    #     #     AppName        = "Microsoft Visual C++ 2015-2022 Redistributable (x64)"
    #     #     SilentSwitches = "/quiet /norestart" # Switches for silent installation
    #     # }


    $add_another = "y"

    $dependency_content = "`$DEPENDENCIES_LIST = @("
    while ($add_another.tolower() -eq 'y') {
        Write-Host "You will need to know the dependency's DisplayName and silent install switches."
        $search_reply = Read-Host "Would you like to search the registry for application info? (y/n)"

        if ($search_reply.tolower() -eq 'y') {
            Get-InstalledApp
        }

        Write-Host "Example: File           = 'vcredist_2022.x64.exe'"
        $dependency_file = Read-Host "Enter the dependency file name."
        Write-Host "`n"

        Write-Host "Example: AppName        = 'Microsoft Visual C++ 2015-2022 Redistributable (x64)'"
        $dependency_appname = Read-Host "Enter the dependency application name."
        Write-Host "`n"

        Write-Host "Example: SilentSwitches = '/install /quiet /norestart'"
        $dependency_silent_switches = Read-Host "Enter the silent switches for the dependency installation."
        Write-Host "`n"

        $dependency = @"
        [pscustomobject]@{
            File           = "$dependency_file"
            AppName        = "$dependency_appname"
            SilentSwitches = "$dependency_silent_switches"
        },
"@

        $dependency_content += $dependency
        $add_another = Read-Host "Add another dependency? (y/n)"
    }

    ## if we're done adding dependencies - remove the last comma
    $dependency_content = $dependency_content.Substring(0, $dependency_content.Length - 1)

    ## close up the dependencies list:
    $dependency_content += ")"

    ## add it to config_content:
    $content += "`n$dependency_content"

    $content | Set-Content -Path $filePath
}



## DIRECTORY STRUCTURE CREATION:

## Create 'Files' and application name directory (to hold source files)
New-Item -Path ".\AppName\Files\$app_name" -ItemType Directory -Force | Out-Null

## Rename the Deploy-AppName.ps1 file:
Rename-Item -Path ".\AppName\Deploy-AppName.ps1" -NewName "Deploy-$app_name.ps1" -Force

## Rename the AppName directory:
Rename-Item -Path ".\AppName" -NewName $app_name -Force




