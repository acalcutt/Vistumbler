<?php
$rel_ver = "*Alpha* 0.20 Build 1.2";
$svn_page = file('http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/');
$time_page = file('http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/');

$res = str_replace("</td>", '', str_replace("<td>", '', str_replace("</a>", '', $svn_page[125])));
#echo $res."<BR><BR>";
$res_exp = explode('">', $res);
$res_c = count($res_exp)-2;
#echo $res_exp[$res_c]."<BR>";
$rev_exp = explode(" (of",$res_exp[$res_c]);
$rev = $rev_exp[0];
#echo $rev."<BR>";

$url = "http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/?view=rev&revision=".$rev;
$time = str_replace("</td>", '', str_replace("<td>", '', str_replace("</a>", '', $time_page[362])));

$comment = str_replace("</td>", '', str_replace("<td>", '', str_replace("</a>", '', $time_page[366])));
?>
<html>
<head>
<title>Wireless DataBase <?php echo $rel_ver; ?> --> Details Page</title>
</head>
<link rel="stylesheet" href="details.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="85%" cellspacing="5" cellpadding="2">
	<tr style="background-color: #315573;">
		<td colspan="2">
			<table width="100%">
				<tr>
					<td style="width: 215px">
						&nbsp;&nbsp;&nbsp;&nbsp;<a class="links" href="http://www.randomintervals.com/wifidb/"><img border="0" src="img/logo.png"></a>
					</td>
					<td>
						<p align="center">
							<b><font style="size: 5;font-family: Arial;color: #FFFFFF;">Wireless DataBase <?php echo $rel_ver; ?><BR><BR></font></b>
						</p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td style="background-color: #304D80;width: 15%;vertical-align: top;">
<?php
include('../config/user.php');
mysql_select_db("site4",$conn);
$sqls = "SELECT * FROM links ORDER BY place ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "$testField";
}
?>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_donations">
<input type="hidden" name="business" value="pferland@randomintervals.com">
<input type="hidden" name="lc" value="US">
<input type="hidden" name="item_name" value="Random Intervals">
<input type="hidden" name="currency_code" value="USD">
<input type="hidden" name="bn" value="PP-DonationsBF:btn_donate_LG.gif:NonHosted">
<input type="image" src="https://www.paypal.com/en_US/i/btn/btn_donate_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>
		</td>
		<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
	<p align="center">
	<br>
	<!-- KEEP BELOW HERE -->
		<table align="center">
			<tr>
				<td valign="top">
					<div>
						<table style="width: 100%">
							<tr>
								<td class="inside_dark_header"><h2>Wireless DataBase Alpha <?php echo $rel_ver; ?></h2></td>
							</tr>
						</table>
						<table style="width: 100%">
							<tr>
								<td style="width: 350px">
									<table bgcolor="#304D80">
										<tr>
											<td>
												<ul>
													<font color="#123"><b><i>Stable</i></b></font>
													<font color="white">
													<li>
														Released: 2010-July-31
													</li>
													<li>
														<a class="linksvn" href="https://sourceforge.net/projects/vistumbler/files/WiFiDB/WiFiDB%20Alpha%200.20/wifidb_alpha_020_b1.2.tar.gz/download">Download Tar</a>
													</li>
													<li>
														<a class="linksvn" href="https://sourceforge.net/projects/vistumbler/files/WiFiDB/WiFiDB%20Alpha%200.20/wifidb_alpha_020_b1.2.zip/download">Download ZIP</a>
													</li>
													<li>
														<a class="linksvn" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/?pathrev=650">SVN</a>
													</li>
													<li>
														<a class="linksvn" href="https://sourceforge.net/downloads/vistumbler//WiFiDB/WiFiDB%20Alpha%200.20/stats_timeline?dates=2010-07-04+to+<?php echo date("Y-m-d");?>">Download Details</a>
												</ul>
												<br>
												<a class="links" href="screenshots"><img alt="WiFiDB Sceenshots" src="screenshots/WDB_theme_main.png" width="268" height="181" /></a>
												</font>
											</td>
										</tr>
									</table>
									<br><br>
									<table bgcolor="#304D80">
										<tr>
											<td>
												<font color="white">
												<ul>
													<font color="red"><b><i>Development</i></b></font>
													<li>
														<font color="red">WARNING! CODE MAY NOT BE STABLE!!</font>
													</li>
													<li>
														Last Edit:<?php echo $time;?> ago
													</li>
													<li>
														Revision: <?php echo $rev; ?>
													</li>
													<li>
														<a target="_blank" class="linksvn" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/">SVN</a> - <font size="1"><a target="_blank" class="linksvn" href="<?php echo $url; ?>">More Details</a></font>
													</li>
													<li>
														Comments: <?php echo $comment; ?><br>
													</li>
												</ul>
												</font>
											</td>
										</tr>
									</table>
								</td>
								<td>
									<iframe src="http://www.facebook.com/plugins/likebox.php?id=138548099496425&amp;width=292&amp;connections=10&amp;stream=true&amp;header=true&amp;height=587" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:292px; height:587px;" allowTransparency="true"></iframe>
								</td>
							</tr>
						</table>
					</div>
				</td>		
				<td>
					<!-- Facebook Badge START -->
					
					<!--
					<a href="http://www.facebook.com/pages/WiFiDB/138548099496425" target="_TOP" style="font-family: &quot;lucida grande&quot;,tahoma,verdana,arial,sans-serif; font-size: 11px; font-variant: normal; font-style: normal; font-weight: normal; color: #3B5998; text-decoration: none;" title="WiFiDB">WiFiDB</a>
					<span style="font-family: &quot;lucida grande&quot;,tahoma,verdana,arial,sans-serif; font-size: 11px; line-height: 16px; font-variant: normal; font-style: normal; font-weight: normal; color: #555555; text-decoration: none;">&nbsp;|&nbsp;</span>
					<a href="http://www.facebook.com/business/dashboard/" target="_TOP" style="font-family: &quot;lucida grande&quot;,tahoma,verdana,arial,sans-serif; font-size: 11px; font-variant: normal; font-style: normal; font-weight: normal; color: #3B5998; text-decoration: none;" title="Make your own badge!">Promote Your Page Too</a>
					<br/>
					
					<a href="http://www.facebook.com/pages/WiFiDB/138548099496425" target="_TOP" title="WiFiDB"><img src="http://badge.facebook.com/badge/138548099496425.1662.643998642.png" width="313" height="84" style="border: 0px;" /></a>
					-->
					<!-- Facebook Badge END -->
				</td>
			</tr>
		</table>
		<br>
		<table style="width: 100%">
			<tr>
				<td><b><u><i>Features:</b></u></i></td>
			</tr>
			<tr>
				<td>
					<UL>
						<li>
							Import VS1 files from Vistumbler.
						</li>
						<UL>
							<LI>
								Support for <a class="links" href="http://code.google.com/p/wardrive-android/">Wardrive</a> on android.
							</LI>
							<LI>
								The wardriving application stores the database as "Wardrive.db3" on the root of your phones sd card.
							</LI>
							<LI>
								Contact me and I'll add your app in.
							</LI>
						</UL>
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
						<li>
							Statistics graphs of activity in the database, &#x2713; imports / new Aps / updates to APs ...etc.
						</li>
						<li>
							&#x2713; Modify current way of printing page numbers so that only a few before and after the current page are shown.
						</li>
						<li>
							Auto Detect Timezones and Daylight Savings time, to calculate the Correct local time.<br>
							<ol><b><font size="2">Still having an issue with DST not being detected correctly when DST is not being observed</font></b></ol>
						</li>
						<li>
							1/2 &#x2713; Mysticache Support. <a class="links" href="http://forum.techidiots.net/forum/viewtopic.php?f=49&t=444">KB444</a> ( Along with XML support. )
						</li>
						<li>
							&#x2713; User based logins. <a class="links" href="http://forum.techidiots.net/forum/viewtopic.php?f=49&t=444">KB444</a>
						</li>
						<LI>Split the Daemon into three seperate processes.
							<UL>
								<LI>a) Daemon->Imports/Exports (this is the old daemon, basically unchanged, just being spawned by the Controller now).</LI>
								<LI>b) Daemon->Statistics (all the statistical data for the database, APs, Users, Geocaches, and more).</LI>
								<LI>c) Daemon->Geoname (Finds the geoname of the Lat/Long for the AP from geonames.org).
								<LI>Performance monitor (watches the CPU/Disk/Mem usage of the daemon procs).</LI>
							</UL>
						<LI>Added a mail function to email the Database admin when there are Errors or Warnings in the Daemon, or the Web front end.</LI>
					</UL>
				</td>
			</tr>
		</table>
		<br>
		<table style="width: 100%">
			<tr>
				<td>
					<UL><b><u><i>On the Plate for 0.20 Build 2:</b></u></i>
						<LI>Teams and multi-user import support.</LI>
						<LI>Things will start obeing the Friends and Foes lists.</LI>
						<LI>Get the web based daemon control working.</LI>
						<LI>Web based updates of WiFiDB code.</LI>
						<LI>Export Geocaches to GPX and LOC files.</LI>
						<LI>Export to DB3 files (Wardrive for Android)</LI>
					</UL>
				</td>
			</tr>
			<tr>
				<td>
					<ul>
						
					</UL>
				</td>
			</tr>
		</table>
		<br>
		<table border="1" style="width: 100%">
			<tr class="style4">
				<th colspan="3">Known Running WiFiDB Instances:</th>
			</tr>
			<tr class="sub_head">
				<th>URL</th><th>Description</th><th>Status</th>
			</tr>
			<tr class="light">
				<td><a class="links" href="http://www.vistumbler.net/wifidb/">vistumbler.net</a></td><td>This is the Official Instance of WiFiDB, running on andrews server.</td><td>Public</td>
			</tr>
			<tr class="dark">
				<td><a class="links" href="http://wifidb.randomintervals.com/">wifidb.randomintervals.com</a></td><td>This is my Demo site. I may some times also use it to do some developemt testing.</td><td>Public</td>
			</tr>
			<tr class="light">
				<td><a class="links" href="http://rihq.randomintervals.com/wifidb/">rihq.randomintervals.com</a></td><td>This is my Development site. Lots and lots of changes constantly happening on this server.</td><td>Public</td>
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
							<a class="links" href="http://wifidb.randomintervals.com/ver.php">Version History</a>
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
<?php
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
		
		<script type="text/javascript"><!--
google_ad_client = "pub-6007574915683746";
/* 728x90, created 6/26/10 */
google_ad_slot = "4681765667";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
	</td>
	</tr>
	</table>
	</body>
	</html>