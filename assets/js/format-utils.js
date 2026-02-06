(function () {
    function formatPrice(value) {
        return '$' + Number(value).toLocaleString('es-CO', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
    }

    function formatProductCardPrices() {
        document.querySelectorAll('.product-card').forEach(card => {
            const priceEl = Array.from(card.querySelectorAll('p')).find(p => /\$\s*\d/.test(p.textContent));
            if (priceEl) {
                const numText = priceEl.textContent.replace(/[^0-9.,]/g, '').replace(/\./g, '').replace(/,/g, '.');
                const num = Number(numText);
                if (!isNaN(num)) {
                    priceEl.textContent = formatPrice(num);
                }
            }
        });
    }

    function actualizarBadge() {
        const cart = JSON.parse(localStorage.getItem('cart')) || [];
        const total = cart.reduce((sum, item) => sum + (Number(item.quantity) || 0), 0);
        const badge = document.getElementById('cart-count');
        if (badge) {
            badge.textContent = String(total);
        }
    }

    function bindAddButtons() {
        const buttons = document.querySelectorAll('button');
        buttons.forEach(button => {
            const onclickValue = button.getAttribute('onclick') || '';
            if (!onclickValue.includes('addToCart')) return;
            if (button.dataset.badgeBound === 'true') return;
            button.dataset.badgeBound = 'true';
            button.addEventListener('click', () => {
                // Let the existing addToCart handler update localStorage first.
                setTimeout(actualizarBadge, 0);
            });
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        actualizarBadge();
        bindAddButtons();
    });

    // Expose globally without polluting too much
    window.formatPrice = formatPrice;
    window.formatProductCardPrices = formatProductCardPrices;
    window.actualizarBadge = actualizarBadge;
})();
