$ErrorActionPreference  = 'Stop';

$packageName            = 'discord.install'

$url32                  = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'
$url64                  = 'https://dl.discordapp.net/apps/win/0.0.301/DiscordSetup.exe'

$checksum32             = 'f4bdf7cb7b93590eef7a60ba09fce822aeb9063d4b0bfdf22a6a9e2e1b22d8f4'
$checksumType32         = 'sha256'

$checksum64             = 'f4bdf7cb7b93590eef7a60ba09fce822aeb9063d4b0bfdf22a6a9e2e1b22d8f4'
$checksumType64         = 'sha256'


$packageArgs = @{
  packageName   = $packageName
  fileType      = 'exe'
  url           = $url32
  url64bit      = $url64

  softwareName  = 'discord*'

  checksum      = $checksum32
  checksumType  = $checksumType32
  checksum64    = $checksum64
  checksumType64= $checksumType64

  silentArgs    = "-s"
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs 
