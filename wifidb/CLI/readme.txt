This is a converter for the Vistumbler Summery Text file to the VS1 file.

I wrote this script in windows, but it can run on any OS that you have PHP on.

In the converter_vs1.php file there is a variable called $dir this is the directory that is searched for .txt files and converts to the .VS1 format

Default value:
$dir="C:\\imp\\text\\";

The function convert_vs1() is the converter that does all the work.
$source is the dir and file that you are converting
the other option is "file" to output the conversion to a VS1 file
I am working on having a database output too, via MySQL