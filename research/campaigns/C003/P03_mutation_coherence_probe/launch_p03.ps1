param([Parameter(Mandatory=$true)][string]$RunId)
$ErrorActionPreference='Stop'
$src=$PSScriptRoot
$repo=(Resolve-Path (Join-Path $src '..\..\..\..')).Path
$run=Join-Path $repo ('research\campaigns\C003\runs\'+$RunId)
if(Test-Path $run){throw "run directory already exists: $run"}
New-Item -ItemType Directory -Path $run | Out-Null
$llvm='E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin'
$clang=Join-Path $llvm 'clang.exe'; $lld=Join-Path $llvm 'ld.lld.exe'; $objcopy=Join-Path $llvm 'llvm-objcopy.exe'
$qemu='C:\Program Files\qemu\qemu-system-i386.exe'; $python='C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe'
$mechanism=Join-Path $src 'mechanism.S'; $fixture=Join-Path $src 'fixture.S'; $linker=Join-Path $src 'linker.ld'; $evaluator=Join-Path $src 'evaluate_p03.py'
function Sha([string]$p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower()}
function RunBuild([string]$name,[scriptblock]$body){$so=Join-Path $run ($name+'.stdout.txt');$se=Join-Path $run ($name+'.stderr.txt');& $body 1>$so 2>$se;$ec=$LASTEXITCODE;if($ec -ne 0){throw "$name failed exit=$ec; see $so $se"}}
$started=[DateTime]::UtcNow.ToString('o')
RunBuild '01_clang_mechanism' {& $clang -target i386-unknown-none-elf -ffreestanding -c $mechanism -o (Join-Path $run 'mechanism.o')}
RunBuild '02_clang_fixture' {& $clang -target i386-unknown-none-elf -ffreestanding -c $fixture -o (Join-Path $run 'fixture.o')}
RunBuild '03_link' {& $lld -m elf_i386 -T $linker (Join-Path $run 'mechanism.o') (Join-Path $run 'fixture.o') -o (Join-Path $run 'probe.elf')}
RunBuild '04_objcopy' {& $objcopy -O binary (Join-Path $run 'probe.elf') (Join-Path $run 'probe.bin')}
$probe=Join-Path $run 'probe.bin';$bytes=[IO.File]::ReadAllBytes($probe)
if($bytes.Length -ne 512){throw "probe size=$($bytes.Length) expected=512"};if($bytes[510]-ne 0x55 -or $bytes[511]-ne 0xaa){throw 'boot signature mismatch'}
$dbg=Join-Path $run 'debugcon.txt';$qso=Join-Path $run '05_qemu.stdout.txt';$qse=Join-Path $run '05_qemu.stderr.txt'
$qargs=@('-display','none','-monitor','none','-serial','none','-no-reboot','-drive',('file='+($probe -replace '\\','/')+',format=raw,if=floppy'),'-device','isa-debug-exit,iobase=0xf4,iosize=0x04','-debugcon',('file:'+$dbg),'-global','isa-debugcon.iobase=0xe9')
& $qemu @qargs 1>$qso 2>$qse;$qexit=$LASTEXITCODE;if($qexit -ne 33){throw "QEMU exit=$qexit expected=33"};if(-not(Test-Path $dbg)){throw 'debugcon missing'}
$eval=Join-Path $run 'evaluation.json';$eso=Join-Path $run '06_evaluator.stdout.txt';$ese=Join-Path $run '06_evaluator.stderr.txt'
& $python $evaluator $dbg $eval 1>$eso 2>$ese;$eexit=$LASTEXITCODE;if($eexit -ne 0){throw "evaluator exit=$eexit"}
$receipt=[ordered]@{run_id=$RunId;run_class='C003_P03_MUTATION_COHERENCE_DISCRIMINATOR';scientific_p03_completion=$true;authority_ceiling='single-core bounded explicit-cut model only';cwd=$repo;started_utc=$started;ended_utc=[DateTime]::UtcNow.ToString('o');tools=[ordered]@{clang=[ordered]@{path=$clang;sha256=(Sha $clang)};lld=[ordered]@{path=$lld;sha256=(Sha $lld)};objcopy=[ordered]@{path=$objcopy;sha256=(Sha $objcopy)};qemu=[ordered]@{path=$qemu;sha256=(Sha $qemu);expected_exit=33;observed_exit=$qexit};python=[ordered]@{path=$python;sha256=(Sha $python);observed_eval_exit=$eexit}};source_sha256=[ordered]@{mechanism=(Sha $mechanism);fixture=(Sha $fixture);linker=(Sha $linker);evaluator=(Sha $evaluator);launcher=(Sha $PSCommandPath)};artifacts=[ordered]@{probe_bin=[ordered]@{path=$probe;bytes=$bytes.Length;sha256=(Sha $probe);boot_signature='55aa'};debugcon=[ordered]@{path=$dbg;sha256=(Sha $dbg)};evaluation=[ordered]@{path=$eval;sha256=(Sha $eval)};qemu_stdout=[ordered]@{path=$qso;sha256=(Sha $qso)};qemu_stderr=[ordered]@{path=$qse;sha256=(Sha $qse)};evaluator_stdout=[ordered]@{path=$eso;sha256=(Sha $eso)};evaluator_stderr=[ordered]@{path=$ese;sha256=(Sha $ese)}}}
$rp=Join-Path $run 'receipt.json';$receipt|ConvertTo-Json -Depth 8|Set-Content -LiteralPath $rp -Encoding UTF8
Write-Output ('RUN_DIR='+$run);Write-Output ('PROBE_SHA256='+(Sha $probe));Write-Output ('DEBUGCON='+((Get-Content -Raw $dbg)-replace "`r?`n",'\n'));Write-Output ('EVALUATION='+(Get-Content -Raw $eval));Write-Output ('RECEIPT_SHA256='+(Sha $rp))
