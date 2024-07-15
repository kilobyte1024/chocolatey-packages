$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9052/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/distro/app/stable/win/x64/1.0.9153/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = 'ce00a897659c4227d1731f7eafd53af16c66024823317563bd2eba3553ab01e1'
  checksumType      = 'sha256'
  checksum64        = '12a56a6df3f57af96c0f2cb95fa26fbed515b5e98e36c6ab266c16928c1744ef'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

$pathsToSearch = $()
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
foreach ($path in $pathsToSearch) {
  if (Test-Path $path) {
    # Track each version # found
    $version = (Get-ItemProperty -Path $path -ErrorAction:SilentlyContinue).VersionInfo.ProductVersion
    if ($version) {
        $versions += [Version]$version
    }
  }
}

# Sort the versions in descending order (highest to lowest)
$versions = $versions | Sort-Object -Descending
Write-Host "Versions found: $versions"

# if Discord is present
if ($versions.Count -gt 0) {
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
