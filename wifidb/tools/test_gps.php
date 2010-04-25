<?php
#7.45911166,49.70898,0 
#7.396225,49.72916330000001,0

echo distance_between(49.70898, 7.45911166, 49.72916330000001, 7.396225);


function distance_between($lat, $long, $lat2, $long2)
{
	$EarthRadius = 6378137;
	$lat1 = deg2rad($lat);
	$lon1 = deg2rad($long);
	$lat2 = deg2rad($lat2);
	$lon2 = deg2rad($long2);
	$distance = (ACos(Sin($lat1) * Sin($lat2) + Cos($lat1) * Cos($lat2) * Cos($lon2 - $lon1)) * $EarthRadius); # distance in meters
	return $distance;
}

?>