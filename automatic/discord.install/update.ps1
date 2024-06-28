Import-Module Chocolatey-AU

$releases = 'https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x86'

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

# This loop pulls through any redirects. We assume the final URL contains the version number we need.
function Update-Url ($url, $headers) {
    while($true) {
    
        $request = Invoke-WebRequest $url -Headers $header
        $request.AllowAutoRedirect = $false
        
        $response = $request.GetResponse()
        $location = $response.GetResponseHeader('Location')
        
        if (!$location -or ($location -eq $url)) { 
            break 
        }
        
        $url = $location
    }    
    return $url
}

function global:au_GetLatest {
    $headers = @{
        "User-Agent" = "Chocolatey AU update check. https://chocolatey.org"
    }
    
    $url = $releases
    
    echo test1
    $url32 = Update-Url($releases, $headers)
    echo test2
    $url64 = Update-Url($releases -replace 'x86', 'x64', $headers)
    echo test3

    $version = ($url64 -split '/' | Select-Object -Last 1 -Skip 1) 
    
    $current_checksum = (Get-Item $PSScriptRoot\tools\chocolateyInstall.ps1 | Select-String '\bchecksum\b') -split "=|'" | Select-Object -Last 1 -Skip 1
    $current_checksum64 = (Get-Item $PSScriptRoot\tools\chocolateyInstall.ps1 | Select-String '\bchecksum64\b') -split "=|'" | Select-Object -Last 1 -Skip 1
    
    if ($current_checksum.Length -ne 64) { 
        throw "Can't find current checksum" 
    }
    
    $remote_checksum32 = Get-RemoteChecksum $url32
    $remote_checksum64 = Get-RemoteChecksum $url64
    
    if ($current_checksum -ne $remote_checksum32 -or $current_checksum64 -ne $remote_checksum64) {
        Write-Host 'Remote checksum is different then the current one, forcing update'
        
        $global:au_old_force = $global:au_force
        $global:au_force = $true
        $global:au_Version = $version
    }
    
    $Latest = @{ 
                URL32       = $url32
                URL64       = $url64
                Version     = $version
                Checksum32  = $remote_checksum32
                Checksum64  = $remote_checksum64
              }  
    
    return $Latest
}

if ($MyInvocation.InvocationName -ne '.') {
    update -ChecksumFor none
    
    if ($global:au_old_force -is [bool]) { 
        $global:au_force = $global:au_old_force 
    }
} 
