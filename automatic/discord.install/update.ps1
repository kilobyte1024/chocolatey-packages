Import-Module Chocolatey-AU

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

function global:au_BeforeUpdate() {
    #Download $Latest.URL32 / $Latest.URL64 in tools directory and remove any older installers.
    Get-RemoteFiles -Purge
}

# function global:au_AfterUpdate ($Package)  {
#     Set-DescriptionFromReadme $Package -SkipFirst 2 
# }

# This loop pulls through any redirects. We assume the final URL contains the version number we need.
function Update-Url ($url, $headers) {
    while($true) {
    
        $request = [System.Net.WebRequest]::Create($url)
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        
        # alt idea
        # $response = Invoke-WebRequest -URI $url -Headers $header -HttpVersion 2.0
        
        $location = $response.GetResponseHeader('Location')
        
        if (!$location -or ($location -eq $url)) { 
            break 
        }
        
        $url = $location
    }    
    return $url
}

function global:au_GetLatest {

    $releaseUri = 'https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch={0}'
    $headers = @{
        "User-Agent" = "Chocolatey AU update check. https://chocolatey.org"
    }

    # workaround for Appveyor cxn problems
    [System.Net.ServicePointManager]::DefaultConnectionLimit = 256

    Write-Host ($releaseUri.ToString() -f 'x86')
    Write-Host ($releaseUri.ToString() -f 'x64')
    $url32 = Update-Url($releaseUri.ToString() -f 'x86', $headers)
    $url64 = Update-Url($releaseUri.ToString() -f 'x64', $headers)

    $version = ($url64 -split '/' | Select-Object -Last 1 -Skip 1) 
    
    $Latest = @{ 
                URL32       = $url32
                URL64       = $url64
                Version     = $version
              }
    # checksums will be automatically updated by BeforeUpdate Get-RemoteFiles
    
    return $Latest
}

if ($MyInvocation.InvocationName -ne '.') {
    # checksum done by Get-RemoteFiles
    update -ChecksumFor none
    
    if ($global:au_old_force -is [bool]) { 
        $global:au_force = $global:au_old_force 
    }
} 
