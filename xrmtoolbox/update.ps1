[CmdletBinding()]
param([switch] $Force)

Import-Module AU

$domain = 'https://github.com'
$releases = "$domain/mscrmtools/xrmtoolbox/releases"
$latestRelease = "$releases/latest"
$expandedAssets = "$releases/expanded_assets"

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
  $latestRelease = Invoke-WebRequest -Uri $latestRelease -Headers @{ "Accept" = "application/json" } -UseBasicParsing | ConvertFrom-Json

  $tagName = $latestRelease.tag_name
  $download_page = Invoke-WebRequest -Uri "$expandedAssets/$tagName" -UseBasicParsing

  $re = 'XrmToolbox\.zip$'
  $url = $download_page.Links | ? href -Match $re | Select -First 1 -Expand href

  $version = $tagName.Substring(1)

  return @{
    Version    = $version
    URL64      = $domain + $url
    ReleaseURL = "$releases/tag/$tagName"
  }
}

update -ChecksumFor none -Force:$Force
