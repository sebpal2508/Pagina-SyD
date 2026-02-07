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

    function showToast(message) {
        if (!message) return;
        const existing = document.getElementById('toast-notification');
        if (existing) {
            existing.remove();
        }

        const toast = document.createElement('div');
        toast.id = 'toast-notification';
        toast.className =
            'fixed bottom-5 left-1/2 -translate-x-1/2 translate-y-2 opacity-0 bg-gray-800 text-white px-6 py-3 rounded-lg shadow-2xl flex items-center gap-3 z-[99999] transition-all duration-300';
        toast.innerHTML =
            '<svg aria-hidden="true" class="w-5 h-5 text-green-400" viewBox="0 0 24 24" fill="currentColor">' +
            '<path d="M9 16.2l-3.5-3.5-1.4 1.4L9 19 20.3 7.7l-1.4-1.4z" />' +
            '</svg>' +
            '<span class="text-sm font-medium">' + message + '</span>';

        document.body.appendChild(toast);

        requestAnimationFrame(() => {
            toast.classList.remove('opacity-0', 'translate-y-2');
            toast.classList.add('opacity-100', 'translate-y-0');
        });

        setTimeout(() => {
            toast.classList.remove('opacity-100', 'translate-y-0');
            toast.classList.add('opacity-0', 'translate-y-2');
            setTimeout(() => toast.remove(), 300);
        }, 3000);
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
    window.showToast = showToast;
})();
