#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<'EOF'
usage: scripts/build.sh <linux|macos|windows> <x86_64|arm64> [platform-checkout]

Build Helium with the password overlay for one native platform target.
The platform checkout is prepared automatically under build/platforms/.
EOF
}

if [ "$#" -lt 2 ]; then
    usage
    exit 2
fi

platform="$1"
arch="$2"
checkout="${3:-}"

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
if [ -z "${checkout}" ]; then
    checkout="$("${root_dir}/scripts/prepare-platform.sh" "${platform}")"
else
    checkout="$("${root_dir}/scripts/prepare-platform.sh" "${platform}" "${checkout}")"
fi

case "${arch}" in
    x86_64|arm64) ;;
    *)
        echo "unsupported arch: ${arch}" >&2
        usage
        exit 2
        ;;
esac

case "${platform}" in
    linux)
        build_args=(-c)
        if [ "${HELIUM_USE_PGO:-0}" = "1" ]; then
            build_args+=(--pgo)
        fi
        (cd "${checkout}" && env -u CI ARCH="${arch}" bash scripts/docker-build.sh "${build_args[@]}")
        (cd "${checkout}" && bash scripts/package.sh)
        ;;
    macos)
        if [ "${CI:-}" = "true" ]; then
            (cd "${checkout}" && bash .github/scripts/github_prepare_xcode.sh)
            (cd "${checkout}" && bash .github/scripts/github_setup_env_toolchain.sh "${arch}")
        fi
        (cd "${checkout}" && ./build.sh "${arch}")
        ;;
    windows)
        windows_args=()
        if [ "${arch}" = "arm64" ]; then
            windows_args+=(--arm)
        fi
        (cd "${checkout}" && python -m pip install httplib2==0.22.0 Pillow)
        (cd "${checkout}" && python build.py "${windows_args[@]}")
        (cd "${checkout}" && python package.py)
        ;;
    *)
        echo "unknown platform: ${platform}" >&2
        usage
        exit 2
        ;;
esac
