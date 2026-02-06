
# Script para actualizar todos los archivos HTML con controles de cantidad

$htmlFiles = @(
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

$basePath = "c:\Users\ASUS VIVOBOOK R7\Desktop\PROGRAMACION\Pagina SyD"

foreach ($file in $htmlFiles) {
    $filePath = Join-Path $basePath $file
    
    if (Test-Path $filePath) {
        Write-Host "Actualizando: $file"
        
        $content = Get-Content $filePath -Raw
        
        # Actualizar la función addToCart en el script
        $oldScript = @"
        function addToCart(productName, price) {
            console.log('Añadiendo producto:', productName, price);
            let cart = JSON.parse(localStorage.getItem('cart')) || [];
            cart.push({ name: productName, price: price });
            localStorage.setItem('cart', JSON.stringify(cart));
            console.log('Cart guardado en localStorage:', localStorage.getItem('cart'));
            alert('Producto añadido al carrito');
            window.location.href = 'index.html';
        }
"@

        $newScript = @"
        function addToCart(productName, price, quantity = 1) {
            console.log('Añadiendo producto:', productName, price, 'Cantidad:', quantity);
            let cart = JSON.parse(localStorage.getItem('cart')) || [];
            
            // Buscar si el producto ya existe en el carrito
            let existingProduct = cart.find(item => item.name === productName);
            
            if (existingProduct) {
                existingProduct.quantity += quantity;
            } else {
                cart.push({ name: productName, price: price, quantity: quantity });
            }
            
            localStorage.setItem('cart', JSON.stringify(cart));
            console.log('Cart guardado en localStorage:', localStorage.getItem('cart'));
            alert(`$`{quantity} unidad(es) añadida(s) al carrito`);
            window.location.href = 'index.html';
        }

        function getQuantity(productName) {
            return parseInt(document.querySelector(`[data-product="`$`{productName}`"]`)?.value) || 1;
        }

        function incrementQuantity(productName) {
            const input = document.querySelector(`[data-product="`$`{productName}`"]`);
            if (input) {
                input.value = parseInt(input.value) + 1;
            }
        }

        function decrementQuantity(productName) {
            const input = document.querySelector(`[data-product="`$`{productName}`"]`);
            if (input && parseInt(input.value) > 1) {
                input.value = parseInt(input.value) - 1;
            }
        }
"@

        $content = $content -replace [regex]::Escape($oldScript), $newScript
        
        # Reemplazar los botones de "Añadir al Carrito"
        # Patrón: <button ... onclick="addToCart('...', ...)">Añadir al Carrito</button>
        $pattern = '<button class="btn-primary w-full py-3"\s+onclick="addToCart\(''([^'']+)'',\s*(\d+)\)">([^<]+)</button>'
        
        $content = [regex]::Replace($content, $pattern, {
            param($match)
            $productName = $match.Groups[1].Value
            $price = $match.Groups[2].Value
            $buttonText = $match.Groups[3].Value
            
            # Crear identificador único
            $productId = $productName.ToLower().Replace(' ', '-').Replace('á', 'a').Replace('é', 'e').Replace('í', 'i').Replace('ó', 'o').Replace('ú', 'u')
            $productId = [regex]::Replace($productId, '[^a-z0-9-]', '')
            
            $newButton = @"
<div class="flex items-center gap-2 mb-4">
                            <button class="btn-primary px-3 py-2" onclick="decrementQuantity('$productId')">-</button>
                            <input type="number" data-product="$productId" value="1" min="1" class="w-12 text-center border border-gray-300 rounded py-2">
                            <button class="btn-primary px-3 py-2" onclick="incrementQuantity('$productId')">+</button>
                        </div>
                        <button class="btn-primary w-full py-3" onclick="addToCart('$productName', $price, getQuantity('$productId'))">$buttonText</button>
"@
            
            return $newButton
        })
        
        # También actualizar el script generateWhatsAppMessage
        $oldWhatsApp = @"
        cart.forEach(item => {
                message += `$`{item.name} - $`$`{item.price.toFixed(2)}\n`;
                total += item.price;
            });
"@

        $newWhatsApp = @"
        cart.forEach(item => {
                const quantity = item.quantity || 1;
                const subtotal = item.price * quantity;
                message += `$`{quantity}x $`$`{item.name} - $`$`$`{item.price.toFixed(2)}\n`;
                total += subtotal;
            });
"@

        $content = $content -replace [regex]::Escape($oldWhatsApp), $newWhatsApp
        
        # Guardar el archivo actualizado
        Set-Content -Path $filePath -Value $content -Encoding UTF8
        Write-Host "✓ $file actualizado correctamente"
    }
    else {
        Write-Host "✗ No se encontró: $file"
    }
}

Write-Host "¡Actualización completada!"
