#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export LD_LIBRARY_PATH="$HERE/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export QEMU_MODULE_DIR="${QEMU_MODULE_DIR:-$HERE/modules}"

args=("$@")
has_network_arg=0
for arg in "${args[@]}"; do
    case "$arg" in
        -nic|-nic=*|-net|-net=*|-netdev|-netdev=*) has_network_arg=1 ;;
    esac
done

if [[ "$has_network_arg" -eq 0 ]]; then
    args=(-nic none "${args[@]}")
fi

exec "$HERE/bin/qemu-system-i386" \
    -L "$HERE/share/qemu" \
    "${args[@]}"
