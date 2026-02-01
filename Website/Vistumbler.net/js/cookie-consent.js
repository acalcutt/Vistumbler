(function(){
    'use strict';
    var COOKIE_NAME = 'vi_cookie_consent';
    var EU_COUNTRIES = [
        'AT','BE','BG','HR','CY','CZ','DK','EE','FI','FR','DE','GR','HU','IS','IE','IT','LV','LI','LT','LU','MT','NL','NO','PL','PT','RO','SK','SI','ES','SE'
    ];

    function readConsent(){
        var m = document.cookie.match(new RegExp('(?:^|; )'+COOKIE_NAME+'=([^;]*)'));
        if(!m) return null;
        try{ return JSON.parse(decodeURIComponent(m[1])); }catch(e){return null;}
    }
    function writeConsent(obj){
        var v = encodeURIComponent(JSON.stringify(obj));
        var expires = new Date(); expires.setFullYear(expires.getFullYear()+1);
        document.cookie = COOKIE_NAME+'='+v+'; path=/; expires='+expires.toUTCString();
    }

    function loadAdsScript(){
        if(window._vi_ads_loaded) return;
        window._vi_ads_loaded = true;
        var s = document.createElement('script');
        s.async = true;
        s.src = '//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js';
        (document.head || document.documentElement).appendChild(s);
        s.onload = function(){
            try{ (adsbygoogle = window.adsbygoogle || []).push({}); }catch(e){}
        };
    }

    function applyConsentState(cons){
        // cons: {ad_storage, analytics_storage, ad_user_data, ad_personalization}
        try{
            if(window.gtag) {
                var gCons = {};
                if('ad_storage' in cons) gCons.ad_storage = cons.ad_storage;
                if('analytics_storage' in cons) gCons.analytics_storage = cons.analytics_storage;
                if('ad_user_data' in cons) gCons.ad_user_data = cons.ad_user_data;
                if('ad_personalization' in cons) gCons.ad_personalization = cons.ad_personalization;
                window.gtag('consent','update', gCons);
                if(cons.ad_storage === 'denied'){
                    window.gtag('set','ads_data_redaction', true);
                }
            }
        }catch(e){}

        // Load or block ads script depending on ad_storage
        if(cons.ad_storage === 'granted'){
            loadAdsScript();
        }
    }

    function setConsentAndClose(cons){
        writeConsent(cons);
        applyConsentState(cons);
        var el = document.getElementById('vi-cookie-banner'); if(el) el.remove();
    }

    function showBanner(defaults){
        if(document.getElementById('vi-cookie-banner')) return;
        var div = document.createElement('div');
        div.id = 'vi-cookie-banner';
        div.style = 'position:fixed; left:0; right:0; bottom:0; background:#fff; border-top:1px solid #ccc; padding:14px; z-index:9999; font-family:Arial,Helvetica,sans-serif;';
        div.innerHTML = '\n            <div style="max-width:1000px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;">\n                <div style="flex:1;min-width:260px">\n                    <strong>Cookie choices</strong> — We use cookies for essential site functions, analytics, and advertising. You can accept all, reject non-essential cookies, or choose specific settings.\n                </div>\n                <div style="flex:0 0 auto;">\n                    <button id="vi-consent-accept" style="margin-right:8px;padding:8px 12px;">Accept all</button>\n                    <button id="vi-consent-reject" style="margin-right:8px;padding:8px 12px;">Reject all</button>\n                    <button id="vi-consent-settings" style="padding:8px 12px;">Settings</button>\n                </div>\n            </div>\n            <div id="vi-consent-modal" style="display:none;padding-top:12px;">\n                <label style="display:block;margin-bottom:6px"><input type=checkbox id=vi-toggle-analytics> Allow analytics cookies</label>\n                <label style="display:block;margin-bottom:6px"><input type=checkbox id=vi-toggle-personal> Allow ad personalization</label>\n                <div style="margin-top:8px">\n                    <button id="vi-consent-save" style="margin-right:8px;padding:8px 12px;">Save</button>\n                    <button id="vi-consent-cancel" style="padding:8px 12px;">Cancel</button>\n                </div>\n            </div>';
        document.body.appendChild(div);
        document.getElementById('vi-consent-accept').addEventListener('click', function(){
            setConsentAndClose({ad_storage:'granted', analytics_storage:'granted', ad_user_data:'granted', ad_personalization:'granted'});
        });
        document.getElementById('vi-consent-reject').addEventListener('click', function(){
            setConsentAndClose({ad_storage:'denied', analytics_storage:'denied', ad_user_data:'denied', ad_personalization:'denied'});
        });
        document.getElementById('vi-consent-settings').addEventListener('click', function(){
            document.getElementById('vi-consent-modal').style.display = 'block';
            var an = document.getElementById('vi-toggle-analytics');
            var per = document.getElementById('vi-toggle-personal');
            if(defaults){
                an.checked = (defaults.analytics_storage === 'granted');
                per.checked = (defaults.ad_personalization === 'granted');
            }
        });
        document.getElementById('vi-consent-save').addEventListener('click', function(){
            var an = document.getElementById('vi-toggle-analytics').checked;
            var per = document.getElementById('vi-toggle-personal').checked;
            var cons = {
                ad_storage: per ? 'granted' : 'denied',
                analytics_storage: an ? 'granted' : 'denied',
                ad_user_data: per ? 'granted' : 'denied',
                ad_personalization: per ? 'granted' : 'denied'
            };
            setConsentAndClose(cons);
        });
        document.getElementById('vi-consent-cancel').addEventListener('click', function(){
            var el = document.getElementById('vi-cookie-banner'); if(el) el.remove();
        });
    }

    function isEuCountry(code){
        if(!code) return false;
        return EU_COUNTRIES.indexOf(code.toUpperCase()) !== -1;
    }

    function determineAndMaybeShow(){
        var existing = readConsent();
        if(existing){
            applyConsentState(existing);
            return;
        }
        // Try to detect country via ipapi.co; conservative: if failure, show banner
        fetch('https://ipapi.co/json/').then(function(r){ return r.json(); }).then(function(j){
            var cc = j && (j.country || j.country_code || j.country_code_iso3) ? (j.country || j.country_code) : null;
            if(isEuCountry(cc) || !cc){
                showBanner({analytics_storage:'denied', ad_personalization:'denied'});
            } else {
                // Non-EU default: grant consent for ads/analytics (you may change this behavior)
                var cons = {ad_storage:'granted', analytics_storage:'granted', ad_user_data:'granted', ad_personalization:'granted'};
                writeConsent(cons);
                applyConsentState(cons);
            }
        }).catch(function(){
            // On error, show banner to be safe
            showBanner({analytics_storage:'denied', ad_personalization:'denied'});
        });
    }

    // Run early
    if(document.readyState === 'loading'){
        determineAndMaybeShow();
    } else {
        determineAndMaybeShow();
    }

})();
