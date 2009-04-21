<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
pageheader("Import Page");
?></td>
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

echo "<br>Only VS1 Files are Supported at this time.<br>The username is optional, but it helps keep track of who has imported what Access Points<br><br>";
?>
					<CENTER><form action="insertnew.php" method="post" enctype="multipart/form-data">
						<TABLE BORDER=1 CELLPADDING=2 CELLSPACING=0>
							<TR height="40">
								<TD class="style4">
									<P>Title of Import: 
									</P>
								</TD>
								<TD>
									<P><A NAME="title"></A><INPUT TYPE=TEXT NAME="title" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR height="40">
								<TD class="style4">
									<P>File location: 
									</P>
								</TD>
								<TD>
									<P><A NAME="file"></A><INPUT TYPE=FILE NAME="file" SIZE=56 STYLE="width: 5.41in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR height="40">
								<TD class="style4">
									<P>Username: 
									</P>
								</TD>
								<TD>
									<P><A NAME="user"></A><INPUT TYPE=TEXT NAME="user" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
								</TD>
							</TR>
							<TR>
								<TD class="style4">
									<P>Notes: 
									</P>
								</TD>
								<TD>
									<P><TEXTAREA NAME="notes" ROWS=4 COLS=50 STYLE="width: 4.42in; height: 1.01in"></TEXTAREA><BR>
									</P>
								</TD>
							</TR>
								<TD>.</TD><TD>
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