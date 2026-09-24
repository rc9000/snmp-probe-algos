#!/bin/bash
set -euo pipefail

export LC_ALL=C

offline=false
while getopts ':o' option; do
    case "$option" in
        o) offline=true ;;
        *) printf 'Usage: %s [-o]\n' "$0" >&2; exit 2 ;;
    esac
done
shift "$((OPTIND - 1))"
if (( $# )); then
    printf 'Usage: %s [-o]\n' "$0" >&2
    exit 2
fi

commands=(snmpget grep)
if ! "$offline"; then
    commands+=(curl sed)
fi
for cmd in "${commands[@]}"; do
    command -v "$cmd" >/dev/null || {
        printf 'Required command missing: %s\n' "$cmd" >&2
        exit 1
    }
done

extract_protocols() {
    local table=$1

    printf '%s\n' "$source_code" |
        sed -n "/^static const usm_alg_type_t ${table}\[\]/,/^};/p" |
        grep -E '^[[:space:]]*\{[[:space:]]*"[^"]+"' |
        sed -E 's/^[^"]*"([^"]+)".*/\1/' |
        grep -Ev '^(NOAUTH|NOPRIV)$'
}

if "$offline"; then
    auth_protocols=$(printf '%s\n' MD5 SHA SHA-224 SHA-256 SHA-384 SHA-512)
    priv_protocols=$(printf '%s\n' DES AES AES-192 AES-256 AES-192-C AES-256-C)
else
    url='https://raw.githubusercontent.com/net-snmp/net-snmp/master/snmplib/snmpusm.c'
    source_code=$(curl --fail --silent --show-error --location \
        --connect-timeout 10 --max-time 60 "$url") || exit 1
    
    # Fail explicitly if upstream changes the table format.
    auth_protocols=$(extract_protocols usm_auth_type) || {
        echo 'Could not extract authentication protocols' >&2
        exit 1
    }
    priv_protocols=$(extract_protocols usm_priv_type) || {
        echo 'Could not extract privacy protocols' >&2
        exit 1
    }
fi

probe() {
    local kind=$1 flag=$2 protocol=$3 output result

    # Help may return nonzero even when the protocol is accepted.
    # Keep -h after the protocol option.
    output=$(snmpget -v3 "$flag" "$protocol" -h 2>&1) || :

    if grep -qiE 'Invalid (authentication|privacy) protocol' <<<"$output"; then
        result=unavailable
    elif grep -qiE '^usage:' <<<"$output"; then
        result=accepted
    else
        result='ERROR (unexpected output)'
        printf '%s\n' "$output" >&2
    fi

    printf '%-4s %-12s %s\n' "$kind" "$protocol" "$result"
}

while IFS= read -r p; do
    probe auth -a "$p"
done <<<"$auth_protocols"
probe auth -a BOGUS-123

printf '\n'

while IFS= read -r p; do
    probe priv -x "$p"
done <<<"$priv_protocols"
probe priv -x BOGUS-123
