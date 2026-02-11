# Vistumbler VS1 - Detailed Export Version 4.0

This document describes the VS1 file format used by Vistumbler (MDB/Access Version).

## VS1 File Format Example

```text
# Vistumbler VS1 - Detailed Export Version 4.0
# Created By: Vistumbler v10.8.2
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# GpsID|Latitude|Longitude|NumOfSatalites|HorizontalDilutionOfPrecision|Altitude(m)|HeightOfGeoidAboveWGS84Ellipsoid(m)|Speed(km/h)|Speed(MPH)|TrackAngle(Deg)|Date(UTC y-m-d)|Time(UTC h:m:s.ms)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1|N 4202.5420|W 7135.2375|04|15.0|331|-34.0|38.34|23.81|243.72|2009-07-03|18:53:28.250
2|N 4202.5342|W 7135.2582|04|14.9|333|-34.0|37.32|23.17|242.96|2009-07-03|18:53:29.252
3|N 4202.5317|W 7135.2646|04|14.8|333|-34.0|35.93|22.31|242.96|2009-07-03|18:53:30.263
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# SSID|BSSID|MANUFACTURER|Authentication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|High Signal|High RSSI|Network Type|Label|GID,SIGNAL,RSSI
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
WIFISSID1|00:11:22:33:44:55|Cisco-Linksys, LLC|WPA2-Personal|CCMP|3|802.11n|6|1,2,5.5,11|6,9,12,18,24,36,48,54|99|-34|Infrastructure|Unknown|1,99,-34\2,41,-75\3,33,-80
WIFISSID2|66:77:88:99:AA:BB|NETGEAR|WPA2-Personal|CCMP|3|802.11n|11|6,9,12,18,24,36,48,54||73|-56|Infrastructure|Unknown|1,73,-56
```

## VS1 Information

The Vistumbler format uses the `#` symbol as a comment. Any line that starts with a `#` will be ignored by Vistumbler.

Vistumbler uses `|` as its delimiter.

The Vistumbler file format consists of two separate arrays (sections).

### GPS Array

The GPS Array holds all location data referenced by the access points.

| Index | Column Name | Description |
|-------|-------------|-------------|
| 1 | GpsID | Unique identifier for the GPS record (referenced later in AP history). |
| 2 | Latitude | GPS Latitude (DMM format, e.g., `N 4202.5420`). |
| 3 | Longitude | GPS Longitude (DMM format, e.g., `W 7135.2375`). |
| 4 | NumOfSatalites | Number of satellites used for the fix. |
| 5 | HorizontalDilutionOfPrecision | HDOP value. |
| 6 | Altitude(m) | Altitude in meters. |
| 7 | HeightOfGeoidAboveWGS84Ellipsoid(m) | Geoid height. |
| 8 | Speed(km/h) | Speed in Kilometers per Hour. |
| 9 | Speed(MPH) | Speed in Miles per Hour. |
| 10 | TrackAngle(Deg) | Direction of travel in degrees. |
| 11 | Date(UTC y-m-d) | UTC Date in YYYY-MM-DD. |
| 12 | Time(UTC h:m:s.ms) | UTC Time in HH:MM:SS.ms. |

**Example:**

```text
1|N 4202.5420|W 7135.2375|04|15.0|331|-34.0|38.34|23.81|243.72|2009-07-03|18:53:28.250
```

### Access Point Array

The Access Point Array holds the details for each discovered network.

| Index | Column Name | Description |
|-------|-------------|-------------|
| 1 | SSID | Service Set Identifier (Network Name). |
| 2 | BSSID | Basic Service Set Identifier (MAC Address). |
| 3 | MANUFACTURER | Device manufacturer (derived from MAC OUI). |
| 4 | Authentication | Authentication type (e.g., Open, WPA2-Personal). |
| 5 | Encryption | Encryption type (e.g., None, CCMP, TKIP). |
| 6 | Security Type | Internal Vistumbler security ID (1=Open, 2=WEP, 3=Secure). |
| 7 | Radio Type | 802.11 standard (e.g., 802.11b, 802.11g, 802.11n). |
| 8 | Channel | Wireless channel. |
| 9 | Basic Transfer Rates | Supported basic rates. |
| 10 | Other Transfer Rates | Supported operational rates. |
| 11 | High Signal | Highest signal percentage recorded (0-100). |
| 12 | High RSSI | Highest RSSI (dBm) recorded. |
| 13 | Network Type | Infrastructure or Ad-Hoc. |
| 14 | Label | User-assigned label. |
| 15 | GID,SIGNAL,RSSI | Signal history (see below). |

**Example:**

```text
WIFISSID1|00:11:22:33:44:55|Cisco-Linksys, LLC|WPA2-Personal|CCMP|3|802.11n|6|1,2,5.5,11|6,9,12,18,24,36,48,54|99|-34|Infrastructure|Unknown|1,99,-34\2,41,-75\3,33,-80
```

### Signal History

The `GID,SIGNAL,RSSI` column contains the entire history of the access point.

**Format:** `GID1,Sig1,RSSI1\GID2,Sig2,RSSI2\GID3,Sig3,RSSI3...`

**Delimiter:** Backslash `\` separates individual history records.

**Internal Delimiter:** Comma `,` separates values within a record.

Each history record points back to a GPS ID defined in the GPS Array section.

**Breakdown Example:** `1,99,-34`

| Value | Description |
|-------|-------------|
| 1 | GPS ID: Corresponds to `GpsID` 1 in the GPS Array (provides Lat, Lon, Time, etc.). |
| 99 | Signal: Signal strength percentage (0-100). |
| -34 | RSSI: Recieved Signal Strength Indication in dBm. |

### Security Types

| Value | Description |
|-------|-------------|
| 1 | Authentication -> Open, Encryption -> None |
| 2 | Encryption -> WEP |
| 3 | Secure (WPA/WPA2/Other) |
