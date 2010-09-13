<?php
include('../lib/database.inc.php');
pageheader("Search Page");
include('../lib/config.inc.php');
?>
<h2>Search for Access Points</h2>
<form action="results.php?ord=ASC&sort=ssid&from=0&to=25" method="post" enctype="multipart/form-data">
    <table border="0" cellpadding="5">
        <thead>
            <tr>
                <th align="right">SSID:</th>
                <th align="left">
                    <input type="text"
                           name="ssid"
                        size="40"
                        id="ssid"
                        onkeyup="doCompletion();">
                </th>
            </tr>
            <tr>
                <th align="right">MacAddress:</th>
                <th align="left">
                    <input type="text"
                           name="mac"
                        size="40"
                        id="mac"
                        onkeyup="doCompletion();">
                </th>
            </tr>
            <tr>
                <th align="right">Authentication:</th>
                <th align="left">
                    <input type="text"
                           name="auth"
                        size="40"
                        id="auth"
                        onkeyup="doCompletion();">
                </th>
            </tr>
            <tr>
                <th align="right">Encryption:</th>
                <th align="left">
                    <input type="text"
                           name="encry"
                        size="40"
                        id="encry"
                        onkeyup="doCompletion();">
                </th>
            </tr>
            <tr>
                <th align="right">Radio Type:</th>
                <th align="left">
                    <input type="text"
                           name="radio"
                        size="40"
                        id="radio"
                        onkeyup="doCompletion();">
                </th>
            </tr>
            <tr>
                <th align="right">Channel:</th>
                <th align="left">
                    <input type="text"
                           name="chan"
                        size="40"
                        id="chan"
                        onkeyup="doCompletion();">
                </th>
            </tr>
            <tr>
                <td align="center" colspan="2">
                    <input type=submit name="submit" value="Submit" style="width: 0.71in; height: 0.36in" />
                </td>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td align="center" id="auto-row" colspan="2">
                    <h4>First 15 results will show here.</h4>
                    <table class="popupBox" style="display: none"></table>
                </td>
            </tr>
        </tbody>
    </table>
</form>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>