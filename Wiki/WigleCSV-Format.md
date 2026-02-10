# WiGLE CSV Format

## Overview

The WiGLE CSV format is a comma-separated value (CSV) file format used by WiGLE (Wireless Geographic Logging Engine) and compatible applications like Vistumbler for wireless network data interchange. The format adheres to UTF-8 encoded [RFC 4180](https://tools.ietf.org/html/rfc4180) with a mandatory pre-header row before the standard CSV header.

**Supported Versions:**
- **WigleWifi-1.4**: Legacy format with 11 columns (supported for import only)
- **WigleWifi-1.6**: Current format with 14 columns (default for export and import)

**Official Specification**: [https://api.wigle.net/csvFormat.html](https://api.wigle.net/csvFormat.html)

## File Structure

### Pre-Header Row

The first line contains metadata about the device and environment used for data collection. This is **not** a standard CSV header, but part of the RFC 4180 escaped data.

**Format:**
```
WigleWifi-[version],appRelease=[version],model=[device],release=[OS],device=[name],display=[display],board=[board],brand=[brand],star=[star],body=[orbit],subBody=[satellite]
```

**Example (v1.6):**
```
WigleWifi-1.6,appRelease=Vistumbler 10.8.2,model=Intel Wi-Fi 6 AX200,release=10.0.0,device=DESKTOP-PC,display=,board=,brand=Dell Inc.,star=Sol,body=3,subBody=0
```

**Example (v1.4):**
```
WigleWifi-1.4,appRelease=Vistumbler 10.8.2,model=Intel Wi-Fi 6 AX200,release=10.0.0,device=DESKTOP-PC,display=,board=,brand=Dell Inc.
```

#### Pre-Header Field Descriptions

| Field | Description | Vistumbler Source | Example |
|-------|-------------|-------------------|---------|
| **Format version** | File format identifier | Hardcoded: `WigleWifi-1.6` | `WigleWifi-1.6` |
| **appRelease** | Application name and version | `$Script_Name` + `$version` | `Vistumbler 10.8.2` |
| **model** | WiFi adapter description | `$DefaultApapterDesc` | `Intel Wi-Fi 6 AX200` |
| **release** | Operating system version | `$dev_version` (from WMI) | `10.0.0` |
| **device** | Computer/device name | `$dev_model` (from WMI) | `OptiPlex 7090` |
| **display** | Display characteristics | (empty in Vistumbler) | |
| **board** | Motherboard/processor info | (empty in Vistumbler) | |
| **brand** | Computer manufacturer | `$dev_brand` (from WMI) | `Dell Inc.` |
| **star** | Host star for observations | Hardcoded: `Sol` (v1.6 only) | `Sol` |
| **body** | Planetary orbit index | Hardcoded: `3` (Earth, v1.6 only) | `3` |
| **subBody** | Satellite orbit index | Hardcoded: `0` (planet, v1.6 only) | `0` |

**Note**: The `star`, `body`, and `subBody` fields were added in v1.6 for planetary coordinate systems. Earth is Sol's 3rd planet (body=3), with subBody=0 indicating the planet itself (not a moon).

### Header Row

The second line contains the column names:

**v1.6 Format (14 columns):**
```
MAC,SSID,AuthMode,FirstSeen,Channel,Frequency,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,RCOIs,MfgrId,Type
```

**v1.4 Format (11 columns):**
```
MAC,SSID,AuthMode,FirstSeen,Channel,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,Type
```

## Field Descriptions

### Common Fields (All Versions)

| Column | Field Name | Type | Description | Vistumbler Source |
|--------|------------|------|-------------|-------------------|
| 1 | **MAC** | String | BSSID (MAC address) in lowercase, colon-separated | `BSSID` (converted to lowercase) |
| 2 | **SSID** | String | Network name, RFC 4180 escaped | `SSID` (commas removed) |
| 3 | **AuthMode** | String | Capabilities/security flags in bracket notation | Derived from `AUTH` + `ENCR` + `NETTYPE` |
| 4 | **FirstSeen** | DateTime | First observation timestamp (UTC) | `Date1` + `Time1` from GPS table |
| 5 | **Channel** | Integer | WiFi channel number | `CHAN` |
| 6* | **RSSI** | Integer | Signal strength in dBm | `RSSI` |
| 7* | **CurrentLatitude** | Decimal | Latitude in decimal degrees | GPS `Latitude` (converted from DMM to DDD) |
| 8* | **CurrentLongitude** | Decimal | Longitude in decimal degrees | GPS `Longitude` (converted from DMM to DDD) |
| 9* | **AltitudeMeters** | Integer | Altitude in meters | GPS `Alt` |
| 10* | **AccuracyMeters** | Decimal | GPS accuracy estimate in meters | `HDOP × 5` |
| 11* | **Type** | String | Network type identifier | Hardcoded: `WIFI` |

**Note**: Fields marked with * shift position in v1.6 due to the inserted Frequency column.

### v1.6 Additional Fields

| Column | Field Name | Type | Description | Vistumbler Source |
|--------|------------|------|-------------|-------------------|
| 6 | **Frequency** | Integer | Center frequency in MHz | `_ChannelToFrequency($CHAN)` |
| 11 | **RCOIs** | String | Roaming Consortium OIs (space-delimited) | (empty for WiFi) |
| 12 | **MfgrId** | String | Manufacturer ID | (empty for WiFi) |

**Note**: RCOIs and MfgrId are reserved for Hotspot 2.0 and Bluetooth respectively, but are empty for standard WiFi networks in Vistumbler.

## AuthMode Field Format

The AuthMode field uses bracket notation to describe network capabilities, security, and network type.

### Security Flags

Vistumbler converts internal authentication and encryption types to WiGLE format using `_WigleCSV_BuildAuthMode()`:

| Vistumbler AUTH | Vistumbler ENCR | WiGLE AuthMode |
|-----------------|-----------------|----------------|
| WPA3-Enterprise | CCMP | `[WPA3-EAP-CCMP]` |
| WPA3-Enterprise | GCMP | `[WPA3-EAP-GCMP]` |
| WPA3-Personal | CCMP | `[WPA3-SAE-CCMP]` |
| WPA3-Personal | GCMP | `[WPA3-SAE-GCMP]` |
| WPA2-Enterprise | CCMP | `[WPA2-EAP-CCMP]` |
| WPA-Enterprise | CCMP | `[WPA-EAP-CCMP]` |
| WPA2-Personal | CCMP | `[WPA2-PSK-CCMP]` |
| WPA-Personal | CCMP | `[WPA-PSK-CCMP]` |
| WPA2-Enterprise | TKIP | `[WPA2-EAP-TKIP]` |
| WPA-Enterprise | TKIP | `[WPA-EAP-TKIP]` |
| WPA2-Personal | TKIP | `[WPA2-PSK-TKIP]` |
| WPA-Personal | TKIP | `[WPA-PSK-TKIP]` |
| Open | WEP | `[WEP]` |
| Open | None | (empty) |

**Security Notes:**
- **WPA3**: Uses SAE (Simultaneous Authentication of Equals) for Personal, EAP for Enterprise
- **GCMP**: Galois/Counter Mode Protocol, preferred cipher for WPA3 (stronger than CCMP)
- **CCMP**: Counter Mode with Cipher Block Chaining Message Authentication Code Protocol (AES)
- **TKIP**: Temporal Key Integrity Protocol (legacy, deprecated)

### Network Type Flag

An additional flag indicates the network topology:

- **`[ESS]`**: Infrastructure mode (most common, sometimes omitted)
- **`[IBSS]`**: Ad-hoc/peer-to-peer mode

**Examples:**
- `[WPA3-SAE-CCMP][ESS]` - WPA3-Personal with AES, infrastructure
- `[WPA3-EAP-GCMP][ESS]` - WPA3-Enterprise with GCMP, infrastructure
- `[WPA2-PSK-CCMP][ESS]` - WPA2-Personal with AES, infrastructure
- `[WPA2-EAP-CCMP][IBSS]` - WPA2-Enterprise with AES, ad-hoc
- `[WEP]` - WEP encryption
- (empty) - Open network

## Channel to Frequency Conversion

Vistumbler uses the `_ChannelToFrequency()` function in [Vistumbler.au3](Vistumbler/VistumblerMDB/Vistumbler.au3) to convert channel numbers to center frequencies in MHz. This supports all modern WiFi bands:

### 2.4 GHz Band (802.11b/g/n/ax)

| Channel Range | Formula | Example |
|---------------|---------|---------|
| 1-13 | $f = 2412 + (c - 1) \times 5$ | Ch 6 → 2437 MHz |
| 14 | $f = 2484$ | Ch 14 → 2484 MHz |

### 5 GHz Band (802.11a/n/ac/ax)

| Channel Range | Formula | Example |
|---------------|---------|---------|
| 32 | $f = 5160$ | Ch 32 → 5160 MHz |
| 34-48 (even) | $f = 5170 + (c - 34) \times 5$ | Ch 36 → 5180 MHz |
| 50-64 (even) | $f = 5250 + (c - 50) \times 5$ | Ch 52 → 5260 MHz |
| 68 | $f = 5340$ | Ch 68 → 5340 MHz |
| 96 | $f = 5480$ | Ch 96 → 5480 MHz |
| 100-144 (even) | $f = 5500 + (c - 100) \times 5$ | Ch 100 → 5500 MHz |
| 149-165 (odd) | $f = 5745 + (c - 149) \times 5$ | Ch 149 → 5745 MHz |
| 167-177 (odd) | $f = 5835 + (c - 167) \times 5$ | Ch 171 → 5855 MHz |
| 180-196 (select) | See table | Ch 183 → 5915 MHz |

### 6 GHz Band (802.11ax - WiFi 6E)

| Channel Range | Formula | Example |
|---------------|---------|---------|
| 1, 5, 9, 13... 233 | $f = 5955 + c \times 5$ | Ch 1 → 5960 MHz |

**Note**: 6 GHz channels are spaced every 4 channel numbers (1, 5, 9, 13...) representing 20 MHz channels.

## GPS Coordinate Conversion

Vistumbler internally stores GPS coordinates in **Degrees-Minutes (DMM)** format but WiGLE CSV requires **Decimal Degrees (DDD)** format. The WigleCSV UDF works with DDD format natively, while Vistumbler handles the conversions.

### Export Conversion (DMM → DDD)

**Function**: `_Format_GPS_DMM_to_DDD()` in [Vistumbler.au3](Vistumbler/VistumblerMDB/Vistumbler.au3)

**Format**: 
- DMM: `N 4042.7680` (40 degrees, 42.768 minutes North)
- DDD: `40.71280000` (decimal degrees)

**Formula**: 

$$\text{DDD} = \text{degrees} + \frac{\text{minutes}}{60}$$

**Hemisphere**: 
- North/East: Positive values
- South/West: Negative values (prepend `-` sign)

**Example Transformations:**
- `N 4042.7680` → `40.712800`
- `W 7135.2375` → `-71.587292`
- `S 3351.4200` → `-33.856667`
- `E 15112.3456` → `151.205760`

### Import Conversion (DDD → DMM)

**Function**: `_Format_GPS_DDD_to_DMM()` in [Vistumbler.au3](Vistumbler/VistumblerMDB/Vistumbler.au3)

**Steps**:
1. Extract degrees (integer part)
2. Convert decimal part to minutes: `(decimal × 60)`
3. Apply hemisphere character based on sign
4. Format as `H DDMM.MMMM`

## Data Row Examples

### v1.6 Format Example

```csv
1a:9f:ee:5c:71:c6,HomeNetwork,[WPA2-PSK-CCMP],2024-08-01 13:08:27,6,2437,-43,40.71280000,-71.58729167,67,16.08,,WIFI
```

**Breakdown**:
- MAC: `1a:9f:ee:5c:71:c6`
- SSID: `HomeNetwork`
- Security: WPA2-Personal with AES
- First seen: August 1, 2024 at 13:08:27 UTC
- Channel: 6 (2.4 GHz)
- Frequency: 2437 MHz
- Signal: -43 dBm
- Location: 40.71280°N, 71.58729°W
- Altitude: 67 meters
- GPS accuracy: 16.08 meters (HDOP of 3.216)
- Type: WiFi

### v1.4 Format Example

```csv
1a:9f:ee:5c:71:c6,HomeNetwork,[WPA2-PSK-CCMP],2024-08-01 13:08:27,6,-43,40.71280000,-71.58729167,67,16.08,WIFI
```

**Note**: Same data as v1.6 but without the Frequency column.

## Vistumbler Implementation

### WigleCSV UDF Library

Vistumbler uses a dedicated **UDF library** ([UDFs/WigleCSV.au3](Vistumbler/VistumblerMDB/UDFs/WigleCSV.au3)) for all WiGLE CSV operations. This library provides generic, reusable functions that can be used in any AutoIt project.

**UDF Functions:**
- `_WigleCSV_BuildAuthMode($auth, $encr, $nettype)` — Converts authentication/encryption to WiGLE capability flags (e.g., `[WPA3-SAE-CCMP][ESS]`)
- `_WigleCSV_ParseAuthMode($authmode)` — Parses WiGLE capability flags to extract auth, encryption, security type, and network type
- `_WigleCSV_WriteFile($filepath, $observations, $deviceinfo)` — Exports observation array to WigleCSV v1.6 file
- `_WigleCSV_ReadFile($filepath)` — Imports WigleCSV file (v1.4/v1.6) and returns standardized observation array

**Design Philosophy:**
- The UDF works with **WiGLE's native formats** (Decimal Degrees for GPS, frequency in MHz)
- GPS and frequency conversions are handled by the **calling application** (not duplicated in UDF)
- Follows the same pattern as NetXML.au3, KismetDB.au3, and NS1.au3

### Export Process

Vistumbler exports to WigleCSV via the `_ExportToWigleCSV()` function in [Vistumbler.au3](Vistumbler/VistumblerMDB/Vistumbler.au3) using the WigleCSV UDF library.

**Export Behavior**:
1. **Version**: Always exports v1.6 format
2. **Data Source**: Exports all signal history points, not just the highest signal
3. **Multiple Entries**: Each GPS point creates a separate row for the same BSSID
4. **Encoding**: UTF-8 with BOM (file mode 128 + 2)

### Export Workflow

```
For each Access Point in database:
  └─ For each History record (signal point):
      ├─ Retrieve GPS data from GpsID
      ├─ Convert GPS coordinates (DMM → DDD using _Format_GPS_DMM_to_DDD)
      ├─ Calculate frequency from channel (using _ChannelToFrequency)
      ├─ Calculate accuracy (HDOP × 5)
      └─ Build observation array [MAC, SSID, Auth, Encr, NetType, DateTime, Channel, Frequency, RSSI, Lat, Lon, Alt, Accuracy]

Call _WigleCSV_WriteFile() with:
  ├─ Observation array (13 elements per row)
  └─ Device metadata array [appRelease, model, release, device, brand]
```

### Signal History Export

Unlike the VS1 format which stores all history in one line, WiGLE CSV outputs **one row per signal observation**:

**VS1 (single line):**
```
HomeNetwork|1A:9F:EE:5C:71:C6|...|1,99,-34\2,88,-45\3,76,-56
```

**WiGLE CSV (three lines):**
```
1a:9f:ee:5c:71:c6,HomeNetwork,...,-34,...,WIFI
1a:9f:ee:5c:71:c6,HomeNetwork,...,-45,...,WIFI
1a:9f:ee:5c:71:c6,HomeNetwork,...,-56,...,WIFI
```

This creates larger files but provides individual GPS coordinates and timestamps for each observation.

### Import Process

Vistumbler imports from WigleCSV via the `_ImportWigleCSV()` function in [Vistumbler.au3](Vistumbler/VistumblerMDB/Vistumbler.au3) using the WigleCSV UDF library.

**Import Behavior**:
1. **Version Detection**: Automatically detects v1.4 (11 cols) or v1.6 (14 cols)
2. **Backward Compatibility**: Supports both formats
3. **Data Validation**: 
   - Filters out invalid dates (year 1969 or earlier)
   - Only imports `Type=WIFI` records
   - Skips rows with zero coordinates
4. **Duplicate Handling**: Checks for existing GPS and AP records to avoid duplication

### Import Workflow

```
Call _WigleCSV_ReadFile():
  ├─ Parse CSV file (using _ParseCSV from ParseCSV.au3)
  ├─ Detect version (11 cols = v1.4, 14 cols = v1.6)
  ├─ Parse AuthMode flags (using _WigleCSV_ParseAuthMode)
  ├─ Determine network type from flags ([ESS] vs [IBSS])
  ├─ Determine radio type from frequency (v1.6) or channel (v1.4)
  └─ Return standardized array [MAC, SSID, Auth, Encr, SecType, NetType, DateTime, Channel, Frequency, RSSI, Lat_DDD, Lon_DDD, Alt, Accuracy, RadType]

For each observation in returned array:
  ├─ Convert GPS coordinates (DDD → DMM using _Format_GPS_DDD_to_DMM)
  ├─ Calculate signal percentage from RSSI
  ├─ Check if GPS point already exists
  │   ├─ If exists: Use existing GpsID
  │   └─ If new: Create GPS record, get new GpsID
  └─ Add AP data with signal history point (using _AddApData)
```

### Security Translation (Import)

The import process parses AuthMode brackets using `_WigleCSV_ParseAuthMode()` to determine internal security settings:

| AuthMode Contains | Internal AUTH | Internal ENCR | Security Type |
|-------------------|---------------|---------------|---------------|
| `WPA2` + `CCMP` + `EAP` | WPA2-Enterprise | CCMP | 3 (Secure) |
| `WPA` + `CCMP` + `EAP` | WPA-Enterprise | CCMP | 3 (Secure) |
| `WPA2` + `CCMP` | WPA2-Personal | CCMP | 3 (Secure) |
| `WPA` + `CCMP` | WPA-Personal | CCMP | 3 (Secure) |
| `WPA2` + `TKIP` + `EAP` | WPA2-Enterprise | TKIP | 3 (Secure) |
| `WPA` + `TKIP` + `EAP` | WPA-Enterprise | TKIP | 3 (Secure) |
| `WPA2` + `TKIP` | WPA2-Personal | TKIP | 3 (Secure) |
| `WPA` + `TKIP` | WPA-Personal | TKIP | 3 (Secure) |
| `WEP` | Open | WEP | 2 (WEP) |
| (none) | Open | None | 1 (Open) |

### Radio Type Detection (Import)

**v1.6 Format** (frequency-based):
- 2412-2484 MHz → `802.11g` (2.4 GHz)
- 5160-5980 MHz → `802.11n` (5 GHz)
- 5955-7115 MHz → `802.11ax` (6 GHz, WiFi 6E)

**v1.4 Format** (channel-based fallback):
- Channels 1-14 → `802.11g`
- Channels > 14 → `802.11n`

**Note**: The radio type is a best-guess based on frequency band. Actual 802.11 standard (b/g/n/ac/ax) cannot be determined from WiGLE CSV alone.

## Format Comparison

| Feature | v1.4 | v1.6 | Vistumbler Support |
|---------|------|------|-------------------|
| **Columns** | 11 | 14 | Both |
| **Frequency Field** | ❌ | ✅ | Calculated on export |
| **RCOIs Field** | ❌ | ✅ | Empty (not used) |
| **MfgrId Field** | ❌ | ✅ | Empty (not used) |
| **Planetary Coordinates** | ❌ | ✅ | Earth (Sol 3,0) |
| **Export** | ❌ | ✅ | v1.6 only |
| **Import** | ✅ | ✅ | Both supported |

## Limitations

### Export Limitations

1. **Frequency Accuracy**: Only supports standard WiFi channels. Custom or DFS channels may not have accurate frequency mappings.
2. **RCOIs/MfgrId**: Always empty (Hotspot 2.0/Bluetooth not supported)
3. **Planetary Coordinates**: Hardcoded to Earth (Sol 3,0)
4. **File Size**: Large files due to one row per observation point
5. **Precision**: Signal history creates very large files for long-running captures

### Import Limitations

1. **Radio Type Guessing**: Cannot distinguish 802.11n from 802.11ac/ax on 5 GHz
2. **Limited Metadata**: No transfer rates, manufacturer info, or 802.11 capabilities
3. **v1.4 Frequency**: Channel-to-frequency conversion less accurate without explicit frequency field
4. **Duplicate Filtering**: Multiple observations of same AP may be consolidated if GPS coordinates match exactly

## File Extension

WiGLE CSV files typically use:
- **Recommended**: `.csv`
- **Alternative**: `.wiglecsv` (for explicit format identification)

## Comparison with Other Formats

| Format | Structure | History Storage | GPS Format | File Size | Compatibility |
|--------|-----------|-----------------|------------|-----------|---------------|
| **WiGLE CSV** | Text/CSV | Multiple rows per AP | Decimal degrees | Large | High (WiGLE, others) |
| **VS1** | Text/Delimited | Inline backslash-separated | Degrees-minutes | Medium | Vistumbler only |
| **NS1** | Binary | Inline array | Decimal degrees | Small | NetStumbler |
| **KML** | XML | No history | Decimal degrees | Small | Mapping apps |

**Best Use Cases for WiGLE CSV**:
- Data sharing with WiGLE.net
- Compatibility with third-party tools
- Long-term archival (human-readable)
- Multi-application workflows

**When to Use Other Formats**:
- **VS1**: Maximum detail preservation within Vistumbler ecosystem
- **NS1**: Compatibility with NetStumbler
- **KML**: Visualization in Google Earth/mapping applications

## Implementation Files

- **UDFs\WigleCSV.au3** — Generic WiGLE CSV library with import/export functions, AuthMode parsing, and flag building
- **UDFs\ParseCSV.au3** — CSV parsing library (dependency for WigleCSV.au3)
- **Vistumbler.au3** — Export (`_ExportToWigleCSV`) and Import (`_ImportWigleCSV`) functions, GPS/frequency conversions

## See Also

- [VS1 Format Documentation](VS1-Format.md) - Vistumbler's native detailed format
- [NS1 Format Documentation](NS1-Format.md) - NetStumbler binary format
- [KismetDB Format Documentation](KismetDB-Format.md) - Kismet's SQLite database format
- [NetXML Format Documentation](NetXML-Format.md) - Kismet's legacy XML format
- [WiGLE Official Specification](https://api.wigle.net/csvFormat.html)
- [RFC 4180 - CSV Format](https://tools.ietf.org/html/rfc4180)
