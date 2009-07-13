<?php
include('../lib/database.inc.php');
pageheader("Patches Page");
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> </title>';
echo '<h2>Patching scripts for WiFiDB<h4><b>----------------------------------------------</b>';
echo '<h4>If you have GPS points that are blank, or If your GPS dates are in the format [MM-DD-YYYY], Alter them to [YYYY-MM-DD], go <a class="links" href="patch_blank_gps/">here</a></h4><b>----------------------------------------------</b>';
echo '<h4>To prevent GPS points from having null data in the fields named `hdp` , `alt` , `geo` , kmh` , and `track`. Need to update `lu`, and `fa` to support miliseconds, go <a class="links" href="patch_gps_table/patch_gps_tbl.php">here</a><BR>This is a quick and dirty script that goes through every %_GPS table and alters the columns from the wrong type (float() to varchar(255), float was having issues with some of the values)<h4>';
footer($_SERVER['SCRIPT_FILENAME'])
?>