# NetStumbler Wi-Scan Text Format

## Overview

The wi-scan format is NetStumbler's text-based export format for wireless network data. These files typically use the `.txt` or `.ns1` extension and contain tab-separated values with header comments describing the format.

## File Structure

### Header Section

Wi-scan files begin with comment lines (starting with `#`) that describe the file metadata:

```
# $Creator: Network Stumbler Version 0.4.0
# $Format: wi-scan with extensions
# Latitude	Longitude	( SSID )	Type	( BSSID )	Time (GMT)	[ SNR Sig Noise ]	# ( Name )	Flags	Channelbits	BcnIntvl	DataRate	LastChannel
# $DateGMT: 2026-02-07
```

**Header Fields:**
- `$Creator`: Application name and version that created the file
- `$Format`: Format identifier (always "wi-scan with extensions")
- Column headers: Tab-separated list of field names
- `$DateGMT`: Date of capture in YYYY-MM-DD format

### Data Section

Each access point is represented by a single line with tab-separated values:

```
N 40.7128	W 74.0060	( MyNetwork )	BSS	( a4:12:34:56:78:90 )	14:30:25 (GMT)	[ 50 100 50 ]	# ( Unknown )	0011	00000800	1000	60	11
```

## Field Descriptions

| Field | Example | Description |
|-------|---------|-------------|
| **Latitude** | `N 40.7128` | Decimal degrees with hemisphere (N/S) |
| **Longitude** | `W 74.0060` | Decimal degrees with hemisphere (E/W) |
| **SSID** | `( MyNetwork )` | Network name in parentheses with spaces |
| **Type** | `BSS` | Network type: `BSS` (infrastructure) or `ad-hoc` |
| **BSSID** | `( a4:12:34:56:78:90 )` | MAC address in lowercase with colons, in parentheses |
| **Time** | `14:30:25 (GMT)` | Timestamp in HH:MM:SS format with timezone |
| **SNR/Signal/Noise** | `[ 50 100 50 ]` | Signal metrics in brackets: [SNR Signal Noise] |
| **Name** | `# ( Unknown )` | Manufacturer or description with `# ( )` |
| **Flags** | `0011` | 4-digit decimal flags (see Flags section) |
| **Channelbits** | `00000800` | 8-character hex channel bitmap |
| **BcnIntvl** | `1000` | Beacon interval in time units |
| **DataRate** | `60` | Maximum data rate in Mbps (0 for unknown) |
| **LastChannel** | `11` | Channel number (1-14 for 2.4GHz, 36+ for 5GHz) |

## GPS Coordinate Format

GPS coordinates are stored in **decimal degrees format** with hemisphere prefix:

- **Format**: `H DD.DDDDDDD` where H is N/S for latitude, E/W for longitude
- **Example**: `N 40.7128000` or `W 74.0060000`
- **Precision**: 7 decimal places
- **Zero coordinates**: `N 0.0000000` and `E 0.0000000` when GPS unavailable

**Important**: This differs from Vistumbler's internal storage (degrees-minutes format). Conversion is required:
- **Export**: Convert from DMM (`N 4042.7680`) to DDD (`N 40.7128000`)
- **Import**: Convert from DDD to DMM for internal storage

## Flags Field

The Flags field is a 4-digit decimal number representing network characteristics derived from the 802.11 capability flags.

### Bitfield Structure

| Bit Position | Decimal Value | Hex | Meaning |
|--------------|---------------|-----|----------|
| 0 | 1 | 0x0001 | ESS (Infrastructure/BSS mode) |
| 1 | 2 | 0x0002 | IBSS (Ad-hoc mode) |
| 4 | 16 | 0x0010 | Privacy/WEP enabled |

**Formula**: $\text{Flags} = \text{ESS} \times 2^0 + \text{IBSS} \times 2^1 + \text{Privacy} \times 2^4$

**Common Values:**
- `0001` (decimal 1, hex 0x0001) = Infrastructure, no encryption
- `0017` (decimal 17, hex 0x0011) = Infrastructure with WEP/encryption  
- `0002` (decimal 2, hex 0x0002) = Ad-hoc, no encryption
- `0018` (decimal 18, hex 0x0012) = Ad-hoc with WEP/encryption

**Note**: The wi-scan text format displays this as a zero-padded 4-digit decimal string, but the underlying binary NS1 format stores this as a `uint32` with the same bit positions.

## Channelbits Field

The Channelbits field is an 8-character hexadecimal string representing a 64-bit bitfield where each bit position represents a channel.

### Bitfield Formula

**Formula**: $\text{Channelbits} = 2^{(\text{Channel} - 1)}$ for 2.4GHz channels 1-14

**Multi-Channel Support**: This bitfield allows recording an access point seen on multiple channels simultaneously by OR-ing the bit values together. For example:
- AP seen on channels 1 and 6: $2^0 + 2^5 = 0x00000042$
- AP seen on channels 11 and 6: $2^{10} + 2^5 = 0x00000840$

### 2.4 GHz Channels (1-14)

| Channel | Bit Position | Formula | Hex Value |
|---------|--------------|---------|-----------|
| 1 | 0 | $2^0$ | 00000002 |
| 2 | 1 | $2^1$ | 00000004 |
| 3 | 2 | $2^2$ | 00000008 |
| 4 | 3 | $2^3$ | 00000010 |
| 5 | 4 | $2^4$ | 00000020 |
| 6 | 5 | $2^5$ | 00000040 |
| 7 | 6 | $2^6$ | 00000080 |
| 8 | 7 | $2^7$ | 00000100 |
| 9 | 8 | $2^8$ | 00000200 |
| 10 | 9 | $2^9$ | 00000400 |
| 11 | 10 | $2^{10}$ | 00000800 |
| 12 | 11 | $2^{11}$ | 00001000 |
| 13 | 12 | $2^{12}$ | 00002000 |
| 14 | 13 | $2^{13}$ | 00004000 |

### 5GHz Channels

**Note**: 5GHz channel mapping does not follow the simple $2^{(n-1)}$ formula. These use assigned bit positions:

| Channel | Bit Position | Hex Value |
|---------|--------------|-----------|
| 36 | 15 | 00008000 |
| 40 | 16 | 00010000 |
| 44 | 17 | 00020000 |
| 48 | 18 | 00040000 |
| 52 | 19 | 00080000 |
| 56 | 20 | 00100000 |
| 60 | 21 | 00200000 |
| 64 | 22 | 00400000 |
| 149 | 23 | 00800000 |
| 153 | 24 | 01000000 |
| 157 | 25 | 02000000 |
| 161 | 26 | 04000000 |
| 38 | 27 | 08000000 |
| 46 | 28 | 10000000 |
| 54 | 29 | 20000000 |
| 62 | 30 | 40000000 |
| 34 | 31 | 80000000 |

### Data Format Notes

- **Text Format**: 8-character uppercase hexadecimal string (e.g., `00000800`)
- **Binary Format**: Stored as `uint64` (8 bytes, little-endian) in NS1 binary files
- **Bit Capacity**: 64-bit field supports future expansion beyond current channel allocations
- **LastChannel Field**: Contains the single most recent/primary channel number for convenience

## Signal Strength Fields

The signal strength section `[ SNR Sig Noise ]` contains three space-separated values:

- **SNR** (Signal-to-Noise Ratio): Calculated as Signal - Noise
- **Signal**: Signal strength (0-150 scale or dBm+50)
- **Noise**: Noise floor (typically 50)

**Example**: `[ 60 110 50 ]`
- SNR = 60
- Signal = 110 (60 dBm signal = 110 on display)
- Noise = 50

## Example File

```
# $Creator: Network Stumbler Version 0.4.0
# $Format: wi-scan with extensions
# Latitude	Longitude	( SSID )	Type	( BSSID )	Time (GMT)	[ SNR Sig Noise ]	# ( Name )	Flags	Channelbits	BcnIntvl	DataRate	LastChannel
# $DateGMT: 2026-02-07
N 40.7128000	W 74.0060000	( CoffeeShopWiFi )	BSS	( a4:12:34:56:78:90 )	14:30:25 (GMT)	[ 60 110 50 ]	# ( Unknown )	0011	00000800	1000	60	11
N 40.7130000	W 74.0062000	( HomeNetwork5G )	BSS	( b8:27:eb:12:34:56 )	14:30:26 (GMT)	[ 45 95 50 ]	# ( Unknown )	0011	02000000	1000	0	157
N 40.7129000	W 74.0061000	( Guest-Network )	BSS	( c0:ff:ee:ca:fe:00 )	14:30:27 (GMT)	[ 30 80 50 ]	# ( Unknown )	0001	00000040	1000	90	6
```

## Vistumbler Implementation

### Export Process

Vistumbler exports to wi-scan format with the following conversions:

1. **GPS Coordinates**: Convert from internal DMM format to decimal degrees:
   ```autoit
   $GPS_Lat_DDD = _Format_GPS_DMM_to_DDD($Found_Lat)
   $GPS_Lon_DDD = _Format_GPS_DMM_to_DDD($Found_Lon)
   ```

2. **BSSID**: Convert to lowercase:
   ```autoit
   $Found_BSSID_Lower = StringLower($Found_BSSID)
   ```

3. **Timestamp**: Remove milliseconds:
   ```autoit
   $Found_Time_NoMs = StringLeft($Found_Time, 8)
   ```

4. **Name Field**: Use "Unknown" instead of manufacturer details for compatibility

5. **Signal Calculation**: 
   ```autoit
   Signal = RSSI + 50
   SNR = Signal - 50
   Noise = 50
   ```

### Import Process

Vistumbler imports wi-scan files with these conversions:

1. **GPS Coordinates**: Convert from decimal degrees to DMM format for internal storage:
   ```autoit
   $Lat_DMM = _Format_GPS_All_to_DMM($Latitude)
   $Lon_DMM = _Format_GPS_All_to_DMM($Longitude)
   ```

2. **Encryption Detection**: Parse Flags field:
   - If bit 4 is set (value >= 10): Network is encrypted
   - Otherwise: Encryption = "None"

3. **Network Type**: Parse Flags field:
   - If bit 1 is set (Flags & 2): Ad-hoc mode
   - If bit 0 is set (Flags & 1): Infrastructure mode

4. **BSSID**: Convert to uppercase for internal storage

### Auto-Detection

Vistumbler can auto-detect wi-scan text format vs binary NS1 format:

```autoit
Func _ImportNS1Auto($NS1file)
    Local $hFile = FileOpen($NS1file, 0)
    Local $sFirstLine = FileReadLine($hFile)
    FileClose($hFile)
    
    If StringLeft($sFirstLine, 1) = "#" Then
        _ImportNS1($NS1file)  ; Text format
    Else
        _ImportNS1Binary($NS1file)  ; Binary format
    EndIf
EndFunc
```

## Format Comparison: Text vs Binary

| Aspect | Wi-Scan Text | NS1 Binary |
|--------|-------------|------------|
| **File Extension** | .txt, .ns1 | .ns1 |
| **Human Readable** | Yes | No |
| **File Size** | Larger | Smaller |
| **GPS Format** | Decimal degrees | IEEE 754 double |
| **BSSID Case** | Lowercase | Mixed/uppercase |
| **Timestamps** | HH:MM:SS | Millisecond precision |
| **Ease of Parsing** | Simple (text) | Complex (binary) |
| **Compatibility** | Wide | NetStumbler-specific |

## Compatibility Notes

### NetStumbler Compatibility

To ensure files are compatible with NetStumbler:

1. Use lowercase BSSID format
2. GPS coordinates in decimal degrees with 7 decimal places
3. Format header exactly: `# $Format: wi-scan with extensions`
4. Name field as `# ( Unknown )` (no manufacturer details)
5. Timestamp without milliseconds
6. Tab-separated values (not spaces)

### Common Issues

1. **Invalid GPS Format**: Must use decimal degrees, not degrees-minutes
   - ❌ Wrong: `N 4042.7680`
   - ✅ Correct: `N 40.7128000`

2. **BSSID Case**: NetStumbler expects lowercase
   - ❌ Wrong: `A4:12:34:56:78:90`
   - ✅ Correct: `a4:12:34:56:78:90`

3. **Timestamp Format**: Must be HH:MM:SS, no milliseconds
   - ❌ Wrong: `14:30:25.521`
   - ✅ Correct: `14:30:25`

4. **Missing Spaces**: Parentheses require spaces
   - ❌ Wrong: `(MyNetwork)`
   - ✅ Correct: `( MyNetwork )`

## References

- NetStumbler: http://www.netstumbler.com/
- Wi-Scan Format Discussion: http://www.netstumbler.org/f4/
- Channel Bits Reference: http://www.netstumbler.org/f4/channelbits-8849/

## Version History

- **v1.0** - Initial documentation (2026-02-07)
  - Documented wi-scan text format structure
  - Vistumbler import/export implementation
  - GPS coordinate conversion details
  - NetStumbler compatibility requirements
