---
title: '3 node mariadb galera cluster, debian 7'
date: '18-05-2014 11:42'
visible: true
---

Reference Links
---------------

**Getting Started with MariaDB Galera Cluster** - <https://mariadb.com/kb/en/getting-started-with-mariadb-galera-cluster/>  
**Installing MariaDB Galera Cluster on Debian/Ubuntu** - <https://blog.mariadb.org/installing-mariadb-galera-cluster-on-debian-ubuntu/>  
**Galera Cluster Best Practices** - <http://www.percona.com/files/presentations/percona-live/nyc-2012/PLNY12-galera-cluster-best-practices.pdf>  
**Benchmarking Galera Cluster** - [http://linsenraum.de/erkules\_int/2014/01/](http://linsenraum.de/erkules_int/2014/01/)   
**Firewall Settings** - [http://galeracluster.com/documentation-webpages/firewallsettings.html  ](http://galeracluster.com/documentation-webpages/firewallsettings.html)**Email Notify Script**<span> - </span><span><https://github.com/gguillen/galeranotify></span>

Install Notes
-------------

**1.)** Add mariadb repository (https://downloads.mariadb.org/mariadb/repositories/#mirror=syringa)

**2.)** Install mariadb galera cluster

$ apt-get update  
$ apt-get install mariadb-galera-server galera

**3.)** Make sure the following ports are open between your nodes

<span>3306—MySQL client connections and mysqldump SST  
</span><span>4567—Galera Cluster replication traffic  
</span><span>4568—IST  
</span><span>4444—all SSTs besides mysqldump</span>

**4.)** Add the following to my.cnf on each host of the cluster.

**------------------------------Host 1----------------------------------**

\[mariadb\]  
wsrep\_cluster\_address = "gcomm://node2.foo.bar,node3.foo.bar"  
wsrep\_provider=/usr/lib/galera/libgalera\_smm.so  
wsrep\_sst\_auth=repuser:supersecretpw  
wsrep\_cluster\_name='cluster1'  
wsrep\_node\_name=node1  
wsrep\_node\_address=node1.foo.bar  
wsrep\_slave\_threads=8  
wsrep\_provider\_options="gcs.fc\_limit=512"  
<span>wsrep\_replicate\_myisam=1  
</span><span>wsrep\_notify\_cmd='/opt/galeranotify/galeranotify.py'   
  
</span><span>binlog\_format=ROW  
</span><span>default\_storage\_engine=InnoDB  
</span><span>innodb\_autoinc\_lock\_mode=2  
</span><span>innodb\_doublewrite=1  
</span><span>innodb\_flush\_log\_at\_trx\_commit=2  
</span><span>query\_cache\_size=0  
</span><span>log-error=/var/log/mysql.log</span>

**------------------------------Host 2----------------------------------**

\[mariadb\]  
wsrep\_cluster\_address = "gcomm://node1.foo.bar,node3.foo.bar"  
wsrep\_provider=/usr/lib/galera/libgalera\_smm.so  
wsrep\_sst\_auth=repuser:supersecretpw  
wsrep\_cluster\_name='cluster1'  
wsrep\_node\_name=node2  
wsrep\_node\_address=node2.foo.bar  
<span>wsrep\_slave\_threads=8</span>  
<span>wsrep\_provider\_options="gcs.fc\_limit=512"</span>  
<span>wsrep\_replicate\_myisam=1  
</span><span>wsrep\_notify\_cmd='/opt/galeranotify/galeranotify.py' </span>

binlog\_format=ROW  
default\_storage\_engine=InnoDB  
innodb\_autoinc\_lock\_mode=2  
innodb\_doublewrite=1  
innodb\_flush\_log\_at\_trx\_commit=2  
query\_cache\_size=0  
log-error=/var/log/mysql.log

**------------------------------Host 3----------------------------------**

\[mariadb\]  
wsrep\_cluster\_address = "gcomm://node2.foo.bar,node1.foo.bar"  
wsrep\_provider=/usr/lib/galera/libgalera\_smm.so  
wsrep\_sst\_auth=repuser:supersecretpw  
wsrep\_cluster\_name='cluster1'  
wsrep\_node\_name=node3  
wsrep\_node\_address=node3.foo.bar  
<span>wsrep\_slave\_threads=8</span>  
<span>wsrep\_provider\_options="gcs.fc\_limit=512"</span>  
<span>wsrep\_replicate\_myisam=1  
</span><span>wsrep\_notify\_cmd='/opt/galeranotify/galeranotify.py' </span>

binlog\_format=ROW  
default\_storage\_engine=InnoDB  
innodb\_autoinc\_lock\_mode=2  
innodb\_doublewrite=1  
innodb\_flush\_log\_at\_trx\_commit=2  
query\_cache\_size=0  
log-error=/var/log/mysql.log

 ****-----------------------------------------------------------------------****

**5.)** on the first node in the cluster (the server that has your current mysql database), start a new cluster using   
$ mysqld --wsrep-new-cluster

<span>**6.)** once the cluster has been started, start the other nodes. Start with "mysqld" to view what is happening, or use "service mysql start" and view the log at "<span>/var/log/mysql.log"</span>. </span>

<span>test</span>