---
title: 'Create a mbtiles file from JAXA aw3d30 elevation images'
date: '21-03-2021 08:21'
visible: true
---

### References

[https://vespucci.io/tutorials/custom\_imagery\_mbtiles/](https://vespucci.io/tutorials/custom_imagery_mbtiles/)  
[https://www.northrivergeographic.com/archives/building-mbtile-fulcrum](https://vespucci.io/tutorials/custom_imagery_mbtiles/)  
[https://github.com/clhenrick/gdal\_hillshade\_tutorial](https://github.com/clhenrick/gdal_hillshade_tutorial)  
<https://gis.stackexchange.com/questions/255537/merging-hillshade-dem-data-into-color-relief-single-geotiff-with-qgis-and-gdal>  
<https://www.kreidefossilien.de/en/miscellaneous/custom-hillshading-for-osmand>  
<https://blog.mapbox.com/using-tilemills-raster-colorizer-e7600fd42dd9>  
<https://gis.stackexchange.com/questions/233297/how-to-create-transparent-tif-images-using-gdal>  
<https://snyk.io/advisor/python/gdal2mbtiles>  
[https://www.eorc.jaxa.jp/ALOS/aw3d30/aw3d30\_srtmhgt.zip](https://www.eorc.jaxa.jp/ALOS/aw3d30/aw3d30_srtmhgt.zip)

### How to build the map

Project: [https://github.com/acalcutt/jaxa\_AW3D30\_to\_MBTiles/](https://github.com/acalcutt/jaxa_AW3D30_to_MBTiles/)

1.) From Jaxa, "To download the data files, you are kindly requested to make your account in the AW3D30 homepage." Go to https://www.eorc.jaxa.jp/ALOS/en/aw3d30/index.htm and register for an account.

2.) Download every zip you would like to make from https://www.eorc.jaxa.jp/ALOS/en/aw3d30/data/index.htm . I did this in a low tech way. I got the url for each square. each square has a xml file that contains the downloads, which is in similar format to the of the square url. with some string replacement to get the xml from the url. then I downloaded all the xml files and merged them into one big file. i then used a webside that would strip urls from text (very low tech)

3.) Extract all the zip files and copy all the \_DSM.tif files into a directory

4.) Use gdal to create a mbtiles file from all the images

`gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*_DSM.tif<br></br>`  
`gdal_translate ${vrtfile} ${mbtilesfile} -of MBTILES<br></br>`  
`gdaladdo ${mbtilesfile} 2 4 8 16 32 64 128 256 512 1024`

<div style="border: 1px solid #ddd; margin-bottom: 20px; padding: 10px; background-color: #f9f9f9;">
	<div style="font-weight: bold; text-align: center;">Advertisement</div>
	<div class="adsense-content" style="margin-top: 5px; text-align: center;">
        [adsense id="unique-id"][/adsense]
    </div>
</div>'