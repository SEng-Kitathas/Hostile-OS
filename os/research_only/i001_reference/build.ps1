$ErrorActionPreference = "Stop"
python "$PSScriptRoot/build.py" @args
exit $LASTEXITCODE
