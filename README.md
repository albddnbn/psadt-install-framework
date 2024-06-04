# psadt-install-framework
A framework to easily create PSADT installation script/package that will 'install' directory of source files to target system, along with creating shortcuts, registry entries, and uninstall .exe.

# Configuration Files:

The main/only configuration file is: ./AppName/SupportFiles/config.json

Inside this file, you can configure the following:

- acl_info: defines which group to allow to access source files, as well as which permissions the group needs to be assigned.
- application_name: The name of the application. This will be used to create the folder structure and the name of the PSADT script.
- author: Your name, script creator.
- conflicting_processes: Used with the -CloseApps switch at the beginning of PSADT scripts. This should be a comma-separated string of process names that will be force-closed before install/uninstall.
- dependencies: a list of 'dependency objects'. Each object contains these properties:
1. File - the name of the file used to install the dependency. This file should be in the ./AppName/SupportFiles directory.
2. AppName - The DisplayName of the application. The script uses this name to check for dependency before attempting installation.
3. SilentSwitches - if not provided, the script will attempt to use default/common silent switches for installer.
- friendly_name: Optional nicely formatted name of the application that can be used for Interactive/Non-Interactive PSADT deploymodes.
- shortcuts: a list of objects. Each object will create a shortcut with the following properties:
1. Target - The target of the shortcut.
2. Location - Location of shortcut on system.
3. Icon
4. Description
- source_destination: The directory where the source files are located. This is the directory that will be copied to the target system.
- uninstall_key: This script will create a registry entry in HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\ with this key. This is used to identify the application in Microsoft Windows, just like any other, as well as point to the executable that can be used to 'uninstall' this application/source files/shortcuts/etc.
Each object in the uninstall_key list is a property of the application's registry key.
- vendor: application vendor.
- version: The version of the application. This will be used to create the folder structure and the name of the PSADT script.


