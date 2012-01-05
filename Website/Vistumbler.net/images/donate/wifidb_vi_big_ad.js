if ("http:" == document.location.protocol) 
{
	/* Show Vistumbler Ad (Vistumbler Bottom 1) */
	google_ad_client = "pub-4275640341473005";
	google_ad_slot = "5223071023";
	google_ad_width = 728;
	google_ad_height = 90;
	document.write('<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>');
}
else
{
	/* Show Vistumbler Donate Image */
	document.write('<a class="img" href = "https://www.chipin.com/contribute/id/69d6e4742ac0f255"><img src="https://www.vistumbler.net/images/donate/donate-vi_300x200.png" alt="Donate to Vistumbler"></a>');
}