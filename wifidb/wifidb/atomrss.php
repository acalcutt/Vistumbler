<?php
include 'lib/config.inc.php';
include("lib/FeedWriter.php");
error_reporting('E_NONE');
$TestFeed = new FeedWriter(ATOM);
$TestFeed->setTitle('Wireless Database ATOM Feed');
$TestFeed->setLink($hosturl.$root."/atomrss.php");
$TestFeed->setChannelElement('updated', date(DATE_ATOM , time()));
$TestFeed->setChannelElement('author', array('name'=>$WDBadmin));

$link = mysql_connect($host, $db_user, $db_pwd)
    or die('Could not connect: ' . mysql_error());

$query = "SELECT * FROM `$db`.`files` ORDER BY `id` DESC";
$result = mysql_query($query) or die('SQL Failed: ' . mysql_error());
while($row = mysql_fetch_array($result))
{
	$newItem = $TestFeed->createNewItem();
	
	$newItem->setTitle('"'.$row['user'].'" Imported \''.$row['title'].'\'');
	
	$newItem->setLink($hosturl.$root."/opt/userstats.php?func=useraplist&amp;row=".$row['user_row']);
	$newItem->setDate(strtotime($row['date']));
	
	$newItem->setDescription("User: ".$row['user']."<br />
Title: ".$row['title']."<br />
Date: ".$row['date']."<br />
Filename: ".$row['file']."<br />
File Size: ".$row['size']." kb<br />
Notes: ".$row['notes']."<br />
<a href='".$hosturl.$root."/opt/userstats.php?func=useraplist&amp;row=".$row['user_row']."'>Link</a>");
$TestFeed->addItem($newItem);
}
$TestFeed->genarateFeed();

?>