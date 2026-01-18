---
title: Donate
media_order: 'qr-code-dynamic (1).png,donate_paypal.png,qr-code-dynamic.png,eth.png,bitcoin.png'
---

<div class="donate-page">
  Help support TechIdiots, Vistumbler, and WifiDB projects and development. Any contributions are appreciated. -Andrew Calcutt

  <h3>Donate with Paypal</h3>
  <br />
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JZRGSY2S4J6MC">
     <img src="https://techidiots.net/donate/donate_paypal.png" alt="Donate with Paypal">
  </a>

  <h3>Donate with Cryptocurrency</h3>
    <br />
    <br />
    <div class="donate-item">
        <br />
        <br />
        <div class="image-container">
             <img class="qr-code" src="https://techidiots.net/donate/bitcoin.png" alt="QR Code for BTC"/>
        </div>
        <div class="address-with-box">
           <div class="address-container">
                <h3>BTC Address</h3>
                <div class="address-box">
                    <input type="text" class="address-input btc-address-input" value="bc1qrggspyz0v9ex9fys85u0vethkjcluklrtj3fzd" readonly>
                    <button class="copy-button" onclick="copyText('btc-address-input')">Copy</button>
                    <div class="copy-message" id="btc-copy-message"></div>
                </div>
            </div>
        </div>
    </div>
       <br />
       <br />
       <div class="donate-item">
          <div class="image-container">
             <img class="qr-code" src="https://techidiots.net/donate/eth.png" alt="QR Code for ETH"/>
        </div>
      <div class="address-with-box">
         <div class="address-container">
            <h3>ETH Address</h3>
             <div class="address-box">
                <input type="text" class="address-input eth-address-input" value="0x8253AA00C46f6f2b171BB3FA7512Da31dCdE0A21" readonly>
                <button class="copy-button" onclick="copyText('eth-address-input')">Copy</button>
                 <div class="copy-message" id="eth-copy-message"></div>
             </div>
         </div>
        </div>
    </div>
{% raw %}
    <script>
        function copyText(inputClass) {
            const addressInput = document.querySelector("." + inputClass);
            const addressValue = addressInput.value;
             navigator.clipboard.writeText(addressValue)
              const messageDiv = addressInput.parentElement.querySelector(".copy-message");
            messageDiv.innerText = 'Address Copied!';
           setTimeout(function() { messageDiv.innerText = ''; }, 1500);
        }
    </script>
{% endraw %}