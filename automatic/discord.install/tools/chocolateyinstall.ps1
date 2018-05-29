$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = $env:ChocolateyPackageName 
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = 'f4bdf7cb7b93590eef7a60ba09fce822aeb9063d4b0bfdf22a6a9e2e1b22d8f4'
  checksumType      = 'sha256'
  checksum64        = 'f4bdf7cb7b93590eef7a60ba09fce822aeb9063d4b0bfdf22a6a9e2e1b22d8f4'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

Install-ChocolateyPackage @packageArgs 
