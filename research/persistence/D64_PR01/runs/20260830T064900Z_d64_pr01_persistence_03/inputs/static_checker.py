from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

VERSION = "D64-PR01-static-v1"
ACTIVITY_FIELDS = [
    "act_identity", "act_gen", "act_progress", "act_cont", "act_waiting",
    "act_woken", "act_parent_slot", "act_parent_gen", "act_wait_slot",
    "act_wait_gen", "act_epoch",
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def block(text: str, start: str, end: str) -> str:
    return text.split(start + ":\n", 1)[1].split("\n" + end + ":", 1)[0]


def pos_order(text: str, needles: list[str]) -> bool:
    positions = [text.find(x) for x in needles]
    return all(p >= 0 for p in positions) and positions == sorted(positions)


def main() -> int:
    if len(sys.argv) != 9:
        print(
            "usage: static_check_pr01.py STAGE2 STAGE2_LD LAUNCHER EVALUATOR MANIFEST RECEIPT BOOT1_SECTOR BOOT2_SECTOR OUTPUT_JSON",
            file=sys.stderr,
        )
        return 64

    stage2, linker, launcher, evaluator, manifest, receipt, boot1_sector, boot2_sector, out = map(Path, sys.argv[1:])
    t = stage2.read_text(encoding="utf-8").replace("\r\n", "\n")
    ld = linker.read_text(encoding="utf-8").replace("\r\n", "\n")
    l = launcher.read_text(encoding="utf-8").replace("\r\n", "\n")
    e = evaluator.read_text(encoding="utf-8").replace("\r\n", "\n")
    m = json.loads(manifest.read_text(encoding="utf-8"))
    r = json.loads(receipt.read_text(encoding="utf-8"))

    c: dict[str, bool] = {}

    c["exact_d64_capacities_and_arrays"] = bool(
        all(x in t for x in [
            ".equ ACTIVITY_CAP,64", ".equ BINDINGS_PER_ACTIVITY,20",
            ".equ BINDING_CELL_COUNT,1280", ".equ RESOURCE_CAP,64",
        ])
        and all(t.count(f"{name}:.space ACTIVITY_CAP,0") == 1 for name in ACTIVITY_FIELDS)
        and t.count("binding_resource_plus1:.space BINDING_CELL_COUNT,0") == 1
        and t.count("binding_generation:.space BINDING_CELL_COUNT,0") == 1
        and t.count("resource_identity:.space RESOURCE_CAP,0") == 1
        and t.count("resource_generation:.space RESOURCE_CAP,0") == 1
        and t.count("resource_value:.space RESOURCE_CAP,0") == 1
    )

    c["resource_live_count_exact_64_words"] = bool(
        t.count("resource_live_count:.space RESOURCE_CAP*2,0") == 1
        and ".equ RESOURCE_CAP,64" in t
    )

    c["stage2_linker_8k_envelope"] = bool(
        ". = 0x8000;" in ld
        and 'ASSERT(. <= 0xa000, "D64 PR01 stage2 exceeds 8 KiB envelope")' in ld
    )

    durable_read = block(t, "durable_read", "durable_read_fail")
    durable_write = block(t, "durable_write", "durable_write_fail")
    exact_transport = [
        "movb $0x01,%al", "movb $0x00,%ch", "movb $DURABLE_SECTOR,%cl",
        "movb $0x00,%dh", "movb boot_drive,%dl", "int $0x13",
    ]
    c["bios_sector18_single_sector_saved_drive"] = bool(
        ".equ DURABLE_SECTOR,0x12" in t
        and ".equ QUAL_STAGE1_BOOT_DRIVE_MEM,0x7c4b" in t
        and "movb QUAL_STAGE1_BOOT_DRIVE_MEM,%al" in t
        and "movb %al,boot_drive" in t
        and all(x in durable_read for x in exact_transport)
        and all(x in durable_write for x in exact_transport)
        and "movb $0x02,%ah" in durable_read
        and "movb $0x03,%ah" in durable_write
    )

    serialize = block(t, "serialize_boot1_record", "verify_boot1_durable_record")
    c["durable_record_exact20_and_zero_tail"] = bool(
        "movw $512,%cx" in serialize
        and "rep stosb" in serialize
        and all(f"durable_buffer+{i}" in serialize for i in range(1, 20))
        and "durable_buffer+20" not in serialize
        and "movw $durable_buffer+20,%si" in t
        and "movw $492,%cx" in t
    )

    selection = block(t, "_start", "boot1")
    c["boot_selection_from_durable_magic"] = bool(
        all(x in selection for x in [
            "cmpb $'H',durable_buffer", "cmpb $'4',durable_buffer+1",
            "cmpb $'P',durable_buffer+2", "cmpb $'1',durable_buffer+3",
            "jmp boot2", "check_blank_magic:", "jmp boot1",
        ])
        and "HOST_BOOT_MODE" not in l
    )

    c["generic_activity_acquire_both_boots"] = bool(
        t.count("call activity_acquire") == 2
        and t.count("activity_acquire:") == 1
    )

    bind_block = block(t, "bind_new_resource", "binding_read")
    c["generic_bind_rebind_both_boots_and_publish_last"] = bool(
        t.count("call bind_new_resource") == 2
        and t.count("bind_new_resource:") == 1
        and pos_order(bind_block, [
            "incb resource_generation", "movb %al,resource_identity",
            "movb %al,resource_value", "movw $1,resource_live_count",
            "incb binding_generation", "movb %al,binding_resource_plus1",
        ])
    )

    binding_read = block(t, "binding_read", "binding_detach")
    c["checked_binding_read_validates_before_value"] = bool(
        pos_order(binding_read, [
            "call validate_activity", "cmpb $BINDINGS_PER_ACTIVITY,input_binding_index",
            "cmpb $0,binding_resource_plus1", "cmpb binding_generation",
            "cmpb $0,resource_identity", "movb resource_value",
        ])
        and "cmpb act_epoch" in block(t, "validate_activity", "binding_base_from_input")
        and "cmpb activity_epoch" in block(t, "validate_activity", "binding_base_from_input")
    )

    resource_read = block(t, "resource_read", "bad_binding_epochless")
    c["checked_resource_read_validates_before_value"] = bool(
        pos_order(resource_read, [
            "cmpw $RESOURCE_CAP,%bx", "cmpb $0,resource_identity",
            "cmpb resource_generation", "cmpb resource_epoch",
            "movb resource_value",
        ])
    )

    runtime_names = ACTIVITY_FIELDS + [
        "binding_resource_plus1", "binding_generation", "resource_identity",
        "resource_generation", "resource_value", "resource_live_count",
    ]
    c["boot1_serializes_scalars_not_runtime_tables"] = bool(
        all(name not in serialize for name in runtime_names)
        and all(x in serialize for x in [
            "o_a_slot", "o_a_gen", "o_a_epoch", "o_bind_index", "o_bind_gen",
            "o_res_slot", "o_res_gen", "o_res_epoch",
        ])
    )

    detach = block(t, "binding_detach", "resource_read")
    c["detach_clear_ref_before_decrement_and_reclaim_on_zero"] = bool(
        pos_order(detach, [
            "movb $0,binding_resource_plus1(%di)",
            "decw resource_live_count(%si)",
            "cmpw $0,resource_live_count(%si)",
            "movb $0,resource_identity(%bx)",
            "movb $0,resource_value(%bx)",
        ])
    )

    release = block(t, "activity_release_checked", "bind_new_resource")
    c["activity_release_scans_20_cell_row"] = bool(
        "call binding_base_from_input" in release
        and "cmpw $BINDINGS_PER_ACTIVITY,%dx" in release
        and "cmpb $0,binding_resource_plus1(%si)" in release
        and pos_order(release, [
            "cmpb $0,binding_resource_plus1(%si)", "activity_release_clear:",
            "movb $0,act_identity(%bx)",
        ])
    )

    boot2 = block(t, "boot2", "restart_epoch_exhausted")
    c["boot2_resets_full_runtime_before_rebind"] = bool(
        pos_order(boot2, ["call reset_runtime", "movb durable_buffer+6,%al", "call activity_acquire", "call bind_new_resource"])
        and "movw $(runtime_state_end-runtime_state_start),%cx" in block(t, "reset_runtime", "activity_acquire")
        and "rep stosb" in block(t, "reset_runtime", "activity_acquire")
    )

    c["independent_restart_epochs_fail_closed_at_255"] = bool(
        boot2.count("cmpb $255,%al") == 2
        and "movb %al,activity_epoch" in boot2
        and "movb %al,resource_epoch" in boot2
        and "restart_epoch_exhausted:" in t
        and "movb $'G',restart_epoch_status" in t
    )

    c["old_handles_checked_pre_and_post_rebind"] = bool(
        pos_order(boot2, [
            "call binding_read", "movb %al,o_old_bind_pre",
            "call resource_read", "movb %al,o_old_res_pre",
            "call activity_acquire", "call bind_new_resource",
            "call binding_read", "movb %al,o_old_bind_post",
            "call resource_read", "movb %al,o_old_res_post",
        ])
    )

    c["old_binding_rejected_by_activity_epoch_before_value"] = bool(
        "movb durable_buffer+10,%ch" in boot2
        and "cmpb act_epoch(%bx),%al" in block(t, "validate_activity", "binding_base_from_input")
        and "cmpb activity_epoch,%al" in block(t, "validate_activity", "binding_base_from_input")
        and pos_order(binding_read, ["call validate_activity", "movb resource_value(%bx),%al"])
    )

    c["old_resource_rejected_by_resource_epoch_before_value"] = bool(
        "movb durable_buffer+15,%ch" in boot2
        and pos_order(resource_read, ["cmpb resource_epoch,%al", "movb resource_value(%bx),%al"])
    )

    c["fresh_handles_use_epoch2_before_value"] = bool(
        all(x in boot2 for x in [
            "movb o2_a_epoch,%ch", "movb o2_res_epoch,%ch",
            "movb %al,o_fresh_bind", "movb %al,o_fresh_res",
        ])
        and "cmpb $0x7e,o_fresh_bind_val" in boot2
        and "cmpb $0x7e,o_fresh_res_val" in boot2
    )

    bad_binding = block(t, "bad_binding_epochless", "bad_resource_epochless")
    c["bad_binding_control_omits_only_activity_epoch"] = bool(
        all(x in bad_binding for x in [
            "input_activity_slot", "input_activity_gen", "input_binding_index",
            "input_binding_gen", "act_identity", "act_gen", "binding_resource_plus1",
            "binding_generation", "resource_identity", "resource_value",
        ])
        and "input_activity_epoch" not in bad_binding
        and "act_epoch" not in bad_binding
        and "activity_epoch" not in bad_binding
    )

    bad_resource = block(t, "bad_resource_epochless", "print_boot1")
    c["bad_resource_control_omits_only_resource_epoch"] = bool(
        all(x in bad_resource for x in [
            "input_resource_slot", "input_resource_gen", "resource_identity",
            "resource_generation", "resource_value",
        ])
        and "input_resource_epoch" not in bad_resource
        and "resource_epoch" not in bad_resource
    )

    update_start = boot2.find("# Boot2 persistence update changes only last activity/resource epoch fields.")
    update = boot2[update_start:] if update_start >= 0 else ""
    c["boot2_persistence_updates_only_epoch_bytes"] = bool(
        "movb %al,durable_buffer+6" in update
        and "movb %al,durable_buffer+7" in update
        and all(f"durable_buffer+{i}" not in update for i in list(range(0, 6)) + list(range(8, 20)))
        and "call durable_write" in update
    )

    c["launcher_two_distinct_qemu_processes_strict_order"] = bool(
        all(x in l for x in [
            "boot1_proc = subprocess.Popen", "boot2_proc = subprocess.Popen",
            "boot1_pid != boot2_pid", "boot2_started_monotonic >= boot1_ended_monotonic",
        ])
    )

    c["launcher_no_host_disk_mutation_between_boots"] = bool(
        "NO_HOST_DISK_WRITE_BETWEEN_BOOTS = True" in l
        and "durable_after_boot1 = disk.read_bytes()[DURABLE_OFFSET:DURABLE_OFFSET + 512]" in l
        and "disk.write_bytes" not in l.split("# BOOT 1 COMPLETE", 1)[1].split("# BOOT 2 COMPLETE", 1)[0]
    ) if "# BOOT 1 COMPLETE" in l and "# BOOT 2 COMPLETE" in l else False

    forbidden = ["debug.write_text(", "debug.write_bytes(", "synthesize_guest", "mutate_guest_state"]
    c["host_does_not_synthesize_guest_trace_or_state"] = bool(
        all(x not in l for x in forbidden)
        and all(x not in e for x in forbidden)
    )

    snapshots_ok = True
    source_map: dict[str, str] = {}
    for item in m.get("inputs", []):
        snapshot = manifest.parent / item["snapshot_path"]
        ok = snapshot.exists() and snapshot.stat().st_size == item["bytes"] and sha256(snapshot) == item["sha256"]
        snapshots_ok = snapshots_ok and ok
        source_map[item["key"]] = item["sha256"]
    c["run_input_snapshot_manifest_receipt_closure"] = bool(
        snapshots_ok
        and r.get("input_manifest_sha256") == sha256(manifest)
        and all(r.get("source_sha256", {}).get(k) == v for k, v in source_map.items())
    )

    c["all_checks_literal_boolean"] = bool(all(isinstance(v, bool) for v in c.values()))

    expected_boot1 = bytes.fromhex("48 34 50 31 51 7E 01 01 00 01 01 00 01 00 01 01 34 12 01 00") + bytes(492)
    expected_boot2 = bytes.fromhex("48 34 50 31 51 7E 02 02 00 01 01 00 01 00 01 01 34 12 01 00") + bytes(492)
    durable_bytes_match = boot1_sector.read_bytes() == expected_boot1 and boot2_sector.read_bytes() == expected_boot2

    result = {
        "checker_version": VERSION,
        "checks": c,
        "passed": bool(all(c.values()) and durable_bytes_match),
        "durable_sector_bytes_match": bool(durable_bytes_match),
        "stage2_sha256": sha256(stage2),
        "stage2_linker_sha256": sha256(linker),
        "input_manifest_sha256": sha256(manifest),
        "boot1_durable_sha256": sha256(boot1_sector),
        "boot2_durable_sha256": sha256(boot2_sector),
        "check_count": len(c),
    }
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
