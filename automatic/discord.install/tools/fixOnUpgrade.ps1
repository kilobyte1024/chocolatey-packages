# Define the root directory for Discord installations
$discordPath = Join-Path $Env:LOCALAPPDATA -ChildPath 'Discord'
if (-not (Test-Path $discordPath)) {
    Write-Host "No Discord dir found in LocalAppData."
    return
}

# Define the path to the installer.db file
$installerDbPath = Join-Path $discordPath "installer.db"

# Get the latest folder that starts with "app-"
$appVersionFolder = Get-ChildItem -Path $discordPath | Where-Object { $_.Name -like 'app-*' } | Sort-Object -Descending | Select-Object -First 1

# Check if the app- folder was found
if (-not $appVersionFolder) {
    Write-Host "Error: No Discord installation found."
    return
}

# Determine if the squirrel firstrun has been completed

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

        Write-Host "installer.db Discord version: $version"
        $squirrelFirstRunCompleted = $true
    } else {
        Write-Host "Version string not found in the installer.db file. Deleting the file..."
        Remove-Item -Path $installerDbPath -Force
    }
} else {
    Write-Host "No installer.db file found."
    
}

# Check if the squirrel firstrun has been completed
if (-not $squirrelFirstRunCompleted) {
    Write-Host "No valid version string found in installer.db or file missing. Running repair process."

    # Define the custom log file path
    $customLog = Join-Path $Env:TEMP "DiscordSquirrelFirstrun.log"
    if (Test-Path $customLog) { Remove-Item $customLog -Force } # Remove existing log file

    # Compute a start boundary (current time + 1 minute)
    $startBoundary = (Get-Date).AddMinutes(1).ToString("yyyy-MM-ddTHH:mm:ss")

    # Generate a temporary XML file for the scheduled task
    $xmlFile = Join-Path $Env:TEMP "DiscordSquirrelFirstrun.xml"
    if (Test-Path $xmlFile) { Remove-Item $xmlFile -Force } # Remove existing XML file

    $TaskXML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
    <RegistrationInfo>
        <Date>$startBoundary</Date>
        <Author>$env:USERDOMAIN\$env:USERNAME</Author>
        <Description>Run Discord --squirrel-firstrun silently and log output to a custom file.</Description>
        <URI>\DiscordSquirrelFirstrun</URI>
    </RegistrationInfo>
    <Triggers>
        <RegistrationTrigger>
            <Enabled>true</Enabled>
        </RegistrationTrigger>
    </Triggers>
    <Principals>
        <Principal id="Author">
            <RunLevel>HighestAvailable</RunLevel>
            <UserId>$env:USERDOMAIN\$env:USERNAME</UserId>
            <LogonType>S4U</LogonType>
        </Principal>
    </Principals>
    <Settings>
        <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
        <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
        <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
        <AllowHardTerminate>true</AllowHardTerminate>
        <StartWhenAvailable>true</StartWhenAvailable>
        <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
        <IdleSettings>
            <StopOnIdleEnd>true</StopOnIdleEnd>
            <RestartOnIdle>false</RestartOnIdle>
        </IdleSettings>
        <AllowStartOnDemand>true</AllowStartOnDemand>
        <Enabled>true</Enabled>
        <Hidden>true</Hidden>
        <RunOnlyIfIdle>false</RunOnlyIfIdle>
        <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
        <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
        <WakeToRun>true</WakeToRun>
        <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
        <Priority>7</Priority>
    </Settings>
    <Actions Context="Author">
        <Exec>
            <Command>cmd.exe</Command>
            <Arguments>/c "$discordPath\$appVersionFolder\Discord.exe --squirrel-firstrun >> $customLog 2>&amp;1"</Arguments>
        </Exec>
    </Actions>
</Task>
"@

    $TaskXML | Set-Content -Path $xmlFile -Encoding Unicode

    # Create the scheduled task
    $taskName = "DiscordSquirrelFirstrun"
    Write-Host "Creating scheduled task '$taskName'..."
    schtasks /Create /TN "$taskName" /XML "$xmlFile" /F | Out-Null
    if (-not $?) {
        Write-Host "Failed to create scheduled task."
        return
    }
    Remove-Item $xmlFile -Force # Remove the temporary XML file

    # Run the scheduled task immediately then delete it
    Write-Host "Running scheduled task..."
    schtasks /Run /TN "$taskName" | Out-Null
    schtasks /Delete /TN "$taskName" /F | Out-Null

    # Monitor the log file for the success message
    Write-Host "Monitoring custom log file for success message (timeout: 60 seconds)..."
    # Note: This string is unique to the successful completion of the squirrel firstrun process 
    # It works whether the Discord account is automatically signed in through a browser or not.
    $successString = "CDM completed with status: cdm-ready-"
    $success = $false

    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 1
        if (Test-Path $customLog) {
            if (Select-String -Path $customLog -Pattern $successString -Quiet) {
                $success = $true
                Write-Host "Terminating Discord..."
                Stop-Process -Name "Discord" -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
                break
            }
        }
    }

    # Cleanup and exit
    Write-Host "Repair complete."
    if (Test-Path $customLog) { Remove-Item $customLog -Force }
    if ($success) {
        Write-Host "Success: Installer state repaired. Launch Discord normally."
    } else {
        Write-Host "Warning: Timeout reached. Try manual launch."
    }
    return
}