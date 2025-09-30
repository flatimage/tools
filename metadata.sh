#!/usr/bin/env bash
set -euo pipefail

declare -A LICENSE_MAP
VERSION=""
SOURCE=""
SHA=""

usage() {
  cat >&2 <<EOF
Usage:
  $0 --version <v> --source <url> --sha <hash> [--license <type> <url>]...

Example:
  $0 --version v1.0 \\
    --source https://some-url \\
    --sha 0912783LHFKLSHJF \\
    --license gpl https://some-gpl-url \\
    --license mit https://some-mit-url
EOF
}

# Require jo
command -v jo >/dev/null 2>&1 || { echo "Error: 'jo' is required." >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --license)
      if [[ $# -lt 3 ]]; then
        echo "Error: --license requires <type> and <url>." >&2
        exit 1
      fi
      LICENSE_MAP["$2"]="$3"
      shift 3
      ;;
    --version)
      [[ $# -ge 2 ]] || { echo "Error: --version requires a value." >&2; exit 1; }
      VERSION="$2"
      shift 2
      ;;
    --source)
      [[ $# -ge 2 ]] || { echo "Error: --source requires a value." >&2; exit 1; }
      SOURCE="$2"
      shift 2
      ;;
    --sha)
      [[ $# -ge 2 ]] || { echo "Error: --sha requires a value." >&2; exit 1; }
      SHA="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Invalid argument '$1'" >&2
      usage
      exit 1
      ;;
  esac
done

# Basic validation
[[ -n "${VERSION}" ]] || { echo "Error: --version is required." >&2; exit 1; }
[[ -n "${SOURCE}"  ]] || { echo "Error: --source is required."  >&2; exit 1; }
[[ -n "${SHA}"     ]] || { echo "Error: --sha is required."     >&2; exit 1; }

# Build final JSON
jo_args=( -s version="$VERSION" -s source="$SOURCE" -s sha="$SHA" )

# Sort types alphabetically
mapfile -t _types < <(printf "%s\n" "${!LICENSE_MAP[@]}" | sort)

# Create a JSON object for each license and append to licenses[]
if [[ ${#_types[@]} -eq 0 ]]; then
  echo "Error: --license is required."  >&2
  exit 1
fi
for type in "${_types[@]}"; do
  jo_args+=( "licenses[]=$(jo type="$type" url="${LICENSE_MAP[$type]}")" )
done

# Emit pretty JSON
jo -p -- "${jo_args[@]}"