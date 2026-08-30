param(
    [Parameter(Mandatory=$true)][string]$RunId
)

$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot
$repo = (Resolve-Path (Join-Path $src '..\..\..\..')).Path
$run = Join-Path $repo ("research\campaigns\C003\runs\" + $RunId)
if (Test-Path $run) { throw "run directory already exists: $run" }
New-Item -ItemType Directory -Path $run | Out-Null

$llvm = 'E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin'
$clang = Join-Path $llvm 'clang.exe'
$lld = Join-Path $llvm 'ld.lld.exe'
$objcopy = Join-Path $llvm 'llvm-objcopy.exe'
$qemu = 'C:\Program Files\qemu\qemu-system-i386.exe'
$python = 'C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe'

$mechanism = Join-Path $src 'mechanism.S'
$fixture = Join-Path $src 'fixture.S'
$linker = Join-Path $src 'linker.ld'
$evaluator = Join-Path $src 'evaluate_reconstruction.py'

function Sha([string]$p) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower() }
function RunBuild([string]$name, [scriptblock]$body) {
    $stdout = Join-Path $run ($name + '.stdout.txt')
    $stderr = Join-Path $run ($name + '.stderr.txt')
    & $body 1> $stdout 2> $stderr
    $ec = $LASTEXITCODE
    if ($ec -ne 0) { throw "$name failed exit=$ec; see $stdout and $stderr" }
}

$started = [DateTime]::UtcNow.ToString('o')

RunBuild '01_clang_mechanism' { & $clang -target i386-unknown-none-elf -ffreestanding -c $mechanism -o (Join-Path $run 'mechanism.o') }
RunBuild '02_clang_fixture' { & $clang -target i386-unknown-none-elf -ffreestanding -c $fixture -o (Join-Path $run 'fixture.o') }
RunBuild '03_link' { & $lld -m elf_i386 -T $linker (Join-Path $run 'mechanism.o') (Join-Path $run 'fixture.o') -o (Join-Path $run 'probe.elf') }
RunBuild '04_objcopy' { & $objcopy -O binary (Join-Path $run 'probe.elf') (Join-Path $run 'probe.bin') }

$probe = Join-Path $run 'probe.bin'
$probeBytes = [IO.File]::ReadAllBytes($probe)
if ($probeBytes.Length -ne 512) { throw "probe raw size is $($probeBytes.Length), expected 512" }
if ($probeBytes[510] -ne 0x55 -or $probeBytes[511] -ne 0xaa) { throw 'boot signature mismatch' }

$debugcon = Join-Path $run 'debugcon.txt'
$qstdout = Join-Path $run '05_qemu.stdout.txt'
$qstderr = Join-Path $run '05_qemu.stderr.txt'
$qargs = @(
    '-display','none',
    '-monitor','none',
    '-serial','none',
    '-no-reboot',
    '-drive',("file=" + ($probe -replace '\\','/') + ',format=raw,if=floppy'),
    '-device','isa-debug-exit,iobase=0xf4,iosize=0x04',
    '-debugcon',("file:" + $debugcon),
    '-global','isa-debugcon.iobase=0xe9'
)
& $qemu @qargs 1> $qstdout 2> $qstderr
$qexit = $LASTEXITCODE
if ($qexit -ne 33) { throw "QEMU exit=$qexit; expected 33; see $qstdout and $qstderr" }
if (-not (Test-Path $debugcon)) { throw 'debugcon missing after QEMU completion' }

$evalResult = Join-Path $run 'evaluation.json'
$evalStdout = Join-Path $run '06_evaluator.stdout.txt'
$evalStderr = Join-Path $run '06_evaluator.stderr.txt'
& $python $evaluator $debugcon $evalResult 1> $evalStdout 2> $evalStderr
$evalExit = $LASTEXITCODE
if ($evalExit -ne 0) { throw "evaluator exit=$evalExit; see $evalStdout and $evalStderr" }

$ended = [DateTime]::UtcNow.ToString('o')
$receipt = [ordered]@{
    run_id = $RunId
    run_class = 'C003_P01_NON_SOURCE_EQUIVALENT_RECONSTRUCTION_PROBE'
    scientific_p01_completion = $false
    authority_ceiling = 'semantic reconstruction only; exact C002 Python source unrecovered; host-subsidy inventory remains open'
    cwd = $repo
    started_utc = $started
    ended_utc = $ended
    tools = [ordered]@{
        clang = [ordered]@{ path=$clang; sha256=(Sha $clang) }
        lld = [ordered]@{ path=$lld; sha256=(Sha $lld) }
        objcopy = [ordered]@{ path=$objcopy; sha256=(Sha $objcopy) }
        qemu = [ordered]@{ path=$qemu; sha256=(Sha $qemu); expected_exit=33; observed_exit=$qexit }
        python = [ordered]@{ path=$python; sha256=(Sha $python); observed_eval_exit=$evalExit }
    }
    source_sha256 = [ordered]@{
        mechanism = (Sha $mechanism)
        fixture = (Sha $fixture)
        linker = (Sha $linker)
        evaluator = (Sha $evaluator)
        launcher = (Sha $PSCommandPath)
    }
    artifacts = [ordered]@{
        probe_bin = [ordered]@{ path=$probe; bytes=$probeBytes.Length; sha256=(Sha $probe); boot_signature='55aa' }
        debugcon = [ordered]@{ path=$debugcon; sha256=(Sha $debugcon) }
        evaluation = [ordered]@{ path=$evalResult; sha256=(Sha $evalResult) }
        qemu_stdout = [ordered]@{ path=$qstdout; sha256=(Sha $qstdout) }
        qemu_stderr = [ordered]@{ path=$qstderr; sha256=(Sha $qstderr) }
        evaluator_stdout = [ordered]@{ path=$evalStdout; sha256=(Sha $evalStdout) }
        evaluator_stderr = [ordered]@{ path=$evalStderr; sha256=(Sha $evalStderr) }
    }
}
$receiptPath = Join-Path $run 'receipt.json'
$receipt | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $receiptPath -Encoding UTF8

Write-Output ('RUN_DIR=' + $run)
Write-Output ('PROBE_SHA256=' + (Sha $probe))
Write-Output ('DEBUGCON=' + ((Get-Content -Raw -LiteralPath $debugcon) -replace "`r?`n", '\n'))
Write-Output ('EVALUATION=' + (Get-Content -Raw -LiteralPath $evalResult))
Write-Output ('RECEIPT_SHA256=' + (Sha $receiptPath))
