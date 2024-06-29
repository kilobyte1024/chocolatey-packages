$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9051/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/distro/app/stable/win/x64/1.0.9152/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = '4865f70b92896ecb15ffd09caaf579ea533978a4e4306d499dfdc2e19bd46b0d'
  checksumType      = 'sha256'
  checksum64        = 'd24dddbdf2970f6a51611a193bcd839faf3d7a28d4dc96adcb3c20a11424209e'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

# ex: C:\Users\foobar\AppData\Local\Discord\app-1.0.9147\Discord.exe
$DiscordPath = Join-Path $Env:LOCALAPPDATA "Discord" * "Discord.exe" -Resolve
$DiscordPresent = Test-Path -Path $DiscordPath

if ($DiscordPresent) {
  $InstalledVersion = (Get-ItemProperty -Path $DiscordPath -ErrorAction:SilentlyContinue).VersionInfo.ProductVersion
  $DiscordOutdated = [Version]$($Env:ChocolateyPackageVersion) -gt [Version]$InstalledVersion
}

## community forums bugfix alternative 1 : swap the install file here

# Only Attempt an install if the existing version is older than the package version, or if forced
if (-not $DiscordPresent -or ($DiscordPresent -and $DiscordOutdated) -or $Env:ChocolateyForce)
{
  Get-Process 'discord' -ErrorAction SilentlyContinue | Stop-Process -Force
  Install-ChocolateyPackage @packageArgs
}

## Potential bugfix for community forums bug
#$DiscordPath --squirrel-firstrun
