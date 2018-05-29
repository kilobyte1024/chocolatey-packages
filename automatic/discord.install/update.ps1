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
        
    $url32 = $url
    $url64 = $url

    $version = ($url -split '/' | select -Last 1 -Skip 1) 

    $Latest = @{ 
                URL32       = $url32; 
                URL64       = $url64; 
                Version     = $version 
              }  
    
    return $Latest
}

if ($MyInvocation.InvocationName -ne '.') {
    update
} 