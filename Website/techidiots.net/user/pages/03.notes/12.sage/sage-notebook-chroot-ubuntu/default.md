---
title: 'Sage Notebook - chroot  - ubuntu/debian'
date: '05-07-2011 09:25'
visible: true
media_order: sage_init_files.zip
---

**Reference Docs (Most of the commands came from the pages below)**

<http://www.sagemath.org/doc/installation/source.html> **(Guide to install sage from source)**  
<http://sage.math.washington.edu/tmp/sage-2.8.12.alpha0/doc/inst/node10.html> **(Guide to chroot sage)**  
[http://wiki.cs.earlham.edu/index.php/Cluster:\_Sage\_Chroot](http://wiki.cs.earlham.edu/index.php/Cluster:_Sage_Chroot) **(another guide on setting up sage in chroot. Also includes scripts to start sage silently)**  
<http://groups.google.com/group/sage-support/msg/849e906146b41d28?pli=1> (**support thread with steps taken for chrooting sage**)  
<https://help.ubuntu.com/community/BasicChroot> **(Guide to create a basic chroot in ubuntu)**  
<https://wiki.ubuntu.com/DebootstrapChroot> **(Guide on debootstrap, used by cage chroot instructions)**  
<http://manpages.ubuntu.com/manpages/hardy/man5/schroot.conf.5.html> **(Basic schroot.conf info)**

Set up sage chroot environment
------------------------------

**1.)Make sure you have all the sage source requirements**

apt-get install build-essential gfortran  
apt-get install texlive xpdf evince # Note: The sage site says to also install xdvi here, but ubuntu did not find it and I didn't install it.  
apt-get install tk8.5-dev # or the latest version available  
apt-get install dvipng

**2.) Install the chroot requirements**

apt-get install dchroot debootstrap

**3.) Create Sage chroot directory. I used /sage\_chroot/**

mkdir /sage\_chroot

**4.) create sage chroot user**

adduser sageserver

**5.) open /etc/schroot/schroot.conf and add the following.**

\[sage\]  
description=Sage Server  
location=/sage\_chroot  
priority=3  
users=sageserver  
groups=sageserver  
root-groups=root

**6.) Create basic chroot files with debootstrap**

\#Ubuntu 9.10  
debootstrap --variant=minbase --arch i386 karmic /sage\_chroot/ http://archive.ubuntu.com/ubuntu/  
  
\#Debian 6  
debootstrap --variant=minbase --arch i386 squeeze /sage\_chroot/ http://ftp.debian.org/debian/

**7.)Set up networking and package sources in the chroot environment**

cp /etc/resolv.conf /sage\_chroot/etc/resolv.conf  
cp /etc/apt/sources.list /sage\_chroot/etc/apt/

**8.) Configure chroot environment**

chroot /sage\_chroot/  
apt-get update  
\#add sageserver user that will run sage  
useradd sageserver  
\*modify chroot /etc/passwd so sageserver user UID matches normal /etc/passwd  
\#Set up authbind so sage can bind to port 443  
apt-get install authbind  
touch /etc/authbind/byport/443  
chmod 500 /etc/authbind/byport/443  
chown sageserver /etc/authbind/byport/443  
\#Install ImageMagick for sage animate()  
apt-get --no-install-recommends install imagemagick

\#whats below was commented out because it is not needed  
\#apt-get --no-install-recommends install wget debconf devscripts gnupg vim #For package-building  
\#apt-get update #clean the gpg error message  
\#apt-get install locales dialog #If you don't talk en\_US  
\#locale-gen en\_GB.UTF-8 # or your preferred locale  
\#tzselect; TZ='Continent/Country'; export TZ #Configure and use our local time instead of UTC; save in .profile  
exit

**9.)Copy server home directory to chroot directory**

cp -rpvf /home/sageserver /sage\_chroot/home/  
rm -rf /home/sageserver/\*

**10.) edit /etc/fstab and add the following**

/tmp /sage\_chroot/tmp none bind 0 0  
/dev /sage\_chroot/dev none bind 0 0  
/sage\_chroot/home/sageserver /home/sageserver none bind 0 0  
proc-chroot /sage\_chroot/proc proc defaults 0 0  
devpts-chroot /sage\_chroot/dev/pts devpts defaults 0 0

**11.) run**

mount -a

**12.) edit /etc/dchroot.conf. add the following (this may be a new file)**

sage /sage\_chroot/

**13.) Now get SAGE and install it to the desired subdirectory of /sage\_chroot**

cd ~   
wget http://www.sagemath.org/dist/src/sage-x.y.z.tar  
cd /sage\_chroot  
tar xvf ~/sage-x.y.z.tar  
mv sage-x.y.z/ sage/  
cd sage  
make  
make clean

**14.) Set chroot permissions and make necessary changes**

\#remove write permissions from user group and other groups  
chmod og-w -R /sage\_chroot/\*

\#Fix /dev/null errors  
rm /sage\_chroot/dev/null  
mknod -m 666 /sage\_chroot/dev/null c 1 3

\#fix /sage\_chroot/tmp permission  
chmod 1777 /sage\_chroot/tmp

\#create sage files (sage will not have permission to write them later. make sure to replace /sage with the sage directroy in your chroot environment)  
echo &gt; /sage\_chroot/sage/local/lib/sage-flags.txt  
echo /sage &gt; /sage\_chroot/sage/local/lib/sage-current-location.txt  
  
\#give sageserver user rights to the .sage folder (this should not be needed.)  
chown -R sageserver:sageserver /home/sageserver/.sage  
  
\#Fix libgfortran.so.3 dependency error  
cp /usr/lib/libgfortran.so.3 /sage\_chroot/lib/

**15.) Switch to your chroor environment and test sage**

chroot /sage\_chroot/  
su - sageserver  
/sage/sage

**\*If all went well you should be at the sage prompt with no errors**

**Set sage server to run at statup with init.d** 
-------------------------------------------------

**So, Sage chroot is already set up. Now we need to create the init script and sage scripts to start sage in the background**

\#Copy the [sage_init_files.zip](sage_init_files.zip) into their proper folders. The following files are added  
/opt/sage/sage-config  
/opt/sage/sage-notebook  
/opt/sage/sage-killer  
/etc/init.d/sageserver

\#**Add sageserver to default runtime** update-rc.d sageserver defaults