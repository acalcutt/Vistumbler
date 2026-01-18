---
title: 'Migrate data away from Plone 5 and Zope 4 to Grav'
media_order: plone_extract_grav.zip
visible: true
---

I have been using Plone since 2007, but I have always founds upgrade with it to be painful. I decided i finally wanted to move away from it and  I wanted to get my images and files out of my Plone 5 site and migrate it to something new. I decided to move my website to Grav, because I was sick of the python or database backends and just wanted something more like flat files with templates.

To start the migrations I created a python script that would go through my Zope and Plone instances and Export files. Working with Google AI we created this script that exports files, images, and documents into flat files and a json file that listed all the data information. You can download a cope here: [plone_extract_grav.zip](plone_extract_grav.zip)

The steps to extract the data using this script
1. Place the 'plone_extract_grav.py' file into your zinstace folder (in my case this was '/opt/Plone_5-2-11/zinstance')
2. Stop your plone/zope instance
3. In command line, browse to you zinstance folder
4. run 'bin/instance run plone_extract_grav.py'
5.) the script will go though all your plone instance and export them to the 'plone_export' folder. In  'plone_export' there should be a folder for each site. and in each site folder is a json file, folder of image, and folder of files.

<div style="border: 1px solid #ddd; margin-bottom: 20px; padding: 10px; background-color: #f9f9f9;">
	<div style="font-weight: bold; text-align: center;">Advertisement</div>
	<div class="adsense-content" style="margin-top: 5px; text-align: center;">
        [adsense id="unique-id"][/adsense]
    </div>
</div>'
