from __future__ import annotations

import importlib.util
import json
import os
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUN = ROOT / "os/research_only/d64_reference_v2/run.py"
PATCH003 = ROOT / "infra/reproduction/qemu_transplant/PATCH_003/runtime/qemu/run-qemu-i386.sh"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def main() -> int:
    run = load("hostile_d64_v2_run_portability", RUN)
    checks: dict[str, bool] = {}
    details: dict[str, object] = {}

    with tempfile.TemporaryDirectory(prefix="hostile-qemu-runtime-") as td:
        t = Path(td)
        qroot = t / "runtime/qemu"
        (qroot / "bin").mkdir(parents=True)
        (qroot / "modules").mkdir()
        (qroot / "share/qemu").mkdir(parents=True)
        qemu = qroot / "bin/qemu-system-i386"
        qemu.write_bytes(b"placeholder")
        (qroot / "share/qemu/bios-256k.bin").write_bytes(b"placeholder")

        env, module_dir, data_dir = run.qemu_runtime(qemu)
        checks["module_dir_inferred"] = module_dir == str(qroot / "modules") and env.get("QEMU_MODULE_DIR") == str(qroot / "modules")
        checks["data_dir_inferred"] = data_dir == str(qroot / "share/qemu")
        details["synthetic_module_dir"] = module_dir
        details["synthetic_data_dir"] = data_dir

        explicit_data = t / "explicit-data"
        explicit_data.mkdir()
        old_data = os.environ.get("HOSTILE_QEMU_DATA_DIR")
        os.environ["HOSTILE_QEMU_DATA_DIR"] = str(explicit_data)
        try:
            _, _, explicit_selected = run.qemu_runtime(qemu)
        finally:
            if old_data is None:
                os.environ.pop("HOSTILE_QEMU_DATA_DIR", None)
            else:
                os.environ["HOSTILE_QEMU_DATA_DIR"] = old_data
        checks["explicit_data_dir_override"] = explicit_selected == str(explicit_data)

        explicit_alias = t / "explicit-firmware"
        explicit_alias.mkdir()
        old_alias = os.environ.get("HOSTILE_QEMU_FIRMWARE")
        os.environ["HOSTILE_QEMU_FIRMWARE"] = str(explicit_alias)
        try:
            # Ensure the primary name is absent so the alias is actually tested.
            old_primary = os.environ.pop("HOSTILE_QEMU_DATA_DIR", None)
            try:
                _, _, alias_selected = run.qemu_runtime(qemu)
            finally:
                if old_primary is not None:
                    os.environ["HOSTILE_QEMU_DATA_DIR"] = old_primary
        finally:
            if old_alias is None:
                os.environ.pop("HOSTILE_QEMU_FIRMWARE", None)
            else:
                os.environ["HOSTILE_QEMU_FIRMWARE"] = old_alias
        checks["firmware_alias_override"] = alias_selected == str(explicit_alias)

    source = RUN.read_text(encoding="utf-8")
    checks["runner_maps_data_dir_to_dash_L"] = "if data_dir:argv += ['-L',data_dir]" in source
    checks["runner_records_qemu_data_dir"] = "'qemu_data_dir':data" in source
    checks["runner_disables_default_nic"] = "'-nic','none'" in source

    wrapper = PATCH003.read_text(encoding="utf-8", errors="replace")
    checks["historical_patch003_supplies_dash_L"] = '-L "$HERE/share/qemu"' in wrapper
    checks["historical_patch003_supplies_module_dir"] = "QEMU_MODULE_DIR" in wrapper and "$HERE/modules" in wrapper

    result = {
        "format": "HOSTILE_OS_CURRENT_QEMU_TRANSPLANT_PORTABILITY_GATE_V1",
        "passed": all(checks.values()),
        "checks": checks,
        "details": details,
    }
    print(json.dumps(result, indent=2))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
