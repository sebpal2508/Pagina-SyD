
# Script para actualizar todos los archivos HTML restantes con los controles de cantidad

$basePath = "c:\Users\ASUS VIVOBOOK R7\Desktop\PROGRAMACION\Pagina SyD"

$filesToUpdate = @(
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

$newScript = @'
    <script>
        function addToCart(productName, price, quantity = 1) {
            console.log('Añadiendo producto:', productName, price, 'Cantidad:', quantity);
            let cart = JSON.parse(localStorage.getItem('cart')) || [];

            let existingProduct = cart.find(item => item.name === productName);

            if (existingProduct) {
                existingProduct.quantity += quantity;
            } else {
                cart.push({ name: productName, price: price, quantity: quantity });
            }

            localStorage.setItem('cart', JSON.stringify(cart));
            console.log('Cart guardado en localStorage:', localStorage.getItem('cart'));
            alert(`${quantity} unidad(es) añadida(s) al carrito`);
            window.location.href = 'index.html';
        }

        function getQuantity(productName) {
            return parseInt(document.querySelector(`[data-product="${productName}"]`)?.value) || 1;
        }

        function incrementQuantity(productName) {
            const input = document.querySelector(`[data-product="${productName}"]`);
            if (input) {
                input.value = parseInt(input.value) + 1;
            }
        }

        function decrementQuantity(productName) {
            const input = document.querySelector(`[data-product="${productName}"]`);
            if (input && parseInt(input.value) > 1) {
                input.value = parseInt(input.value) - 1;
            }
        }

        function sanitizeId(text) {
            return text.toLowerCase()
                .replace(/á/g, 'a')
                .replace(/é/g, 'e')
                .replace(/í/g, 'i')
                .replace(/ó/g, 'o')
                .replace(/ú/g, 'u')
                .replace(/ñ/g, 'n')
                .replace(/[^a-z0-9]+/g, '-')
                .replace(/^-+|-+$/g, '');
        }

        function initializeQuantityControls() {
            const buttons = document.querySelectorAll('.product-card button.btn-primary:not([data-quantity-initialized])');
            
            buttons.forEach(button => {
                if (button.textContent.includes('Añadir')) {
                    const onclickText = button.getAttribute('onclick');
                    const match = onclickText.match(/addToCart\('([^']+)',\s*(\d+)(?:,.*?)?\)/);
                    
                    if (match && !onclickText.includes('getQuantity')) {
                        const productName = match[1];
                        const price = match[2];
                        const productId = sanitizeId(productName);
                        
                        const quantityDiv = document.createElement('div');
                        quantityDiv.className = 'flex items-center gap-2 mb-4';
                        quantityDiv.innerHTML = `
                            <button class="btn-primary px-3 py-2" onclick="decrementQuantity('${productId}')">-</button>
                            <input type="number" data-product="${productId}" value="1" min="1" class="w-12 text-center border border-gray-300 rounded py-2">
                            <button class="btn-primary px-3 py-2" onclick="incrementQuantity('${productId}')">+</button>
                        `;
                        
                        button.setAttribute('onclick', `addToCart('${productName}', ${price}, getQuantity('${productId}'))`);
                        button.parentNode.insertBefore(quantityDiv, button);
                        button.setAttribute('data-quantity-initialized', 'true');
                    }
                }
            });
        }

        function generateWhatsAppMessage() {
            let cart = JSON.parse(localStorage.getItem('cart')) || [];
            if (cart.length === 0) {
                return encodeURIComponent("Hola, tengo una pregunta sobre sus productos.");
            }
            let message = "Hola, quiero comprar los siguientes productos:\n";
            let total = 0;
            cart.forEach(item => {
                const quantity = item.quantity || 1;
                const subtotal = item.price * quantity;
                message += `${quantity}x ${item.name} - $${item.price.toFixed(2)}\n`;
                total += subtotal;
            });
            message += `Total: $${total.toFixed(2)}`;
            return encodeURIComponent(message);
        }

        document.addEventListener('DOMContentLoaded', function () {
            initializeQuantityControls();
            document.getElementById('whatsapp-link').href = `https://wa.me/573001770901?text=${generateWhatsAppMessage()}`;
        });

        document.getElementById('search').addEventListener('input', function () {
            const query = this.value.toLowerCase().trim();
            const products = document.querySelectorAll('.product-card');
            products.forEach(card => {
                const name = card.querySelector('h3').textContent.toLowerCase();
                card.style.display = name.includes(query) ? 'block' : 'none';
            });
        });
    </script>
'@

foreach ($file in $filesToUpdate) {
    $filePath = Join-Path $basePath $file
    
    if (Test-Path $filePath) {
        Write-Host "Actualizando: $file"
        $content = Get-Content $filePath -Raw
        
        # Buscar el script existente y reemplazarlo
        $scriptPattern = '<script>.*?function addToCart\(productName, price\).*?</script>'
        
        if ($content -match $scriptPattern) {
            $content = [regex]::Replace($content, $scriptPattern, $newScript, [System.Text.RegularExpressions.RegexOptions]::Singleline)
            Set-Content -Path $filePath -Value $content -Encoding UTF8
            Write-Host "✓ $file actualizado correctamente"
        }
        else {
            Write-Host "⚠ No se encontró el script en $file"
        }
    }
    else {
        Write-Host "✗ No existe: $file"
    }
}

Write-Host "`nActualización completada"
