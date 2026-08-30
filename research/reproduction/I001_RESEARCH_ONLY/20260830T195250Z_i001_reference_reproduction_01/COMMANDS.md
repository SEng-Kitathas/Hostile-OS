# Reproduction commands used

```text
$env:HOSTILE_LLVM_BIN='E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin'
python os/research_only/i001_reference/build.py
python os/research_only/i001_reference/run.py
python os/research_only/i001_reference/verify.py
```

Equivalent outside-review entry point after build/run:

```text
python os/research_only/i001_reference/VERIFY_PACKAGE.py
```

The portable scripts do not require the historical Windows paths; those commands record the local qualifying environment used for this captured reproduction.
