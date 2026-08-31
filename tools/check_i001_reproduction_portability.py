from __future__ import annotations

import importlib.util
import json
import os
import shutil
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "os/research_only/i001_reference/build.py"
RUN = ROOT / "os/research_only/i001_reference/run.py"
PATCH = ROOT / "payload_history/lab_tooling/HOSTILE_OS_SMUGGLE_PATCH_003.zip"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def main() -> int:
    build = load("hostile_build_portability", BUILD)
    run = load("hostile_run_portability", RUN)
    checks: dict[str, bool] = {}
    details: dict[str, object] = {}

    with tempfile.TemporaryDirectory(prefix="hostile-portability-") as td:
        t = Path(td)
        (t / "bin").mkdir()
        tool = t / "bin/ld.lld"
        tool.write_bytes(b"placeholder")
        spelled = t / "alias/../bin/ld.lld"
        old = os.environ.get("HOSTILE_LLD")
        os.environ["HOSTILE_LLD"] = str(spelled)
        try:
            found = build.find_tool("HOSTILE_LLD", ["ld.lld"])
        finally:
            if old is None:
                os.environ.pop("HOSTILE_LLD", None)
            else:
                os.environ["HOSTILE_LLD"] = old
        identity = build.resolved_identity_path(found)
        checks["tool_invocation_spelling_preserved"] = str(found) == str(spelled)
        checks["tool_identity_resolves_separately"] = identity == tool.resolve()
        details["tool_invocation"] = str(found)
        details["tool_identity"] = str(identity)

        qroot = t / "runtime/qemu"
        (qroot / "bin").mkdir(parents=True)
        (qroot / "modules").mkdir()
        qemu = qroot / "bin/qemu-system-i386"
        qemu.write_bytes(b"placeholder")
        env, module_dir = run.qemu_environment(qemu)
        checks["qemu_module_dir_inferred"] = module_dir == str(qroot / "modules") and env.get("QEMU_MODULE_DIR") == str(qroot / "modules")

    source = RUN.read_text(encoding="utf-8")
    checks["run_disables_default_nic"] = '"-nic", "none"' in source

    with zipfile.ZipFile(PATCH) as z:
        names = set(z.namelist())
        wrapper = z.read("runtime/qemu/run-qemu-i386.sh").decode("utf-8")
        checks["patch003_has_wrapper"] = "runtime/qemu/run-qemu-i386.sh" in names
        checks["patch003_exports_qemu_module_dir"] = "QEMU_MODULE_DIR" in wrapper and "$HERE/modules" in wrapper
        checks["patch003_defaults_nic_none"] = "-nic none" in wrapper
        checks["patch003_supplies_qemu_data_dir"] = '-L "$HERE/share/qemu"' in wrapper
        details["patch003_entries"] = sorted(names)

    result = {"format":"HOSTILE_OS_I001_PORTABILITY_GATE_V2","passed":all(checks.values()),"checks":checks,"details":details}
    print(json.dumps(result, indent=2))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
