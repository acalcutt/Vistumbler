<?php
include('../lib/config.inc.php');
global $theme;
if(!isset($_SESSION['token']) or !isset($_GET['token']))
{
	$token = md5(uniqid(rand(), true));
	$_SESSION['token'] = $token;
}else
{
	$token = $_SESSION['token'];
}

$func = '';
$theme_post = '';

if( !isset($_GET['func']) ) { $_GET['func'] = ""; }
$func = strip_tags(addslashes($_GET['func']));

if($func == 'change')
{
	if( !isset($_POST['theme']) ) { $_POST['theme'] = ""; }
	$theme_post = strip_tags(addslashes($_POST['theme']));
	$cookie_path = (@$GLOBALS['root']!='' ? '/'.$GLOBALS['root'].'/' : '/');
	setcookie( 'wifidb_theme' , $theme_post , (time()+(86400 * 7)), $cookie_path ); // 86400 = 1 day
	header('Location: ?token='.$_SESSION['token']);
}
$theme = (@$_COOKIE['wifidb_theme']!='' ? @$_COOKIE['wifidb_theme'] : $default_theme);
#echo $theme."<BR>";
include('../lib/database.inc.php');

pageheader("Themes Switchboard");
?>
<script type="text/javascript">

/***********************************************
* Dynamic Ajax Content- © Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

var loadedobjects=""
var rootdomain="http://"+window.location.hostname

function ajaxpage(url, containerid){
var page_request = false
if (window.XMLHttpRequest) // if Mozilla, Safari etc
page_request = new XMLHttpRequest()
else if (window.ActiveXObject){ // if IE
try {
page_request = new ActiveXObject("Msxml2.XMLHTTP")
} 
catch (e){
try{
page_request = new ActiveXObject("Microsoft.XMLHTTP")
}
catch (e){}
}
}
else
return false
page_request.onreadystatechange=function(){
loadpage(page_request, containerid)
}
page_request.open('GET', url, true)
page_request.send(null)
}

function loadpage(page_request, containerid){
if (page_request.readyState == 4 && (page_request.status==200 || window.location.href.indexOf("http")==-1))
document.getElementById(containerid).innerHTML=page_request.responseText
}

</script>
<h2>Themes Switchboard</h2>
<table width="100%"><tr><td><img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="100%" height="1" /></td></tr>
<tr><td id="leftcolumn">
<?php
$dh = opendir(".") or die("couldn't open directory");
while (($file = readdir($dh)) == true)
{
	if (!is_file($file)) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		if($file == '.svn'){continue;}
		if($file == 'index.php'){continue;}
		if($file == 'theme.txt'){continue;}
		if($file == 'themes_template.php'){continue;}
		?>[ 
		<a class="links" href="javascript:ajaxpage('themes_template.php?theme=<?php echo $file;?>', 'rightcolumn');"><?php echo $file;?></a> ]
		<?php
	}
}
?>
</td></tr>
<tr>
<td id="rightcolumn" align="center"><h3>Choose a Theme to preview.</h3></td>
</tr></table>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>