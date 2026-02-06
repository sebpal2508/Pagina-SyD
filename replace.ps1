$files = Get-ChildItem -Path . -Filter "*.html" -Exclude "index.html"

foreach ($file in $files) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    $updated = $content -replace 'class="product-card p-4"', 'class="product-card"'
    Set-Content -LiteralPath $file.FullName -Value $updated -Encoding UTF8 -NoNewline
}