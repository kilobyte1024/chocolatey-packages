$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9039/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/distro/app/stable/win/x64/1.0.9039/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = 'ccd1b73aa774e3deefb7672629099eec167b130521b9036b553af6e46ffdbe3f'
  checksumType      = 'sha256'
  checksum64        = '4cfeffc865e99ab59c5c9f7134bcd174cdcecac858d2e23f652be4b789a4605a'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

Install-ChocolateyPackage @packageArgs 
