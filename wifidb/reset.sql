# RanInt WifiDB SQL file
# Ver: 0.16 Build 4
# Last Edit: 2009-Aug-28
# http://www.randomintervals.com/wifidb/
#
#	WARNING: This script Drops both the `wifi_st` (Storage Database) and `wifi` (Main Database, holds pointers and other info) DB's,
#			if you do not want to loose all your data, back it
#			up and then run this scrip.
#
#
##############################################################

#
# Database : `wifi_st` (Used to store all the Access Point Signal and GPS Data)
# 

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

CREATE DATABASE `wifi` DEFAULT CHARACTER SET utf8 COLLATE latin1_swedish_ci;
USE `wifi`;



CREATE TABLE IF NOT EXISTS `annunc-comm` (
  `id` int(11) NOT NULL auto_increment,
  `author` varchar(32) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;





CREATE TABLE IF NOT EXISTS `annunc` (
  `id` int(11) NOT NULL auto_increment,
  `auth` varchar(32) NOT NULL default 'Annon Coward',
  `title` varchar(255) NOT NULL default 'Blank',
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `body` text NOT NULL,
  `comments` text NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `title` (`title`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;





CREATE TABLE IF NOT EXISTS `files` (
  `id` int(11) NOT NULL auto_increment,
  `file` varchar(255) NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `size` varchar(12) NOT NULL,
  `aps` int(11) NOT NULL,
  `gps` int(11) NOT NULL,
  `hash` varchar(255) NOT NULL,
  `user_row` int(11) NOT NULL,
  `user` varchar(255) NOT NULL,
  `notes` text NOT NULL,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `file` (`file`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;





CREATE TABLE IF NOT EXISTS `files_tmp` (
  `id` int(11) NOT NULL auto_increment,
  `file` varchar(255) NOT NULL,
  `user` varchar(255) NOT NULL,
  `notes` text NOT NULL,
  `title` varchar(255) NOT NULL,
  `size` varchar(12) NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `hash` varchar(255) NOT NULL,
  `importing` tinyint(1) NOT NULL,
  `ap` varchar(32) NOT NULL,
  `tot` varchar(128) NOT NULL,
  `row` int(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `file` (`file`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;





CREATE TABLE IF NOT EXISTS `links` (
  `ID` int(255) NOT NULL auto_increment,
  `links` varchar(255) NOT NULL,
  KEY `INDEX` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;


INSERT INTO `links` (`ID`, `links`) VALUES
(1, '<a class="links" href="http://192.168.1.25//wifidb/">Main Page</a>'),
(2, '<a class="links" href="http://192.168.1.25//wifidb/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a>'),
(3, '<a class="links" href="http://192.168.1.25//wifidb/import/">Import</a>'),
(4, '<a class="links" href="http://192.168.1.25//wifidb/opt/export.php?func=index">Export</a>'),
(5, '<a class="links" href="http://192.168.1.25//wifidb/opt/search.php">Search</a>'),
(6, '<a class="links" href="http://192.168.1.25//wifidb/opt/userstats.php?func=allusers">View All Users</a>'),
(7, '<a class="links" href="http://192.168.1.25//wifidb/ver.php">WiFiDB Version</a>'),
(8, '<a class="links" href="http://192.168.1.25//wifidb/announce.php?func=allusers">Announcements</a>');



CREATE TABLE IF NOT EXISTS `settings` (
  `id` int(255) NOT NULL auto_increment,
  `table` varchar(25) NOT NULL,
  `size` varchar(254) default NULL,
  UNIQUE KEY `table` (`table`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;


INSERT INTO `settings` (`id`, `table`, `size`) VALUES
(1, 'files', '2009-09-29 02:42:01'),
(2, 'theme', 'wifidb'),
(1, 'wifi0', '2009-09-29 02:42:01');



CREATE TABLE IF NOT EXISTS `users` (
  `id` int(255) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `points` text NOT NULL,
  `notes` text NOT NULL,
  `title` varchar(255) NOT NULL,
  `date` varchar(25) NOT NULL,
  `aps` int(11) NOT NULL,
  `gps` int(11) NOT NULL,
  `hash` varchar(255) NOT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;





CREATE TABLE IF NOT EXISTS `wifi0` (
  `id` int(255) NOT NULL auto_increment,
  `ssid` varchar(32) NOT NULL,
  `mac` varchar(25) NOT NULL,
  `chan` varchar(3) NOT NULL,
  `sectype` varchar(1) NOT NULL,
  `radio` varchar(1) NOT NULL,
  `auth` varchar(25) NOT NULL,
  `encry` varchar(25) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;


CREATE DATABASE `wifi_st` DEFAULT CHARACTER SET utf8 COLLATE latin1_swedish_ci;
