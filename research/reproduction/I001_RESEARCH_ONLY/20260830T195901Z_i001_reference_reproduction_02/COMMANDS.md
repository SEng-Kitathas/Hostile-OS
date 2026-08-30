# Commands — clean reproduction 02

The first build was intentionally attempted without LLVM discovery configuration and failed closed with the preserved diagnostic.

Successful build:
```powershell
$env:HOSTILE_LLVM_BIN='E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin'
python os\research_only\i001_reference\build.py --out .pcmmad_sync_runs\repro_current_build
```

Two-boot run:
```text
python os/research_only/i001_reference/run.py --build-dir .pcmmad_sync_runs/repro_current_build
```

Verification:
```text
python os/research_only/i001_reference/verify.py --build-dir .pcmmad_sync_runs/repro_current_build
python os/research_only/i001_reference/VERIFY_PACKAGE.py --build-dir .pcmmad_sync_runs/repro_current_build
```

Historical RB02 source-hash adjudication:
```text
python tools/verify_historical_receipt_sources.py research/resource_binding/D64_RB02/runs/20260830T054900Z_d64_rb02_resource_binding_03
```
