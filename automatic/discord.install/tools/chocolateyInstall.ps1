$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9057/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/distro/app/stable/win/x64/1.0.9158/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = 'b119f405829511270ebb7fb3523c7311061b50563606c69e10ec4ba6e026d856'
  checksumType      = 'sha256'
  checksum64        = '8d5c5c4aa33c9bae3f6f2d82e27bd7246389b490081434ba735a926fb63f6380'
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
}
