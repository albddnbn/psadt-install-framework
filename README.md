# psadt-install-framework
This 'framework' should be used to 'install' a set of application source files on a system. The word 'install' is in quotes, because this framework is meant for applications that consist of a source file/folder, as opposed to having a traditional .exe/.msi installer.

Powershell modules used in this script:
1. [PSADT](https://psappdeploytoolkit.com/)
2. [PS2exe](https://github.com/MScholtes/PS2EXE)

> [!NOTE]
> Deploy-AppName.ps1 will copy the source files to system, create desktop/start menu shortcuts, and compile an uninstall.exe that is cited in a registry key created for the application in HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\.
> *Please read through directions before using the script - it may have unintended effects otherwise.

## Configuration File (./SupportFiles/config.json):

In the configuration json file, you can set the values listed below. Values are assigned to variables in the Deploy-AppName.ps1 script (it's the Deploy-Application.ps1 script from PSADT):

- acl_info: defines which group to allow to access source files, as well as which permissions the group needs to be assigned.
- application_name: The name of the application. This will be used to create the folder structure and the name of the PSADT script.
- author: Your name, script creator.
- conflicting_processes: Used with the -CloseApps switch at the beginning of PSADT scripts. This should be a comma-separated string of process names that will be force-closed before install/uninstall.
- dependencies: a list of 'dependency objects'. Each object contains these properties:
1. File - the name of the file used to install the dependency. This file should be in the ./AppName/SupportFiles directory.
2. AppName - The DisplayName of the application. The script uses this name to check for dependency before attempting installation.
3. SilentSwitches - if not provided, the script will attempt to use default/common silent switches for installer.

**There is an example listing in config.json, using vcredist_2022.x64.exe as the dependency.**

- friendly_name: Optional nicely formatted name of the application that can be used for Interactive/Non-Interactive PSADT deploymodes.
- shortcuts: a list of objects. Each object will create a shortcut with the following properties:
1. Target - The target of the shortcut.
2. Location - Location of shortcut on system.
3. Icon
4. Description

**By default, the script will create shortcuts in the public desktop and system start menu locations.**

- source_destination: The directory where the source files are located. This is the directory that will be copied to the target system.

**The source_destination is set to C:\ by default. It gets combined with the application_name to create the full destination path for source files.**

- uninstall_key: This script will create a registry entry in HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\ with this key. This is used to identify the application in Microsoft Windows, just like any other, as well as point to the executable that can be used to 'uninstall' this application/source files/shortcuts/etc.
Each object in the uninstall_key list is a property of the application's registry key.
- vendor: application vendor.
- version: The version of the application. This will be used to create the folder structure and the name of the PSADT script.


## Uninstall.exe info
At the end of the installation script, an executable is compiled that does a few things including: removing source files, shortcuts, etc. from the system.
