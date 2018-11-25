$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = 'F4BDF7CB7B93590EEF7A60BA09FCE822AEB9063D4B0BFDF22A6A9E2E1B22D8F4'
  checksumType      = 'sha256'
  checksum64        = 'F4BDF7CB7B93590EEF7A60BA09FCE822AEB9063D4B0BFDF22A6A9E2E1B22D8F4'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

Install-ChocolateyPackage @packageArgs 
