param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

function New-ResizedPng {
  param(
    [Parameter(Mandatory=$true)][System.Drawing.Image]$Source,
    [Parameter(Mandatory=$true)][int]$SizePx,
    [Parameter(Mandatory=$true)][string]$OutPath
  )

  $outDir = Split-Path -Parent $OutPath
  if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

  $bmp = New-Object System.Drawing.Bitmap $SizePx, $SizePx, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $gfx = [System.Drawing.Graphics]::FromImage($bmp)
  try {
    $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gfx.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gfx.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $gfx.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver

    # Fill black to guarantee a black background even if the source has alpha.
    $gfx.Clear([System.Drawing.Color]::Black)

    $destRect = New-Object System.Drawing.Rectangle 0, 0, $SizePx, $SizePx
    $gfx.DrawImage($Source, $destRect)

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  finally {
    $gfx.Dispose()
    $bmp.Dispose()
  }
}

$srcPath = Join-Path $ProjectRoot "amicooked\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png"
if (!(Test-Path $srcPath)) {
  throw "Source icon not found: $srcPath`nCreate/choose a 1024x1024 PNG with a BLACK background and rerun."
}

# Load source image WITHOUT locking the file (FromFile keeps a lock on Windows).
$srcBytes = [System.IO.File]::ReadAllBytes($srcPath)
$ms = New-Object System.IO.MemoryStream(, $srcBytes)
$srcImg = [System.Drawing.Image]::FromStream($ms)
try {
  # iOS AppIcon set (driven by Contents.json)
  $appIconDir = Join-Path $ProjectRoot "amicooked\ios\Runner\Assets.xcassets\AppIcon.appiconset"
  $contentsPath = Join-Path $appIconDir "Contents.json"
  $iosCount = 0
  if (Test-Path $contentsPath) {
    $contents = Get-Content -Raw -Encoding UTF8 $contentsPath | ConvertFrom-Json
    foreach ($entry in $contents.images) {
      if (!$entry.filename -or !$entry.size -or !$entry.scale) { continue }
      $base = [double]($entry.size.Split("x")[0])
      $mult = [double]($entry.scale.Replace("x",""))
      $px = [int][Math]::Round($base * $mult)
      $outPath = Join-Path $appIconDir $entry.filename
      # Don't try to overwrite the source file itself (even with memory-load, safest to skip).
      if ((Resolve-Path $outPath).Path -eq (Resolve-Path $srcPath).Path) { continue }
      New-ResizedPng -Source $srcImg -SizePx $px -OutPath $outPath
      $iosCount++
    }
  }

  # Android mipmap launcher icons (standard sizes)
  $androidResDir = Join-Path $ProjectRoot "amicooked\android\app\src\main\res"
  $androidTargets = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
  }
  $andCount = 0
  foreach ($folder in $androidTargets.Keys) {
    $px = [int]$androidTargets[$folder]
    $outPath = Join-Path $androidResDir (Join-Path $folder "ic_launcher.png")
    New-ResizedPng -Source $srcImg -SizePx $px -OutPath $outPath
    $andCount++
  }

  Write-Host "Generated iOS AppIcon images: $iosCount"
  Write-Host "Generated Android mipmap icons: $andCount"
  Write-Host "Done."
}
finally {
  $srcImg.Dispose()
  $ms.Dispose()
}


