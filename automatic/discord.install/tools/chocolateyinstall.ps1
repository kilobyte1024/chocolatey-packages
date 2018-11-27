$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = '4ca0db268656fd3928633b4cea554ca356def0b8188ada68ec4e56d1696f6bf2'
  checksumType      = 'sha256'
  checksum64        = '4ca0db268656fd3928633b4cea554ca356def0b8188ada68ec4e56d1696f6bf2'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

Install-ChocolateyPackage @packageArgs 
