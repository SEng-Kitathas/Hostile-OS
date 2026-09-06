$ErrorActionPreference='Stop'
$root='E:\new pc\AI_Pushes_Sandbox\projects\PCMMAD\HOSTILE_OS'
$image=Join-Path $root 'research\targets\H1_BIOS_USB_READ_DISCRIMINATOR\build_chs_single\h1_bios_usb_read_chs_single_1MiB.img'
$outDir=Join-Path $root 'research\targets\H1_BIOS_USB_READ_DISCRIMINATOR\physical_runs\20260831_h1_read6_qualified_01_prep'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$expected='0c1a08ab84f03b6906330fa8b0706a7bb3e2ceb52ab7ae6c0edb4cae802f62b8'
$disk=Get-Disk -Number 3
$serial=([string]$disk.SerialNumber).Trim()
if($disk.FriendlyName -ne 'SanDisk Extreme Pro' -or $serial -ne '0FDC87754321' -or $disk.BusType -ne 'USB' -or [int64]$disk.Size -ne 128043712512L -or $disk.IsBoot -or $disk.IsSystem){throw 'PhysicalDrive3 identity gate failed'}
$img=[IO.File]::ReadAllBytes($image)
$sha=[Security.Cryptography.SHA256]::Create(); try{$h=([BitConverter]::ToString($sha.ComputeHash($img))).Replace('-','').ToLowerInvariant()} finally{$sha.Dispose()}
if($h -ne $expected){throw "source image hash mismatch $h"}
$fs=New-Object IO.FileStream('\\.\PhysicalDrive3',[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::ReadWrite,65536,[IO.FileOptions]::WriteThrough)
try{[void]$fs.Seek(0,[IO.SeekOrigin]::Begin);for($off=0;$off -lt $img.Length;){$n=[Math]::Min(65536,$img.Length-$off);$fs.Write($img,$off,$n);$off+=$n};$fs.Flush($true);[void]$fs.Seek(0,[IO.SeekOrigin]::Begin);$rb=New-Object byte[] $img.Length;$off=0;while($off -lt $rb.Length){$n=$fs.Read($rb,$off,$rb.Length-$off);if($n -le 0){throw 'short raw readback'};$off+=$n}}finally{$fs.Dispose()}
$sha=[Security.Cryptography.SHA256]::Create(); try{$rh=([BitConverter]::ToString($sha.ComputeHash($rb))).Replace('-','').ToLowerInvariant()} finally{$sha.Dispose()}
if($rh -ne $expected){throw "raw readback mismatch $rh"}
$sec=$rb[(257*512)..((258*512)-1)]
if(($sec | Where-Object {$_ -ne 0} | Measure-Object).Count -ne 0){throw 'LBA257 not zero before physical run'}
@{prepared_utc=(Get-Date).ToUniversalTime().ToString('o');device='\\.\PhysicalDrive3';model=$disk.FriendlyName;serial=$serial;written_bytes=$rb.Length;sha256=$rh;lba257_zero=$true} | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $outDir 'write_receipt.json')
Write-Host "PASS qualified READ6 discriminator written and verified $rh"
