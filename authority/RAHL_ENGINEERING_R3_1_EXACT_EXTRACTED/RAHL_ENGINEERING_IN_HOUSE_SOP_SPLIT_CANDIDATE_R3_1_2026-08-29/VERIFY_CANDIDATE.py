from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from typing import Any, NoReturn

R = Path(__file__).resolve().parent
EXPECTED_SOURCE_HASHES = {'ancestry/R5/02_ACTIVE_SCARS.md': '9ad09284a7009e05d4b419f96f6f7b2c8ba09798471539cd83599a02a92ec827', 'ancestry/R6/00_READ_ME_FIRST.md': '6a3e1b744468f41794e22d24056859304a7857385c5209f509ebcc6b87c2f64f', 'ancestry/R6/01_CURRENT_TRUSTED_STATE.json': '4b09930563e90bfcea6481cc6d6d2b16e57a2cfb75f4b1461e58d84ba74da414', 'ancestry/R6/02_ACTIVE_SCARS.md': '282c32a657b86b7cc955c992c1aab9976ee7fc25a0467a2c5b2cdddfb301f6a1', 'ancestry/R6/03_NEXT_ACTION.md': '5c29bf0d6dadf414e1fcd1729b36b220868a21179d915639ac1fb7d726ac5f67', 'ancestry/V5/00_START_HERE.md': '76958e4882f9d51ddae8c6e48b15ee360aa8a9acf7afe3251188a345c3bb9d48', 'ancestry/V5/04_ENGINEERING_DECISION_LEDGER.md': '3cff14f313347b6117391f2ea5b5df05a569c36a6f24d631e5a90f3021d0475a', 'ancestry/V5/10_CONTINUATION_AND_EXECUTION_PROTOCOL.md': '9649c1ebe130c71a0621d95ed631f073f8116be8894650a2afd5b0b92442b6c9', 'ancestry/V5/14_MACHINERY_STATUS_SNAPSHOT.md': 'c39b1fd59465b6fadad9d5f47792ad08ffe602cbbb91654072dbb958197c6522', 'ancestry/V5/15_AUTHORSHIP_ENGINEERING_CURRENT_STATE.md': '3d09db4f8747df6611e5da6a536370031eb3a53b42726afd7e872165a7e14808', 'ancestry/V5/18_CURRENT_WHOLE_ENGINEERING_DOCTRINE_CANDIDATES.md': 'fbe46856e06d8d84955f1cbb45ba7de027ecc02da50d0b494d9a349439027bcc', 'ancestry/V5/27_DOCTRINE_AUTHORITY_CLASSES_AND_CONFLICT_RESOLUTION.md': '20dbe9abfdf37c9687bbc3510cb2e2fc5288c2efc8543db69e57298ac5f3b72f', 'ancestry/V5/DOCTRINE_AUTHORITY_REGISTRY.json': '8c84eaa207c3664f28b9650c3356eabd9702dcdf6f0500f7dde96aa838575c21', 'ancestry/V7/01_CUSTOM_GPT_INSTRUCTIONS.md': '899af704a04f0ad73aed0ca26fd05dc5c9d0ea1c45d553debc87818629b67a99', 'ancestry/V7/02_ENGINEERING_RESEARCH_CONSTITUTION.md': '0974dc4b11e5d33f09bd1fb347fbda0e697ff46be533899a145921de13351029'}
EXPECTED_FROZEN_HASHES = {'machine/AUTHORITY_CONTRACT.json': '386c0458e757a4d4bb7dcd09057b969b85b13e1fdc6374fdb64ebfeb95953a59', 'machine/COLD_START_COVERAGE.json': '7b358db55c126ead3fecb1ce6b3a134661e831c02271fb0005c64046623435e7', 'machine/EXECUTION_RELEASE_OBLIGATIONS.json': '0ed12c622e37d8b35474de195e35bcfd353709b3f836fab228a3526dd1602775', 'machine/INTERNAL_GOVERNANCE_REGISTRY.json': '2f4e50dc21c241e167f2aec4094e540732a06049050389f29f99015dceddacc0', 'machine/MACHINERY_AND_MODES.json': '1ff63f8366cae7236addbdebb2aab3d0ba983baf4826bc7d1d391998a00e406f', 'machine/PROJECT_OBLIGATION_SCHEMA.json': '78bb6dd00d295315e5957cc1b6170e89317c197bbe4088b34947d605a39f5f53', 'machine/SUBSTRATE_PROFILE.json': '42982271ff0f4dab858f8c245b82a6982a55d80fa7dd19e61514a77da63d8211'}
EXPECTED_PARENT_SHA = '69721b7b6c4b8c04d5377f1b7c0afa044530a6352496c7cb564f4cb4ef2df257'
EXPECTED_CHURN_SHA = 'c65d7e6fa00ae846d6138fffbf26478caa40006b09859ecc4a7fc31ff75bbb02'
EXPECTED_CANDIDATE_ID = 'RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29'
EXPECTED_FILES = ['00_READ_ME_FIRST.md', '01_ENGINEERING_AUTHORITY_SURFACE.md', '02_PROJECT_CONTRACT_OBLIGATION_INTERFACE.md', '03A_RESEARCH_MACHINERY_AND_MODES.md', '03_INTERNAL_RESEARCH_GOVERNANCE.md', '04_EXECUTION_AND_RELEASE_DISCIPLINE.md', '05_ACTIVE_SCAR_INDEX.md', '06_SUBSTRATE_PROFILE_ACTIVATION.md', '07_COLD_START_USE_ORDER.md', '08_PARENT_EQUIVALENCE_AND_OMISSION_AUDIT.md', '09_REVIEW_ADJUDICATION_AND_R1_R2_REJECTIONS.md', '10_CHURN_FALSIFICATION_RESULT.md', '11_NEXT_DISCRIMINATOR.md', 'MANIFEST_SHA256.json', 'RELEASE_VERIFICATION.md', 'VERIFY_CANDIDATE.py', 'ancestry/R5/02_ACTIVE_SCARS.md', 'ancestry/R6/00_READ_ME_FIRST.md', 'ancestry/R6/01_CURRENT_TRUSTED_STATE.json', 'ancestry/R6/02_ACTIVE_SCARS.md', 'ancestry/R6/03_NEXT_ACTION.md', 'ancestry/SOURCE_HASHES.json', 'ancestry/V5/00_START_HERE.md', 'ancestry/V5/04_ENGINEERING_DECISION_LEDGER.md', 'ancestry/V5/10_CONTINUATION_AND_EXECUTION_PROTOCOL.md', 'ancestry/V5/14_MACHINERY_STATUS_SNAPSHOT.md', 'ancestry/V5/15_AUTHORSHIP_ENGINEERING_CURRENT_STATE.md', 'ancestry/V5/18_CURRENT_WHOLE_ENGINEERING_DOCTRINE_CANDIDATES.md', 'ancestry/V5/27_DOCTRINE_AUTHORITY_CLASSES_AND_CONFLICT_RESOLUTION.md', 'ancestry/V5/DOCTRINE_AUTHORITY_REGISTRY.json', 'ancestry/V7/01_CUSTOM_GPT_INSTRUCTIONS.md', 'ancestry/V7/02_ENGINEERING_RESEARCH_CONSTITUTION.md', 'evidence/CHURN_FALSIFICATION_SUMMARY.json', 'evidence/HOSTILE_MUTATIONS.json', 'evidence/R2_HOSTILE_RESULTS.json', 'machine/ACTIVE_SCARS.json', 'machine/AUTHORITY_CONTRACT.json', 'machine/COLD_START_COVERAGE.json', 'machine/ENGINEERING_AUTHORITY_BINDINGS.json', 'machine/EXECUTION_RELEASE_OBLIGATIONS.json', 'machine/FROZEN_CANDIDATE_BINDINGS.json', 'machine/INTERNAL_GOVERNANCE_REGISTRY.json', 'machine/MACHINERY_AND_MODES.json', 'machine/PROJECT_OBLIGATION_SCHEMA.json', 'machine/SUBSTRATE_PROFILE.json', 'tests/hostile_mutations.py']


def fail(message: str) -> NoReturn:
    print('FAIL:', message)
    raise SystemExit(1)


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(relative: str) -> Any:
    return json.loads((R / relative).read_text(encoding='utf-8'))


def read_text(relative: str) -> str:
    return (R / relative).read_text(encoding='utf-8')


def parse_h3_rule_sections(text: str, prefix: str) -> dict[str, tuple[str, str]]:
    pattern = re.compile(
        rf'(?ms)^### ({re.escape(prefix)}\d{{2}}) — ([^\n]+)\n(.*?)(?=^### {re.escape(prefix)}\d{{2}} — |\Z)'
    )
    return {
        match.group(1): (match.group(2).strip(), match.group(3).strip())
        for match in pattern.finditer(text)
    }


def h2_body(text: str, heading: str) -> str:
    pattern = re.compile(rf'(?ms)^## {re.escape(heading)}\n(.*?)(?=^## |\Z)')
    match = pattern.search(text)
    if match is None:
        fail('missing human section: ' + heading)
    return match.group(1).strip()


def bullet_lines(text: str, prefix: str = '- ') -> list[str]:
    return [line.strip() for line in text.splitlines() if line.startswith(prefix)]


def verify_membership_integrity() -> None:
    actual = {str(path.relative_to(R)) for path in R.rglob('*') if path.is_file()}
    if actual != set(EXPECTED_FILES):
        fail(
            'package membership drift '
            f'missing={sorted(set(EXPECTED_FILES) - actual)} '
            f'extra={sorted(actual - set(EXPECTED_FILES))}'
        )
    manifest = read_json('MANIFEST_SHA256.json')
    if set(manifest) != actual - {'MANIFEST_SHA256.json'}:
        fail('manifest membership drift')
    for relative, expected in manifest.items():
        if sha256_file(R / relative) != expected:
            fail('manifest hash drift: ' + relative)


def verify_pinned_ancestry() -> None:
    ledger = read_json('ancestry/SOURCE_HASHES.json')
    if ledger != EXPECTED_SOURCE_HASHES:
        fail('source hash ledger drift')
    for relative, expected in EXPECTED_SOURCE_HASHES.items():
        if sha256_file(R / relative) != expected:
            fail('pinned ancestry drift: ' + relative)


def parse_v5_candidates() -> list[tuple[str, str, str, list[str], str]]:
    registry = read_json('ancestry/V5/DOCTRINE_AUTHORITY_REGISTRY.json')
    classes = {item['id']: item['classes'] for item in registry['current_candidates']}
    names = {item['id']: item['name'] for item in registry['current_candidates']}
    text = read_text('ancestry/V5/18_CURRENT_WHOLE_ENGINEERING_DOCTRINE_CANDIDATES.md')
    pattern = re.compile(
        r'(?ms)^([1-9]|1\d|2[0-5])\. \*\*(.+?)\.\*\* (.*?)(?=^\d+\. \*\*|^## Authority note)'
    )
    candidates: list[tuple[str, str, str, list[str], str]] = []
    for match in pattern.finditer(text):
        number = int(match.group(1))
        rule_id = f'C{number:02d}'
        body = ' '.join(line.strip() for line in match.group(3).strip().splitlines())
        candidates.append(
            (rule_id, match.group(2).strip(), body, classes[rule_id], names[rule_id])
        )
    if len(candidates) != 25:
        fail('could not recover 25 pinned V5 candidates')
    return candidates


def verify_engineering_authority() -> None:
    expected = parse_v5_candidates()
    actual = read_json('machine/ENGINEERING_AUTHORITY_BINDINGS.json')
    if [item['rule_id'] for item in actual] != [item[0] for item in expected]:
        fail('engineering authority id drift')

    for row, (rule_id, title, body, classes, name) in zip(actual, expected):
        if row.get('title') != title or row.get('statement') != body:
            fail('engineering source body drift: ' + rule_id)
        if row.get('inherited_classes') != classes:
            fail('engineering source class drift: ' + rule_id)
        if row.get('source_name') != name:
            fail('engineering source name drift: ' + rule_id)
        if row.get('surface') != 'CLASSIFIED_ENGINEERING_AUTHORITY':
            fail('engineering surface drift: ' + rule_id)
        if row.get('authority_effect') != 'NONE_COMPRESSION_ONLY':
            fail('engineering authority effect drift: ' + rule_id)

    sections = parse_h3_rule_sections(read_text('01_ENGINEERING_AUTHORITY_SURFACE.md'), 'C')
    if set(sections) != {item[0] for item in expected}:
        fail('human engineering rule-set drift')
    for rule_id, title, body, classes, _ in expected:
        actual_title, actual_body = sections[rule_id]
        expected_body = f"Inherited classes: `{', '.join(classes)}`\n\n{body}"
        if actual_title != title or actual_body != expected_body:
            fail('human engineering section drift: ' + rule_id)


def verify_frozen_candidate_files() -> None:
    ledger = read_json('machine/FROZEN_CANDIDATE_BINDINGS.json')
    if ledger != EXPECTED_FROZEN_HASHES:
        fail('frozen binding ledger drift')
    for relative, expected in EXPECTED_FROZEN_HASHES.items():
        if sha256_file(R / relative) != expected:
            fail('candidate semantic binding drift: ' + relative)


def verify_governance_human_binding() -> None:
    registry = read_json('machine/INTERNAL_GOVERNANCE_REGISTRY.json')
    if len(registry) != 16:
        fail('governance rule count drift')
    sections = parse_h3_rule_sections(read_text('03_INTERNAL_RESEARCH_GOVERNANCE.md'), 'G')
    if set(sections) != {item['rule_id'] for item in registry}:
        fail('governance human rule-set drift')
    for item in registry:
        rule_id = item['rule_id']
        if (
            item['surface'] != 'INTERNAL_RESEARCH_GOVERNANCE'
            or item['authority'] != 'IN_HOUSE_PROCESS_RULE_ONLY'
            or item['product_authority']
            or item['foundation_authority']
        ):
            fail('governance authority/surface drift: ' + rule_id)
        title, body = sections[rule_id]
        if title != item['title'] or body != item['statement']:
            fail('governance human section drift: ' + rule_id)


def verify_scars() -> None:
    def parse(relative: str) -> list[str]:
        return re.findall(r'- `([^`]+)`', read_text(relative))

    expected = (
        [('R5_ACTIVE_SCARS', scar) for scar in parse('ancestry/R5/02_ACTIVE_SCARS.md')]
        + [('R6_ADDITIVE_ACTIVE_SCARS', scar) for scar in parse('ancestry/R6/02_ACTIVE_SCARS.md')]
    )
    data = read_json('machine/ACTIVE_SCARS.json')
    got = [(item['source'], item['scar']) for item in data['scars']]
    if got != expected or data.get('count') != len(expected):
        fail('active scar set drift')
    actual_lines = bullet_lines(read_text('05_ACTIVE_SCAR_INDEX.md'))
    expected_lines = [f'- `{scar}` — {source}' for source, scar in expected]
    if actual_lines != expected_lines:
        fail('human active scar index drift')


def verify_machinery_modes() -> None:
    data = read_json('machine/MACHINERY_AND_MODES.json')
    human = read_text('03A_RESEARCH_MACHINERY_AND_MODES.md')
    if data.get('automatic_resume') is not False:
        fail('method stack resumed automatically')
    if (
        len(data.get('machinery', [])) != 15
        or len(data.get('modes', [])) != 8
        or len(data.get('roles', [])) != 5
    ):
        fail('machinery/mode/role set drift')
    if any(item.get('authority') != 'ATTACK_POSTURE_ONLY' for item in data['roles']):
        fail('role gained authority')
    if any(
        item.get('authority') != 'DISCOURSE_SEPARATION_LABEL_ONLY'
        for item in data['modes']
    ):
        fail('mode gained authority')

    expected_machinery = [
        f"- **{item['name']}:** {item['status']}" for item in data['machinery']
    ]
    expected_modes = [
        f"- **{item['name']}:** {item['meaning']}" for item in data['modes']
    ]
    expected_roles = [
        f"- **{item['name']}:** {item['meaning']}" for item in data['roles']
    ]
    if bullet_lines(h2_body(human, 'Machinery status')) != expected_machinery:
        fail('machinery human section drift')
    if bullet_lines(h2_body(human, 'Modes — optional discourse separation labels')) != expected_modes:
        fail('mode human section drift')
    if bullet_lines(h2_body(human, 'Roles — optional attack postures')) != expected_roles:
        fail('role human section drift')


def verify_project_substrate_coverage_contract() -> None:
    project = read_json('machine/PROJECT_OBLIGATION_SCHEMA.json')
    if project.get('active_by_default') is not False:
        fail('project obligations active by default')

    substrate = read_json('machine/SUBSTRATE_PROFILE.json')
    if (
        substrate.get('profile_instance') is not None
        or substrate.get('status') != 'DORMANT_NO_QUALIFIED_INSTANCE'
    ):
        fail('unearned substrate profile instance')

    coverage = read_json('machine/COLD_START_COVERAGE.json')
    ids = [item['legacy_topic_id'] for item in coverage]
    if ids != [f'L{i:02d}' for i in range(1, 20)]:
        fail('legacy topic identity drift')
    if [item for item in coverage if item.get('blocks_replacement')]:
        fail('legacy coverage still marked replacement-blocking')

    contract = read_json('machine/AUTHORITY_CONTRACT.json')
    if (
        contract.get('candidate_id') != EXPECTED_CANDIDATE_ID
        or contract.get('parent_sha256') != EXPECTED_PARENT_SHA
    ):
        fail('authority contract parent/id drift')
    if (
        contract.get('foundation_promotion') is not False
        or contract.get('candidate_authority')
        != 'COMPRESSION_ONLY_INHERITS_NO_NEW_AUTHORITY'
    ):
        fail('candidate authority drift')
    if contract.get('replacement_ready') is not False:
        fail('candidate claims replacement readiness')
    if contract.get('replacement_blockers') != ['FRESH_REAL_PROJECT_SHADOW_USE']:
        fail('replacement blocker set drift')
    if contract.get('churn_falsification_sha256') != EXPECTED_CHURN_SHA:
        fail('churn evidence binding drift')


def verify_execution_human_binding() -> None:
    rows = read_json('machine/EXECUTION_RELEASE_OBLIGATIONS.json')
    if [item['id'] for item in rows] != [f'E{i:02d}' for i in range(1, 11)]:
        fail('execution/release obligation set drift')
    sections = parse_h3_rule_sections(read_text('04_EXECUTION_AND_RELEASE_DISCIPLINE.md'), 'E')
    if set(sections) != {item['id'] for item in rows}:
        fail('execution/release human rule-set drift')
    for item in rows:
        title, body = sections[item['id']]
        expected_body = f"Authority: `{item['authority']}`\n\n{item['statement']}"
        if title != item['source'] or body != expected_body:
            fail('execution/release human section drift: ' + item['id'])


def verify_no_bytecode() -> None:
    bad = [
        str(path.relative_to(R))
        for path in R.rglob('*')
        if path.is_file() and path.suffix in {'.pyc', '.pyo'}
    ]
    if bad:
        fail('generated bytecode present: ' + repr(bad))


def main() -> None:
    verify_membership_integrity()
    verify_pinned_ancestry()
    verify_engineering_authority()
    verify_frozen_candidate_files()
    verify_governance_human_binding()
    verify_machinery_modes()
    verify_scars()
    verify_project_substrate_coverage_contract()
    verify_execution_human_binding()
    verify_no_bytecode()
    print(
        'PASS: exact membership, pinned ancestry, source class+body binding, '
        'exact human-section binding, governance boundary, active scars, '
        'execution/release recovery, honest coverage blockers, and dormant substrate schema'
    )
    print('ASSURANCE_CEILING=STRUCTURE_SOURCE_CLASS_BODY_COVERAGE_AND_INTEGRITY_ONLY')


if __name__ == '__main__':
    main()
