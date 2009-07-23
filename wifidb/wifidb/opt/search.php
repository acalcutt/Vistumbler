<?php
include('../lib/database.inc.php');
pageheader("Search Page");
include('../lib/config.inc.php');
if (isset($_GET['token']))
{
	if (isset($_SESSION['token']) && $_GET['token'] == $_SESSION['token'])
	{
		?><h2>Search for Access Points</h2>
						<form action="results.php?ord=ASC&sort=ssid&from=0&to=25&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
								<TABLE WIDTH=75% BORDER=1 CELLPADDING=2 CELLSPACING=0 align="center">
									<COL WIDTH=40*>
									<COL WIDTH=216*>
									<TR>
										<TD WIDTH=16%></TD>
										<TD WIDTH=84% VALIGN=TOP></TD>
									</TR>
									<TR>
										<TD class="style3" WIDTH=16%>
											<P>SSID  <font size="2"><i>(Linksys)</i></font>: 
											</P>
										</TD>
										<TD WIDTH=84%>
											<P><A NAME="ssid"></A><INPUT TYPE=TEXT NAME="ssid" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
										</TD>
									</TR>
									<TR>
										<TD class="style3" WIDTH=16% HEIGHT=35>
											<P>MAC Address  <font size="2"><i>(00:11:22:33:44:55)</i></font>: 
											</P>
										</TD>
										<TD WIDTH=84%>
											<P><A NAME="mac"></A><INPUT TYPE=TEXT NAME="mac" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
										</TD>
									</TR>
									<TR>
										<TD class="style3" WIDTH=16%>
											<P>Radio Type  <font size="2"><i>(a/b/g/n)</i></font>: 
											</P>
										</TD>
										<TD WIDTH=84%>
											<P><A NAME="radio"></A><INPUT TYPE=TEXT NAME="radio" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
										</TD>
									</TR>
									<TR>
										<TD class="style3" WIDTH=16%>
											<P>Channel <font size="2"><i>(1/2/3/..)</i></font>: 
											</P>
										</TD>
										<TD WIDTH=84%>
											<P><A NAME="chan"></A><INPUT TYPE=TEXT NAME="chan" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
										</TD>
									</TR>
									<TR>
										<TD class="style3" WIDTH=16%>
											<P>Authentication <font size="2"><i>(WPA/WPA2/OPEN)</i></font>: 
											</P>
										</TD>
										<TD WIDTH=84%>
											<P><A NAME="auth"></A><INPUT TYPE=TEXT NAME="auth" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
										</TD>
									</TR>
									<TR>
										<TD class="style3" WIDTH=16%>
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
	}else
	{
		echo "<h2>Could not Compare Tokens, try again.</h2>";
	}
}else
{
	echo "<h2>You dont have a token, try again</h2>";
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);?>