from pathlib import Path
import argparse, hashlib, json, struct

LBA = 257
SECTOR = 512
TABLE_OFF = 0x40
TABLE_CAP = SECTOR - TABLE_OFF


def pick_sector(blob: bytes) -> bytes:
    if len(blob) == SECTOR:
        return blob
    end = (LBA + 1) * SECTOR
    if len(blob) >= end:
        return blob[LBA * SECTOR:end]
    raise ValueError(f"input is {len(blob)} bytes; expected 512-byte result or image containing LBA {LBA}")


def cstr(raw: bytes) -> str:
    return raw.split(b"\0", 1)[0].decode("ascii", "replace")


def sval(strings, index):
    return strings[index - 1] if 0 < index <= len(strings) else None


def parse_structures(raw: bytes, advertised_length: int):
    limit = min(len(raw), advertised_length)
    pos = 0
    out = []
    truncated = advertised_length > len(raw)
    while pos + 4 <= limit:
        typ = raw[pos]
        length = raw[pos + 1]
        handle = struct.unpack_from("<H", raw, pos + 2)[0]
        if length < 4 or pos + length > limit:
            truncated = True
            break
        string_start = pos + length
        end = string_start
        while end + 1 < limit and not (raw[end] == 0 and raw[end + 1] == 0):
            end += 1
        if end + 1 >= limit:
            truncated = True
            break
        string_blob = raw[string_start:end]
        strings = [x.decode("latin1", "replace") for x in string_blob.split(b"\0") if x]
        formatted = raw[pos:pos + length]
        rec = {"type": typ, "length": length, "handle": handle, "strings": strings}
        if typ == 0 and length >= 0x0A:
            rec["decoded"] = {
                "kind": "BIOS Information",
                "vendor": sval(strings, formatted[4]),
                "version": sval(strings, formatted[5]),
                "release_date": sval(strings, formatted[8]),
            }
            if length >= 0x16:
                rec["decoded"]["system_bios_major_release"] = formatted[0x14]
                rec["decoded"]["system_bios_minor_release"] = formatted[0x15]
        elif typ == 1 and length >= 8:
            d = {
                "kind": "System Information",
                "manufacturer": sval(strings, formatted[4]),
                "product": sval(strings, formatted[5]),
                "version": sval(strings, formatted[6]),
                "serial": sval(strings, formatted[7]),
            }
            if length >= 0x19:
                d["uuid_raw"] = formatted[8:24].hex()
            if length >= 0x1B:
                d["sku"] = sval(strings, formatted[0x19])
                d["family"] = sval(strings, formatted[0x1A])
            rec["decoded"] = d
        elif typ == 2 and length >= 0x0B:
            d = {
                "kind": "Baseboard Information",
                "manufacturer": sval(strings, formatted[4]),
                "product": sval(strings, formatted[5]),
                "version": sval(strings, formatted[6]),
                "serial": sval(strings, formatted[7]),
                "asset_tag": sval(strings, formatted[8]),
                "location": sval(strings, formatted[0x0A]),
            }
            if length >= 0x0E:
                d["board_type"] = formatted[0x0D]
            rec["decoded"] = d
        out.append(rec)
        pos = end + 2
        if typ == 127:
            break
    return out, truncated, pos


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input", type=Path)
    args = ap.parse_args()
    blob = args.input.read_bytes()
    sec = pick_sector(blob)
    result = {
        "input": str(args.input),
        "input_bytes": len(blob),
        "result_sector_sha256": hashlib.sha256(sec).hexdigest(),
        "header": cstr(sec[:0x10]),
        "boot_drive": sec[0x10],
        "status": sec[0x11],
    }
    if result["header"] == "H1SMBIOS1":
        result.update({
            "entry_point_length": sec[0x12],
            "smbios_major": sec[0x13],
            "smbios_minor": sec[0x14],
            "entry_point_revision": sec[0x15],
            "smbios_bcd_revision": sec[0x16],
            "checksum_valid_marker": sec[0x17],
            "structure_table_length": struct.unpack_from("<H", sec, 0x18)[0],
            "structure_count": struct.unpack_from("<H", sec, 0x1A)[0],
            "structure_table_physical_address": struct.unpack_from("<I", sec, 0x1C)[0],
            "entry_point_raw_32": sec[0x20:0x40].hex(),
        })
        if result["status"] == 0:
            structs, truncated, consumed = parse_structures(sec[TABLE_OFF:], result["structure_table_length"])
            result["captured_table_bytes"] = min(TABLE_CAP, result["structure_table_length"])
            result["parsed_bytes"] = consumed
            result["table_capture_truncated"] = truncated
            result["structures"] = structs
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
