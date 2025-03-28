$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://stable.dl2.discordapp.net/distro/app/stable/win/x86/1.0.9059/DiscordSetup.exe'
  url64bit          = 'https://stable.dl2.discordapp.net/distro/app/stable/win/x64/1.0.9187/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = '85060117d7c75378fcbf8b3824e79549002bc5298ae46fcaa2524c83c476596a'
  checksumType      = 'sha256'
  checksum64        = '08e3c37ca679ef09ce8ab861994abfff69b9e3f6f1c04d64b720a7fd869cd71c'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

$pathsToSearch = @()
if (Test-Path (Join-Path $Env:LOCALAPPDATA -ChildPath 'Discord')) {
  $pathsToSearch = Join-Path $Env:LOCALAPPDATA -ChildPath 'Discord\*\Discord.exe' -Resolve
}
$pathsToSearch += Join-Path $Env:ProgramFiles -ChildPath 'Discord\Discord.exe'
if ($Env:ProgramFilesX86) {
  $pathsToSearch += Join-Path $Env:ProgramFilesX86 -ChildPath 'Discord\Discord.exe'
}
$DiscordPresent = $false

# ex: C:\Users\foobar\AppData\Local\Discord\app-1.0.9153\Discord.exe
# Iterate through the paths and check if Discord.exe exists
$versions = @()
foreach ($path in $pathsToSearch) {
  if (Test-Path $path) {
    # Track each version # found
    $version = (Get-ItemProperty -Path $path -ErrorAction:SilentlyContinue).VersionInfo.ProductVersion
    if ($version) {
        $versions += ([Version]$version)
    }
  }
}

# Sort the versions in descending order (highest to lowest)
$versions = $versions | Sort-Object -Descending
Write-Host "Versions found: $versions"

# if Discord is present
if ($null -ne $versions -and $versions.Count -gt 0) {
  $InstalledVersion = $versions[0]
  $DiscordOutdated = [Version]$($Env:ChocolateyPackageVersion) -gt [Version]$InstalledVersion
  $DiscordPresent = $true
  Write-Host "Highest version found: $InstalledVersion"
} else {
  $DiscordPresent = $false
  Write-Host "No prior Discord installs found."
}

# Only Attempt an install if the existing version is older than the package version, or if forced
if (-not $DiscordPresent -or ($DiscordPresent -and $DiscordOutdated) -or $Env:ChocolateyForce)
{
  # stop the existing Discord process, if any
  Write-Host "Attempting to stop running Discord process (if any)..."
  Get-Process 'discord' -ErrorAction SilentlyContinue | Stop-Process -Force
  Write-Host "Installing package"
  Install-ChocolateyPackage @packageArgs

  Write-Host "Due to a bug in the Discord silent installer, you may see this error message:"
  Write-Host "A fatal Javascript error occured"
  Write-Host "Error: (InconsistentInstallerState) Attempt to install host that is currently running. current_exe_path: ..."
  Write-Host "To fix, run $Env:LOCALAPPDATA\Discord\*\discord.exe --squirrel-firstrun"
}
