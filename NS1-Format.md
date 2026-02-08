# NetStumbler NS1 Binary Format

The NetStumbler NS1 file format is a binary format originally created by NetStumbler for storing WiFi access point data and signal history. Vistumbler supports reading and writing NS1 files in version 12 format for compatibility with NetStumbler.

## Format Overview

Unlike Vistumbler's text-based VS1 and CSV formats, NS1 is a binary format that stores:
- Access Point metadata (SSID, BSSID, signal statistics, capabilities)
- Signal history with timestamps
- GPS coordinates in decimal degrees (if available)
- Network configuration details

## File Version Support

Vistumbler implements **NS1 File Version 12**, the latest version used by NetStumbler 0.4.0. This version includes:
- AP miscellaneous flags
- IP subnet and mask information
- Full GPS data support
- 802.11 Information Elements (when available)

## Binary Structure

### NS1 File Header

All NS1 files start with this header:

| Size | Type | Name | Description |
|------|------|------|-------------|
| 4 bytes | char[4] | dwSignature | File signature ('NetS') |
| 4 bytes | uint32 | dwFileVer | File format version (12) |
| 4 bytes | uint32 | ApCount | Number of access points in file |

### APINFO Entry (Per Access Point)

Each access point in the file contains:

| Size | Type | Name | Description |
|------|------|------|-------------|
| 1 byte | uint8 | SSIDLength | Length of SSID string |
| Variable | char[] | SSID | SSID (no null terminator) |
| 6 bytes | uint8[6] | BSSID | MAC address of AP |
| 4 bytes | int32 | MaxSignal | Maximum signal level (dBm) |
| 4 bytes | int32 | MinNoise | Minimum noise level (dBm) |
| 4 bytes | int32 | MaxSNR | Maximum signal-to-noise ratio (dB) |
| 4 bytes | uint32 | Flags | 802.11 capability flags |
| 4 bytes | uint32 | BeaconInterval | Beacon interval (μs) |
| 8 bytes | FILETIME | FirstSeen | First detection timestamp |
| 8 bytes | FILETIME | LastSeen | Last detection timestamp |
| 8 bytes | double | BestLat | Estimated latitude (decimal degrees) |
| 8 bytes | double | BestLong | Estimated longitude (decimal degrees) |
| 4 bytes | uint32 | DataCount | Number of signal history entries |
| Variable | APDATA[] | ApData | Signal history entries |
| 1 byte | uint8 | NameLength | Length of AP name |
| Variable | char[] | Name | AP name (no null terminator) |
| 8 bytes | uint64 | Channels | Channel activity bit field |
| 4 bytes | uint32 | LastChannel | Last reported channel |
| 4 bytes | uint32 | IPAddress | AP IP address |
| 4 bytes | int32 | MinSignal | Minimum signal level (dBm) |
| 4 bytes | int32 | MaxNoise | Maximum noise level (dBm) |
| 4 bytes | uint32 | DataRate | Maximum data rate (×100 kbps) |
| 4 bytes | uint32 | IPSubnet | IP subnet address |
| 4 bytes | uint32 | IPMask | IP subnet mask |
| 4 bytes | uint32 | ApFlags | Miscellaneous flags |
| 4 bytes | uint32 | IELength | Information Elements length |
| Variable | uint8[] | InformationElements | 802.11 IE data |

### Channel Bitmask Mapping

The `Channels` field is a 64-bit integer representing activity on specific channels. Vistumbler maps channels to bit positions as follows:

**2.4 GHz Band:**
- Channels 1-14 map directly to bits 1-14.

**5 GHz Band Mapping:**
| Channel | Bit Position | Value (Hex) |
|---------|--------------|-------------|
| 34 | 31 | 0x80000000 |
| 36 | 15 | 0x00008000 |
| 38 | 27 | 0x08000000 |
| 40 | 16 | 0x00010000 |
| 42 | 32 | 0x100000000 |
| 44 | 17 | 0x00020000 |
| 46 | 28 | 0x10000000 |
| 48 | 18 | 0x00040000 |
| 52 | 19 | 0x00080000 |
| 54 | 29 | 0x20000000 |
| 56 | 20 | 0x00100000 |
| 60 | 21 | 0x00200000 |
| 62 | 30 | 0x40000000 |
| 64 | 22 | 0x00400000 |
| 149 | 23 | 0x00800000 |
| 153 | 24 | 0x01000000 |
| 157 | 25 | 0x02000000 |
| 161 | 26 | 0x04000000 |

**Unsupported Bitmask Channels:**
The following channels do not have a known legacy bitmask mapping in NetStumbler 0.4.0. For these channels, the `Channels` bitfield is set to `0`, and the channel number is stored only in the `LastChannel` field. NetStumbler typically displays these channels in brackets (e.g., `[37]`, `[100]`).
- **Low 5GHz:** 37, 50, 58
- **DFS / Mid 5GHz:** 100, 104, 108, 112, 116, 120, 124, 128, 132, 133, 136, 140, 144
- **High 5GHz:** 165

### APDATA Entry (Signal History Point)

Each signal measurement contains:

| Size | Type | Name | Description |
|------|------|------|-------------|
| 8 bytes | FILETIME | Time | Measurement timestamp |
| 4 bytes | int32 | Signal | Signal level (dBm) |
| 4 bytes | int32 | Noise | Noise level (dBm) |
| 4 bytes | int32 | LocationSource | GPS fix type (0=None, 1=GPS) |
| Variable | GPSDATA | GpsData | GPS data (only if LocationSource=1) |

### GPSDATA Entry (GPS Coordinates)

When GPS data is available (LocationSource=1):

| Size | Type | Name | Description |
|------|------|------|-------------|
| 8 bytes | double | Latitude | Latitude (decimal degrees) |
| 8 bytes | double | Longitude | Longitude (decimal degrees) |
| 8 bytes | double | Altitude | Altitude (meters) |
| 4 bytes | uint32 | NumSats | Number of satellites |
| 8 bytes | double | Speed | Speed (km/h) |
| 8 bytes | double | Track | Track angle (degrees) |
| 8 bytes | double | MagVariation | Magnetic variation |
| 8 bytes | double | Hdop | Horizontal dilution of precision |

## Vistumbler Implementation Notes

### GPS Coordinate Conversion

Vistumbler stores GPS coordinates internally in degrees-minutes format (e.g., "N 3551.9912"), but NS1 requires decimal degrees.

**Export conversion (DMM → Decimal Degrees):**
```
Input:  "N 3551.9912" (35 degrees, 51.9912 minutes North)
Output: 35.86652 (decimal degrees)
```

**Import conversion (Decimal Degrees → DMM):**
```
Input:  35.86652 (decimal degrees)
Output: "N 3551.9912" (35 degrees, 51.9912 minutes North)
```

### Data Type Notes

- **FILETIME**: 64-bit integer representing 100-nanosecond intervals since January 1, 1601 UTC
- **All integers**: Little-endian byte order (least significant byte first)
- **No padding**: Structures are packed with no alignment padding
- **Doubles**: IEEE 754 64-bit floating point format

### Supported Fields in Export

When exporting from Vistumbler to NS1, the following mappings are used:

| Vistumbler Field | NS1 Field | Notes |
|------------------|-----------|-------|
| SSID | SSID | Direct copy |
| BSSID | BSSID | MAC address |
| HighSignal | MaxSignal | Converted to int32 |
| HighRSSI | MaxSNR | Signal-to-noise ratio |
| FirstActive | FirstSeen | Converted to FILETIME |
| LastActive | LastSeen | Converted to FILETIME |
| Latitude/Longitude | BestLat/BestLong | Converted to decimal degrees |
| Channel | LastChannel | Primary channel |
| Signal (from Hist) | APDATA.Signal | Per-sample signal |
| GPS data | GPSDATA | Converted to decimal degrees |

### Limitations

- **Information Elements**: Vistumbler does not currently store 802.11 IEs, so IELength is always 0
- **IP Information**: IP address, subnet, and mask fields are set to 0
- **AP Flags**: Currently set to 0
- **Noise Data**: Set to 0 if not available in Vistumbler database
- **Data Rate**: Set to 0 if not available

## Example File Structure

A conceptual view of an NS1 file with 2 APs:

```
[File Header]
  Signature: "NetS"
  Version: 12
  ApCount: 2

[AP #1: "EIHOME-N"]
  SSID: "EIHOME-N" (8 bytes)
  BSSID: C0:C1:C0:A1:65:6B
  MaxSignal: -44 dBm
  ...
  BestLat: 35.86652
  BestLong: 140.01440
  DataCount: 2
  
  [Signal Point #1]
    Time: 2013-05-02 01:07:19.901
    Signal: -45 dBm
    LocationSource: 1 (GPS)
    GPS: 35.86652, 140.01440, 25m alt
  
  [Signal Point #2]
    Time: 2013-05-02 01:07:20.909
    Signal: -44 dBm
    LocationSource: 1 (GPS)
    GPS: 35.86653, 140.01441, 26m alt

[AP #2: "EIHOME-G"]
  SSID: "EIHOME-G" (8 bytes)
  BSSID: C0:C1:C0:A1:65:6A
  MaxSignal: -49 dBm
  ...
  DataCount: 4
  [4 signal points...]
```

## Compatibility

NS1 files created by Vistumbler are compatible with:
- **NetStumbler 0.4.0** and 0.3.99 (reads version 12 files)
- **Other NS1 readers** that support file version 12

Files can be imported back into Vistumbler, maintaining GPS coordinates and signal history.

## See Also

- [VS1 Format](VS1-Format.md) - Vistumbler's native XML-based format
- [Detailed CSV Format](CSV-Format.md) - Human-readable export format
- [Original NS1 Specification](http://www.stumbler.net/ns1files.html) - NetStumbler's official documentation

## Implementation Files

- **UDFs\NS1.au3** - Binary serialization/deserialization library
- **Vistumbler.au3** - Export (_ExportNS1Binary) and Import (_ImportNS1Binary) functions
