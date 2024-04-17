import-module au

$releases = 'https://discordapp.com/api/download?platform=win'

function global:au_SearchReplace {
    @{
        'tools\chocolateyinstall.ps1' = @{
            "(?i)(^\s*packageName\s*=\s*)('.*')"    = "`$1'$($Latest.PackageName)'"
            "(?i)(^\s*url\s*=\s*)('.*')"            = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*url64bit\s*=\s*)('.*')"       = "`$1'$($Latest.URL64)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
        }
        'tools\chocolateyuninstall.ps1' = @{
            "(?i)(^\s*packageName\s*=\s*)('.*')"    = "`$1'$($Latest.PackageName)'"
        }
     }
}

function global:au_BeforeUpdate() { }

function global:au_AfterUpdate ($Package)  {
    Set-DescriptionFromReadme $Package -SkipFirst 2 
}

function global:au_GetLatest {
    $url = $releases

    while($true) {
    
        $request = [System.Net.WebRequest]::Create($url)
        $request.AllowAutoRedirect = $false
        
        $response = $request.GetResponse()
        $location = $response.GetResponseHeader('Location')
        
        if (!$location -or ($location -eq $url)) { 
            break 
        }
        
        $url = $location
    }

    $version = ($url -split '/' | select -Last 1 -Skip 1)
    $arch = ($url -split '/' | select -Last 1 -Skip 2)

    if ($arch -eq 'x86') {
        $url32 = $url
        $url64 = $url.replace('x86', 'x64')
    } elseif ($arch -eq 'x64') {
        $url32 = $url.replace('x64', 'x86')
        $url64 = $url
    } else
        throw "Unknown URL format $($url)"
    }

    $current_checksum_32 = (gi $PSScriptRoot\tools\chocolateyInstall.ps1 | sls '\bchecksum\b') -split "=|'" | Select -Last 1 -Skip 1
    $current_checksum_64 = (gi $PSScriptRoot\tools\chocolateyInstall.ps1 | sls '\bchecksum64\b') -split "=|'" | Select -Last 1 -Skip 1

    if ($current_checksum_32.Length -ne 64 -or $current_checksum_64.Length -ne 64) {
        throw "Can't find current checksum" 
    }
    
    $remote_checksum_32 = Get-RemoteChecksum $url32
    $remote_checksum_64 = Get-RemoteChecksum $url64

    if ($current_checksum_32 -ne $remote_checksum_32 -or $current_checksum_64 -ne $remote_checksum_64) {
        Write-Host 'Remote checksum is different then the current one, forcing update'
        
        $global:au_old_force = $global:au_force
        $global:au_force = $true
        #$global:au_Version = $version
    }

    $Latest = @{ 
                URL32       = $url32
                URL64       = $url64 
                Version     = $version 
                Checksum32  = $remote_checksum_32
                Checksum64  = $remote_checksum_64
              }  
    
    return $Latest
}

if ($MyInvocation.InvocationName -ne '.') {
    update -ChecksumFor none
    
    if ($global:au_old_force -is [bool]) { 
        $global:au_force = $global:au_old_force 
    }
} 
