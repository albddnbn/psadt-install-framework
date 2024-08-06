function Replace-ConfigVariables {
    param (
        [string]$config_filename = 'config.ps1'
    )

    $config_ps1_file = Get-ChildItem -Path "." -Filter "$config_filename" -Recurse -File -ErrorAction SilentlyContinue
    if (-not $config_ps1_file) {
        Write-Host "Failure: $config_filename file not found" -Foregroundcolor Red
        return
    }

    $config_filepath = "$($config_ps1_file.fullname)"
    $config_file_content = Get-Content -Path $config_filepath


    $variables = $config_file_content | Select-String -Pattern '\(\(\$.*\$\)\)' -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique
    ForEach ($single_variable in $variables) {
        $formatted_variable_name = $single_variable -split '=' | select -first 1
        # $formatted_variable_name = $formatted_variable_name.replace('(($', '')

        ForEach ($str_item in @('(($', '$))')) {
            $formatted_variable_name = $formatted_variable_name.replace($str_item, '')
        }


        if ($single_variable -like "*=*") {
            $variable_description = $single_variable -split '=' | select -last 1
            $variable_description = $variable_description.replace('$))', '')
        }
        Write-Host "Description: " -nonewline -foregroundcolor yellow
        Write-host "$variable_description"
        $variable_value = Read-Host "Enter value for $formatted_variable_name"
        Write-Host "Replacing $single_variable with $variable_value"
        $config_file_content = $config_file_content.replace($single_Variable, $variable_value)
    }

    ## output to file:
    Set-Content -Path $config_filepath -Value $config_file_content

}