<?php

include 'lib/config.inc.php' ;
include 'lib/database.inc.php' ;

$root	= $GLOBALS['root'];
$head	= 	$GLOBALS['headers'];

echo "<html>\r\n<head>\r\n<title>Wireless DataBase".$GLOBALS['ver']['wifidb']." --> ".$title."</title>\r\n".$head."\r\n</head>\r\n";
check_install_folder();

$sql = "SELECT `id` FROM `$db`.`files`";
$result1 = mysql_query($sql, $conn);
if(!$result1){echo "<p align=\"center\"><font color=\"red\">You need to <a class=\"upgrade\" href=\"install/upgrade/\">upgrade</a> before you will be able to properly use WiFiDB Build 3.</p></font>";}

# START YOUR HTML EDITS HERE #
?>
<link rel="stylesheet" href="<?php if($root != ''){echo '/'.$root;}?>/themes/wifidb/styles.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="85%" cellspacing="5" cellpadding="2">
	<tr style="background-color: #315573;"><td colspan="2">
	<table width="100%"><tr>
			<td style="width: 215px">
				&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.randomintervals.com"><img border="0" src="/<?php echo $root; ?>/img/logo.png"></a>
			</td>
			<td>
				<p align="center"><b>
				<font style="size: 5;font-family: Arial;color: #FFFFFF;">
				Wireless DataBase<?php echo $GLOBALS['ver']['wifidb'].'<br /><br />'; ?>
				</font>
					<?php breadcrumb($_SERVER["REQUEST_URI"]); ?>
				</b></p>
			</td>
	</tr></table>
	</td></tr>
	<tr>
		<td style="background-color: #304D80;width: 15%;vertical-align: top;">
		<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" /><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/?token=<?php echo $token;?>">Main Page</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/all.php?sort=SSID&ord=ASC&from=0&to=100&token=<?php echo $token;?>">View All APs</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/import/?token=<?php echo $token;?>">Import</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/scheduling.php?token=<?php echo $token;?>">Files Waiting for Import</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/scheduling.php?func=done&token=<?php echo $token;?>">Files Already Imported</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/scheduling.php?func=daemon_kml&token=<?php echo $token;?>">Daemon Generated KML</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/export.php?func=index&token=<?php echo $token;?>">Export</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/search.php?token=<?php echo $token;?>">Search</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/themes/?token=<?php echo $token;?>">Themes</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/userstats.php?func=allusers&token=<?php echo $token;?>">View All Users</a><br>
		<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a><br>
		<a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/ver.php?token=<?php echo $token;?>">WiFiDB Version</a><br>
		<a class="links" href="http://www.randomintervals.com/wifidb/details.php">Download WiFiDB</a><br>
	</td>
	<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
	<p align="center">
	<br>
	<!-- KEEP BELOW HERE -->
	<table style="width: 100%">
		<tr>
			<td>
				<table style="width: 100%" cellpadding="0" cellspacing="0">
					<tr>
						<td>
							<table cellpadding="0" cellspacing="0" style="width: 95%; height: 95%">
								<tr>
									<td class="cell_color">
										<table align="center">
											<tr>
												<td valign="top">
													<div>
														<table style="width: 100%">
															<tr>
																<td class="inside_dark_header">WiFiDB *Alpha* 0.16 Build 4</td>
															</tr>
															<tr>
																<td style="width: 350px">
																	<p>&nbsp;</p>
																	<ul>
																		<li class="inside_text_bold">
																			Released: 09/--/2009
																		</li>
																		
																		<li class="inside_text_bold">
																		<a href="http://sourceforge.net/projects/vistumbler/files/WiFiDB/WiFiDB%20Alpha%200.16/wifidb_alpha_016_b4.zip/download">Download Tar</a></li>
																		
																		<li class="inside_text_bold">
																			<a href="http://sourceforge.net/projects/vistumbler/files/WiFiDB/WiFiDB%20Alpha%200.16/wifidb_alpha_016_b4.zip/download">Download ZIP</a>
																		</li>
																	</ul>
																</td>
															</tr>
														</table>
													</div>
												</td>		
												<td>
													<a href="img/wifidb_preview/"><img alt="WiFiDB Sceenshots" src="img/wifidb_preview/screenshot.PNG" width="268" height="181" /></a>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
							<table style="width: 100%">
								<tr>
									<td class="inside_dark_header">Features</td>
								</tr>
								<tr>
									<td>
										<ul>
											<li>
												Import VS1 files from Vistumbler.
											</li>
											<li>
												Graph access point signal strength, in bargraph or linegraph style.
											</li>
											<li>
												Search for APs with similar features.
											</li>
											<li>
												Export User Aps, User lists, Single Ap, or Entire Database to KML.
											</li>
											<li>
												HTML or CLI (Daemon) Mode, Daemon mode supports much, much larger files, because of unlimited time limits in php-cli.
											</li>
											<li>
												Open Source ( PHP Hypertext Parser - <a href="http://www.php.net">http://www.php.net</a> & MySQL - <a href="http://www.mysql.com">http://www.mysql.com</a>.)
											</li>
											<li>
												Easily manage large numbers of Access Points.
											</li>
											<li>
												Daemon Generated KML files. For up to the second updates on when APs are imported into your database.
											</li>
											<li>
												Daemon Console Viewer, to view the CLI interface of the daemon on the web.
											</li>
										</ul>
									</td>
								</tr>
							</table>
							<table style="width: 100%">
								<tr>
									<td>
										On the Plate in the Next release:
									</td>
								</tr>
								<tr>
									<td>
										<ul>
											<li>
												Statistics graphs of activity in the database, imports / exports / new Aps / updates to APs ...etc.
											</li>
										</ul>
									</td>
								</tr>
							</table>
							<table style="width: 100%">
								<tr>
									<td>Version History:</td>
								</tr>
								<tr>
									<td>
										<ul>
											<li >
												<a href="ver.php">Version History</a>
											</li>
											<li >
												<a href="down.php">Legacy Downloads</a>
										</ul>
									</td>
								</tr>
							</table>
							<table style="width: 100%">
								<tr>
									<td>
										For the Future:
									</td>
								</tr>
								<tr>
									<td class="center">
										<ul>
											<li>
												Thinking...
											</li>
										</ul>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
<?php
footer($_SERVER['SCRIPT_FILENAME']);
?>