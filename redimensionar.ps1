# Script para redimensionar imágenes a 800x600 píxeles
# Requiere .NET Framework (incluido en Windows)

Add-Type -AssemblyName System.Drawing

$inputFolder = ".\Images"  # Carpeta de entrada (relativa al script)
$outputFolder = ".\Images\Resized"  # Carpeta de salida

# Crear carpeta de salida si no existe
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

# Obtener todas las imágenes (jpg, png, etc.)
$images = Get-ChildItem $inputFolder -Include *.jpg, *.jpeg, *.png, *.bmp -Recurse

foreach ($imageFile in $images) {
    try {
        $img = [System.Drawing.Image]::FromFile($imageFile.FullName)
        $bitmap = New-Object System.Drawing.Bitmap 800, 600
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($img, 0, 0, 800, 600)
        $graphics.Dispose()

        # Guardar con el mismo formato
        $outputPath = Join-Path $outputFolder $imageFile.Name
        $bitmap.Save($outputPath, $img.RawFormat)
        $bitmap.Dispose()
        $img.Dispose()

        Write-Host "Redimensionada: $($imageFile.Name)"
    } catch {
        Write-Host "Error procesando $($imageFile.Name): $_"
    }
}

Write-Host "Proceso completado. Imágenes redimensionadas en $outputFolder"