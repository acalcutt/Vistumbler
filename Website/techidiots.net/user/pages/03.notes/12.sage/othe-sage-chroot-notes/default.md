---
title: 'othe sage chroot notes'
date: '04-07-2011 08:09'
visible: true
---

mount: Not a directory when mounting image file
-----------------------------------------------

I originally was following (http://sage.math.washington.edu/tmp/sage-2.8.12.alpha0/doc/inst/node10.html) but had issues at the following step

Then we add the line  
  
/sage\_chroot.image /sage\_chroot ext3 bind 0 0  
  
(Of course, the above values should be changed to reflect the directory location and filesystem type you chose previously.) Then finally to mount it we run:

$ sudo mount -a

Whenever I ran "mount -a" I was getting the error

mount: Not a directory

I eventually found this was because to mount a file with fstab you need to use the loop option instead of bind, like the following

/sage\_chroot.image /sage\_chroot ext3 loop 0 0

While this did seem to work, I didn't end up using a image file like that because none of the other chroot examples I read did it that way

Ubuntu 9.10 404 errors on apt-get
---------------------------------

**I had 404 errors from "sudo apt-get install texlive xpdf evince" in ubuntu 9.10. I installed the following packages manually then re-ran "sudo apt-get install texlive xpdf evince" to get around this.**

https://launchpad.net/ubuntu/karmic/i386/libpoppler5/0.12.0-0ubuntu2.3  
https://launchpad.net/ubuntu/karmic/i386/libpoppler-glib4/0.12.0-0ubuntu2.3  
https://launchpad.net/ubuntu/karmic/i386/libevdocument1/2.28.1-0ubuntu1.3  
https://launchpad.net/ubuntu/karmic/i386/libevview1/2.28.1-0ubuntu1.3  
https://launchpad.net/ubuntu/karmic/i386/evince/2.28.1-0ubuntu1.3