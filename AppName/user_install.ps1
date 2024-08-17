param(
    [string]$TargetFolder = '(($default_path$))',
    # [string]$TargetUser = "$env:USERNAME"
    [string]$TargetUser
)

if (-not $TargetUser) {
    $TargetUser = Get-CimInstance -Class Win32_ComputerSystem | Select -Exp UserName
    $TargetUser = $targetuser.split('\')[-1]
}

## Get Application name from target folder:
$ApplicationName = $TargetFolder | Split-Path -Leaf
if ($TargetUser) {
    if (-not (Test-Path "C:\Users\$TargetUser\$ApplicationName" -ErrorAction SilentlyContinue)) {
        Copy-Item -Path "$TargetFolder" -Destination "C:\Users\$TargetUser" -Recurse -Exclude "$ApplicationName.lnk", "user_install.ps1"

        ## Create start menu folder and shortcut:
        $shortcut_folder = "C:\Users\$TargetUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$ApplicationNAme"
        if (-not (Test-Path $shortcut_folder -ErrorAction SilentlyContinue)) {
            New-Item -Path $shortcut_folder -ItemType Directory | Out-null
        }
    
        @("C:\Users\$TargetUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\$ApplicationNAme\") | % {
            Copy-Item -Path "$TargetFolder\$ApplicationName.lnk" -Destination "$_"
        }
    }
}