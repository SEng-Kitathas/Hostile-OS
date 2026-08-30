from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tarfile
from pathlib import Path

REMOTE_URL = "https://github.com/SEng-Kitathas/Hostile-OS.git"
REMOTE_BRANCH = "main"
MIRROR_ROOT_RELATIVE = Path(".pcmmad_sync_runs") / "github_publish_mirrors"
LFS_THRESHOLD_BYTES = 95_000_000


def run(argv: list[str], cwd: Path, *, check: bool = True, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    cp = subprocess.run(argv, cwd=cwd, text=True, capture_output=True, env=env)
    if check and cp.returncode != 0:
        raise RuntimeError(
            f"command failed ({cp.returncode}): {' '.join(argv)}\nstdout:\n{cp.stdout}\nstderr:\n{cp.stderr}"
        )
    return cp


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def clear_worktree(root: Path) -> None:
    # The PCMMAD execution surface may create ignored runtime logs inside the
    # mirror while publication is running. They are control-plane scratch, not
    # project content, and on Windows may be locked by the active process.
    preserve = {".git", ".pcmmad_sync_runs"}
    for child in root.iterdir():
        if child.name in preserve:
            continue
        if child.is_dir() and not child.is_symlink():
            shutil.rmtree(child)
        else:
            child.unlink()


def export_commit_snapshot(source: Path, mirror: Path, canonical_head: str) -> list[dict[str, object]]:
    """Export one immutable Git commit, never the moving canonical worktree."""
    scratch = source / ".pcmmad_sync_runs" / "github_publication_archives"
    scratch.mkdir(parents=True, exist_ok=True)
    archive = scratch / f"{canonical_head}_{os.getpid()}.tar"
    try:
        run(["git", "archive", "--format=tar", "-o", str(archive), canonical_head], source)
        with tarfile.open(archive, "r:") as tf:
            tf.extractall(mirror, filter="fully_trusted")
    finally:
        archive.unlink(missing_ok=True)

    copied: list[dict[str, object]] = []
    for path in sorted(mirror.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(mirror)
        if ".git" in relative.parts or ".pcmmad_sync_runs" in relative.parts:
            continue
        rel = relative.as_posix()
        copied.append({"path": rel, "bytes": path.stat().st_size, "sha256": sha256(path)})
    return copied


def ensure_mirror(source: Path, mirror: Path) -> None:
    if (mirror / ".git").exists():
        current = run(["git", "remote", "get-url", "origin"], mirror, check=False)
        if current.returncode != 0:
            run(["git", "remote", "add", "origin", REMOTE_URL], mirror)
        elif current.stdout.strip() != REMOTE_URL:
            run(["git", "remote", "set-url", "origin", REMOTE_URL], mirror)
        if os.name == "nt":
            run(["git", "config", "--local", "--replace-all", "credential.helper", ""], mirror)
            run(["git", "config", "--local", "--add", "credential.helper", "manager"], mirror)
        return

    if mirror.exists():
        shutil.rmtree(mirror)

    probe = run(["git", "-c", "credential.helper=", "ls-remote", "--heads", REMOTE_URL, f"refs/heads/{REMOTE_BRANCH}"], source, check=False)
    if probe.returncode == 0 and probe.stdout.strip():
        env = os.environ.copy()
        env["GIT_LFS_SKIP_SMUDGE"] = "1"
        cp = run(["git", "-c", "credential.helper=", "clone", "--branch", REMOTE_BRANCH, "--single-branch", REMOTE_URL, str(mirror)], source, check=False, env=env)
        if cp.returncode != 0:
            raise RuntimeError(f"could not clone publication mirror\nstdout:\n{cp.stdout}\nstderr:\n{cp.stderr}")
    else:
        mirror.mkdir(parents=True)
        run(["git", "init", "-b", REMOTE_BRANCH], mirror)
        run(["git", "remote", "add", "origin", REMOTE_URL], mirror)

    name = run(["git", "config", "user.name"], source, check=False).stdout.strip() or "HOSTILE-OS publication"
    email = run(["git", "config", "user.email"], source, check=False).stdout.strip() or "hostile-os@local.invalid"
    run(["git", "config", "user.name", name], mirror)
    run(["git", "config", "user.email", email], mirror)
    if os.name == "nt":
        # Empty helper resets inherited helper lists before adding GCM directly.
        # This suppresses Git for Windows' interactive helper-selector.
        run(["git", "config", "--local", "--replace-all", "credential.helper", ""], mirror)
        run(["git", "config", "--local", "--add", "credential.helper", "manager"], mirror)


def configure_lfs(mirror: Path, copied: list[dict[str, object]]) -> list[str]:
    run(["git", "lfs", "install", "--local"], mirror)
    large = [str(item["path"]) for item in copied if int(item["bytes"]) >= LFS_THRESHOLD_BYTES]

    attrs = mirror / ".gitattributes"
    existing = attrs.read_text(encoding="utf-8") if attrs.exists() else ""
    marker = "# GitHub publication mirror LFS rules"
    base = existing.split(marker, 1)[0].rstrip()
    lines = [base] if base else []
    if large:
        lines.append(marker)
        for rel in sorted(large):
            escaped = rel.replace("[", "\\[").replace("]", "\\]")
            lines.append(f"{escaped} filter=lfs diff=lfs merge=lfs -text")
    if lines:
        attrs.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    elif attrs.exists():
        attrs.unlink()
    return sorted(large)


def main() -> int:
    source = Path(__file__).resolve().parents[1]

    canonical_head = run(["git", "rev-parse", "HEAD"], source).stdout.strip()
    mirror = source / MIRROR_ROOT_RELATIVE / f"{canonical_head[:12]}_{os.getpid()}"
    branch = run(["git", "branch", "--show-current"], source).stdout.strip()
    if branch != "main":
        raise RuntimeError(f"publication requires canonical branch main, observed {branch!r}")

    staged = run(["git", "diff", "--cached", "--quiet"], source, check=False)
    unstaged = run(["git", "diff", "--quiet"], source, check=False)
    if staged.returncode != 0 or unstaged.returncode != 0:
        raise RuntimeError("canonical tracked worktree has uncommitted changes; commit the substantive pass before publication")

    ensure_mirror(source, mirror)
    clear_worktree(mirror)

    copied = export_commit_snapshot(source, mirror, canonical_head)
    lfs_paths = configure_lfs(mirror, copied)

    head_after_snapshot = run(["git", "rev-parse", "HEAD"], source).stdout.strip()
    canonical_advanced_during_publication = head_after_snapshot != canonical_head

    publication_time = utc_now()
    metadata = {
        "format": "HOSTILE_OS_GITHUB_PUBLICATION_SNAPSHOT_V1",
        "canonical_local_head": canonical_head,
        "canonical_branch": branch,
        "publication_utc": publication_time,
        "remote": REMOTE_URL,
        "published_tracked_file_count": len(copied),
        "published_tracked_bytes_before_lfs": sum(int(x["bytes"]) for x in copied),
        "lfs_paths": lfs_paths,
        "research_included": any(str(x["path"]).startswith("research/") for x in copied),
        "install_surface": "os/",
        "research_required_for_install": False,
        "canonical_head_after_snapshot": head_after_snapshot,
        "canonical_advanced_during_publication": canonical_advanced_during_publication,
        "snapshot_source": "git archive <captured canonical commit>",
    }
    (mirror / ".github-publication-source.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")

    run(["git", "add", "-A"], mirror)
    changed = run(["git", "diff", "--cached", "--quiet"], mirror, check=False).returncode != 0
    if changed:
        message = f"Publish HOSTILE-OS snapshot {canonical_head[:12]} {publication_time}"
        run(["git", "commit", "-m", message], mirror)

    publication_head = run(["git", "rev-parse", "HEAD"], mirror).stdout.strip()
    push_env = os.environ.copy()
    push_env["GIT_TERMINAL_PROMPT"] = "0"
    push_env["GCM_INTERACTIVE"] = "Never"
    push = run(["git", "push", "-u", "origin", REMOTE_BRANCH], mirror, check=False, env=push_env)
    if push.returncode != 0:
        raise RuntimeError(f"GitHub push failed\nstdout:\n{push.stdout}\nstderr:\n{push.stderr}")

    remote = run(["git", "-c", "credential.helper=", "ls-remote", "origin", f"refs/heads/{REMOTE_BRANCH}"], mirror)
    fields = remote.stdout.strip().split()
    remote_head = fields[0] if fields else ""
    if remote_head != publication_head:
        raise RuntimeError(f"remote readback mismatch: local publication {publication_head}, remote {remote_head}")

    result = {
        "ok": True,
        "canonical_local_head": canonical_head,
        "publication_head": publication_head,
        "remote_head": remote_head,
        "remote": REMOTE_URL,
        "publication_utc": publication_time,
        "tracked_files": len(copied),
        "tracked_bytes_before_lfs": sum(int(x["bytes"]) for x in copied),
        "lfs_paths": lfs_paths,
        "research_included": metadata["research_included"],
        "canonical_head_after_snapshot": head_after_snapshot,
        "canonical_advanced_during_publication": canonical_advanced_during_publication,
        "mirror_workspace": str(mirror),
    }
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"PUBLISH_FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
