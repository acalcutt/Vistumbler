<?php
$lastedit	=	'11.24.2008';

#---------------- Debug Info ----------------#
$rebuild	=	0;
$debug	=	0;
$loglev	=	0;

#---------------- URL Info ----------------#
$root	=	'wifidb';
$hosturl	=	'http://vistumbler.sourceforge.net';

#---------------- SQL Host ----------------#
$host	=	'mysql4-v';

#---------------- Tables ----------------#
$settings_tb 	=	'settings';
$users_tb 		=	'users';
$links 			=	'links';
$wtable 		=	'wifi0';
$gps_ext 		=	'_GPS';
$sep 			=	'-';

#---------------- DataBases ----------------#
$db			=	'v235720_wifi';
$db_st 		=	'v235720_wifi_st';

#---------------- SQL User Info ----------------#
$db_user		=	'v235720admin';
$db_pwd		=	'sansui20si';

#---------------- SQL Connection Info ----------------#
$conn 			=	 mysql_pconnect($host, $db_user, $db_pwd) or die("Unable to connect to SQL server: $host");

#---------------- KML Info ----------------#
$open_loc 		=	'http://vistumbler.sourceforge.net/images/program-images/open.png';
$WEP_loc 		=	'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';
$WPA_loc 		=	'http://vistumbler.sourceforge.net/images/program-images/secure.png';


?>