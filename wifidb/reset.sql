# RanInt WifiDB SQL file
# Ver: 0.16 Build 2
# Last Edit: 2009-04-27
# http://www.randomintervals.com/wifidb/
#
#	WARNING: This script Drops both the `wifi_st` and `wifi` DB's,
#			if you do not want to loose all your data, back it
#			up and then run this scrip.
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
(NULL, 'wifi0', 0);

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
  chan varchar(3) NOT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

#
# Data for table `links`
#

INSERT INTO `links` (`ID`, `links`) VALUES
(1, '<a class=\"links\" href=\"/wifidb\">Main Page</a>'),
(2, '<a class=\"links\" href=\"/wifidb/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),
(3, '<a class=\"links\" href=\"/wifidb/import/\">Import</a>'),
(4, '<a class=\"links\" href=\"/wifidb/opt/export.php?func=index\">Export</a>'),
(5, '<a class=\"links\" href=\"/wifidb/opt/search.php\">Search</a>'),
(6, '<a class=\"links\" href=\"/wifidb/opt/userstats.php?func=allusers\">View All Users</a>'),
(7, '<a class=\"links\" href=\"/wifidb/ver.php\">WiFiDB Version</a>'),
(8, '<a class=\"links\" href=\"/wifidb/announce.php?func=allusers\">Announcements</a>');

#
# Table structure for table `annunc-comm`
#
CREATE TABLE `annunc-comm` (
`id` INT NOT NULL AUTO_INCREMENT ,
`author` VARCHAR( 32 ) NOT NULL ,
`title` VARCHAR( 120 ) NOT NULL ,
`body` TEXT NOT NULL ,
`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
PRIMARY KEY ( `id` ) ,
INDEX ( `id` ) ,
UNIQUE (`title` )
) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 


#
# Table structure for table `annunc`
#
CREATE TABLE `annunc` (
`id` INT NOT NULL AUTO_INCREMENT ,
`auth` VARCHAR( 32 ) NOT NULL DEFAULT 'Annon Coward',
`title` VARCHAR( 120 ) NOT NULL DEFAULT 'Blank',
`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
`body` TEXT NOT NULL ,
`comments` TEXT NOT NULL ,
PRIMARY KEY ( `id` ) ,
INDEX ( `id` ) ,
UNIQUE ( `title` )
) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1


#
# Table structure for table `files`
#
CREATE TABLE `files` (
`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`file` TEXT NOT NULL ,
`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
`size` FLOAT( 12, 12 ) NOT NULL ,
`aps` INT NOT NULL ,
`gps` INT NOT NULL ,
`hash` VARCHAR( 255 ) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1


#
# Table structure for table `files_tmp`
#
CREATE TABLE `files_tmp` (
`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`file` VARCHAR( 255 ) NOT NULL ,
`user` VARCHAR ( 32 ) NOT NULL,
`notes` TEXT NOT NULL,
`title` VARCHAR ( 128 ) NOT NULL,
`size` FLOAT (12,12 ) NOT NULL ,
`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
`hash` VARCHAR ( 255 ) NOT NULL
) ENGINE = $ENG  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1