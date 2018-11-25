$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = 'X'
  checksumType      = 'sha256'
  checksum64        = 'X'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

Install-ChocolateyPackage @packageArgs 
