# Script para agregar controles de cantidad a todos los archivos HTML

$basePath = "c:\Users\ASUS VIVOBOOK R7\Desktop\PROGRAMACION\Pagina SyD"

# Archivos a procesar (excluyendo index.html y dotaciones-generales.html ya actualizado)
$filesToProcess = @(
    "extintores.html",
    "kit-antiderrame.html", 
    "proteccion-altura.html",
    "proteccion-cabeza.html",
    "proteccion-manos.html",
    "proteccion-pies.html",
    "proteccion-respiratoria.html",
    "proteccion-visual.html",
    "protecciones-auditivas.html",
    "senalizaciones.html"
)

# Script de funciones de cantidad
$quantityFunctions = @'
        function getQuantity(productName) {
            return parseInt(document.querySelector(`[data-product="`+"`"+`${productName}`+"`"+`"]`)?.value) || 1;
        }

        function incrementQuantity(productName) {
            const input = document.querySelector(`[data-product="`+"`"+`${productName}`+"`"+`"]`);
            if (input) {
                input.value = parseInt(input.value) + 1;
            }
        }

        function decrementQuantity(productName) {
            const input = document.querySelector(`[data-product="`+"`"+`${productName}`+"`"+`"]`);
            if (input && parseInt(input.value) > 1) {
                input.value = parseInt(input.value) - 1;
            }
        }
'@

foreach ($file in $filesToProcess) {
    $filePath = Join-Path $basePath $file
    
    if (Test-Path $filePath) {
        Write-Host "Procesando: $file"
        $content = Get-Content $filePath -Raw
        
        # Actualizar addToCart para incluir quantity
        if ($content -match 'function addToCart\(productName, price\)') {
            $oldFunc = 'function addToCart(productName, price) {
            console.log(''Añadiendo producto:'', productName, price);
            let cart = JSON.parse(localStorage.getItem(''cart'')) || [];
            cart.push({ name: productName, price: price });
            localStorage.setItem(''cart'', JSON.stringify(cart));
            console.log(''Cart guardado en localStorage:'', localStorage.getItem(''cart''));
            alert(''Producto añadido al carrito'');
            window.location.href = ''index.html'';
        }'
            
            $newFunc = 'function addToCart(productName, price, quantity = 1) {
            console.log(''Añadiendo producto:'', productName, price, ''Cantidad:'', quantity);
            let cart = JSON.parse(localStorage.getItem(''cart'')) || [];
            
            // Buscar si el producto ya existe en el carrito
            let existingProduct = cart.find(item => item.name === productName);
            
            if (existingProduct) {
                existingProduct.quantity += quantity;
            } else {
                cart.push({ name: productName, price: price, quantity: quantity });
            }
            
            localStorage.setItem(''cart'', JSON.stringify(cart));
            console.log(''Cart guardado en localStorage:'', localStorage.getItem(''cart''));
            alert(`${quantity} unidad(es) añadida(s) al carrito`);
            window.location.href = ''index.html'';
        }'
            
            $content = $content.Replace($oldFunc, $newFunc)
        }
        
        Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "✓ Actualizado: $file"
    }
}

Write-Host "`nScript completado"
