#!/usr/bin/env bash
# scripts/probe.sh - Dependency-graph and value-equality probe for the resolved lazy.nvim spec
#
# ============================================================================
# WHY THIS EXISTS
# ============================================================================
# During the config audit, three findings were asserted from reading source and
# then DISPROVEN when the resolved spec was actually inspected:
#
#   1. "nvim-treesitter's highlight/indent opts are dead config."
#      WRONG. LazyVim's own nvim-treesitter spec declares `indent`, `highlight`
#      and `folds` as its OWN opts and consumes them in a FileType autocmd.
#      The user's restatement is REDUNDANT, not DEAD -- a materially different
#      conclusion with a different safe action.
#
#   2. "Nothing depends on telescope.nvim, so it can be made lazy."
#      WRONG. Two specs declare it in `dependencies` (see `deps telescope.nvim`).
#      One of them, xcodebuild.nvim, is `lazy = false`, which is the root cause
#      of the eager-load cascade.
#
#   3. "diffview is referenced in the config, so something depends on it."
#      WRONG. That was a grep hit inside catppuccin's *colorscheme integration*
#      files, not a spec dependency. Grepping plugin source produces false
#      positives in both directions.
#
# Conclusion: removals and laziness changes must be PROBE-GATED, never inferred
# from reading or grepping source. This script is that gate. Run it BEFORE
# deleting a spec, before flipping `lazy`, and before removing a config line
# believed to be redundant.
#
# ============================================================================
# SUBCOMMANDS
# ============================================================================
#
#   deps <plugin>
#       Walk `require("lazy.core.config").spec.plugins` and print every spec
#       that lists <plugin> in its resolved `dependencies`. Run this before any
#       removal or laziness change so dependency breakage surfaces BEFORE a spec
#       is deleted.
#
#       stdout: one TAB-separated row per dependent -- `<name>\tlazy=<value>`,
#               sorted by name. EMPTY stdout asserts exactly one thing: no
#               resolved spec names <plugin> in a `dependencies` field. That is
#               NOT proof it is safe to remove.
#
#               NOT covered by this probe:
#                 * runtime `require("<module>")` from lua/ or from the harness
#                 * `keys`/`cmd` bindings that invoke the plugin (`<cmd>Trouble ...`)
#                 * LazyVim helper usage (`Snacks.picker`, `LazyVim.*`)
#                 * colorscheme/integration references
#
#               Measured counterexamples, all reporting ZERO dependents while
#               being required at runtime: conform.nvim (required directly by
#               scripts/lib/probe_common.lua:244 -- the whole formatters gate),
#               snacks.nvim, plenary.nvim, trouble.nvim. Removing any of them on
#               the strength of empty `deps` output would break the config.
#
#               Treat empty output as "no declared dependents, now go check the
#               uncovered surfaces above" -- never as a removal green light.
#       stderr: human-readable provenance (resolved name, dependent count).
#       exit:   0 on a successful probe (including zero dependents).
#
#   optval <plugin> <dotted.key> [--list]
#       Resolve the plugin's MERGED opts and print the value at <dotted.key>.
#       Run this to prove a "redundant" config line is truly redundant BEFORE
#       deleting it -- i.e. that the value survives unchanged without the line.
#
#       stdout: the value. Scalars print bare (`true`, `42`, `some-string`).
#               Tables print as canonical JSON via scripts/lib/json.lua (keys
#               sorted, so equal values are byte-identical across runs -- plain
#               `vim.inspect` has nondeterministic key order and is unusable for
#               an equality probe). An absent key prints `nil`, it is not an error.
#       stderr: human-readable provenance (resolved name, Lua type).
#       exit:   0 on a successful probe (including an absent key).
#
# ============================================================================
# OPTS RESOLUTION: is_list=false, NOT true
# ============================================================================
# `require("lazy.core.plugin").values(plugin, "opts", is_list)` is the merge
# entry point. This script passes is_list=FALSE, matching what lazy.nvim itself
# does when it loads a plugin (lazy/core/loader.lua:379,386).
#
# is_list=true is WRONG for `opts` and silently returns wrong answers. That
# branch merges with `Util.extend`, which walks only `ipairs` -- so dictionary
# keys contributed by a super-fragment never merge in. Measured on this config:
#
#     values(nvim-treesitter, "opts", true)  -> highlight.enable == nil   (WRONG)
#     values(nvim-treesitter, "opts", false) -> highlight.enable == true  (RIGHT)
#
# The is_list=true reading is precisely the failure mode that produced wrong
# finding #1 above. If `optval nvim-treesitter highlight.enable` ever prints
# `nil`, the resolution call has regressed -- STOP, and do not delete anything
# on that basis.
#
# `--list` exposes is_list=true deliberately, for the rare case of inspecting
# list-extend semantics. It is never the right flag for proving redundancy.
#
# ============================================================================
# INVOCATION AND STATE SAFETY
# ============================================================================
# * Runs plain `nvim --headless`. It deliberately does NOT pass `-u init.lua`:
#   doing so drives LazyVim's news-check/JSON-save cycle, which rewrites
#   lazyvim.json and drops `install_version`, silently flipping the default
#   explorer and picker. lazyvim.json is gitignored, so git cannot restore it.
# * Lua is written to a temp file and run via `-c "luafile <path>"`. A heredoc
#   into `dofile('/dev/stdin')` is fragile under --headless.
# * Hard self-guard: lazyvim.json and lazy-lock.json are sha256'd before the run
#   and compared after. Any change is restored byte-for-byte from a backup and
#   the script exits 2. A probe must never mutate config state.
# * nvim stdout+stderr is captured and REPLAYED to stderr on failure. Output is
#   never discarded -- `>/dev/null 2>&1` is exactly what hid the lazyvim.json
#   corruption for hours.
# * `User VeryLazy` is NOT fired. Neither subcommand needs post-VeryLazy state,
#   and firing it would load more plugins and widen the side-effect surface. A
#   future probe that does need it should fire it explicitly:
#   `vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })`
# * Dependencies are read from the RESOLVED spec, never grepped from source.
#
# ============================================================================
# EXIT CODES
# ============================================================================
#   0  probe succeeded (zero dependents and absent keys are successes)
#   1  plugin not found in the resolved spec, or the name was ambiguous
#   2  harness failure: bad usage, nvim failed, or a state guard tripped
#
# ============================================================================
# EXAMPLES
# ============================================================================
#   ./scripts/probe.sh deps telescope.nvim
#   ./scripts/probe.sh deps nvim-telescope/telescope.nvim   # owner/repo also works
#   ./scripts/probe.sh optval nvim-treesitter highlight.enable
#   ./scripts/probe.sh optval blink.cmp sources.default

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/probe.sh deps <plugin>
  ./scripts/probe.sh optval <plugin> <dotted.key> [--list]

Subcommands:
  deps    Print every spec that lists <plugin> in its resolved dependencies.
          Empty stdout == no spec DECLARES it as a dependency. That is not proof
          it is safe to remove: runtime require(), keys/cmd bindings and LazyVim
          helper usage are invisible here. See the header comment.
  optval  Print the merged-opts value at <dotted.key>. Absent key prints `nil`.

<plugin> accepts a short name (telescope.nvim) or owner/repo
(nvim-telescope/telescope.nvim).

Exit: 0 success | 1 plugin not found or ambiguous | 2 harness/guard failure
EOF
}

die_usage() {
  echo "probe: $1" >&2
  echo >&2
  usage >&2
  exit 2
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
[[ $# -ge 1 ]] || die_usage "missing subcommand"

SUBCMD=""
PLUGIN=""
DOTTED_KEY=""
IS_LIST="false"

case "$1" in
  -h|--help|help)
    usage
    exit 0
    ;;
  deps)
    SUBCMD="deps"
    shift
    [[ $# -ge 1 ]] || die_usage "deps requires a <plugin> argument"
    PLUGIN="$1"
    shift
    [[ $# -eq 0 ]] || die_usage "deps takes exactly one argument (got extra: $1)"
    ;;
  optval)
    SUBCMD="optval"
    shift
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --list)
          IS_LIST="true"
          shift
          ;;
        -*)
          die_usage "unknown option for optval: $1"
          ;;
        *)
          if [[ -z "${PLUGIN}" ]]; then
            PLUGIN="$1"
          elif [[ -z "${DOTTED_KEY}" ]]; then
            DOTTED_KEY="$1"
          else
            die_usage "optval takes exactly two positional arguments (got extra: $1)"
          fi
          shift
          ;;
      esac
    done
    [[ -n "${PLUGIN}" ]] || die_usage "optval requires a <plugin> argument"
    [[ -n "${DOTTED_KEY}" ]] || die_usage "optval requires a <dotted.key> argument"
    ;;
  *)
    die_usage "unknown subcommand: $1"
    ;;
esac

command -v nvim >/dev/null 2>&1 || { echo "probe: nvim not found on PATH" >&2; exit 2; }

RUN_TIMEOUT=""
if command -v timeout >/dev/null 2>&1; then
  RUN_TIMEOUT="timeout 120"
elif command -v gtimeout >/dev/null 2>&1; then
  RUN_TIMEOUT="gtimeout 120"
fi

# ---------------------------------------------------------------------------
# Temp files. Lua never writes to stdout/stderr directly: it writes a payload,
# a message and a status word to separate files so bash owns the exit code and
# no Lua traceback can leak into user-facing output.
# ---------------------------------------------------------------------------
OUT_TMP="$(mktemp)"
MSG_TMP="$(mktemp)"
STATUS_TMP="$(mktemp)"
LOG_TMP="$(mktemp)"
LUA_TMP="$(mktemp)"
LAZYVIM_BAK="$(mktemp)"
LOCKFILE_BAK="$(mktemp)"
trap 'rm -f "${OUT_TMP}" "${MSG_TMP}" "${STATUS_TMP}" "${LOG_TMP}" "${LUA_TMP}" "${LAZYVIM_BAK}" "${LOCKFILE_BAK}"' EXIT

# ---------------------------------------------------------------------------
# Hard self-guard: hash + back up mutable state files before the run.
# Mirrors scripts/verify.sh.
# ---------------------------------------------------------------------------
LAZYVIM_JSON="${REPO_ROOT}/lazyvim.json"
LOCKFILE_JSON="${REPO_ROOT}/lazy-lock.json"
LAZYVIM_HASH_BEFORE=""
LOCKFILE_HASH_BEFORE=""

if [[ -f "${LAZYVIM_JSON}" ]]; then
  LAZYVIM_HASH_BEFORE="$(shasum -a 256 "${LAZYVIM_JSON}" | awk '{print $1}')"
  cp "${LAZYVIM_JSON}" "${LAZYVIM_BAK}"
fi
if [[ -f "${LOCKFILE_JSON}" ]]; then
  LOCKFILE_HASH_BEFORE="$(shasum -a 256 "${LOCKFILE_JSON}" | awk '{print $1}')"
  cp "${LOCKFILE_JSON}" "${LOCKFILE_BAK}"
fi

guard_state() {
  local tripped=0
  if [[ -n "${LAZYVIM_HASH_BEFORE}" && -f "${LAZYVIM_JSON}" ]]; then
    local after
    after="$(shasum -a 256 "${LAZYVIM_JSON}" | awk '{print $1}')"
    if [[ "${LAZYVIM_HASH_BEFORE}" != "${after}" ]]; then
      cp "${LAZYVIM_BAK}" "${LAZYVIM_JSON}"
      echo "FATAL: probe.sh mutated lazyvim.json! Restored original bytes." >&2
      tripped=1
    fi
  fi
  if [[ -n "${LOCKFILE_HASH_BEFORE}" && -f "${LOCKFILE_JSON}" ]]; then
    local after
    after="$(shasum -a 256 "${LOCKFILE_JSON}" | awk '{print $1}')"
    if [[ "${LOCKFILE_HASH_BEFORE}" != "${after}" ]]; then
      cp "${LOCKFILE_BAK}" "${LOCKFILE_JSON}"
      echo "FATAL: probe.sh mutated lazy-lock.json! Restored original bytes." >&2
      tripped=1
    fi
  fi
  if [[ ${tripped} -ne 0 ]]; then
    cat "${LOG_TMP}" >&2
    exit 2
  fi
}

export PROBE_SUBCMD="${SUBCMD}"
export PROBE_PLUGIN="${PLUGIN}"
export PROBE_KEY="${DOTTED_KEY}"
export PROBE_IS_LIST="${IS_LIST}"
export PROBE_OUT="${OUT_TMP}"
export PROBE_MSG="${MSG_TMP}"
export PROBE_STATUS="${STATUS_TMP}"
export PROBE_LIB="${SCRIPT_DIR}/lib"

# ---------------------------------------------------------------------------
# Lua payload. Everything runs inside pcall so a surprise never emits a
# traceback; failures are reported through the status file instead.
# ---------------------------------------------------------------------------
cat <<'LUA_SCRIPT' > "${LUA_TMP}"
-- Belt-and-braces: keep LazyVim's news check from ever saving lazyvim.json.
pcall(function()
  require("lazyvim.config").news = { lazyvim = false, neovim = false }
  local ok_json, uj = pcall(require, "lazyvim.util.json")
  if ok_json and uj then
    uj.save = function() end
  end
end)

local out_lines = {}
local msg_lines = {}
local status = "ok"

local function emit(s)
  out_lines[#out_lines + 1] = s
end

local function note(s)
  msg_lines[#msg_lines + 1] = s
end

local function finish()
  local function dump(path, lines)
    local fh = io.open(path, "w")
    if fh then
      if #lines > 0 then
        fh:write(table.concat(lines, "\n") .. "\n")
      end
      fh:close()
    end
  end
  dump(vim.env.PROBE_OUT, out_lines)
  dump(vim.env.PROBE_MSG, msg_lines)
  local sf = io.open(vim.env.PROBE_STATUS, "w")
  if sf then
    sf:write(status .. "\n")
    sf:close()
  end
  vim.cmd("qa!")
end

local ok, err = pcall(function()
  -- scripts/ is deliberately OFF the runtimepath, so `require` will not find
  -- these; load them by absolute path.
  local json = dofile(vim.env.PROBE_LIB .. "/json.lua")

  local Config = require("lazy.core.config")
  local Plugin = require("lazy.core.plugin")

  -- `Config.spec.plugins` is the resolved spec table. `Config.plugins` is the
  -- same table in practice; fall back to it if `spec` is somehow unset.
  local spec = (Config.spec and Config.spec.plugins) or Config.plugins
  if type(spec) ~= "table" then
    status = "nospec"
    note("could not read require('lazy.core.config').spec.plugins")
    return
  end

  local subcmd = vim.env.PROBE_SUBCMD
  local query = vim.env.PROBE_PLUGIN

  ---------------------------------------------------------------------------
  -- Name resolution: exact key, case-insensitive key, owner/repo via url,
  -- or the basename of an owner/repo form. Matching stays exact-ish on
  -- purpose -- fuzzy matching is how false positives get in.
  ---------------------------------------------------------------------------
  local function resolve_name(q)
    if spec[q] then
      return q
    end
    local lq = q:lower()
    local base = lq:match("([^/]+)$") or lq
    local by_key, by_url = {}, {}
    for name, plug in pairs(spec) do
      local lname = name:lower()
      if lname == lq or lname == base then
        by_key[#by_key + 1] = name
      end
      local url = tostring(plug.url or ""):lower():gsub("%.git$", "")
      if lq:find("/", 1, true) and url ~= "" and url:sub(-(#lq + 1)) == "/" .. lq then
        by_url[#by_url + 1] = name
      end
    end
    local pool = #by_key > 0 and by_key or by_url
    table.sort(pool)
    if #pool == 1 then
      return pool[1]
    elseif #pool > 1 then
      return nil, "ambiguous", pool
    end
    -- Not found: gather substring suggestions purely as a usability hint.
    local hints = {}
    for name in pairs(spec) do
      if name:lower():find(base, 1, true) then
        hints[#hints + 1] = name
      end
    end
    table.sort(hints)
    return nil, "notfound", hints
  end

  local resolved, why, extra = resolve_name(query)

  if not resolved then
    if why == "ambiguous" then
      status = "ambiguous"
      note(string.format("'%s' is ambiguous in the resolved spec; matches: %s", query, table.concat(extra, ", ")))
    else
      status = "notfound"
      note(string.format("'%s' not found in spec (%d plugins resolved)", query, vim.tbl_count(spec)))
      if #extra > 0 then
        note("did you mean: " .. table.concat(extra, ", "))
      end
    end
    return
  end

  local plugin = spec[resolved]
  note(string.format("resolved '%s' -> '%s'", query, resolved))

  ---------------------------------------------------------------------------
  -- deps: who declares `resolved` in their resolved `dependencies`?
  ---------------------------------------------------------------------------
  if subcmd == "deps" then
    local rows = {}
    for name, plug in pairs(spec) do
      for _, dep in ipairs(plug.dependencies or {}) do
        -- Resolved deps are short names (lazy/core/meta.lua inserts
        -- `dep_meta.name`), but tolerate an owner/repo form defensively.
        local dep_s = tostring(dep)
        local dep_base = dep_s:match("([^/]+)$") or dep_s
        if dep_s == resolved or dep_base == resolved then
          rows[#rows + 1] = string.format("%s\tlazy=%s", name, tostring(plug.lazy))
          break
        end
      end
    end
    table.sort(rows)
    for _, r in ipairs(rows) do
      emit(r)
    end
    if #rows == 0 then
      -- State ONLY what the walk above proves. It inspects `dependencies` fields
      -- and nothing else, so "0 declared dependents" is not "0 references": measured
      -- counterexamples reporting zero declared dependents while being required at
      -- runtime include conform.nvim (scripts/lib/probe_common.lua:244 requires it
      -- directly), snacks.nvim, plenary.nvim and trouble.nvim.
      note(string.format("0 specs declare '%s' in a `dependencies` field", resolved))
      note("  NOT proof it is unreferenced -- this probe does not see: runtime require(),")
      note("  `keys`/`cmd` bindings that invoke it, or LazyVim helper usage (Snacks.*, LazyVim.*)")
    else
      note(string.format("%d spec(s) declare '%s' in a `dependencies` field", #rows, resolved))
    end
    return
  end

  ---------------------------------------------------------------------------
  -- optval: merged opts, then walk the dotted path.
  ---------------------------------------------------------------------------
  if subcmd == "optval" then
    local is_list = (vim.env.PROBE_IS_LIST == "true")
    if is_list then
      note("WARNING: --list uses is_list=true, which does NOT merge dictionary keys from super-fragments. Not valid for proving redundancy.")
    end

    local vok, vals = pcall(Plugin.values, plugin, "opts", is_list)
    if not vok then
      status = "optserror"
      note(string.format("opts resolution failed for '%s': %s", resolved, tostring(vals)))
      return
    end
    note(string.format("resolved opts via lazy.core.plugin.values(plugin, \"opts\", %s)", tostring(is_list)))

    local key = vim.env.PROBE_KEY
    local segments = vim.split(key, ".", { plain = true })
    local cur = vals
    local walked = {}
    for _, seg in ipairs(segments) do
      if type(cur) ~= "table" then
        cur = nil
        break
      end
      local nxt = cur[seg]
      if nxt == nil then
        local n = tonumber(seg)
        if n ~= nil then
          nxt = cur[n]
        end
      end
      cur = nxt
      walked[#walked + 1] = seg
      if cur == nil then
        break
      end
    end

    if cur == nil then
      emit("nil")
      note(string.format("key '%s' is absent (type=nil); deepest resolved segment: %s", key, table.concat(walked, ".")))
      return
    end

    local ty = type(cur)
    note(string.format("key '%s' type=%s", key, ty))
    if ty == "table" then
      -- Canonical JSON: sorted keys, so equal values are byte-identical
      -- across runs. `vim.inspect` key order is nondeterministic.
      local enc = json.encode(cur)
      for line in tostring(enc):gmatch("[^\n]+") do
        emit(line)
      end
    elseif ty == "function" or ty == "userdata" or ty == "thread" then
      emit("<" .. ty .. ">")
      note("value is a " .. ty .. ", not a comparable literal")
    else
      emit(tostring(cur))
    end
    return
  end

  status = "badsubcmd"
  note("unknown subcommand: " .. tostring(subcmd))
end)

if not ok then
  status = "luaerror"
  note("internal probe error: " .. tostring(err))
end

finish()
LUA_SCRIPT

# ---------------------------------------------------------------------------
# Run plain headless nvim. NEVER pass -u. Capture everything.
# ---------------------------------------------------------------------------
NVIM_RC=0
# shellcheck disable=SC2086
${RUN_TIMEOUT} nvim --headless -c "luafile ${LUA_TMP}" >"${LOG_TMP}" 2>&1 || NVIM_RC=$?

# Guard first: a mutation is worse news than a bad exit code.
guard_state

if [[ ${NVIM_RC} -ne 0 ]]; then
  echo "probe: nvim --headless failed with exit code ${NVIM_RC}" >&2
  cat "${LOG_TMP}" >&2
  exit 2
fi

if [[ ! -s "${STATUS_TMP}" ]]; then
  echo "probe: runner produced no status (nvim exited without completing the probe)" >&2
  cat "${LOG_TMP}" >&2
  exit 2
fi

STATUS="$(tr -d '[:space:]' < "${STATUS_TMP}")"

# Provenance and diagnostics go to stderr so stdout stays a clean payload:
# `deps` with zero dependents must produce genuinely empty stdout.
if [[ -s "${MSG_TMP}" ]]; then
  while IFS= read -r line; do
    echo "probe: ${line}" >&2
  done < "${MSG_TMP}"
fi

case "${STATUS}" in
  ok)
    cat "${OUT_TMP}"
    exit 0
    ;;
  notfound|ambiguous)
    exit 1
    ;;
  nospec|optserror|badsubcmd|luaerror)
    cat "${LOG_TMP}" >&2
    exit 2
    ;;
  *)
    echo "probe: unrecognized runner status: ${STATUS}" >&2
    cat "${LOG_TMP}" >&2
    exit 2
    ;;
esac
