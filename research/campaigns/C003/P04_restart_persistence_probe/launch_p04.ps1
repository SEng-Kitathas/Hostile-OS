param([Parameter(Mandatory=$true)][string]$RunId)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

$src = $PSScriptRoot
$repo = (Resolve-Path (Join-Path $src '..\..\..\..')).Path
$run = Join-Path $repo ('research\campaigns\C003\runs\' + $RunId)
if (Test-Path $run) { throw "run directory already exists: $run" }
New-Item -ItemType Directory -Path $run | Out-Null

$llvm = 'E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin'
$clang = Join-Path $llvm 'clang.exe'
$lld = Join-Path $llvm 'ld.lld.exe'
$objcopy = Join-Path $llvm 'llvm-objcopy.exe'
$qemu = 'C:\Program Files\qemu\qemu-system-i386.exe'
$python = 'C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe'

$mechanism = Join-Path $src 'mechanism.S'
$fixtureAsm = Join-Path $src 'fixture.S'
$fixtureJson = Join-Path $src 'fixture.json'
$linker = Join-Path $src 'linker.ld'
$evaluator = Join-Path $src 'evaluate_p04.py'

function Sha([string]$p) {
    (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower()
}

function Run-Native([string]$name, [string]$exe, [string[]]$argv) {
    $so = Join-Path $run ($name + '.stdout.txt')
    $se = Join-Path $run ($name + '.stderr.txt')
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $exe @argv 1> $so 2> $se
    $ec = $LASTEXITCODE
    $ErrorActionPreference = $old
    if ($ec -ne 0) {
        throw "$name failed exit=$ec; stdout=$so stderr=$se"
    }
    return $ec
}

$started = [DateTime]::UtcNow.ToString('o')

$mechanismObj = Join-Path $run 'mechanism.o'
$fixtureObj = Join-Path $run 'fixture.o'
$probeElf = Join-Path $run 'probe.elf'
$probeBin = Join-Path $run 'probe.bin'

Run-Native '01_clang_mechanism' $clang @('-target','i386-unknown-none-elf','-ffreestanding','-c',$mechanism,'-o',$mechanismObj) | Out-Null
Run-Native '02_clang_fixture' $clang @('-target','i386-unknown-none-elf','-ffreestanding','-c',$fixtureAsm,'-o',$fixtureObj) | Out-Null
Run-Native '03_link' $lld @('-m','elf_i386','-T',$linker,$mechanismObj,$fixtureObj,'-o',$probeElf) | Out-Null
Run-Native '04_objcopy' $objcopy @('-O','binary',$probeElf,$probeBin) | Out-Null

$bootBytes = [IO.File]::ReadAllBytes($probeBin)
if ($bootBytes.Length -ne 512) { throw "probe size=$($bootBytes.Length) expected=512" }
if ($bootBytes[510] -ne 0x55 -or $bootBytes[511] -ne 0xaa) { throw 'boot signature mismatch' }

$fixture = Get-Content -LiteralPath $fixtureJson -Raw | ConvertFrom-Json
$imageBytes = [int]$fixture.image_bytes
$sectorBytes = [int]$fixture.sector_bytes
$sectorIndex = [int]$fixture.durable_sector_index_zero_based
if ($sectorBytes -ne 512 -or $sectorIndex -ne 1) { throw 'fixture sector geometry mismatch' }

$disk = Join-Path $run 'disk.img'
[byte[]]$image = New-Object byte[] $imageBytes
[Array]::Copy($bootBytes, 0, $image, 0, 512)
[IO.File]::WriteAllBytes($disk, $image)
$diskInitialSha = Sha $disk

$boot1Debug = Join-Path $run 'boot1.debugcon.txt'
$boot1Stdout = Join-Path $run '05_qemu_boot1.stdout.txt'
$boot1Stderr = Join-Path $run '05_qemu_boot1.stderr.txt'
$qargs1 = @(
    '-display','none','-monitor','none','-serial','none','-no-reboot','-boot','a',
    '-drive',('file=' + ($disk -replace '\\','/') + ',format=raw,if=floppy'),
    '-device','isa-debug-exit,iobase=0xf4,iosize=0x04',
    '-debugcon',('file:' + $boot1Debug),'-global','isa-debugcon.iobase=0xe9'
)
$old = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& $qemu @qargs1 1> $boot1Stdout 2> $boot1Stderr
$boot1Exit = $LASTEXITCODE
$ErrorActionPreference = $old
if ($boot1Exit -ne 33) { throw "QEMU boot1 exit=$boot1Exit expected=33" }
if (-not (Test-Path $boot1Debug)) { throw 'boot1 debug artifact missing' }
$diskAfterBoot1Sha = Sha $disk

$boot2Debug = Join-Path $run 'boot2.debugcon.txt'
$boot2Stdout = Join-Path $run '06_qemu_boot2.stdout.txt'
$boot2Stderr = Join-Path $run '06_qemu_boot2.stderr.txt'
$qargs2 = @(
    '-display','none','-monitor','none','-serial','none','-no-reboot','-boot','a',
    '-drive',('file=' + ($disk -replace '\\','/') + ',format=raw,if=floppy'),
    '-device','isa-debug-exit,iobase=0xf4,iosize=0x04',
    '-debugcon',('file:' + $boot2Debug),'-global','isa-debugcon.iobase=0xe9'
)
$old = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& $qemu @qargs2 1> $boot2Stdout 2> $boot2Stderr
$boot2Exit = $LASTEXITCODE
$ErrorActionPreference = $old
if ($boot2Exit -ne 33) { throw "QEMU boot2 exit=$boot2Exit expected=33" }
if (-not (Test-Path $boot2Debug)) { throw 'boot2 debug artifact missing' }
$diskAfterBoot2Sha = Sha $disk

$sectorExtract = Join-Path $run 'durable_sector.bin'
$fs = [IO.File]::Open($disk, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
try {
    [void]$fs.Seek($sectorIndex * $sectorBytes, [IO.SeekOrigin]::Begin)
    [byte[]]$sector = New-Object byte[] $sectorBytes
    $read = $fs.Read($sector, 0, $sectorBytes)
    if ($read -ne $sectorBytes) { throw "sector read=$read expected=$sectorBytes" }
    [IO.File]::WriteAllBytes($sectorExtract, $sector)
}
finally {
    $fs.Dispose()
}

$evaluation = Join-Path $run 'evaluation.json'
$evalStdout = Join-Path $run '07_evaluator.stdout.txt'
$evalStderr = Join-Path $run '07_evaluator.stderr.txt'
$old = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& $python $evaluator $boot1Debug $boot2Debug $disk $sectorExtract $evaluation 1> $evalStdout 2> $evalStderr
$evalExit = $LASTEXITCODE
$ErrorActionPreference = $old
if ($evalExit -ne 0) { throw "evaluator exit=$evalExit" }

$receipt = [ordered]@{
    run_id = $RunId
    run_class = 'C003_P04_RESTART_PERSISTENCE_DISCRIMINATOR'
    scientific_p04_completion = $true
    authority_ceiling = 'bounded clean-restart QEMU/raw-floppy/BIOS transport only'
    cwd = $repo
    started_utc = $started
    ended_utc = [DateTime]::UtcNow.ToString('o')
    tools = [ordered]@{
        clang = [ordered]@{path=$clang; sha256=(Sha $clang)}
        lld = [ordered]@{path=$lld; sha256=(Sha $lld)}
        objcopy = [ordered]@{path=$objcopy; sha256=(Sha $objcopy)}
        qemu = [ordered]@{path=$qemu; sha256=(Sha $qemu); boot1_expected_exit=33; boot1_observed_exit=$boot1Exit; boot2_expected_exit=33; boot2_observed_exit=$boot2Exit}
        python = [ordered]@{path=$python; sha256=(Sha $python); observed_eval_exit=$evalExit}
    }
    source_sha256 = [ordered]@{
        mechanism = Sha $mechanism
        fixture_asm = Sha $fixtureAsm
        fixture_json = Sha $fixtureJson
        linker = Sha $linker
        evaluator = Sha $evaluator
        launcher = Sha $PSCommandPath
    }
    artifacts = [ordered]@{
        probe_bin = [ordered]@{path=$probeBin; bytes=$bootBytes.Length; sha256=(Sha $probeBin); boot_signature='55aa'}
        disk = [ordered]@{path=$disk; bytes=(Get-Item $disk).Length; initial_sha256=$diskInitialSha; after_boot1_sha256=$diskAfterBoot1Sha; after_boot2_sha256=$diskAfterBoot2Sha}
        boot1_debug = [ordered]@{path=$boot1Debug; sha256=(Sha $boot1Debug)}
        boot2_debug = [ordered]@{path=$boot2Debug; sha256=(Sha $boot2Debug)}
        durable_sector = [ordered]@{path=$sectorExtract; bytes=(Get-Item $sectorExtract).Length; sha256=(Sha $sectorExtract)}
        evaluation = [ordered]@{path=$evaluation; sha256=(Sha $evaluation)}
        boot1_stdout = [ordered]@{path=$boot1Stdout; sha256=(Sha $boot1Stdout)}
        boot1_stderr = [ordered]@{path=$boot1Stderr; sha256=(Sha $boot1Stderr)}
        boot2_stdout = [ordered]@{path=$boot2Stdout; sha256=(Sha $boot2Stdout)}
        boot2_stderr = [ordered]@{path=$boot2Stderr; sha256=(Sha $boot2Stderr)}
        evaluator_stdout = [ordered]@{path=$evalStdout; sha256=(Sha $evalStdout)}
        evaluator_stderr = [ordered]@{path=$evalStderr; sha256=(Sha $evalStderr)}
    }
}

$receiptPath = Join-Path $run 'receipt.json'
$receipt | ConvertTo-Json -Depth 9 | Set-Content -LiteralPath $receiptPath -Encoding UTF8

Write-Output ('RUN_DIR=' + $run)
Write-Output ('PROBE_SHA256=' + (Sha $probeBin))
Write-Output ('DISK_INITIAL_SHA256=' + $diskInitialSha)
Write-Output ('DISK_AFTER_BOOT1_SHA256=' + $diskAfterBoot1Sha)
Write-Output ('DISK_AFTER_BOOT2_SHA256=' + $diskAfterBoot2Sha)
Write-Output ('BOOT1=' + ((Get-Content -Raw $boot1Debug) -replace "`r?`n",'\n'))
Write-Output ('BOOT2=' + ((Get-Content -Raw $boot2Debug) -replace "`r?`n",'\n'))
Write-Output ('EVALUATION=' + (Get-Content -Raw $evaluation))
Write-Output ('RECEIPT_SHA256=' + (Sha $receiptPath))
