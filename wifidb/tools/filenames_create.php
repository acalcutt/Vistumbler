<?php
include('daemon/config.inc.php');
$dbconfig = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'config.inc.php';
echo $dbconfig."\n";
include($dbconfig);
$filewrite = fopen("filenames.txt", 'w');
$fileappend = fopen("filenames.txt", 'a');
fwrite($fileappend, "# FILE HASH | FILENAME | USERNAME | TITLE | DATE | NOTES\r\n");
$sql1 = "select * from `$db`.`files` ORDER BY `id` ASC";
$result1 = mysql_query($sql1, $conn);
if($result1)
{
    while($array = mysql_fetch_array($result1))
    {
        if(!$file_cont = @file($GLOBALS['wifidb_install'].'import/up/'.$array['file']))
        {continue;}
        if(strlen($file_cont[1]) > 64)
        {
            echo "I think this is a text file... not supported anymore.\r\n";
            $source = $GLOBALS['wifidb_install'].'import/up/'.$array['file'];
            $dest = "/srv/www/1/".$array['file'];
            if(copy($source, $dest))
            {unlink($source);}
            else{echo "failed to move\r\n";}
            echo $file_cont[1]."\r\n";
            continue;
        }
        echo $file_cont[1]."\r\n";
        $exp_line = explode(":", $file_cont[1]);

        if(!@$exp_line[1])
        {
            echo "ODD: " .$file."\r\n";
            echo $file_cont[1]."\r\n";
            // movie file;
            #$source = $dir.$file;
            #$dest = "/srv/www/1/".$file;
            #if(copy($source, $dest))
            #{unlink($source);}
            #else{echo "failed to move\r\n";}
            continue;
        }

        $line_exp = explode(" ", trim($exp_line[1]));
        $file_part = $line_exp[0];
        if($file_part == "RanInt")
        {
            //move file;
            echo $file."\r\n";
            echo $file_cont[1]."\r\n";
        }





        if(preg_match("/wardrive/", $array['file']))
        {
            $exp = explode(".", $array['file']);
            $c = count($exp)-1;
            echo $exp[$c]."\r\n";

            $exp[$c] = "db3";
            $file = implode(".", $exp);
            $hash = md5_file($GLOBALS['wifidb_install'].'import/up/'.$file);
            echo "DB3 File\r\n";
        }else
        {
            $file = $array['file'];
            $hash = $array['hash'];
        }
        $write = $hash."|".$file."|".$array['user']."|".$array['title']."|".$array['date']."|".$array['notes']."\r\n";
        echo $array['id']." -=> ".$write;
        fwrite($fileappend, $write);
    }
}
fclose($fileappend);
?>