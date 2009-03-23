<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Search Page</title>';
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
			<p align="center"><h2>Search for Access Points</h2>
				<form action="results.php?ord=ASC&sort=ssid&from=0&to=25" method="post" enctype="multipart/form-data">
						<TABLE WIDTH=75% BORDER=1 CELLPADDING=2 CELLSPACING=0>
							<COL WIDTH=40*>
							<COL WIDTH=216*>
							<TR>
								<TD WIDTH=16%></TD>
								<TD WIDTH=84% VALIGN=TOP></TD>
							</TR>
							<TR>
								<TD class="style4" WIDTH=16%>
									<P>SSID  <font size="2"><i>(Linksys)</i></font>: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="ssid"></A><INPUT TYPE=TEXT NAME="ssid" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD class="style4" WIDTH=16% HEIGHT=35>
									<P>MAC Address  <font size="2"><i>(00:11:22:33:44:55)</i></font>: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="mac"></A><INPUT TYPE=TEXT NAME="mac" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD class="style4" WIDTH=16%>
									<P>Radio Type  <font size="2"><i>(a/b/g/n)</i></font>: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="radio"></A><INPUT TYPE=TEXT NAME="radio" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD class="style4" WIDTH=16%>
									<P>Channel <font size="2"><i>(1/2/3/..)</i></font>: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="chan"></A><INPUT TYPE=TEXT NAME="chan" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD class="style4" WIDTH=16%>
									<P>Authentication <font size="2"><i>(WPA/WPA2/OPEN)</i></font>: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="auth"></A><INPUT TYPE=TEXT NAME="auth" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD class="style4" WIDTH=16%>
									<P>Encryption <font size="2"><i>(None/WEP/TKIP)</i></font>: 
									</P>
								</TD>
								<TD WIDTH=84%>
									<P><A NAME="encry"></A><INPUT TYPE=TEXT NAME="encry" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
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
				</p>
<?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);?>