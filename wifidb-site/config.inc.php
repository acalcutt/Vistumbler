<?php
global $header, $ads, $tracker, $hosturl;
global $WiFiDB_LNZ_User, $apache_grp, $div, $conn, $wifidb_tools, $daemon, $root;
global $console_refresh, $console_scroll, $console_last5, $console_lines, $default_theme, $default_refresh, $default_dst, $default_timezone;
$lastedit	=	'2009-09-20';

#---------------- Daemon Info ----------------#
$daemon		=	1;
$debug			=	0;
$log_level		=	0;
$log_interval	=	0;
$wifidb_tools	=	'/CLI';
$timezn		=	'';
$WiFiDB_LNZ_User 	=	'www-data';
$apache_grp			=	'www-data';

#-------------Themes Settings--------------#
$default_theme		= 'wifidb';
$default_refresh 	= 15;
$default_timezone	= 0;
$default_dst			= 0;
$timeout			= 31536000; #(86400 [seconds in a day] * 365 [days in a year]) 

#-------------Console Viewer Settings--------------#
$console_refresh = 15;
$console_scroll  = 1;
$console_last5   = 1;
$console_lines   = 10;
$console_log		= '/var/log/wifidb';

#---------------- Debug Info ----------------#
$rebuild		=	0;
$bench			=	0;

#---------------- URL Info ----------------#
$root		=	'demo';
$hosturl	=	'http://www.randomintervals.com/wifidb/';

#---------------- SQL Host ----------------#
$host	=	'localhost';

#---------------- Tables ----------------#
$settings_tb 	=	'';
$users_tb 		=	'users';
$links 			=	'links';
$wtable 		=	'wifi0';
$gps_ext 		=	'_GPS';
$sep 			=	'-';

#---------------- DataBases ----------------#
$db			=	'wifi';
$db_st 		=	'wifi_st';

#---------------- SQL User Info ----------------#
$db_user		=	'wifidbu';
$db_pwd			=	'wifidbu';

#---------------- SQL Connection Info ----------------#
$conn 				=	 mysql_pconnect($host, $db_user, $db_pwd) or die("Unable to connect to SQL server: $host");

#---------------- Export Info ----------------#
$open_loc 				=	'http://vistumbler.sourceforge.net/images/program-images/open.png';
$WEP_loc 				=	'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';
$WPA_loc 				=	'http://vistumbler.sourceforge.net/images/program-images/secure.png';
$KML_SOURCE_URL		=	'http://www.opengis.net/kml/2.2';
$kml_out				=	'../out/kml/';
$vs1_out				=	'../out/vs1/';
$daemon_out			=	'out/daemon/';
$gpx_out				=	'../out/gpx/';

#---------------- Header and Footer Additional Info -----------------#
$ads			= '';
$header 		= '<meta name="description" content="A Wireless Database based off of scans from Vistumbler." />
		<meta name="keywords" content="WiFiDB, linux, windows, vistumbler, Wireless, database, db, php, mysql" />
		<!-- Begin Analytics Tracking Code -->
		<script type="text/javascript">
			var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
			document.write(unescape("%3Cscript src=\'" + gaJsHost + "google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E"));
		</script>
		<script type="text/javascript">
			try {
			var pageTracker = _gat._getTracker("UA-6849049-1");
			pageTracker._trackPageview();
			} catch(err) {}
		</script>
		<!-- End Analytics Tracking Code-->'; # <-- put the code for your ads in here www.google.com/adsense
$tracker 	= ''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )
