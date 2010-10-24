<?php
global $screen_output;
$screen_output = "CLI";
include 'demo/lib/config.inc.php' ;
include 'demo/lib/database.inc.php';

$head	= 	$GLOBALS['headers'];

echo $root."<html>\r\n<head>\r\n<title>Wireless DataBase".$GLOBALS['ver']['wifidb']." --> Details Page</title>\r\n".$head."\r\n</head>\r\n";
$rel_ver = "*Alpha* 0.16 Build 4";
# START YOUR HTML EDITS HERE #
?>
<link rel="stylesheet" href="demo/themes/wifidb/styles.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="85%" cellspacing="5" cellpadding="2">
	<tr style="background-color: #315573;"><td colspan="2">
	<table width="100%"><tr>
			<td style="width: 215px">
				&nbsp;&nbsp;&nbsp;&nbsp;<a class="links" href="http://www.randomintervals.com/wifidb/"><img border="0" src="/wifidb/demo/img/logo.png"></a>
			</td>
			<td>
				<p align="center"><b>
				<font style="size: 5;font-family: Arial;color: #FFFFFF;">
				Wireless DataBase <?php echo $rel_ver."<BR><BR>";?>
				</font>
				</b></p>
			</td>
	</tr></table>
	</td></tr>
	<tr>
		<td style="background-color: #304D80;width: 15%;vertical-align: top;">
		<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" /><br>
		<a class="links" href="demo/">Main Page</a><br>
		<a class="links" href="demo/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a><br>
		<a class="links" href="demo/import/">Import</a><br>
		<a class="links" href="demo/opt/scheduling.php">Files Waiting for Import</a><br>
		<a class="links" href="demo/opt/scheduling.php?func=done">Files Already Imported</a><br>
		<a class="links" href="demo/opt/scheduling.php?func=daemon_kml">Daemon Generated KML</a><br>
		<a class="links" href="demo/opt/export.php?func=index">Export</a><br>
		<a class="links" href="demo/opt/search.php">Search</a><br>
		<a class="links" href="demo/themes/">Themes</a><br>
		<a class="links" href="demo/opt/userstats.php?func=allusers">View All Users</a><br>
		<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a><br>
		<a class="links" href="demo/ver.php">WiFiDB Version</a><br>
		<a class="links" href="http://www.randomintervals.com/wifidb/down.php">Download WiFiDB</a><br>
		<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="8658233">
<input type="image" src="https://www.paypal.com/en_US/i/btn/btn_donate_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>

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
																<td class="inside_dark_header">Wireless DataBase <?php echo $rel_ver;?></td>
															</tr>
															<tr>
																<td style="width: 350px">
																	<p>&nbsp;</p>
																	<ul>
																		<li class="inside_text_bold">
																			Released: 09/28/2009
																		</li>
																		
																		<li class="inside_text_bold">
																		<a class="links" href="http://sourceforge.net/projects/vistumbler/files/WiFiDB/WiFiDB%20Alpha%200.16/wifidb_alpha_016_b4.tar.gz/download">Download Tar</a></li>
																		
																		<li class="inside_text_bold">
																			<a class="links" href="http://sourceforge.net/projects/vistumbler/files/WiFiDB/WiFiDB%20Alpha%200.16/wifidb_alpha_016_b4.zip/download">Download ZIP</a>
																		</li>
																		<li class="inside_text_bold">
																			<a class="links" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/?pathrev=489">SVN</a>
																		</li>
																	</ul>
																</td>
															</tr>
														</table>
													</div>
												</td>		
												<td>
													<a class="links" href="demo/img/wifidb_preview/"><img alt="WiFiDB Sceenshots" src="demo/img/wifidb_preview/screenshot.PNG" width="268" height="181" /></a>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
							<br>
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
												Open Source ( PHP Hypertext Parser - <a class="links" href="http://www.php.net">http://www.php.net</a> & MySQL - <a class="links" href="http://www.mysql.com">http://www.mysql.com</a>.)
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
							<br>
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
												Statistics graphs of activity in the database, &#x2713; imports / new Aps / updates to APs ...etc.
											</li>
											<li>
												&#x2713; Modify current way of printing page numbers so that only a few before and after the current page are shown.
											</li>
											<li>
												&#x2713; Auto Detect Timezones and Daylight Savings time, to calculate the Correct local time.<br>
												<ol><b><font size="2">Still having an issue with DST not being detected correctly when DST is not being observed</font></b></ol>
											</li>
											<li>
												Mysticache Support. <a class="links" href="http://forum.techidiots.net/forum/viewtopic.php?f=49&t=444">KB444</a> ( Along with XML support. )
											</li>
											<li>
												User based logins. <a class="links" href="http://forum.techidiots.net/forum/viewtopic.php?f=49&t=444">KB444</a>
											</li>
										</ul>
									</td>
								</tr>
							</table>
							<br>
							<table border="1" style="width: 100%">
								<tr>
									<th colspan="3">Known Running WiFiDB Instances:</th>
								</tr>
								<tr>
									<th>URL</th><th>Description</th><th>Status</th>
								</tr>
								<tr>
									<td><a class="links" href="http://www.vistumbler.net/wifidb/">vistumbler.net</a></td><td>This is the Official Instance of WiFiDB, running on andrews server.</td><td>Public</td>
								</tr>
								<tr>
									<td><a class="links" href="http://www.randomintervals.com/wifidb/demo/">randomintervals.com</a></td><td>This is my Demo site. I may some times also use it to do some developemt testing.</td><td>Public</td>
								</tr>
								<tr>
									<td><a class="links" href="http://rihq.randomintervals.com/wifidb/">rihq.randomintervals.com</a></td><td>This is my Development site. Lots and lots of changes constantly happening on this server.</td><td>Public</td>
								</tr>
								<tr>
									<td><a class="links" href="http://www.0xyg3n.com/wifidb/">0xyg3n.com</a></td><td>This is the first known alternate (Not run by Andrew or myself) WIFiDB instance.</td><td>Private (As far as I know)</td>
								</tr>
							</table>
							<br>
							<table style="width: 100%">
								<tr>
									<td>Version History:</td>
								</tr>
								<tr>
									<td>
										<UL>
											<LI>
												<a class="links" href="http://www.randomintervals.com/wifidb/demo/ver.php">Version History</a>
											</LI>
											<LI>
												<a class="links" href="http://www.randomintervals.com/wifidb/down.php">Legacy Downloads</a>
											</LI>
											<LI>
												<a class="links" href="http://www.randomintervals.com/wifidb/tree.php">Directory Tree of WiFiDB</a>
										</UL>
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
	$tracker = $GLOBALS['tracker'];
	$ads = $GLOBALS['ads'];
	$filename = $_SERVER['SCRIPT_FILENAME'];
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$filename = $file_ex[($count)-1];
	?>
	</p>
	<br>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a class="links" href="demo/themes/wifidb/img/moon.png"><img border="0" src="demo/themes/wifidb/img/moon_tn.png"></a></td>
	<td bgcolor="#315573" width="0" align="center">
	<?php
	if (file_exists($filename)) {?>
		<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));}?></h6>
	</td>
	</tr>
	<tr>
	<td></td>
	<td align="center">
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
		<!-- End Analytics Tracking Code-->
	</td>
	</tr>
	</table>
	</body>
	</html>