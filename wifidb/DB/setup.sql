# RanInt WifiDB SQL file
# Ver: 1.0
# http://www.randomintervals.com
#
# WARNING: This script Drops both the Wifi_st and wifi DB's,
# 	   if you do not want to loose all your data, back it
#	   up and then run this scrip.
#
#
##############################################################

#
# Database : `wifi_st` (Used to store all the Access Point Signal and GPS Data)
# 

DROP DATABASE `wifi_st`;
CREATE DATABASE `wifi_st`;

# --------------------------------------------------------
# 
# Database : `wifi` (Used to store all the pointer records and settings)
# 

DROP DATABASE `wifi`;
CREATE DATABASE `wifi`;
USE wifi;

# --------------------------------------------------------

#
# Table structure for table `settings`
#


CREATE TABLE `settings` (
  `id` int(255) NOT NULL auto_increment,
  `table` varchar(25) NOT NULL,
  `size` int(254) default NULL,
  UNIQUE KEY `table` (`table`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

#
# Data for table `settings`
#

INSERT INTO `settings` (`id`, `table`, `size`) VALUES
(0, 'wifi0', 0);

#
# Table structure for table `settings`
#

 CREATE TABLE `users` (
`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,
`username` VARCHAR( 25 ) NOT NULL ,
`points` TEXT NOT NULL ,
`notes` TEXT NOT NULL ,
`title` varchar(32) NOT NULL ,
`date` varchar(25) NOT NULL ,
PRIMARY KEY ( `id` ) ,
INDEX ( `id` )
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

# --------------------------------------------------------

#
# Table structure for table `wifi0`
#

CREATE TABLE wifi0 (
  id int(255) default NULL,
  ssid varchar(25) NOT NULL,
  mac varchar(25) NOT NULL,
  chan varchar(2) NOT NULL,
  radio varchar(1) NOT NULL,
  auth varchar(25) NOT NULL,
  encry varchar(25) NOT NULL,
  KEY id (id) 
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

# --------------------------------------------------------

#
# Table structure for table `wifi0`
#
  
 CREATE TABLE `links` (
  `ID` int(255) NOT NULL auto_increment,
  `links` varchar(255) NOT NULL,
  KEY `INDEX` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

#
# Data for table `links`
#

INSERT INTO `links` (`ID`, `links`) VALUES
(1, '<a class="links" href="/$root/">Main Page</a>'),
(2, '<a class="links" href="/$root/all.php">View All AP\'s</a>'),
(3, '<a class="links" href="/$root/import/">Import AP\'s</a>'),
(4, '<a class="links" href="/$root/opt/userstats.php?func=usersall">View All Users</a>'),
(5, '<a class="links" href="/$root/ver.php">WiFiDB Version</a>');
