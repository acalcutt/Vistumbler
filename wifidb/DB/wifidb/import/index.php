<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Import Page</title>';
?>
<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Wireless DataBase *Alpha* <?php echo $ver["wifidb"]; ?></font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">
<?php
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}
?>
</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
			<h2>Import Access Points</h2>
<?php
$domain = $_SERVER['HTTP_HOST'];
if ($domain === "rihq.randomintervals.com" or $domain === "lanncafe.dynu.com" or $domain === "192.168.3.23")
{echo '<h2>This is my Development server </h2><H4>(which is unstable because I am always working in it)</H4><H2>Go on over to my <i><a href="http://www.randomintervals.com/wifidb/">\'Production Server\'</i></a> for a more stable enviroment</h2>';}
if (isset($_GET['file']))
{
echo "Due to security restrictions in current browsers, file fields cannot have dynamic content, <br> The file that you are trying to import via Vistumbler Is here: <b>".$_GET['file']."</b><br>Copy and Paste the bolded text into the file location field to import it.<br>";
}

echo "<br>The old txt summery files are nolonger supported.<br>VS1 file gives many GPS points<br> and many Signal history per AP<br>The username is optional, but it helps keep track of who has imported what AP's<br><br>";
?>
					<CENTER><form action="insertnew.php" method="post" enctype="multipart/form-data">
						<TABLE WIDTH=75% BORDER=1 CELLPADDING=2 CELLSPACING=0>
							<COL WIDTH=40*>
							<COL WIDTH=216*>
							<TR>
								<TD WIDTH=16%></TD>
								<TD WIDTH=84% VALIGN=TOP></TD>
							</TR>
							<TR>
								<TD WIDTH=16%>
									<P>Give a Title to the Import: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="title"></A><INPUT TYPE=TEXT NAME="title" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD WIDTH=16% HEIGHT=35>
									<P>File location: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="file"></A><INPUT TYPE=FILE NAME="file" SIZE=56 STYLE="width: 5.41in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD WIDTH=16%>
									<P>Username: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="user"></A><INPUT TYPE=TEXT NAME="user" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD WIDTH=16%>
									<P>Notes: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><TEXTAREA NAME="notes" ROWS=4 COLS=50 STYLE="width: 4.42in; height: 1.01in"></TEXTAREA><BR>
									</P>
								</TD>
							</TR>
								<TD WIDTH=16%>.</TD><TD WIDTH=84%>
									<P>
								<?php	
									if($rebuild === 0)
									{
									echo '<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit" STYLE="width: 0.71in; height: 0.36in"></P>';
									}else{echo "The database is in  rebuild mode, please wait...";}
								?>
								</TD>
							</TR>
						</TABLE>
						</form>
					</CENTER>


<?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>