param(
    [string]$TargetFolder = '(($default_path$))',
    [string]$TargetUser = "$env:USERNAME"
)

## Get Application name from target folder:
$ApplicationName = $TargetFolder | Split-Path -Leaf

Copy-Item -Path "$TargetFolder" -Destination "C:\Users\$TargetUser" -Recurse -Exclude "$ApplicationName.lnk", "user_install.ps1"

## Create start menu folder and shortcut:
$shortcut_folder = "C:\Users\$TargetUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$ApplicationNAme"
if (-not (Test-Path $shortcut_folder -ErrorAction SilentlyContinue)) {
    New-Item -Path $shortcut_folder -ItemType Directory | Out-null
}

@("C:\Users\$TargetUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$ApplicationNAme\$ApplicationName.lnk",
    "C:\Users\$TargetUser\Desktop\$ApplicationName.lnk") | % {
    Copy-Item -Path "$TargetFolder\$ApplicationName.lnk" -Destination "$_"
}