#!/usr/bin/env bash
# Deterministic baseline snapshot of this Neovim configuration.
#
# Captures the 11 Phase A items from .omo/drafts/nvim-config-modernization.md §6.
# Items 4, 6-hash and 8 are INFORMATIONAL and land in <dir>/informational/ so the
# gating diff stays clean.
#
# Usage:
#   scripts/snapshot.sh                 write/refresh tests/baseline/
#   scripts/snapshot.sh --out <dir>     write to <dir> instead
#   scripts/snapshot.sh --check         re-snapshot to a temp dir and diff against
#                                       tests/baseline/; exit 0 if the GATING subtree
#                                       is identical, 1 otherwise
#
# Read-only w.r.t. lazyvim.json: every full-config nvim launch redirects `g:lazyvim_json` to
# a throwaway copy, and the original bytes are hash-verified on exit. This is hardening, not
# the repair of an active bug -- see the note above NVIM_CAPTURE_ARGS. `--out` and `--check`
# never touch tests/baseline/.
#
# Environment requirement: nvim's effective 'helplang' must be non-empty, which the script
# measures rather than inferring from $LC_ALL -- see require_capturable_helplang below.
#
# Tunables (env):
#   SNAPSHOT_PRE_MS          settle before the first capture           (default 3000)
#   SNAPSHOT_POST_MS         settle after firing VeryLazy              (default 3000)
#   SNAPSHOT_LSP_WAIT_MS     per-fixture LSP attach ceiling            (default 12000)
#   SNAPSHOT_LSP_SETTLE_MS   client set must be unchanged this long    (default 2500)
#   SNAPSHOT_STARTUPTIME_RUNS  startuptime sample count                (default 10)
#   SNAPSHOT_RAW_DIR         if set, volatile raw measurements are written here
#   SNAPSHOT_TIMEOUT         hard per-nvim-invocation timeout, seconds (default 600)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
FIXTURE_DIR="${REPO_ROOT}/tests/fixtures"
DEFAULT_OUT="${REPO_ROOT}/tests/baseline"

LAZYVIM_JSON="${REPO_ROOT}/lazyvim.json"
LAZYVIM_HASH_BEFORE=""
LAZYVIM_BAK=""
if [[ -f "${LAZYVIM_JSON}" ]]; then
  LAZYVIM_HASH_BEFORE="$(shasum -a 256 "${LAZYVIM_JSON}" | awk '{print $1}')"
  LAZYVIM_BAK="$(mktemp)"
  cp "${LAZYVIM_JSON}" "${LAZYVIM_BAK}"
fi

# Hardening, NOT the repair of an observed mutation. Stated plainly because the reverse was
# implied before: with the redirect REMOVED, a full `--check` still leaves lazyvim.json
# byte-identical, exit unchanged, and the FATAL guard silent. So in the settled state the
# capture performs no write and this redirect prevents nothing observable. What it does
# prevent is measured and real -- a forced `LazyVim.json.save()` without the redirect writes
# the live file, and with a shadow seeded pre-8 it emits 56 bytes with `install_version`
# MISSING. The write path exists and is reachable; the current capture just does not take it.
# Keep the redirect: the trigger (a news bump, an extras change, a version migration) is a
# LazyVim update away, and the failure is silent when it comes.
#
# LazyVim resolves the path once, at require("lazyvim.config") time --
# config/init.lua:142  `path = vim.g.lazyvim_json or vim.fn.stdpath("config").."/lazyvim.json"`
# -- and writes it from its VeryLazy handler. A write landing on the real file can drop
# `install_version`; LazyVim then reads the install as pre-8 (config/init.lua:444,
# `if (install_version or 7) < 8`) and promotes fzf-lua over snacks in the picker
# defaults, so every later artifact describes a config the user does not have.
#
# `-u` is NOT the lever, contrary to the original diagnosis: `stdpath("config")` is
# XDG-derived and measured identical with and without `-u`. `-u` is passed only to make the
# sourced init file explicit; it does not repoint 'runtimepath'.
LAZYVIM_SHADOW_DIR="$(mktemp -d)"
LAZYVIM_SHADOW="${LAZYVIM_SHADOW_DIR}/lazyvim.json"
if [[ -f "${LAZYVIM_JSON}" ]]; then
  cp "${LAZYVIM_JSON}" "${LAZYVIM_SHADOW}"
fi

# Applied to all three full-config launch sites (probes, startuptime x10, checkhealth):
# any of the 12 starts could reach the write path, so redirecting only the probe launch
# would leave 11 unguarded.
NVIM_CAPTURE_ARGS=(-u "${REPO_ROOT}/init.lua" --cmd "let g:lazyvim_json = '${LAZYVIM_SHADOW}'")

verify_lazyvim_guard() {
  if [[ -n "${LAZYVIM_HASH_BEFORE}" && -f "${LAZYVIM_JSON}" ]]; then
    local hash_after
    hash_after="$(shasum -a 256 "${LAZYVIM_JSON}" | awk '{print $1}')"
    if [[ "${LAZYVIM_HASH_BEFORE}" != "${hash_after}" ]]; then
      [[ -n "${LAZYVIM_BAK}" && -f "${LAZYVIM_BAK}" ]] && cp "${LAZYVIM_BAK}" "${LAZYVIM_JSON}"
      printf 'FATAL: snapshot.sh mutated lazyvim.json! Restored original bytes.\n' >&2
      exit 2
    fi
  fi
  [[ -n "${LAZYVIM_BAK}" && -f "${LAZYVIM_BAK}" ]] && rm -f "${LAZYVIM_BAK}"
}

CHECK_TMP=""
cleanup_snapshot() {
  [[ -n "${CHECK_TMP}" ]] && rm -rf "${CHECK_TMP}"
  [[ -n "${LAZYVIM_SHADOW_DIR}" ]] && rm -rf "${LAZYVIM_SHADOW_DIR}"
  verify_lazyvim_guard
}
trap cleanup_snapshot EXIT

SNAPSHOT_TIMEOUT="${SNAPSHOT_TIMEOUT:-600}"
STARTUPTIME_RUNS="${SNAPSHOT_STARTUPTIME_RUNS:-10}"

OUT=""
MODE="write"

die() {
  printf 'snapshot: %s\n' "$*" >&2
  exit 2
}

usage() {
  awk 'NR>1 { if ($0 !~ /^#/) exit; sub(/^# ?/, ""); print }' "${BASH_SOURCE[0]}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      [[ $# -ge 2 ]] || die "--out requires a directory"
      OUT="$2"
      shift 2
      ;;
    --out=*)
      OUT="${1#--out=}"
      shift
      ;;
    --check)
      MODE="check"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

if [[ "${MODE}" == "check" && -n "${OUT}" ]]; then
  die "--check and --out are mutually exclusive"
fi

command -v nvim >/dev/null || die "nvim not found on PATH"
command -v jq >/dev/null || die "jq not found on PATH (required by write_meta and by the JSON completeness gate)"
[[ -d "${FIXTURE_DIR}" ]] || die "missing fixture directory: ${FIXTURE_DIR}"

# REFUSE, do not normalize. 'helplang' is derived from the locale at nvim startup, not from
# this configuration, so it lands in the gating baseline as an environment artifact.
#
# That is how tests/baseline was poisoned: 1675055 ran the refresh under LC_ALL=C, flipping
# helplang from ["en"] to []. The same commit's own artifact records the environment that did
# it -- informational/checkhealth.txt:92 `$LANG=en_US.UTF-8 $LC_ALL=C $LC_CTYPE=` and :658
# "Locale does not support UTF-8".
#
# Pinning a locale for the nvim launches instead would make the capture agree with whatever
# was pinned and the gating diff would silently disappear, manufacturing a green --check out
# of the defect. Refusing surfaces it.
#
# ASSERT THE RUNTIME VALUE, NOT THE LOCALE NAME. A previous version of this guard matched the
# locale *string* against `*UTF-8*`. That is a proxy for the thing that matters, and it was
# defeated by a real and common locale: measured, `LC_ALL=C.UTF-8` yields helplang "" while
# matching the glob, so the guard accepted a poisoning environment. Worse, the resulting
# capture is byte-identical to the already-poisoned baseline, so the helplang gating diff
# vanishes instead of failing. Never reintroduce a locale-string test here.
#
# The probe launches nvim exactly as the capture does (same -u, same g:lazyvim_json redirect)
# and applies the same transformation probe_common.canonical() applies to a commalist option,
# so what it measures is what would be written to options_global.json.
#
# BOUND, measured and stated rather than implied: this asserts NON-EMPTY only. nvim derives
# helplang from the first two characters of the locale name, so `LC_ALL=POSIX` yields the
# nonsense value "PO", which is non-empty and therefore PERMITTED here. That case is not
# silent -- it produces a visible ["en"] -> ["PO"] gating diff -- whereas empty is, which is
# why empty is what this refuses.
require_capturable_helplang() {
  local eff="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" probe out count raw
  probe="$(mktemp)"
  cat >"${probe}" <<'LUA'
local v = vim.api.nvim_get_option_value("helplang", { scope = "global" })
io.write(("%d|%s"):format(#vim.split(v, ",", { trimempty = true }), v))
LUA
  out="$(timeout "${SNAPSHOT_TIMEOUT}" nvim "${NVIM_CAPTURE_ARGS[@]}" --headless \
    -c "luafile ${probe}" -c 'qa!' 2>/dev/null)" || out=""
  rm -f "${probe}"
  count="${out%%|*}"
  raw="${out#*|}"
  # A probe that returns nothing, or something non-numeric, is a fact about the probe -- it
  # must never be read as a pass.
  case "${count}" in
    '' | *[!0-9]*)
      die "could not determine nvim's effective 'helplang' (probe returned: '${out}'). Refusing to capture rather than guess."
      ;;
    0)
      die "nvim reports 'helplang' EMPTY (raw value: '${raw}'; effective locale: '${eff:-unset}'). It would be captured as [] into tests/baseline/options_global.json, which is exactly the poisoning that produced the current baseline. Re-run with e.g. LANG=en_US.UTF-8."
      ;;
  esac
}
require_capturable_helplang

# extra|fixture-basename  -- one entry per language extra imported in
# lua/config/lazy.lua (draft §2). The extra name is the stable snapshot key; the
# basename is what triggers filetype detection.
#
# tests/fixtures/fixture.swift is DELIBERATELY absent, and this is the only list it
# is absent from. The invariant here is one-entry-per-`lazyvim.plugins.extras.lang.*`
# import, and it holds exactly: 21 entries, 21 lang imports (lazy.lua:25-45), which is
# what makes the list auditable against lazy.lua by counting. Swift is not a LazyVim
# lang extra -- lua/plugins/swift.lua (xcodebuild.nvim) plus the `sourcekit` entry at
# lua/plugins/lspconfig.lua:61 own it -- so adding it would require inventing an extra
# name that does not exist and would destroy that count check.
# What the exclusion costs, stated so it is not mistaken for coverage: keys derived
# from this list -- formatters.json, lsp_clients.json, keymaps_buflocal.json and
# informational/lsp_capabilities_hash.json -- carry NO swift row, and swift's
# options_buflocal.json row is sourced from a scratch buffer, not the real fixture
# (see `source` in that file). Swift IS gated, elsewhere and behaviorally:
# verify.sh's FMT_FIXTURES (formatters swift_swiftformat) and expected_fixtures
# (extras smoke + sourcekit attach). A "no snapshot diff" result for a swift change
# therefore means "this baseline does not observe swift", not "swift is unchanged".
FIXTURES=(
  "c|fixture.c"
  "dart|fixture.dart"
  "docker|Dockerfile"
  "git|COMMIT_EDITMSG"
  "go|fixture.go"
  "helm|helmfile.yaml"
  "java|Fixture.java"
  "json|fixture.json"
  "kotlin|fixture.kt"
  "markdown|fixture.md"
  "python|fixture.py"
  "rust|fixture.rs"
  "sql|fixture.sql"
  "tailwind|fixture.html"
  "terraform|fixture.tf"
  "tex|fixture.tex"
  "toml|fixture.toml"
  "typescript|fixture.ts"
  "vue|fixture.vue"
  "yaml|fixture.yaml"
  "zig|fixture.zig"
)

# Only the filetypes a downstream task actually changes; a full 21-filetype
# option dump is pure diff-noise (draft §6 item 2).
OPTION_FILETYPES='["python","swift","typescript","html","json","markdown"]'

build_manifest() {
  local first=1 json="[" extra file
  for entry in "${FIXTURES[@]}"; do
    extra="${entry%%|*}"
    file="${entry#*|}"
    [[ -f "${FIXTURE_DIR}/${file}" ]] || die "missing fixture: ${FIXTURE_DIR}/${file}"
    [[ ${first} -eq 1 ]] || json+=","
    first=0
    json+=$(printf '{"extra":"%s","file":"%s","path":"%s"}' \
      "${extra}" "${file}" "${FIXTURE_DIR}/${file}")
  done
  printf '%s]' "${json}"
}

run_probe() {
  local probe="$1" log
  shift
  log="$(mktemp)"
  # `--headless -c luafile` is the only probe shape proven to work here: `nvim -l`
  # skips the deferred-timer window the LSP/VeryLazy captures depend on.
  if ! env "$@" \
    SNAPSHOT_LIB="${LIB_DIR}" \
    timeout "${SNAPSHOT_TIMEOUT}" \
    nvim "${NVIM_CAPTURE_ARGS[@]}" --headless -c "luafile ${LIB_DIR}/${probe}" >"${log}" 2>&1; then
    printf 'snapshot: probe output follows\n' >&2
    cat "${log}" >&2
    rm -f "${log}"
    die "probe failed or timed out: ${probe}"
  fi
  rm -f "${log}"
}

capture_lazy_lock() {
  local dest="$1" lock="${REPO_ROOT}/lazy-lock.json" hash count
  if [[ -f "${lock}" ]]; then
    hash="$(shasum -a 256 "${lock}" | awk '{print $1}')"
    count="$(jq 'length' "${lock}")"
  else
    hash="<missing>"
    count=0
  fi
  jq -S -n --arg h "${hash}" --argjson c "${count}" \
    '{sha256:$h, plugin_count:$c, file:"lazy-lock.json"}' >"${dest}/lazy_lock.json"
}

capture_lazyvim_json() {
  local dest="$1" config="${REPO_ROOT}/lazyvim.json" hash install_version version
  if [[ -f "${config}" ]]; then
    hash="$(shasum -a 256 "${config}" | awk '{print $1}')"
    install_version="$(jq '.install_version // null' "${config}")"
    version="$(jq '.version // null' "${config}")"
  else
    hash="<missing>"
    install_version="null"
    version="null"
  fi
  jq -S -n --arg h "${hash}" --argjson iv "${install_version}" --argjson v "${version}" \
    '{file:"lazyvim.json", install_version:$iv, sha256:$h, version:$v}' >"${dest}/lazyvim_json.json"
}

capture_startuptime() {
  local dest="$1" raw="" log total
  log="$(mktemp)"
  local -a samples=()
  for _ in $(seq 1 "${STARTUPTIME_RUNS}"); do
    : >"${log}"
    timeout "${SNAPSHOT_TIMEOUT}" nvim "${NVIM_CAPTURE_ARGS[@]}" --headless --startuptime "${log}" -c 'qa!' >/dev/null 2>&1 || true
    total="$(awk '/--- NVIM STARTED ---/ {print $1}' "${log}" | tail -1)"
    [[ -n "${total}" ]] || total="$(awk 'NF>1 && $1+0>0 {v=$1} END {print v+0}' "${log}")"
    samples+=("${total:-0}")
  done
  rm -f "${log}"
  raw="$(printf '%s\n' "${samples[@]}" | jq -R 'tonumber' | jq -s -S '
    sort as $s
    | ($s | length) as $n
    | (add / $n) as $mean
    | {
        samples: $n,
        raw_ms: $s,
        min_ms: $s[0],
        max_ms: $s[$n-1],
        median_ms: (if $n % 2 == 1 then $s[($n-1)/2] else (($s[$n/2-1] + $s[$n/2]) / 2) end),
        mean_ms: $mean,
        variance_ms2: (($s | map(pow(. - $mean; 2)) | add) / $n),
      }')"

  # Wall-clock milliseconds are irreducibly volatile, so they are NOT written into
  # the snapshot -- a snapshot that changes on every run cannot prove idempotency.
  # The measurement is INFORMATIONAL (draft §6 item 4); its values go to stdout and,
  # when SNAPSHOT_RAW_DIR is set, to a file outside the diffed tree.
  printf 'startuptime (informational, not snapshotted):\n%s\n' "${raw}"
  if [[ -n "${SNAPSHOT_RAW_DIR:-}" ]]; then
    mkdir -p "${SNAPSHOT_RAW_DIR}"
    printf '%s\n' "${raw}" >"${SNAPSHOT_RAW_DIR}/startuptime-raw.json"
  fi

  jq -S -n --argjson n "${STARTUPTIME_RUNS}" '{
    item: "4. startup time (--startuptime, median + variance)",
    informational: true,
    gating: false,
    samples: $n,
    statistics: ["min_ms","max_ms","median_ms","mean_ms","variance_ms2"],
    values_recorded_in_snapshot: false,
    values_location: "stdout of scripts/snapshot.sh; also $SNAPSHOT_RAW_DIR/startuptime-raw.json when that variable is set",
    rationale: "wall-clock ms differ on every run; recording them here would break the byte-stability guarantee that every downstream gate depends on"
  }' >"${dest}/informational/startuptime.json"
}

capture_checkhealth() {
  local dest="$1" tmp
  tmp="$(mktemp)"
  timeout "${SNAPSHOT_TIMEOUT}" nvim "${NVIM_CAPTURE_ARGS[@]}" --headless \
    -c 'checkhealth' -c "w! ${tmp}" -c 'qa!' >/dev/null 2>&1 || true
  {
    printf '# checkhealth (INFORMATIONAL, non-gating)\n'
    printf '# Lines are sorted (LC_ALL=C) and paths/sizes normalized: several health\n'
    printf '# providers (nvim-dap adapters, java, uname) iterate hash tables, so the\n'
    printf '# natural report order differs on every run. Sorting makes the file diffable.\n'
    # BSD sed has no BRE alternation, so each unit needs its own expression.
    sed \
      -e "s#${REPO_ROOT}#\$NVIM_CONFIG#g" \
      -e "s#${HOME}/.local/share/nvim#\$NVIM_DATA#g" \
      -e "s#${HOME}/.local/state/nvim#\$NVIM_STATE#g" \
      -e "s#${HOME}/.cache/nvim#\$NVIM_CACHE#g" \
      -e "s#${HOME}#\$HOME#g" \
      -e 's/[0-9][0-9]*\.[0-9][0-9]*ms/<ms>/g' \
      -e 's/[0-9][0-9]*ms/<ms>/g' \
      -e 's/[0-9][0-9]* KB/<size> KB/g' \
      -e 's/[0-9][0-9]* MB/<size> MB/g' \
      -e 's/[0-9][0-9]* GB/<size> GB/g' \
      -e 's/[0-9][0-9]* bytes/<size> bytes/g' \
      -e 's/nvim\.[0-9][0-9]*/nvim.<pid>/g' \
      -e 's/pid[: =][0-9][0-9]*/pid <pid>/g' \
      -e 's/[[:space:]]*$//' \
      "${tmp}" | LC_ALL=C sort
  } >"${dest}/informational/checkhealth.txt"
  rm -f "${tmp}"
}

write_meta() {
  local dest="$1" nvim_version
  nvim_version="$(nvim --version | head -1 | awk '{print $2}')"
  jq -S -n --arg nv "${nvim_version}" --argjson fixtures "$(printf '%s\n' "${FIXTURES[@]}" |
    sed 's/|.*//' | jq -R . | jq -s -S .)" '{
    snapshot_format_version: 1,
    nvim_version: $nv,
    language_extras: $fixtures,
    items: {
      "1_keymaps": ["keymaps_global.json", "keymaps_buflocal.json"],
      "2_options": ["options_global.json", "options_buflocal.json"],
      "3_plugins": ["plugins.json"],
      "4_startuptime": ["informational/startuptime.json"],
      "5_formatters": ["formatters.json"],
      "6_lsp": ["lsp_clients.json", "informational/lsp_capabilities_hash.json"],
      "7_diagnostics": ["diagnostics.json"],
      "8_checkhealth": ["informational/checkhealth.txt"],
      "9_messages": ["messages.json"],
      "10_lazy_lock": ["lazy_lock.json"],
      "10b_lazyvim_json": ["lazyvim_json.json"],
      "11_mason": ["mason_packages.json"]
    },
    informational_non_gating: [
      "informational/startuptime.json",
      "informational/lsp_capabilities_hash.json",
      "informational/checkhealth.txt"
    ],
    determinism: {
      options_excluded: ["columns","lines","statusline","tabline","winbar"],
      options_canonicalized: "flaglist options are character-sorted; commalist options are emitted as a sorted array",
      checkhealth: "line-sorted (LC_ALL=C), paths and sizes normalized",
      startuptime: "values deliberately not snapshotted (see informational/startuptime.json)"
    }
  }' >"${dest}/meta.json"
}

assert_no_foreign_files() {
  local target_dir="$1"
  local clean_dir="${target_dir%/}"
  local foreign=0 actual_file rel
  while IFS= read -r actual_file; do
    [[ -n "${actual_file}" ]] || continue
    rel="${actual_file#"${clean_dir}/"}"
    case "${rel}" in
      keymaps_global.json | keymaps_buflocal.json | options_global.json | \
      options_buflocal.json | plugins.json | formatters.json | lsp_clients.json | \
      diagnostics.json | messages.json | lazy_lock.json | lazyvim_json.json | \
      mason_packages.json | meta.json | informational/startuptime.json | \
      informational/lsp_capabilities_hash.json | informational/checkhealth.txt)
        ;;
      .DS_Store | */.DS_Store)
        ;;
      *)
        printf 'snapshot: foreign file found in destination %s: %s\n' "${target_dir}" "${rel}" >&2
        foreign=1
        ;;
    esac
  done < <(find "${clean_dir}" -type f)
  [[ ${foreign} -eq 0 ]] || die "foreign file(s) detected in snapshot destination: ${target_dir}"
}

snapshot_into() {
  local dest="$1"
  case "${dest}" in
    "" | "/" | "${HOME}") die "refusing to snapshot into '${dest}'" ;;
  esac
  if [[ -d "${dest}" ]]; then
    assert_no_foreign_files "${dest}"
  fi
  rm -rf "${dest}"
  mkdir -p "${dest}/informational"
  cd "${REPO_ROOT}"

  run_probe probe_static.lua SNAPSHOT_OUT="${dest}"
  run_probe probe_fixtures.lua \
    SNAPSHOT_OUT="${dest}" \
    SNAPSHOT_MANIFEST="$(build_manifest)" \
    SNAPSHOT_OPTION_FILETYPES="${OPTION_FILETYPES}"

  capture_lazy_lock "${dest}"
  capture_lazyvim_json "${dest}"
  capture_startuptime "${dest}"
  capture_checkhealth "${dest}"
  write_meta "${dest}"

  # Completeness gate. `-s` alone is not a completeness test: a truncated write, a
  # half-flushed encoder or a stream of error records all leave a non-empty file, and
  # the gate would then bless that degraded capture as truth with exit 0 -- after which
  # `--check` compares garbage to garbage and reports "identical". So every JSON
  # artifact must additionally PARSE and carry at least one top-level member. That is
  # only enforceable since the encoder started emitting valid UTF-8 (3c9d37b); before
  # that, keymaps_{global,buflocal}.json were rejected by strict parsers outright.
  #
  # informational/checkhealth.txt gets a content test rather than a size test on
  # purpose: capture_checkhealth writes its 4-line header UNCONDITIONALLY (266 bytes),
  # so `-s` on that file can never fail no matter how completely `checkhealth` failed.
  # The assertion is therefore "at least one non-comment, non-blank line", which is
  # exactly what disappears when the capture produces nothing.
  local missing=0 f
  for f in keymaps_global.json keymaps_buflocal.json options_global.json \
    options_buflocal.json plugins.json formatters.json lsp_clients.json \
    diagnostics.json messages.json lazy_lock.json lazyvim_json.json mason_packages.json \
    meta.json informational/startuptime.json \
    informational/lsp_capabilities_hash.json informational/checkhealth.txt; do
    if [[ ! -s "${dest}/${f}" ]]; then
      printf 'snapshot: empty or missing capture: %s\n' "${f}" >&2
      missing=1
      continue
    fi
    case "${f}" in
      *.json)
        if ! jq -e 'if (type == "object" or type == "array") then (length > 0) else true end' \
          "${dest}/${f}" >/dev/null 2>&1; then
          printf 'snapshot: malformed or empty JSON capture: %s\n' "${f}" >&2
          missing=1
        fi
        ;;
      informational/checkhealth.txt)
        if ! LC_ALL=C grep -qv -e '^#' -e '^[[:space:]]*$' "${dest}/${f}"; then
          printf 'snapshot: checkhealth capture is header-only (no report content): %s\n' "${f}" >&2
          missing=1
        fi
        ;;
    esac
  done
  [[ ${missing} -eq 0 ]] || die "incomplete snapshot"

  assert_no_foreign_files "${dest}"
}

do_check() {
  [[ -d "${DEFAULT_OUT}" ]] || die "no baseline at ${DEFAULT_OUT}; run scripts/snapshot.sh first"
  assert_no_foreign_files "${DEFAULT_OUT}"
  CHECK_TMP="$(mktemp -d)"
  snapshot_into "${CHECK_TMP}/current" >/dev/null

  local rc=0
  if ! diff -ru --exclude=informational "${DEFAULT_OUT}" "${CHECK_TMP}/current"; then
    printf '\nsnapshot: GATING DIFF -- baseline and current disagree\n' >&2
    rc=1
  else
    printf 'snapshot: gating subtree identical to %s\n' "${DEFAULT_OUT}"
  fi

  if ! diff -ru "${DEFAULT_OUT}/informational" "${CHECK_TMP}/current/informational" >/dev/null 2>&1; then
    printf 'snapshot: informational diff (NON-GATING, review only):\n'
    diff -ru "${DEFAULT_OUT}/informational" "${CHECK_TMP}/current/informational" || true
  fi
  return "${rc}"
}

if [[ "${MODE}" == "check" ]]; then
  do_check
else
  snapshot_into "${OUT:-${DEFAULT_OUT}}"
  printf 'snapshot: wrote %s\n' "${OUT:-${DEFAULT_OUT}}"
fi
