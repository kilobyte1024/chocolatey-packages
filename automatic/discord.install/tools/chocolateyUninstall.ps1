$ErrorActionPreference  = 'Stop'
$softwareNamePattern = 'discord*'

# stop systray discord
Get-Process 'discord' -ErrorAction SilentlyContinue | Stop-Process -Force

# check for installs and begin uninstall if it makes sense
[array]$key             = Get-UninstallRegistryKey -SoftwareName $softwareNamePattern

if ($key.Count -eq 1) {
  $key | ForEach-Object {
    $packageArgs = @{
      packageName       = 'discord.install'
      fileType          = 'exe'
      silentArgs        = '-s --uninstall'
      validExitCodes    = @(0)
      file              = "$($_.UninstallString.TrimEnd('--uninstall'))"
    }

    Uninstall-ChocolateyPackage  @packageArgs
    Write-Warning 'Windows must reboot in order to complete the uninstallation.'
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$key.Count matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  
  $key | ForEach-Object {Write-Warning "- $_.DisplayName"}
}
