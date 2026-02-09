# KismetDB (.kismet) Format

The KismetDB format is Kismet's SQLite-based database for storing wireless network captures. Files use the `.kismet` extension and contain device metadata, raw packet captures, GPS data, alerts, and data source information. Vistumbler supports both reading and writing KismetDB files for interoperability with Kismet.

## Format Overview

Unlike binary or text-based formats, KismetDB uses a standard **SQLite 3** database. This provides:
- Structured storage with SQL query capability
- Device metadata stored as JSON BLOBs in the `devices` table
- Raw packet data stored as binary BLOBs in the `packets` table
- GPS coordinates, signal strength, and timestamps per packet
- Self-describing schema via the `KISMET` metadata table

## Database Version

Vistumbler implements **KismetDB Version 10**, matching modern Kismet releases (2023+). The version is stored in the `KISMET` table and determines schema compatibility.

## Database Schema

### KISMET Table (Metadata)

Stores database-level metadata. Always contains exactly one row.

| Column | Type | Description |
|--------|------|-------------|
| kismet_version | TEXT | Kismet version string (e.g., `"2023-07"`) |
| db_version | INTEGER | Database schema version (`10`) |
| db_module | TEXT | Module name (always `"kismetlog"`) |

### devices Table

Stores one row per unique device (AP, client, etc.) with a JSON BLOB containing the full device state.

| Column | Type | Description |
|--------|------|-------------|
| first_time | INTEGER | Unix epoch timestamp of first detection |
| last_time | INTEGER | Unix epoch timestamp of last detection |
| devkey | TEXT | Unique device key |
| phyname | TEXT | PHY layer name (e.g., `"IEEE802.11"`) |
| devmac | TEXT | Device MAC address (e.g., `"AA:BB:CC:DD:EE:FF"`) |
| strongest_signal | INTEGER | Strongest observed signal (dBm, e.g., `-45`) |
| min_lat | REAL | Minimum observed latitude (decimal degrees) |
| min_lon | REAL | Minimum observed longitude (decimal degrees) |
| max_lat | REAL | Maximum observed latitude (decimal degrees) |
| max_lon | REAL | Maximum observed longitude (decimal degrees) |
| avg_lat | REAL | Average latitude (decimal degrees) |
| avg_lon | REAL | Average longitude (decimal degrees) |
| bytes_data | INTEGER | Total data bytes observed |
| type | TEXT | Device type (e.g., `"Wi-Fi AP"`, `"Wi-Fi Ad-Hoc"`) |
| device | BLOB | JSON object containing full device state (see below) |

**Indexes:**
- `idx_devices_devkey` on `devkey`
- `idx_devices_devmac` on `devmac`

**Unique constraint:** `UNIQUE(phyname, devmac) ON CONFLICT REPLACE`

### packets Table

Stores individual captured packets with raw packet data as BLOBs.

| Column | Type | Description |
|--------|------|-------------|
| ts_sec | INTEGER | Unix epoch timestamp (seconds) |
| ts_usec | INTEGER | Microseconds portion of timestamp |
| phyname | TEXT | PHY layer name |
| sourcemac | TEXT | Source MAC address |
| destmac | TEXT | Destination MAC address |
| transmac | TEXT | Transmitter MAC address |
| frequency | REAL | Center frequency in KHz |
| devkey | TEXT | Device key reference |
| lat | REAL | Latitude at capture time (decimal degrees) |
| lon | REAL | Longitude at capture time (decimal degrees) |
| alt | REAL | Altitude at capture time (meters) |
| speed | REAL | Speed at capture time |
| heading | REAL | Heading at capture time (degrees) |
| packet_len | INTEGER | Length of packet data in bytes |
| signal | INTEGER | Signal strength (dBm) |
| datasource | TEXT | UUID of the capture data source |
| dlt | INTEGER | Data link type (127 = IEEE 802.11 with Radiotap) |
| packet | BLOB | Raw packet data (Radiotap + 802.11 frame) |
| error | INTEGER | Error flag (0 = no error) |
| tags | TEXT | Space-separated packet tag labels (see [Packet Tags](#packet-tags-vistumbler-original-signal)) |
| datarate | REAL | Data rate |
| hash | INTEGER | Packet hash |
| packetid | INTEGER | Unique packet identifier |
| packet_full_len | INTEGER | Full packet length (may differ from stored length) |

**Index:** `idx_packets_sourcemac` on `sourcemac`

### datasources Table

Stores capture data source configuration.

| Column | Type | Description |
|--------|------|-------------|
| uuid | TEXT | Unique data source identifier |
| typestring | TEXT | Source type (e.g., `"vistumbler"`, `"linuxwifi"`) |
| definition | TEXT | Source definition string |
| name | TEXT | Human-readable source name |
| interface | TEXT | Capture interface name |
| json | BLOB | JSON configuration object |

**Unique constraint:** `UNIQUE(uuid) ON CONFLICT REPLACE`

### alerts Table

Stores Kismet alert/IDS events.

| Column | Type | Description |
|--------|------|-------------|
| ts_sec | INTEGER | Unix epoch timestamp |
| ts_usec | INTEGER | Microseconds portion |
| phyname | TEXT | PHY layer name |
| devmac | TEXT | Device MAC triggering alert |
| lat | REAL | Latitude |
| lon | REAL | Longitude |
| header | TEXT | Alert header/title |
| json | BLOB | Full alert details as JSON |

### data Table

Stores non-packet data records.

| Column | Type | Description |
|--------|------|-------------|
| ts_sec | INTEGER | Unix epoch timestamp |
| ts_usec | INTEGER | Microseconds portion |
| phyname | TEXT | PHY layer name |
| devmac | TEXT | Device MAC address |
| lat | REAL | Latitude |
| lon | REAL | Longitude |
| alt | REAL | Altitude |
| speed | REAL | Speed |
| heading | REAL | Heading |
| datasource | TEXT | Data source UUID |
| type | TEXT | Data type identifier |
| json | BLOB | JSON data object |
| signal | INTEGER | Signal strength |

### messages Table

Stores Kismet system/log messages.

| Column | Type | Description |
|--------|------|-------------|
| ts_sec | INTEGER | Unix epoch timestamp |
| lat | REAL | Latitude |
| lon | REAL | Longitude |
| alt | REAL | Altitude |
| speed | REAL | Speed |
| heading | REAL | Heading |
| msgtype | TEXT | Message type/severity |
| message | TEXT | Message text |

### snapshots Table

Stores device state snapshots.

| Column | Type | Description |
|--------|------|-------------|
| ts_sec | INTEGER | Unix epoch timestamp |
| ts_usec | INTEGER | Microseconds portion |
| lat | REAL | Latitude |
| lon | REAL | Longitude |
| snaptype | TEXT | Snapshot type identifier |
| json | TEXT | JSON snapshot data |

## Device JSON Structure

The `device` column in the `devices` table contains a JSON object with the full device state. This is the richest data source in the database.

### Key Fields

```json
{
  "kismet.device.base.key": "AA:BB:CC:DD:EE:FF",
  "kismet.device.base.macaddr": "AA:BB:CC:DD:EE:FF",
  "kismet.device.base.name": "MyNetwork",
  "kismet.device.base.commonname": "MyNetwork",
  "kismet.device.base.phyname": "IEEE802.11",
  "kismet.device.base.manuf": "NETGEAR",
  "kismet.device.base.channel": "6",
  "kismet.device.base.frequency": 2437000,
  "kismet.device.base.crypt_string": "WPA2 WPA2-PSK AES-CCMP",
  "kismet.device.base.type": "Wi-Fi AP",
  "vistumbler.device.radio_type": "802.11ax",
  "dot11.device": { ... }
}
```

### Vistumbler Custom Extension: Radio Type

Vistumbler stores the Wi-Fi radio type (e.g., `802.11ax`, `802.11ac`, `802.11n`) in a custom JSON field:

```json
"vistumbler.device.radio_type": "802.11ax"
```

This field is a **Vistumbler-specific extension** — Kismet ignores unknown keys, so it does not affect Kismet compatibility. It preserves the radio type through KismetDB export/import round-trips.

**Common values:**

| Value | Description |
|-------|-------------|
| `802.11be` | Wi-Fi 7 |

| `802.11ax` | Wi-Fi 6/6E |
| `802.11ac` | Wi-Fi 5 |
| `802.11n` | Wi-Fi 4 |
| `802.11g` | Wi-Fi 3 |
| `802.11b` | Wi-Fi 1 |
| `802.11a` | Wi-Fi 2 (5 GHz legacy) |

**Import fallback:** When importing real Kismet files (which don't contain this field), the radio type is inferred from `kismet.device.base.frequency`:

| Frequency Range | Inferred Radio Type |
|-----------------|---------------------|
| ≥ 5925 MHz (6 GHz band) | `802.11ax` |
| 4900–5900 MHz (5 GHz band) | `802.11ac` |
| 2400–2500 MHz (2.4 GHz band) | `802.11n` |
| Other / unknown | `Unknown` |

### Packet Tags: Vistumbler Original Signal (`VISTUMBLER_SIG`)

Kismet's `packets.tags` column stores **space-separated string labels** (tag names). In the Kismet source code:

- **Writing:** Kismet iterates the packet's in-memory `tag_map` (a `map<string, bool>` — presence-only keys) and joins all keys with spaces into a single TEXT string. For example, a packet with tags `WARDRIVE` and `INDOOR` would be stored as `"WARDRIVE INDOOR"`.
- **Parsing:** Kismet tools (`kismetdb_to_pcap`, `kismetdb_statistics`) split the tags string on spaces and treat each word as a distinct tag name.
- **Filtering:** Kismet's `--tag` CLI option and REST API use SQL `LIKE %tagname%` to match specific tags.

Tags are label-only (no native key=value support), but since each tag is a freeform string, using `KEY=VALUE` as a tag name is fully compatible.

**Vistumbler usage:** Vistumbler stores the original adapter-reported signal percentage in the `tags` column using a labeled tag:

```
VISTUMBLER_SIG=83
```

This preserves the original Windows adapter signal percentage (0–100%) through KismetDB round-trips. Without this, reimported signal values would only reflect the RSSI-to-percentage formula approximation (`_DbToSignalPercent()`), which differs from the original adapter-reported values.

**Export:** Each packet written to the `packets` table includes the original signal percentage as a `VISTUMBLER_SIG=N` tag. If the AP had signal 83%, the tags column contains `"VISTUMBLER_SIG=83"`.

**Import:** On reimport, the tags string is split on spaces and searched for a tag starting with `VISTUMBLER_SIG=`. If found, the number after `=` is used as the original signal percentage. If not found (real Kismet files, or files without this tag), the import falls back to the RSSI-to-percentage formula conversion.

**Compatibility:**
- Kismet sees `VISTUMBLER_SIG=83` as a valid tag label — it is completely harmless and ignored during normal Kismet processing.
- `kismetdb_statistics --list-tags` will display `VISTUMBLER_SIG=83` in the tag list.
- `kismetdb_to_pcap --tag VISTUMBLER_SIG=83` can filter by specific signal values.
- If Kismet writes other tags to the same packet, they coexist as space-separated entries (e.g., `"WARDRIVE VISTUMBLER_SIG=83"`).
- Real Kismet files have empty tags or non-matching tag names, so the fallback to RSSI conversion is triggered automatically.

### Encryption String (`crypt_string`)

Kismet stores encryption as a **space-separated string** of capability tokens. This differs from Vistumbler's `Auth/Encr` slash-separated format.

**Real Kismet examples:**
| crypt_string Value | Auth | Cipher |
|--------------------|------|--------|
| `"WPA2 WPA2-PSK AES-CCMP"` | WPA2-Personal | CCMP |
| `"WPA2 WPA2-1X AES-CCMP"` | WPA2-Enterprise | CCMP |
| `"WPA WPA-PSK TKIP"` | WPA-Personal | TKIP |
| `"WPA3 SAE AES-CCMP"` | WPA3-Personal | CCMP |
| `"WEP"` | Open | WEP |
| `"Open"` or `""` | Open | None |

**Vistumbler export format:**
| crypt_string Value | Auth | Cipher |
|--------------------|------|--------|
| `"WPA2-Personal/CCMP"` | WPA2-Personal | CCMP |
| `"WPA2-Enterprise/CCMP"` | WPA2-Enterprise | CCMP |
| `"Open/None"` | Open | None |

### Dot11 Device Sub-Object

The `dot11.device` nested object contains 802.11-specific device information:

```json
{
  "dot11.device": {
    "dot11.device.last_beaconed_ssid": "MyNetwork",
    "dot11.device.last_beaconed_ssid_checksum": 12345678,
    "dot11.device.num_advertised_ssids": 1,
    "dot11.device.last_beaconed_ssid_record": {
      "dot11.advertisedssid.ssid": "MyNetwork",
      "dot11.advertisedssid.ssidlen": 9,
      "dot11.advertisedssid.crypt_set": 68721328138,
      "dot11.advertisedssid.channel": "6"
    },
    "dot11.device.advertised_ssid_map": {
      "12345678": {
        "dot11.advertisedssid.ssid": "MyNetwork",
        "dot11.advertisedssid.channel": "6",
        "dot11.advertisedssid.crypt_string": "WPA2 WPA2-PSK AES-CCMP"
      }
    }
  }
}
```

### Multi-Entry SSID Map (Same BSSID, Different Auth/Encr)

In Vistumbler, an AP with the same BSSID but different authentication (e.g., WPA2-Personal and WPA3-Personal on the same radio) is tracked as separate AP entries. However, KismetDB enforces `UNIQUE(phyname, devmac) ON CONFLICT REPLACE`, allowing only one device record per MAC address.

**Export:** When multiple Vistumbler APs share the same BSSID, they are merged into a single KismetDB device with multiple entries in the `advertised_ssid_map`. Each entry carries its own `dot11.advertisedssid.crypt_string` field in Vistumbler's `Auth/Encr` format (e.g., `"WPA2-Personal/CCMP"`). Map keys are computed as checksums of `"SSID|channel|encryption"` to ensure uniqueness.

**Import:** On reimport, all entries in `advertised_ssid_map` are iterated. Each entry with a distinct `crypt_string` creates a separate AP. Packet history is shared (duplicated) across all APs from the same device.

```json
{
  "dot11.device": {
    "dot11.device.last_beaconed_ssid": "MyNetwork",
    "dot11.device.num_advertised_ssids": 2,
    "dot11.device.advertised_ssid_map": {
      "83927451": {
        "dot11.advertisedssid.ssid": "MyNetwork",
        "dot11.advertisedssid.ssidlen": 9,
        "dot11.advertisedssid.channel": "6",
        "dot11.advertisedssid.crypt_set": 706,
        "dot11.advertisedssid.crypt_string": "WPA2-Personal/CCMP"
      },
      "41829375": {
        "dot11.advertisedssid.ssid": "MyNetwork",
        "dot11.advertisedssid.ssidlen": 9,
        "dot11.advertisedssid.channel": "6",
        "dot11.advertisedssid.crypt_set": 706,
        "dot11.advertisedssid.crypt_string": "WPA3-Personal/CCMP"
      }
    }
  }
}
```

### GPS Location Object

Real Kismet stores GPS data in a nested location structure with geopoint arrays:

```json
{
  "kismet.device.base.location": {
    "kismet.common.location.avg_loc": {
      "kismet.common.location.geopoint": [ -74.006, 40.7128 ]
    },
    "kismet.common.location.last": {
      "kismet.common.location.geopoint": [ -74.006, 40.7128 ]
    }
  }
}
```

**Important:** Geopoint arrays are `[longitude, latitude]` — note the reversed order from typical lat/lon conventions.

Vistumbler export files store GPS in the `avg_lat`/`avg_lon` columns of the `devices` table directly, and do not include the nested location object.

## Packet BLOB Format

Each packet stored in the `packets` table is a binary BLOB containing a **Radiotap header** followed by an **802.11 frame**. The `dlt` column is set to `127` (DLT_IEEE802_11_RADIO), indicating Radiotap encapsulation.

### Radiotap Header

| Offset | Size | Field | Value |
|--------|------|-------|-------|
| 0 | 1 | Version | `0x00` |
| 1 | 1 | Pad | `0x00` |
| 2 | 2 | Header Length (LE) | `0x000D` (13 bytes) |
| 4 | 4 | Present Flags (LE) | `0x00000028` (Channel + Signal) |
| 8 | 2 | Frequency (LE) | Channel center frequency in MHz |
| 10 | 2 | Channel Flags (LE) | See Channel Flags table |
| 12 | 1 | Signal (dBm) | Signed 8-bit signal strength |

**Radiotap Present Flags:**
- Bit 3 (0x08): Channel — 2 bytes frequency + 2 bytes channel flags
- Bit 5 (0x20): dBm Antenna Signal — 1 byte signed

**Channel Flags:**

| Value | Meaning |
|-------|---------|
| `0x00B0` | 2.4 GHz + CCK (channels 1-14) |
| `0x0140` | 5 GHz + OFDM (channels 36+) |

### 802.11 Beacon Frame

Following the Radiotap header is a standard 802.11 management frame:

| Offset | Size | Field | Value |
|--------|------|-------|-------|
| 0 | 2 | Frame Control | `0x8000` (Beacon) |
| 2 | 2 | Duration | `0x0000` |
| 4 | 6 | Addr1 (Dest) | `FF:FF:FF:FF:FF:FF` (Broadcast) |
| 10 | 6 | Addr2 (Source) | BSSID |
| 16 | 6 | Addr3 (BSSID) | BSSID |
| 22 | 2 | Sequence Control | `0x0000` |

### Beacon Frame Body

| Offset | Size | Field | Value |
|--------|------|-------|-------|
| 0 | 8 | Timestamp | `0x0000000000000000` |
| 8 | 2 | Beacon Interval (LE) | `0x0064` (100 TU) |
| 10 | 2 | Capabilities (LE) | `0x0021` (ESS) or `0x0031` (ESS+Privacy) |

### Information Elements

The beacon body is followed by variable-length Information Elements (IEs). Each IE has a Tag (1 byte), Length (1 byte), and Value (Length bytes).

#### IE 0: SSID Parameter Set

| Field | Size | Description |
|-------|------|-------------|
| Tag | 1 | `0x00` |
| Length | 1 | SSID length in bytes |
| SSID | Variable | SSID as ASCII bytes |

#### IE 1: Supported Rates

| Field | Size | Description |
|-------|------|-------------|
| Tag | 1 | `0x01` |
| Length | 1 | Number of rate bytes (max 8) |
| Rates | Variable | Each byte = rate × 2, bit 7 set for basic rates |

**Rate encoding:** Rate in Mbps × 2, with bit 7 (`0x80`) set for basic (mandatory) rates.

| Rate | Basic | Hex |
|------|-------|-----|
| 1 Mbps | Yes | `0x82` |
| 2 Mbps | Yes | `0x84` |
| 5.5 Mbps | Yes | `0x8B` |
| 11 Mbps | Yes | `0x96` |
| 6 Mbps | No | `0x0C` |
| 9 Mbps | No | `0x12` |
| 12 Mbps | No | `0x18` |
| 18 Mbps | No | `0x24` |

**Default rates** (when no rate data available): `0x82, 0x84, 0x8B, 0x96, 0x0C, 0x12, 0x18, 0x24`

#### IE 3: DS Parameter Set (Channel)

| Field | Size | Description |
|-------|------|-------------|
| Tag | 1 | `0x03` |
| Length | 1 | `0x01` |
| Channel | 1 | Current channel number (mod 256 for 5 GHz) |

Kismet reads the channel from this IE tag. For 5 GHz channels > 255, the value is `channel AND 0xFF`.

#### IE 50: Extended Supported Rates

| Field | Size | Description |
|-------|------|-------------|
| Tag | 1 | `0x32` |
| Length | 1 | Number of rate bytes |
| Rates | Variable | Same encoding as IE 1 |

Only present when there are more than 8 supported rates.

#### IE 48: RSN Information Element (WPA2/WPA3)

Tag `0x30` — present for WPA2 and WPA3 networks.

| Field | Size | Description |
|-------|------|-------------|
| Tag | 1 | `0x30` |
| Length | 1 | Body length |
| Version | 2 | `0x0100` (version 1, LE) |
| Group Cipher | 4 | OUI (3) + Cipher Type (1) |
| Pairwise Count | 2 | `0x0100` (1 suite, LE) |
| Pairwise Cipher | 4 | OUI (3) + Cipher Type (1) |
| AKM Count | 2 | `0x0100` (1 suite, LE) |
| AKM Suite | 4 | OUI (3) + AKM Type (1) |
| RSN Capabilities | 2 | `0x0000` |

**RSN OUI:** `00:0F:AC`

**Cipher Suite Types:**

| Type | Cipher |
|------|--------|
| `0x02` | TKIP |
| `0x04` | CCMP-128 (AES) |

**AKM Suite Types:**

| Type | Authentication |
|------|----------------|
| `0x01` | 802.1X (Enterprise) |
| `0x02` | PSK (Personal) |
| `0x08` | SAE (WPA3-Personal) |

#### IE 221: WPA Vendor Specific (WPA1)

Tag `0xDD` — present for WPA1 networks.

| Field | Size | Description |
|-------|------|-------------|
| Tag | 1 | `0xDD` |
| Length | 1 | Body length |
| OUI | 3 | `00:50:F2` (Microsoft) |
| OUI Type | 1 | `0x01` (WPA) |
| Version | 2 | `0x0100` (version 1, LE) |
| Multicast Cipher | 4 | OUI (3) + Cipher Type (1) |
| Unicast Count | 2 | `0x0100` (1 suite, LE) |
| Unicast Cipher | 4 | OUI (3) + Cipher Type (1) |
| AKM Count | 2 | `0x0100` (1 suite, LE) |
| AKM Suite | 4 | OUI (3) + AKM Type (1) |

**WPA OUI:** `00:50:F2`

Cipher and AKM type values are the same as RSN (0x02 = TKIP, 0x04 = CCMP, 0x02 = PSK, 0x01 = 802.1X).

## Encryption Bitfield (`crypt_set`)

The `dot11.advertisedssid.crypt_set` field is a bitfield encoding all detected encryption capabilities. Vistumbler generates this from Auth/Encr strings.

| Bit Value | Constant | Meaning |
|-----------|----------|---------|
| 1 | `dot11_crypt_general_wep` | WEP detected |
| 2 | `dot11_crypt_general_wpa` | WPA family detected |
| 4 | `dot11_crypt_general_wpa1` | WPA1 specifically |
| 8 | `dot11_crypt_general_wpa2` | WPA2 specifically |
| 256 | `dot11_crypt_group_wep104` | Group cipher: WEP-104 |
| 512 | `dot11_crypt_group_tkip` | Group cipher: TKIP |
| 1024 | `dot11_crypt_group_ccmp128` | Group cipher: CCMP-128 |
| 16777216 | `dot11_crypt_pairwise_wep104` | Pairwise cipher: WEP-104 |
| 33554432 | `dot11_crypt_pairwise_tkip` | Pairwise cipher: TKIP |
| 67108864 | `dot11_crypt_pairwise_ccmp128` | Pairwise cipher: CCMP-128 |
| 137438953472 | `dot11_crypt_akm_1x` | AKM: 802.1X (Enterprise) |
| 274877906944 | `dot11_crypt_akm_psk` | AKM: PSK (Personal) |

**Example:** WPA2-Personal with CCMP = `2 + 8 + 1024 + 67108864 + 274877906944` = `342052888586`

## Vistumbler Implementation

### Export Process

Vistumbler exports to KismetDB via the `_ExportKismetDB_Common()` function in [Vistumbler.au3](Vistumbler/VistumblerMDB/Vistumbler.au3) and the library functions in [UDFs/KismetDB.au3](Vistumbler/VistumblerMDB/UDFs/KismetDB.au3).

**Export steps:**

1. **Create database** — `_KismetDB_Create()` builds all tables with proper schema and inserts the KISMET metadata row and a default Vistumbler datasource.

2. **Query APs** — Reads all APs (or filtered set) from Vistumbler's internal MDB database, including SSID, BSSID, channel, Auth, Encr, manufacturer, rates, and GPS.

3. **Generate device JSON** — `_KismetDB_GenerateDeviceJSON()` creates a JSON object with:
   - Base device fields (`kismet.device.base.*`)
   - Dot11 extension with SSID records and advertised SSID map
   - Encryption as `Auth/Encr` format in `crypt_string` (e.g., `"WPA2-Personal/CCMP"`)
   - Radio type stored in custom `vistumbler.device.radio_type` field (e.g., `"802.11ax"`)

4. **Export signal history as packets** — For each AP, queries the Vistumbler HIST table and generates one packet per history entry:
   - `_KismetDB_GenerateRadiotapBeacon()` creates a Radiotap + 802.11 beacon frame with proper IE tags
   - Each packet includes GPS coordinates, signal strength, and timestamp
   - Stored with `dlt=127` (Radiotap)

5. **Write device row** — `_KismetDB_AddDevice()` inserts the device with timestamps, GPS bounds, signal, and JSON.

**GPS conversion:** Vistumbler stores coordinates internally in degrees-minutes format (e.g., `"N 3551.9912"`). These are converted to decimal degrees for KismetDB using `_Format_GPS_DMM_to_DDD()`.

**Frequency calculation:**
```
2.4 GHz: freq_khz = (2407 + channel × 5) × 1000    (channel 14 = 2484 × 1000)
5 GHz:   freq_khz = (5000 + channel × 5) × 1000
```

### Import Process

Vistumbler imports KismetDB files via the `_ImportKismetDB()` function. The import is designed to handle both **real Kismet** database files and **Vistumbler-exported** files.

**Import steps:**

1. **Open database** — Opens the SQLite file and reads `db_version` from the KISMET table.

2. **Query devices** — Queries the `devices` table filtering for Wi-Fi types:
   ```sql
   SELECT ... FROM devices WHERE type='Wi-Fi AP' OR type='Wi-Fi Ad-Hoc' 
       OR type='Wi-Fi' OR type='Wi-Fi Device' OR type LIKE '%Wi-Fi%'
   ```

3. **Parse device JSON** — For each device row, decodes the JSON and extracts fields using a multi-fallback strategy:

   **SSID extraction priority:**
   1. `dot11.device.last_beaconed_ssid` (works for both real Kismet and Vistumbler exports)
   2. `dot11.device.last_beaconed_ssid_record` → `dot11.advertisedssid.ssid`
   3. `dot11.device.advertised_ssid_map` → first entry → `dot11.advertisedssid.ssid`
   4. `kismet.device.base.name` (only if non-empty and not equal to MAC address)
   5. `kismet.device.base.commonname` (only if non-empty and not equal to MAC address)
   6. Empty SSID is preserved as-is (hidden/cloaked networks are stored with `SSID=""` in MDB)

   **Encryption extraction:**
   1. `dot11.advertisedssid.crypt_string` (from SSID record, if found during SSID extraction)
   2. `kismet.device.base.crypt_string`
   3. `kismet.device.base.encryption` (legacy fallback)

   **GPS extraction:**
   1. `kismet.device.base.location` → `kismet.common.location.avg_loc` → `kismet.common.location.geopoint`
   2. `kismet.device.base.location` → `kismet.common.location.last` → `kismet.common.location.geopoint`
   3. `avg_lat` / `avg_lon` columns from the `devices` table (Vistumbler export fallback)

   **Radio type extraction:**
   1. `vistumbler.device.radio_type` (Vistumbler-exported files)
   2. Inferred from `kismet.device.base.frequency` (real Kismet files): 6 GHz → `802.11ax`, 5 GHz → `802.11ac`, 2.4 GHz → `802.11n`
   3. Falls back to `"Unknown"`

4. **Parse encryption string** — Determines Auth and Encr values:

   **Vistumbler format** (contains `/`):
   - Split on `/` → `Auth = parts[1]`, `Encr = parts[2]`
   - Example: `"WPA2-Personal/CCMP"` → Auth=`"WPA2-Personal"`, Encr=`"CCMP"`

   **Real Kismet format** (space-separated):
   - Parse authentication: Look for WPA3/WPA2/WPA/WEP keywords, then PSK/Enterprise/SAE qualifiers
   - Parse cipher: Look for CCMP/AES, TKIP, GCMP keywords
   - Example: `"WPA2 WPA2-PSK AES-CCMP"` → Auth=`"WPA2-Personal"`, Encr=`"CCMP"`

5. **Convert timestamps** — Unix epoch seconds are converted to local date/time strings using `_StringFormatTime()` from `UnixTime.au3` (the same method used by the Wardrive import):
   ```autoit
   $sDate = _StringFormatTime("%Y", $iFirstTime) & "-" & _StringFormatTime("%m", $iFirstTime) & "-" & _StringFormatTime("%d", $iFirstTime)
   $sTime = _StringFormatTime("%X", $iFirstTime) & ".000"
   ```
   Both `first_time` and `last_time` are converted. The date format is `YYYY-MM-DD` and time format is `HH:MM:SS.000`, matching Vistumbler's internal GPS/HIST table conventions.

6. **Convert GPS** — Decimal degrees are converted to Vistumbler's internal DMM format using `_Format_GPS_DDD_to_DMM()`.

7. **Add AP** — Calls `_AddApData()` with extracted BSSID, SSID, channel, Auth, Encr, network type, radio type, signal, and RSSI.

8. **Import signal history** — Queries the `packets` table for each AP's MAC address and creates HIST table entries with per-packet GPS, signal, and timestamp data.

### AutoIt Hex() Bug Fix

A critical bug was discovered during development: AutoIt's `Hex()` function treats **Double** and **Integer** types differently. When given a Double value (common when using division `/` or when parameters are passed through function calls), `Hex()` converts the IEEE 754 binary representation to hexadecimal instead of the integer value.

**Example of the bug:**
```autoit
$val = 2412            ; Integer type → Hex($val, 4) = "096C" ✓
$val = 2412.0          ; Double type  → Hex($val, 4) = "0000" ✗ (IEEE 754 bits)
$val = 2407 + (1 * 5)  ; Expression returns Double → Hex($val, 4) = "0000" ✗
```

**Fix:** Wrap all values with `Int()` before passing to `Hex()`:
```autoit
Hex(Int($iFreq), 4)                    ; Frequency in Radiotap header
Int(StringLen($sSSIDHex) / 2)          ; SSID IE length
Int(StringLen($sBody) / 2)             ; RSN/WPA IE body length
Int(Number($rate) * 2)                 ; Supported rate bytes
```

This fix is applied throughout `KismetDB.au3` in all beacon generation functions.

### Signal Conversion

Kismet uses dBm signal values (negative numbers like -45). Vistumbler uses both a 0-100 percentage and dBm RSSI:

```autoit
; Import: dBm → percentage
$iSignalPercent = _DbToSignalPercent($iRSSI)

; Import: percentage → dBm (if only percentage available)
$iRSSI = _SignalPercentToDb($iSignalPercent)
```

### Supported Encryption Types

| Kismet crypt_string | Vistumbler Auth | Vistumbler Encr |
|---------------------|-----------------|-----------------|
| `WPA3 SAE AES-CCMP` | WPA3-Personal | CCMP |
| `WPA3 Enterprise AES-CCMP` | WPA3-Enterprise | CCMP |
| `WPA2 WPA2-PSK AES-CCMP` | WPA2-Personal | CCMP |
| `WPA2 WPA2-1X AES-CCMP` | WPA2-Enterprise | CCMP |
| `WPA WPA-PSK TKIP` | WPA-Personal | TKIP |
| `WPA WPA-1X TKIP` | WPA-Enterprise | TKIP |
| `WEP` | Open | WEP |
| `Open` / empty | Open | None |

## Example Device JSON

### Vistumbler Export

```json
{
  "kismet.device.base.key": "AA:BB:CC:DD:EE:FF",
  "kismet.device.base.macaddr": "AA:BB:CC:DD:EE:FF",
  "kismet.device.base.name": "MyNetwork",
  "kismet.device.base.phyname": "IEEE802.11",
  "kismet.device.base.manuf": "NETGEAR",
  "kismet.device.base.channel": "6",
  "kismet.device.base.frequency": 2437000,
  "kismet.device.base.freq_khz_map": { "2437000": 1 },
  "kismet.device.base.crypt_string": "WPA2-Personal/CCMP",
  "kismet.device.base.type": "Wi-Fi AP",
  "kismet.device.base.commonname": "MyNetwork",
  "dot11.device": {
    "dot11.device.last_beaconed_ssid": "MyNetwork",
    "dot11.device.last_beaconed_ssid_record": {
      "dot11.advertisedssid.ssid": "MyNetwork",
      "dot11.advertisedssid.ssidlen": 9,
      "dot11.advertisedssid.crypt_set": 342052888586,
      "dot11.advertisedssid.channel": "6"
    },
    "dot11.device.last_beaconed_ssid_checksum": 12345678,
    "dot11.device.num_advertised_ssids": 1,
    "dot11.device.advertised_ssid_map": {
      "12345678": {
        "dot11.advertisedssid.ssid": "MyNetwork",
        "dot11.advertisedssid.ssidlen": 9,
        "dot11.advertisedssid.crypt_set": 342052888586,
        "dot11.advertisedssid.channel": "6"
      }
    }
  }
}
```

### Real Kismet Capture

```json
{
  "kismet.device.base.key": "4202770D00000000_AFB4F4B09FCAECB5",
  "kismet.device.base.macaddr": "AA:BB:CC:DD:EE:FF",
  "kismet.device.base.name": "MyNetwork",
  "kismet.device.base.commonname": "MyNetwork",
  "kismet.device.base.phyname": "IEEE802.11",
  "kismet.device.base.manuf": "NETGEAR, Inc.",
  "kismet.device.base.channel": "6",
  "kismet.device.base.frequency": 2437000,
  "kismet.device.base.crypt_string": "WPA2 WPA2-PSK AES-CCMP",
  "kismet.device.base.type": "Wi-Fi AP",
  "kismet.device.base.location": {
    "kismet.common.location.avg_loc": {
      "kismet.common.location.geopoint": [ -74.006, 40.7128 ],
      "kismet.common.location.fix": 2
    },
    "kismet.common.location.last": {
      "kismet.common.location.geopoint": [ -74.006, 40.7128 ],
      "kismet.common.location.fix": 2
    }
  },
  "kismet.device.base.signal": {
    "kismet.common.signal.last_signal": -52,
    "kismet.common.signal.max_signal": -45
  },
  "dot11.device": {
    "dot11.device.last_beaconed_ssid": "MyNetwork",
    "dot11.device.last_beaconed_ssid_record": {
      "dot11.advertisedssid.ssid": "MyNetwork",
      "dot11.advertisedssid.ssidlen": 9,
      "dot11.advertisedssid.crypt_set": 342052888586,
      "dot11.advertisedssid.crypt_string": "WPA2 WPA2-PSK AES-CCMP",
      "dot11.advertisedssid.channel": "6"
    },
    "dot11.device.advertised_ssid_map": { ... }
  }
}
```

## Example Packet Hex Dump

A complete beacon for SSID `"Test"` on channel 6 (2437 MHz), WPA2-Personal/CCMP, signal -45 dBm:

```
Radiotap Header (13 bytes):
  00 00        Version=0, Pad=0
  0D 00        Header Length=13 (LE)
  28 00 00 00  Present Flags (Channel + Signal)
  85 09        Frequency=2437 MHz (LE)
  B0 00        Channel Flags=0x00B0 (2.4GHz+CCK)
  D3           Signal=-45 dBm (0xD3 = -45 signed)

802.11 Beacon Frame:
  80 00        Frame Control (Beacon)
  00 00        Duration
  FF FF FF FF FF FF  Dest=Broadcast
  AA BB CC DD EE FF  Source=BSSID
  AA BB CC DD EE FF  BSSID
  00 00        Seq Control

Beacon Body:
  00 00 00 00 00 00 00 00  Timestamp
  64 00        Beacon Interval (100 TU)
  31 00        Capabilities (ESS + Privacy)

Information Elements:
  00 04 54 65 73 74        IE 0: SSID="Test" (4 bytes)
  01 08 82 84 8B 96 0C 12 18 24  IE 1: Supported Rates (default)
  03 01 06                 IE 3: DS Parameter Set (Channel 6)
  30 14 01 00 00 0F AC 04  IE 48: RSN
        01 00 00 0F AC 04        Pairwise: CCMP
        01 00 00 0F AC 02        AKM: PSK
        00 00                    RSN Capabilities
```

## Compatibility

### With Real Kismet

- **Import**: Vistumbler reads real Kismet `.kismet` files, extracting SSID, encryption, channel, GPS, and signal from the `devices` table JSON. Signal history is imported from the `packets` table.
- **Export**: Vistumbler-exported `.kismet` files can be opened by Kismet. Kismet replays the beacon packets from the `packets` table and re-derives device information (SSID, channel, encryption) from the 802.11 IE tags in the beacon frames.

### Key Differences Between Real Kismet and Vistumbler Files

| Aspect | Real Kismet | Vistumbler Export |
|--------|-------------|-------------------|
| `crypt_string` format | Space-separated (e.g., `"WPA2 WPA2-PSK AES-CCMP"`) | Slash-separated (e.g., `"WPA2-Personal/CCMP"`) |
| GPS in device JSON | Nested location object with geopoint arrays | Not included (uses `avg_lat`/`avg_lon` columns) |
| Radio type | Not stored (inferred from frequency on import) | `vistumbler.device.radio_type` custom field |
| `type` values | `"Wi-Fi AP"`, `"Wi-Fi Ad-Hoc"`, etc. | Same values |
| Device key format | Hash-based key (e.g., `"4202770D..."`) | MAC address as key |
| Packet content | Real captured packets | Synthetic beacon frames |
| `datasource` | Real interface UUID | `"00000000-0000-0000-0000-000000000000"` |

### Limitations

- **Packet data**: Vistumbler exports synthetic beacon frames, not real captured packets. These contain reconstructed IE tags sufficient for Kismet to identify SSID, channel, and encryption.
- **Signal history**: Only beacon-related signal measurements are exported; other packet types are not preserved.
- **GPS precision**: Vistumbler's internal DMM format has limited precision compared to Kismet's double-precision coordinates.
- **Non-Wi-Fi devices**: Only Wi-Fi devices (APs and Ad-Hoc) are imported/exported; Bluetooth, Zigbee, and other PHY types are ignored.

## See Also

- [NS1 Binary Format](NS1-Format.md) — NetStumbler's binary format
- [Wi-Scan Text Format](Wi-Scan-Format.md) — NetStumbler's text-based format
- [Kismet Documentation](https://www.kismetwireless.net/docs/) — Official Kismet documentation
- [Radiotap Standard](https://www.radiotap.org/) — Radiotap header specification
- [IEEE 802.11 Standard](https://standards.ieee.org/ieee/802.11/7028/) — 802.11 frame format

## Implementation Files

- **UDFs\KismetDB.au3** — Database creation, device/packet insertion, beacon frame generation, encryption bitfield computation
- **Vistumbler.au3** — Export (`_ExportKismetDB_Common`) and Import (`_ImportKismetDB`) functions

## Version History

- **v1.1** — Bugfixes and improvements
  - Fixed import: JSON parsing for Auth/Encr now correctly extracts `crypt_string` from device JSON
  - Fixed import: First Active/Last Active timestamps now populate correctly using `_StringFormatTime()` instead of `_DateAdd()` (which failed with large Unix epoch values)
  - Fixed import: Both `first_time` and `last_time` from the devices table are now converted for proper First/Last Active display
  - Added: Radio Type now preserved through KismetDB export/import round-trips via custom `vistumbler.device.radio_type` JSON field
  - Added: Frequency-based radio type inference for real Kismet files (6 GHz → 802.11ax, 5 GHz → 802.11ac, 2.4 GHz → 802.11n)
  - Fixed export: `$save_column_OtherTransferRates` typo in IniWrite causing column position corruption after drag-and-drop reorder
  - Fixed column reorder: Header builder now adds `|` separators based on position index instead of INI entry index, preventing column merge when reordered columns are at the end of the INI section
  - Fixed export: Timestamp `_DateDiff` format mismatch — MDB stores `YYYY-MM-DD` dates and times with `.000` ms suffix, but `_DateDiff` requires `YYYY/MM/DD` without ms; added `StringReplace`/`StringRegExpReplace` normalization
  - Fixed import: FirstHistID/LastHistID now updated after packet HIST loop via `UPDATE AP` query, fixing First Active = Last Active bug
  - Fixed import: Timezone shift — switched from `_StringFormatTime()` (uses C `localtime`) to new `_StringFormatTimeUTC()` (uses C `gmtime`) since MDB stores UTC timestamps
  - Fixed import: Hidden/cloaked SSIDs now preserved as empty strings instead of being replaced with "Unknown", fixing duplicate AP entries on reimport and maintaining round-trip fidelity
  - Fixed import: `base.name`/`base.commonname` fallback now skips values that are empty or match the MAC address (real Kismet sets `name` to MAC for hidden-SSID APs)
  - Fixed export: Same-BSSID/different-Auth APs (e.g., WPA2-Personal and WPA3-Personal on the same radio) are now merged into a single KismetDB device with multiple entries in `advertised_ssid_map`, each carrying its own `dot11.advertisedssid.crypt_string` field. This works around KismetDB's `UNIQUE(phyname, devmac) ON CONFLICT REPLACE` constraint which previously silently discarded the first AP.
  - Fixed export: Filtered export column order bug — `$AddQuery` had different column ordering from the non-filtered query, causing wrong values for MANU, HighGpsHistID, and strongest_signal. Fixed by wrapping filtered results with consistent `SELECT ... FROM AP WHERE ApID IN (SELECT ApID FROM ...)`.
  - Fixed export: BSSID group processing now collects all HIST packets from all APs in a group and writes them under a single sourcemac, preserving complete signal history.
  - Fixed import: Multi-entry `advertised_ssid_map` devices are now split back into separate APs — one per unique SSID/channel/auth entry. Shared packet history is duplicated to each AP so all variants show proper signal history.
  - Added: `_ParseKismetCrypt()` helper function for parsing Kismet-style space-separated crypt strings (e.g., "WPA2 WPA2-PSK AES-CCMP") into Vistumbler Auth/Encr fields.
  - Added: `_ImportKismetPackets()` helper function to isolate packet import logic, enabling reuse for both single-AP and multi-AP import paths.
  - Fixed import: HighSignal/HighRSSI/HighGpsHistId values now computed from HIST table data (`MAX(Signal)`, `MAX(RSSI)`) after packet import, instead of relying on a single `_AddApData` call that never updated these fields.
  - Added: Original adapter-reported signal percentage now preserved through KismetDB round-trips via `VISTUMBLER_SIG=N` tag in the `packets.tags` column. On import, if this tag is present the original signal% is used directly; otherwise falls back to RSSI-to-percentage formula conversion. Uses Kismet's standard space-separated tag format for full compatibility.

- **v1.0** — Initial implementation
  - KismetDB v10 schema support
  - Radiotap + 802.11 beacon frame generation with IE tags
  - WPA/WPA2/WPA3 RSN and WPA vendor IE support
  - Device JSON with dot11 extensions and advertised SSID map
  - Import with multi-fallback SSID/GPS/encryption extraction
  - Round-trip compatibility with real Kismet
  - Fixed AutoIt `Hex(Double)` bug causing zero-length IE tags
