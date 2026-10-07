[CmdletBinding()]
param([switch] $Force)

Import-Module AU

function global:au_SearchReplace {
  @{
    ".\legal\VERIFICATION.txt"      = @{
      "(?i)(^\s*location on\:?\s*)\<.*\>" = "`${1}<$($Latest.ReleaseURL)>"
      "(?i)(^\s*software.*)\<.*\>"        = "`${1}<$($Latest.URL64)>"
      "(?i)(^\s*checksum\s*type\:).*"     = "`${1} $($Latest.ChecksumType64)"
      "(?i)(^\s*checksum\:).*"            = "`${1} $($Latest.Checksum64)"
    }

    "$($Latest.PackageName).nuspec" = @{
      "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseURL)`${2}"
    }
  }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }

function global:au_GetLatest {
  $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/mscrmtools/xrmtoolbox/releases/latest" -UseBasicParsing

  $version = $latestRelease.tag_name.Replace('v', '');
  $url64 = ($latestRelease.assets | Where-Object {$_.name.EndsWith("XrmToolbox\.zip")}).browser_download_url
  $releaseUrl = $latestRelease.html_url;

  return @{
    Version    = $version
    URL64      = $url64
    ReleaseURL = $releaseUrl
  }
}

update -ChecksumFor none -Force:$Force
