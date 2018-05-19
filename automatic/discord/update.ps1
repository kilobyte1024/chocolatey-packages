import-module au

$releases = 'https://discordapp.com/api/download?platform=win'

function global:au_SearchReplace {
    @{
        "$($Latest.PackageName).nuspec" = @{
            "(\<dependency .+?`"$($Latest.PackageName).install`" version=)(`".*`")" = "`$1`"$($Latest.Version)`""
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
    
    $Latest = @{ 
                Version = $version 
              }  
    
    return $Latest
}

update -ChecksumFor none