---
title: 'Create a ESRI Satellite mbtiles base map with QGIS and QTiles'
date: '04-04-2023 10:13'
media_order: 'qgis.png,qgis_ersi-map.png,qtiles.png'
visible: true
---

References
----------

[https://www.qgistutorials.com/en/docs/creating\_basemaps\_with\_qtiles.html  ](https://www.qgistutorials.com/en/docs/creating_basemaps_with_qtiles.html)[https://ieqgis.wordpress.com/2014/08/09/adding-esris-online-world-imagery-dataset-to-qgis/  ](https://ieqgis.wordpress.com/2014/08/09/adding-esris-online-world-imagery-dataset-to-qgis/)<https://gis.stackexchange.com/questions/50646/is-there-any-way-to-use-mbutil-on-windows>

Instructions
------------

1.) Install [QGIS 2.18.22](https://qgis.org/downloads/) (newer versions do not support the qtiles plugin)

2.) In QGIS Desktop, add the Qtiles plugin (Plugins --&gt; Manage and install plugins)

3.) In QGIS, open the python console (<span>Plugins --&gt; python console)</span>

4.) In the python console, load the World\_Imagery raster map with "qgis.utils.iface.addRasterLayer("http://services.arcgisonline.com/ArcGIS/rest/services/World\_Imagery/MapServer?f=json&amp;pretty=true","raster")" or the ESRI\_Imagery\_World\_2D raster map with "qgis.utils.iface.addRasterLayer("http://server.arcgisonline.com/arcgis/rest/services/ESRI\_Imagery\_World\_2D/MapServer?f=json&amp;pretty=true","raster")"

[gallery]
![qgis_ersi-map](qgis_ersi-map.png "qgis_ersi-map")
[/gallery]

5.) Open QTiles (Plugins --&gt; <span> QTiles --&gt; <span> QTiles ), set destination folder, set extent to the map raster layer, and set the zoom levels you would like to map (note that the higher zoom levels use more disk space. layer 0-9 used 17GB of disk space, and each additional zoom level uses about 4 times more space.) (note you can export directly to mbtiles, but I am downloading to folder so i can download in batches and merge them later)</span></span>

[gallery]
![qtiles](qtiles.png "qtiles")
[/gallery]

6.) Use mbutil to create a mbtiles file from the qtiles output directory

\- Create a 'metadata.json' and add it to the image directory (ex C:\\tiles\\ESRI\\)

 {  
<span> </span>"name": "ESRI\_0-9",  
<span> </span>"description": "Created with QTiles and mbutil",  
<span> </span>"format": "png",  
<span> </span>"minZoom": "0",  
<span> </span>"maxZoom": "9",  
<span> </span>"type": "baselayer",  
<span> </span>"version": "1.1",  
<span> </span>"bounds": "-180.0,-85.0511287798,180.0,85.0511287798",  
<span> </span>"attribution": "&lt;a href=\\"http://www.arcgis.com/home/item.html?id=10df2279f9684e4a9f6a7f08febac2a9\\" target=\\"\_blank\\"&gt;&amp;copy; ERSI&lt;/a&gt;"  
<span> </span>}

<span> - Run mb-util import</span>

<span> mb-util.py --do\_compression C:\\tiles\\ESRI C:\\ESRI\_0-9.mbtiles</span>

<div style="border: 1px solid #ddd; margin-bottom: 20px; padding: 10px; background-color: #f9f9f9;">
	<div style="font-weight: bold; text-align: center;">Advertisement</div>
	<div class="adsense-content" style="margin-top: 5px; text-align: center;">
        [adsense id="unique-id"][/adsense]
    </div>
</div>'