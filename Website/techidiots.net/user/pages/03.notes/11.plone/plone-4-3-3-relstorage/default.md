---
title: 'Plone 4.3.3 - Relstorage'
date: '20-05-2014 22:35'
visible: true
---

Background
----------

These are my notes for using Relstorage with Plone 4.3.3. My reason for doing this is I wanted to have a live copy of my plone site on a separate server. I wanted things put into one plone site to show up on the other (and vice-versa). This is hard to do with the default plone setup because 'data.fs' is large and plone needs to be restarted when copied it over.

In my searches for a solution I found RelStorage. Relstorage allows you to store you blob data in a mysql database instead of 'data.fs'. Once that data is in mysql, it is easy to replicate between servers with Multi-Master replication (like [mariadb galera](../mysql/3-node-mariadb-galera-cluster-debian-7)).

Reference Documents
-------------------

[http://shane.willowrise.com/archives/how-to-install-plone-with-relstorage-and-mysql/  ](http://shane.willowrise.com/archives/how-to-install-plone-with-relstorage-and-mysql/)[http://docs.silvacms.org/2.3/cluster/relstorage.html  ](http://docs.silvacms.org/2.3/cluster/relstorage.html)[http://plone.org/documentation/faq/plone-backup-move  ](http://plone.org/documentation/faq/plone-backup-move)[https://mail.zope.org/pipermail/zodb-dev/2012-April/014630.html  
https://pypi.python.org/pypi/RelStorage  ](https://mail.zope.org/pipermail/zodb-dev/2012-April/014630.html)<span>  
</span>

Issues I had setting up RelStorage
----------------------------------

<span>1.) Based on previous directions I thought I needed to patch ZODB files for RelStorage. I have since found out that starting in ZODB 3.9 a patch is no longer needed.</span>

<span>2.) On my first attempt I kept getting a Temporary Directory error. The error I was getting was "Error Value: 'NoneType' object has no attribute 'temporaryDirectory'". Eventually I found it was because I was not specifying 'blob-dir' in 'zinstance\\buildout.cfg' (see below).</span>

Instructions
------------

\*note\* my plone directory is '/opt/PloneRep-4-3-3/'. Replace this with your plone path in in the instuctions below.

**1.)** edit 'zinstance/buildout.cfg'.

\--Under \[buildout\], add the following eggs--

 ```
eggs =<br></br>    Plone<br></br>    Pillow<br></br>    RelStorage<br></br>    MySQL-python
```

\--Under \[instance\], add the following--

 ```
[instance]<br></br>rel-storage =<br></br>    type mysql<br></br>    host 127.0.0.1<br></br>    db plone<br></br>    user ploneuser<br></br>    passwd supersecretpw<br></br>    shared-blob-dir false<br></br>    blob-dir /opt/PloneRep-4-3-3/zinstance/var/blobstorage<br></br>    blob-cache-size 10mb
```

\-- Add to the end of buildout.cfg to get zodbconvert tool --

 ```
[zopepy]<br></br>scripts = zopepy zodbconvert<br></br> <br></br>[zodbconvert]<br></br>recipe = zc.recipe.egg<br></br>eggs = ${buildout:eggs}<br></br>scripts = zodbconvert
```

**2.)** Run the plone buildout

\*note\* buildout may fail if libmysqlclient-dev or libmariadbclient-dev are not installed

 ```
cd /opt/PloneRep-4-3-3/zinstance<br></br>sudo -u plone_buildout bin/buildout 
```

**3.)** If you just want a blank plone site you are done at this point. Start plone with 'bin/plonectl fg' to verify there are no errors. If you want to convert an existing plone site...continue to the next step.

**4.)** Create a settings xml file for zodbconvert

\*note\* my data source is my old plone directory, /opt/Plone-4-3-3/ . This is converting data.fs and FileStorage in the 'bushy' format.

/opt/PloneRep-4-3-3/zinstance/conv.xml

 ```
<filestorage source><br></br>  path /opt/Plone-4-3-3/zinstance/var/filestorage/Data.fs<br></br>  blob-dir /opt/Plone-4-3-3/zinstance/var/blobstorage<br></br></filestorage><br></br> <br></br><relstorage destination><br></br>  shared-blob-dir false<br></br>  # ZODB Cache Dir<br></br>  blob-dir ./var/blobstorage<br></br>  blob-cache-size 10mb<br></br>  <mysql><br></br>    host 127.0.0.1<br></br>    db plone<br></br>    user ploneuser<br></br>    passwd supersecretpw<br></br>  </mysql><br></br></relstorage>
```

 **5.)** Run zodbconvert

 ```
cd /opt/PloneRep-4-3-3/zinstance<br></br>bin/zodbconvert --clear /opt/PloneRep-4-3-3/zinstance/conv.xml
```

**6.)** If the conversion goes successfully, this is a good time to make a backup of your new plone mysql database (I know I used my backup a few times in getting this all working)

**7.)** you should now be ready to start plone. start it with 'plonectl fg' to make sure there are no errors.