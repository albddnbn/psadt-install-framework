## ----------------------------------------------------------------------------
## Change the name of this file to config.ps1 after items have been filled out!
## ----------------------------------------------------------------------------
$source_destination = "(($source_destination$))" # Source destination of the application
## This file is 'dot-sourced' towards the top of the Deploy-AppName.ps1 script to make the $script_config variable
## available in the deployment script.
$script_config = @{
    acl_info              = @{
        target_group         = "Everyone" ## This group will be granted the permissions below, to the source file directory.
        assigned_permissions = "ReadAndExecute, Write, Modify" # Permissions assigned to the target group
    }
    application_name      = "(($appname$))" ## Name of the application
    ## The name of the application is used to create the full destination path for source files.
    ## It's also used in registry items created, and desktop/start menu shortcuts.

    author                = "" # Author of the script (probably you)
    conflicting_processes = "(($conflicting_processes$))" ## Comma-separated list of processes that will be closed before install/uninstalls
    ## are run. As is, the script would close the 7zip and winRAR processes.

    ## Deploy-AppName.ps1 will loop through all objects in this array and attempt to install each one.
    ## File 's must be located in the SupportFiles directory.
    ## AppName 's are used to test whether dependency is already installed.
    ##  -- If the PSADT module is available - you can check your dependency display names like this:
    ##  -- Get-InstalledApplication -Name "*<insert part of dependency name>*" -Wildcard
    ## SilentSwitches are used to install the dependency silently.
    dependencies          = @(
        # @{
        #     File           = "vcredist_2022.x64.exe"
        #     AppName        = "Microsoft Visual C++ 2015-2022 Redistributable (x64)"
        #     SilentSwitches = "/quiet /norestart" # Switches for silent installation
        # }
        # , @{
        #     File           = "installer file (msi/exe)"
        #     AppName        = "Display Name from registry or Installed Apps"
        #     SilentSwitches = "/quiet /norestart" # Switches for silent installation
        # }
    )
    friendly_name         = "(($appname$))" # Friendly name of the application, used for Interactive/Non-Interactive installs
    shortcuts             = @(
        [pscustomobject]@{
            ShortcutTarget      = "$source_destination/(($appname$))/(($app_exe$)).exe"        ## Desktop / Start menu shortcuts will target this file.
            ShortcutLocation    = "C:/Users/Public/Desktop/(($appname$)).lnk" ## Desktop shortcut location
            # ShortcutIconPath    = ""                                          ## Path to .ico/icon file for the shortcut
            ShortcutDescription = "Open (($appname$)) application."           ## Description of the shortcut
        },
        [pscustomobject]@{
            ShortcutTarget   = "$source_destination/(($appname$))/(($app_exe$)).exe"           ## Desktop / Start menu shortcuts will target this file.
            ShortcutLocation = "C:/ProgramData/Microsoft/Windows/Start Menu/(($appname$)).lnk" # System start menu location
            # ShortcutIconPath    = ""                                          ## Path to .ico/icon file for the shortcut
            ShortcutIconPath = "Open (($appname$)) application."                ## Icon path for the shortcut
        }
    )
    vendor                = "" # Vendor of the application
    version               = "1.0.0" # Version of the application
    
    ## Creates the uninstallation / application listing information for the 'application' in the registry.
    ## The script cycles through these values, creating registry items for each one at:
    ## HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\($appname$)
    uninstall_key         = @(
        [pscustomobject]@{
            Name  = "DisplayName"
            Value = "(($appname$))"
            Type  = "String" # Type of the DisplayName value
        },
        [pscustomobject]@{
            Name  = "InstallDate"
            Value = ""
            Type  = "String" # Type of the InstallDate value
        },
        [pscustomobject]@{
            Name  = "DisplayVersion"
            Value = ""
            Type  = "String" # Type of the DisplayVersion value
        },
        [pscustomobject]@{
            Name  = "Publisher"
            Value = ""            ## Insert publisher name here (not required)
            Type  = "String"
        },
        ## The uninstallstring value should cite the uninstall-appname.exe created.
        ## This value is used as the destination path for the uninstall .exe compiled during post-installation
        ## of the install deploymenttype.
        [pscustomobject]@{
            Name  = "UninstallString"
            Value = "C:/WINDOWS/syswow64/(($appname$))/uninstall-(($appname$)).exe"
            Type  = "String"
        }
    )
}
