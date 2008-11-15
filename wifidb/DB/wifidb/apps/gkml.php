<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Google Maps JavaScript API Example: Simple Icon</title>
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAyA5XButiBc9xaUO2uiO0-hTeA16-_lTpBPaJVXP3DDMjUgllpRSDuP5M264SN9dlhYsISr-8ufcarw"
            type="text/javascript"></script>
    <script type="text/javascript">

    function initialize() 
	{
    if (GBrowserIsCompatible())
	{
        var map = new GMap2(document.getElementById("map_canvas"));
        map.setCenter(new GLatLng(<?php echo $lat;?>, <?php echo $long;?>), 13);
        map.addControl(new GSmallMapControl());
        map.addControl(new GMapTypeControl());

        // Create our "tiny" marker icon
        var blueIcon = new GIcon(G_DEFAULT_ICON);
        blueIcon.image = "http://gmaps-samples.googlecode.com/svn/trunk/markers/blue/blank.png";

		// Set up our GMarkerOptions object
		markerOptions = { icon:blueIcon };

        // Add 10 markers to the map at random locations
        var bounds = map.getBounds();
        var southWest = bounds.getSouthWest();
        var northEast = bounds.getNorthEast();
        var lngSpan = northEast.lng() - southWest.lng();
        var latSpan = northEast.lat() - southWest.lat();
        for (var i = 0; i < 10; i++) 
		{
          var latlng = new GLatLng(southWest.lat() + latSpan * Math.random(), southWest.lng() + lngSpan * Math.random());
          map.addOverlay(new GMarker(latlng, markerOptions));
        }
      }
    }

    </script>
  </head>
  <body onload="initialize()" onunload="GUnload()">
    <div id="map_canvas" style="width: 500px; height: 300px"></div>
  </body>
</html>
