
Add-Type -AssemblyName System.Drawing

$sourcePath = "assets\images\app_icon.png"
$destPath = "assets\images\app_icon_foreground.png"

$sourceImg = [System.Drawing.Image]::FromFile($sourcePath)
$width = $sourceImg.Width
$height = $sourceImg.Height

# Create a new empty bitmap of the same size
$targetImg = New-Object System.Drawing.Bitmap($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($targetImg)

# clear with transparent
$graphics.Clear([System.Drawing.Color]::Transparent)

# Calculate padding (keep 60% size)
# Adaptive icons safe zone is circular, diameter = 66dp within 108dp.
# So we need the content to fit within ~60-65% of the center.
$scale = 0.65
$newWidth = $width * $scale
$newHeight = $height * $scale

$posX = ($width - $newWidth) / 2
$posY = ($height - $newHeight) / 2

# High quality settings
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$graphics.DrawImage($sourceImg, $posX, $posY, $newWidth, $newHeight)

$targetImg.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$targetImg.Dispose()
$sourceImg.Dispose()

Write-Host "Created padded icon at $destPath"
