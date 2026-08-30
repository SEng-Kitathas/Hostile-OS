from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

EVALUATOR_VERSION = "C003-P05-async-irq-idle-v1"
EXPECTED = [
    "PRE_EVENT=0",
    "IDLE_ENTER=PASS",
    "IRQ_EVENT=PASS",
    "IDLE_WAKE=PASS",
    "DONE",
]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: evaluate_p05.py DEBUGCON RESULT_JSON", file=sys.stderr)
        return 64
    debugcon = Path(sys.argv[1])
    result_path = Path(sys.argv[2])
    observed = debugcon.read_text(encoding="ascii").splitlines()
    passed = observed == EXPECTED
    result = {
        "evaluator_version": EVALUATOR_VERSION,
        "expected_lines": EXPECTED,
        "observed_lines": observed,
        "debugcon_sha256": sha256(debugcon),
        "passed": passed,
        "interpretation": (
            "guest reached idle with zero event generation; a QEMU virtual PIT/PIC IRQ created event state and released the waiting activity"
            if passed
            else "P05 asynchronous IRQ/idle discriminator did not meet its preregistered exact observation contract"
        ),
        "authority_ceiling": (
            "QEMU virtual PIT/PIC real-mode evidence only; no physical timing, scheduler architecture, multicore routing, real-time, or architecture claim"
        ),
    }
    result_path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("EVAL_PASS" if passed else "EVAL_FAIL")
    print(f"debugcon_sha256={result['debugcon_sha256']}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
