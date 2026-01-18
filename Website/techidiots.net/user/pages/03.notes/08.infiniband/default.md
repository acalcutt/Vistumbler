---
title: 'Setup Infiniband in ESX 5.5'
date: '22-01-2015 14:42'
visible: true
---

**Reference Documents**
-----------------------

<http://www.bussink.ch/?p=1306> (most of these commands came from here, but several have been fixed)  
<http://www.hypervisor.fr/?p=4662> ([translated to English](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0CCQQ7gEwAA&url=http%3A%2F%2Ftranslate.google.com%2Ftranslate%3Fhl%3Den%26sl%3Dfr%26u%3Dhttp%3A%2F%2Fwww.hypervisor.fr%2F%253Fp%253D4662%26prev%3Dsearch&ei=KkTBVPTCIMqpyASiwYGIAw&usg=AFQjCNFliMTW9E3-vNSvxATNKWOu23QEmA&bvm=bv.83829542,d.aWw "Translated to English"))  
<https://vibsdepot.v-front.de/wiki/index.php/Ib-opensm>  
[http://www.mellanox.com/page/products\_dyn?product\_family=36&amp;menu\_section=34](http://www.mellanox.com/page/products_dyn?product_family=36&amp;menu_section=34)  
[http://www.mellanox.com/page/management\_tools](http://www.mellanox.com/page/management_tools)  
[http://www.mellanox.com/pdf/MFT/MFT\_VMware\_readme\_2\_7\_1.pdf](http://www.mellanox.com/pdf/MFT/MFT_VMware_readme_2_7_1.pdf)

<span>**Downloads**</span>
--------------------------

[ib-opensm-x64-3.3.15-6.x86_64.zip](ib-opensm-x64-3.3.15-6.x86_64.zip)  
[mlnx-mft-2.7.1-1.zip](mlnx-mft-2.7.1-1.zip)  
[MLNX-MST-ESX-2.0.0.0.zip](MLNX-MST-ESX-2.0.0.0.zip)  
[MLNX-OFED-ESX-1.8.2.4-10EM-500.0.0.472560.zip](MLNX-OFED-ESX-1.8.2.4-10EM-500.0.0.472560.zip)  
[mlx4_en-mlnx-1.6.1.2-471530.zip](mlx4_en-mlnx-1.6.1.2-471530.zip)  

**Remove Mellanox 1.9.7 driver from ESXi 5.5**
----------------------------------------------

 <span>esxcli software vib remove -n=net-mlx4-en -n=net-mlx4-core  
</span><span>reboot</span>

<span>**Install Mellanox 1.61 drivers, OFED, and OpenSM, MFT Tools**</span>
---------------------------------------------------------------------------

<span> </span><span>Copy files from \*Downloads\* to /tmp  
</span><span>cd /tmp  
</span><span>**--- Install 1.6.1 driver ---**  
</span><span>unzip mlx4\_en-mlnx-1.6.1.2-471530.zip  
</span><span>esxcli software acceptance set --level=CommunitySupported  
</span><span>esxcli software vib install -d /tmp/mlx4\_en-mlnx-1.6.1.2-offline\_bundle-471530.zip --no-sig-check  
</span><span>**--- Install OFED ---**   
</span><span>esxcli software vib install -d /tmp/MLNX-OFED-ESX-1.8.2.4-10EM-500.0.0.472560.zip --no-sig-check  
</span><span>**--- Install OpenSM ---**   
</span><span>esxcli software vib install -v /tmp/ib-opensm-x64-3.3.15-6.x86\_64.vib --no-sig-check  
</span><span>**--- Optional - Install MFT Tools ---**  
</span><span>esxcli software vib install -v /tmp/mlnx-mft-2.7.1-1.vib --no-sig-check  
</span><span>esxcli software vib install -d /tmp/MLNX-MST-ESX-2.0.0.0.zip --no-sig-check  
</span><span>**--- Reboot to apply newly installed packages**  
</span><span>reboot</span>

**Set MTU and Configure OpenSM**
--------------------------------

**--- Enable 4k MTU ---** <span>esxcli system module parameters set -m=mlx4\_core -p=mtu\_4k=1  
</span><span>**--- Set up opensm ---**  
cd /tmp  
</span><span>echo "Default=0x7fff,ipoib,mtu=5:ALL=full;" &gt; partitions.conf  
cp partitions.conf /scratch/opensm/&lt;adapter\_1\_hca&gt;/  
cp partitions.conf /scratch/opensm/&lt;adapter\_2\_hca&gt;/</span>

<span>**Optional - Load / Unload the MFT Tools mst driver**</span>
------------------------------------------------------------------

<div id="_mcePaste">**--- load the mst driver ---**</div><div>vmkload_mod mst  
**--- unload the mst driver ---** </div><div id="_mcePaste">vmkload_mod -u mst</div><span>  
</span>