$discordPath = Join-Path $Env:LOCALAPPDATA -ChildPath 'Discord'
if (!Test-Path $discordPath) {
    Write-Host "No Discord dir found in LocalAppData."
    return
}

# Delete the installer.db file if it exists
$installerDbPath = Join-Path $discordPath "installer.db"
if (Test-Path $installerDbPath) {
    Remove-Item $installerDbPath -Force
    Write-Host "Deleted installer.db file from $discordPath"
} else {
    Write-Host "No installer.db file found to delete."
}

# Get the latest folder that starts with "app-"
$appVersionFolder = Get-ChildItem -Path $discordPath | Where-Object { $_.Name -like 'app-*' } | Sort-Object -Descending | Select-Object -First 1

# Check if the app version folder was found
if ($null -ne $appVersionFolder) {
    $sourceDbPath = Join-Path $appVersionFolder.FullName "installer.db"

    # Check if the installer.db file exists in the app version folder
    if (Test-Path $sourceDbPath) {
        # Copy the installer.db file to the Discord folder
        Copy-Item -Path $sourceDbPath -Destination $discordPath -Force
        Write-Host "Copied installer.db from $($appVersionFolder.Name) to $discordPath"
    } else {
        Write-Host "No installer.db file found in $($appVersionFolder.Name)"
    }
} else {
    Write-Host "No app version folder found."
}