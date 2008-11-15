<?php
$lastedit		=	"11.14.2008";
#---------------- Debug Info ----------------#
$rebuild 		=	0
$debug			=	0;
$loglev 		=	0; 					#	(NOT IMPLEMENTED YET)	 0 - off	   	1 - Errors only		2 - Errors and warnings		3 - RESERVED		4 - FULL OUTPUT (WARNING SLOW AND LARGE)

#---------------- URL Info ----------------#
$root			=	'/wifidb';
$hosturl 		=	'http://rihq.randomintervals.com';

#---------------- SQL HOSTS ----------------#
$host			=	'192.168.3.24';

#---------------- Tables ----------------#
$settings_tb 	=	'settings'; 		//used for keeping a running total size of AP's in the DB
$users_tb 		=	'users';
$links 			=	'links';
$wtable 		=	'wifi0';

#---------------- DataBases ----------------#
$db				=	'wifi';				// WiFiDB Settings and Pointers DB. Holds the `settings`,`users`,`wifi0`, and `links` tables. `wifi0`and `users` are the only tables that are empty upon a "fresh install"
$db_st			=	'wifi_st';			// The DB where all the AP's Signal, config and GPS history are stored. Each AP has two (2) tables, a self named [ssid-mac-sectype-radio-chan] {sectype is the same as vistumblers, 1 is open, 2 is WEP, and 3 is Secure (WPA/WPA2), and a table with _GPS at the end to hold all the GPS history

#---------------- USER INFO ----------------#
$db_user		=	'wfdbu';			// The User that is used to connect to MySQL
$db_pwd			=	'WIFI|)|3';			// The password to connect to MySQL

#---------------- Gen info ----------------#
$gps_ext 		=	'_GPS';			// the GPS ending for the tables variable[ssid-mac-sectype-radio-chan] 
$sep 			=	'-';				// The Seperator used in the tables variable [ssid-mac-sectype-radio-chan]

#---------------- Conn Info ----------------#
$conn 			=	 mysql_pconnect($host, $db_user, $db_pwd) or die("Unable to connect to SQL server: ".$host);		// The Connection string used to connect to MySQL

#---------------- KML Info ----------------#
$open_loc 		=	'http://vistumbler.sourceforge.net/images/program-images/open.png';								// The OPEN AP Image for KML export
$WEP_loc 		=	'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';							// The WEP AP image for KML export
$WPA_loc 		=	'http://vistumbler.sourceforge.net/images/program-images/secure.png';								// The Secure (WPA/WPA2) AP image for KML export

?>