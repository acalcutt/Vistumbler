// Main site JS: handles sidebar toggle, accessibility, and small helpers
$(function() {
    $('.bt-menu-trigger').attr('role','button').attr('aria-controls','sidebar').attr('aria-expanded','false').attr('tabindex','0');
    $('.bt-menu-trigger').on('click', function () {
        $('#sidebar').toggleClass('active');
        $('.main').toggleClass('active');
        $('.foot').toggleClass('active');
        $(this).toggleClass('bt-menu-alt');
        var expanded = $(this).attr('aria-expanded') === 'true';
        $(this).attr('aria-expanded', (!expanded).toString());
    });
    $('.bt-menu-trigger').on('keypress', function (e) {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); $(this).trigger('click'); }
    });

    // Highlight current page in sidebar (works with subfolders)
    // Disabled by default unless a page explicitly opts in by adding
    // data-enable-current="true" to the <body> or #sidebar element.
    try {
        var enableHighlight = ($('#sidebar').data('enable-current') === true) || ($('body').data('enable-current') === true);
        if (enableHighlight) {
            var currentFileName = (window.location.pathname.split('/').pop() || 'index.html').split(/[?#]/)[0].toLowerCase();
            $('#sidebar a').removeClass('current-page');
            $('#sidebar a').each(function () {
                var href = ($(this).attr('href') || '').split(/[?#]/)[0];
                try {
                    var url = new URL(href, window.location.href);
                    // Only highlight same-origin pages (skip external links)
                    if (url.origin !== window.location.origin) return;
                    var linkFile = (url.pathname.split('/').pop() || 'index.html').toLowerCase();
                    if (linkFile === currentFileName) {
                        $(this).addClass('current-page');
                    }
                } catch (err) {
                    // Fallback to simple basename check
                    var linkFile = (href.split('/').pop() || 'index.html').toLowerCase();
                    if (linkFile === currentFileName) $(this).addClass('current-page');
                }
            });
        }
    } catch (e) {
        // fail silently
    }

    // Copy-to-clipboard helper used by donate pages. Exposed on window
    window.copyText = function(inputClass) {
        try {
            var addressInput = document.querySelector('.' + inputClass);
            if (!addressInput) return;
            var addressValue = addressInput.value || addressInput.getAttribute('value') || '';
            navigator.clipboard.writeText(addressValue);
            var messageDiv = addressInput.parentElement && addressInput.parentElement.querySelector('.copy-message');
            if (messageDiv) {
                messageDiv.innerText = 'Address Copied!';
                setTimeout(function() { messageDiv.innerText = ''; }, 1500);
            }
        } catch (err) {
            console.error('copyText error', err);
        }
    };
    
    // Ad-block / donate fallback fail-safe: if Google ads render no height after 2s,
    // show the donate fallback images so users see a call-to-action.
    try {
        setTimeout(function() {
            try {
                var ads = document.querySelectorAll('ins.adsbygoogle');
                if (!ads || ads.length === 0) return;
                var anyVisible = Array.prototype.slice.call(ads).some(function(el) {
                    return (el.offsetHeight || el.clientHeight) > 0;
                });
                if (!anyVisible) {
                    var right = document.getElementById('donate-fallback-right');
                    var wide = document.getElementById('donate-fallback-wide');
                    if (right) right.style.display = 'block';
                    if (wide) wide.style.display = 'block';
                }
            } catch (e) { /* silent */ }
        }, 2000);
    } catch (e) { }
});
