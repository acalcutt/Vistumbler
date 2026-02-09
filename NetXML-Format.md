# NetXML Format

The NetXML format is Kismet's legacy XML-based format for storing wireless network detections. These files are typically named `.netxml` and follow the schema defined by Kismet 3.1.0/oldcore. Vistumbler supports both importing and exporting this format for compatibility with older Kismet tools and third-party parsers like WifiDB.

## Format Overview

NetXML uses a hierarchical XML structure to define detection runs, devices, and associated metadata. It is human-readable but verbose compared to modern database formats.
- **Root Element**: `<detection-run>`
- **Key Elements**: `<wireless-network>`, `<SSID>`, `<gps-info>`, `<snr-info>`
- **DTD Reference**: `http://kismetwireless.net/kismet-3.1.0.dtd`

## XML Schema Structure

### Root: detection-run

The top-level container for a session.

| Attribute | Description |
|-----------|-------------|
| kismet-version | The software version that generated the file (e.g., "Vistumbler") |
| start-time | The run start timestamp (formatting varies, typically textual) |

### wireless-network

Represents a single wireless access point or ad-hoc cell.

| Attribute/Tag | Description |
|---------------|-------------|
| type | Network type (e.g., `"infrastructure"`, `"ad-hoc"`) |
| first-time | Timestamp of first detection |
| last-time | Timestamp of last detection |
| BSSID | MAC address of the AP (`AA:BB:CC:DD:EE:FF`) |
| manuf | Manufacturer string (e.g., `"Cisco Systems"`) |
| channel | Channel number (e.g., `6`, `36`) |
| freqmhz | Frequency in MHz (e.g., `2437 0`) - note space separated triplet in some implementations but Vistumbler often writes simplified format |
| maxseenrate | Maximum data rate detected (e.g., `54.0`) |

### SSID

Detailed information about the network name.

| Tag | Description |
|-----|-------------|
| type | SSID availability type (`Beacon`, `ProbeResponse`) |
| encryption | Encryption string (e.g., `"WPA+PSK"`, `"WEP"`, `"None"`) |
| essid | The actual SSID name (encoded for XML safety) |
| essid cloaked | Attribute `"true"` or `"false"` |
| max-rate | Max supported rate |
| packets | Count of packets (Vistumbler often defaults this to `0` for basic AP lists) |
| beaconrate | Beacon interval (often `10` or `100`) |

### snr-info

Signal-to-Noise Ratio and signal strength statistics. Values are typically in dBm or RSSI.

| Tag | Description |
|-----|-------------|
| last_signal_dbm | Most recent signal level in dBm |
| max_signal_dbm | Strongest signal level observed |
| min_signal_dbm | Weakest signal level observed |
| *_noise_dbm | Noise floor levels (often `0` in passive scans without noise data) |
| *_rssi | Raw RSSI values (often mirrored from dBm in some tools) |

### gps-info

Aggregate GPS statistics for the device.

| Tag | Description |
|-----|-------------|
| min-lat/lon/alt | Coordinates at minimum bounds |
| max-lat/lon/alt | Coordinates at maximum bounds |
| peak-lat/lon/alt | Coordinates at location of strongest signal |
| avg-lat/lon/alt | Averaged center of the device location |
| *-spd | Speed metadata associated with the GPS fix |

## Example Snippet

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE detection-run SYSTEM "http://kismetwireless.net/kismet-3.1.0.dtd">
<detection-run kismet-version="Vistumbler" start-time="Fri Feb 09 10:00:00 2024">
  <card-source uuid="00000000-0000-0000-0000-000000000000">vistumbler</card-source>
  <wireless-network number="0" type="infrastructure" first-time="Fri Feb 09 10:01:00 2024" last-time="Fri Feb 09 10:05:00 2024">
    <SSID first-time="Fri Feb 09 10:01:00 2024" last-time="Fri Feb 09 10:05:00 2024">
      <type>infrastructure</type>
      <max-rate>54.0</max-rate>
      <packets>0</packets>
      <beaconrate>10</beaconrate>
      <encryption>WPA2</encryption>
      <essid cloaked="false">MyWiFiNetwork</essid>
    </SSID>
    <BSSID>00:11:22:33:44:55</BSSID>
    <manuf>Example Corp</manuf>
    <channel>6</channel>
    <freqmhz>2437 0</freqmhz>
    <maxseenrate>54.0</maxseenrate>
    <snr-info>
      <last_signal_dbm>-60</last_signal_dbm>
      <last_noise_dbm>0</last_noise_dbm>
      <last_signal_rssi>-60</last_signal_rssi>
      <last_noise_rssi>0</last_noise_rssi>
      <min_signal_dbm>-80</min_signal_dbm>
      <min_noise_dbm>0</min_noise_dbm>
      <min_signal_rssi>-80</min_signal_rssi>
      <min_noise_rssi>0</min_noise_rssi>
      <max_signal_dbm>-50</max_signal_dbm>
      <max_noise_dbm>0</max_noise_dbm>
      <max_signal_rssi>-50</max_signal_rssi>
      <max_noise_rssi>0</max_noise_rssi>
    </snr-info>
    <gps-info>
      <min-lat>40.7128</min-lat>
      <min-lon>-74.0060</min-lon>
      <min-alt>10.0</min-alt>
      <min-spd>0.0</min-spd>
      <max-lat>40.7128</max-lat>
      <max-lon>-74.0060</max-lon>
      <max-alt>10.0</max-alt>
      <max-spd>0.0</max-spd>
      <peak-lat>40.7128</peak-lat>
      <peak-lon>-74.0060</peak-lon>
      <peak-alt>10.0</peak-alt>
      <peak-spd>0.0</peak-spd>
      <avg-lat>40.7128</avg-lat>
      <avg-lon>-74.0060</avg-lon>
      <avg-alt>10.0</avg-alt>
      <avg-spd>0.0</avg-spd>
    </gps-info>
    <datasize>0</datasize>
  </wireless-network>
</detection-run>
```
