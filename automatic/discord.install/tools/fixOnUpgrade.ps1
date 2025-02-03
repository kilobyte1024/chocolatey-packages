$discordPath = Join-Path $Env:LOCALAPPDATA -ChildPath 'Discord'
if (-not (Test-Path $discordPath)) {
    Write-Host "No Discord dir found in LocalAppData."
    return
}

# Define the path to the installer.db file
$installerDbPath = Join-Path $discordPath "installer.db"

# Initialize the variable as false by default
$squirrelFirstRunCompleted = $false

# Check if the installer.db file exists
if (Test-Path $installerDbPath) {
    # Read the file as plain text
    $fileContent = Get-Content -Path $installerDbPath -Raw

    # Define a regex pattern to find the JSON indicating version
    $versionPattern = '{"host_version":.*?"version":\[(\d+),(\d+),(\d+)\]}'

    # Search for the pattern in the file
    if ($fileContent -match $versionPattern) {
        $major = $matches[1]
        $minor = $matches[2]
        $patch = $matches[3]

        # Combine the version components
        $version = "$major.$minor.$patch"

        Write-Host "Discord Version Detected: $version"
        $squirrelFirstRunCompleted = $true
    } else {
        Write-Host "Version string not found in the installer.db file. Deleting the file..."
        Remove-Item -Path $installerDbPath -Force
    }
} else {
    Write-Host "No installer.db file found."
    
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
