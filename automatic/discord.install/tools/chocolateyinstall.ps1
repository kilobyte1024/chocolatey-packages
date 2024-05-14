$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9046/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/distro/app/stable/win/x64/1.0.9147/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = '61a005edb0aabfeca61a2302736111ccf30d20f2f5aecd09da574de3ecb50d80'
  checksumType      = 'sha256'
  checksum64        = 'b515b5239d471fa26f37e816e7c7d5ed7c578348ffaf61aac2b99b4ccb1c292e'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

Install-ChocolateyPackage @packageArgs 
