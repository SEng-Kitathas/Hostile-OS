# H1 splash asset provenance

Date: 2026-08-31
Status: CONTROLLED DERIVATIVE ASSET

Inbound source supplied by commander:
- filename: `Gemini_Generated_Image_ebf7omebf7omebf7.jpg`
- dimensions: 1408x768 RGB
- bytes: 822,945
- SHA-256: `c7e5d0b83ddbd74cdf1291e7e68bbabd418d7c89ed42ada96204392e4630dc63`

The source JPEG remains an inbound conversation artifact and is not duplicated into the research repository.

Deterministic conversion used for the committed boot asset:
1. open source as RGB;
2. resize with Lanczos, preserving aspect ratio, to 320x175;
3. paste at `(0,12)` on a black 320x200 RGB canvas;
4. quantize with Pillow median-cut to 32 colors with dithering disabled;
5. store the 320x200 palette indices directly as 64,000 bytes;
6. take the first 32 RGB palette entries and convert each channel from 8-bit to VGA DAC 6-bit using `round(v*63/255)`.

Committed derivatives:
- `splash_palette_32xrgb6.bin`: 96 bytes, SHA-256 `c0056796d5c7ec2cb5edc95510b66a058a1705e7dcc1dc3ec750b2f511526744`;
- `splash_pixels_320x200.bin`: 64,000 bytes, SHA-256 `c1467575fe43e5b4b466cf27be0997ad97a12496bbfd49e39057038005ac845f`.

These assets are presentation data only. They do not change D64-v3 or the qualified H1 probe mechanism.
