$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/apps/win/0.0.304/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/apps/win/0.0.304/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = 'f4305bb77544523cea3bf7fe75a183813029c0a825dbda35fd9f7659d4550231'
  checksumType      = 'sha256'
  checksum64        = 'f4305bb77544523cea3bf7fe75a183813029c0a825dbda35fd9f7659d4550231'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

Install-ChocolateyPackage @packageArgs 
