#!/usr/bin/env bash
# scripts/verify.sh - Phase C headless assertions runner
#
# Closed tag vocabulary:
#   quit, safequit, explorer, keymaps, whichkey, floats, hover,
#   messages, eager, dap, formatters, diagnostics, extras, lockfile
#
# CLI Contract:
#   --only <csv>     Run only checks whose tag is in the comma-separated list.
#                    Unknown tag -> exit 2 with "unknown tag: <tag>".
#   --report-only    Run every check, print one line each, always exit 0.
#   --declared       Tolerate plenary.nvim and nui.nvim in eager set.
#   (default)        Run every check; exit 0 only if zero FAIL.
#
# PENDING = target task not yet complete in tests/state/completed-tasks.txt;
#           never counts as FAIL.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# EXPECTED_10: Authoritative post-fix eager plugin set (plan line 396, draft §3c)
EXPECTED_10="LazyVim,lazy.nvim,snacks.nvim,rose-pine,nvim-lspconfig,mason.nvim,mason-lspconfig.nvim,nvim-treesitter,vim-sleuth,vimtex"

VALID_TAGS=(
  "quit"
  "safequit"
  "explorer"
  "keymaps"
  "whichkey"
  "floats"
  "hover"
  "messages"
  "eager"
  "dap"
  "formatters"
  "diagnostics"
  "extras"
  "lockfile"
)

REPORT_ONLY=0
DECLARED=0
ONLY_TAGS=""

die_unknown_tag() {
  echo "unknown tag: $1" >&2
  exit 2
}

# Parse CLI flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --report-only)
      REPORT_ONLY=1
      shift
      ;;
    --declared)
      DECLARED=1
      shift
      ;;
    --only)
      [[ $# -ge 2 ]] || { echo "error: --only requires a CSV list of tags" >&2; exit 2; }
      ONLY_TAGS="$2"
      shift 2
      ;;
    --only=*)
      ONLY_TAGS="${1#--only=}"
      shift
      ;;
    -h|--help)
      echo "Usage: ./scripts/verify.sh [--only <csv>] [--report-only] [--declared]"
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# Validate --only tags against the closed 14-tag vocabulary
SELECTED_TAGS_CSV=""
if [[ -n "${ONLY_TAGS}" ]]; then
  IFS=',' read -ra REQ_ARRAY <<< "${ONLY_TAGS}"
  for req in "${REQ_ARRAY[@]}"; do
    req="$(echo "${req}" | xargs)"
    [[ -n "${req}" ]] || continue
    is_valid=0
    for vt in "${VALID_TAGS[@]}"; do
      if [[ "${req}" == "${vt}" ]]; then
        is_valid=1
        break
      fi
    done
    if [[ ${is_valid} -eq 0 ]]; then
      die_unknown_tag "${req}"
    fi
  done
  SELECTED_TAGS_CSV="${ONLY_TAGS}"
else
  # All valid tags active
  SELECTED_TAGS_CSV="$(IFS=','; echo "${VALID_TAGS[*]}")"
fi

RUN_TIMEOUT=""
if command -v timeout >/dev/null 2>&1; then
  RUN_TIMEOUT="timeout 90"
elif command -v gtimeout >/dev/null 2>&1; then
  RUN_TIMEOUT="gtimeout 90"
fi

COMPLETED_TASKS_FILE="${REPO_ROOT}/tests/state/completed-tasks.txt"
if [[ ! -f "${COMPLETED_TASKS_FILE}" ]]; then
  echo "error: completed tasks file missing: ${COMPLETED_TASKS_FILE}" >&2
  exit 2
fi
OUT_TMP="$(mktemp)"
LOG_TMP="$(mktemp)"
LUA_TMP="$(mktemp)"
LAZYVIM_BAK="$(mktemp)"
trap 'rm -f "${OUT_TMP}" "${LOG_TMP}" "${LUA_TMP}" "${LAZYVIM_BAK}"' EXIT

# Hard self-guard: record lazyvim.json hash and create backup before run
LAZYVIM_JSON="${REPO_ROOT}/lazyvim.json"
LAZYVIM_HASH_BEFORE=""
if [[ -f "${LAZYVIM_JSON}" ]]; then
  LAZYVIM_HASH_BEFORE="$(shasum -a 256 "${LAZYVIM_JSON}" | awk '{print $1}')"
  cp "${LAZYVIM_JSON}" "${LAZYVIM_BAK}"
fi

export VERIFY_REPO_ROOT="${REPO_ROOT}"
export VERIFY_EXPECTED_10="${EXPECTED_10}"
export VERIFY_DECLARED="${DECLARED}"
export VERIFY_TAGS="${SELECTED_TAGS_CSV}"
export VERIFY_COMPLETED_TASKS="${COMPLETED_TASKS_FILE}"
export VERIFY_OUT="${OUT_TMP}"

cat << 'LUA_SCRIPT' > "${LUA_TMP}"
-- Verification is strictly read-only: prevent any plugin from mutating lazyvim.json
pcall(function()
  require("lazyvim.config").news = { lazyvim = false, neovim = false }
  local ok_json, uj = pcall(require, "lazyvim.util.json")
  if ok_json and uj then
    uj.save = function() end
  end
end)

local repo_root = vim.env.VERIFY_REPO_ROOT
local expected_10_csv = vim.env.VERIFY_EXPECTED_10
local declared_allowance = (vim.env.VERIFY_DECLARED == "1")
local tags_csv = vim.env.VERIFY_TAGS or ""
local completed_file = vim.env.VERIFY_COMPLETED_TASKS
local out_path = vim.env.VERIFY_OUT

-- Active tags map
local active_tags = {}
for tag in string.gmatch(tags_csv, "[^,]+") do
  active_tags[vim.trim(tag)] = true
end

-- Read completed tasks
local completed_tasks = {}
local cf = io.open(completed_file, "r")
if not cf then
  io.stderr:write(string.format("error: completed tasks file missing: %s\n", tostring(completed_file)))
  vim.cmd("cquit 2")
end
for line in cf:lines() do
  local num = tonumber(line:match("^%s*(%d+)%s*$"))
  if num then
    completed_tasks[num] = true
  end
end
cf:close()

local function is_task_completed(task_id)
  return completed_tasks[task_id] == true
end

local results = {}
local pass_count = 0
local fail_count = 0
local pending_count = 0

local function check(tag, name, target_task, condition_passed)
  if not active_tags[tag] then
    return
  end
  local status
  if condition_passed then
    status = "PASS"
    pass_count = pass_count + 1
  else
    if is_task_completed(target_task) then
      status = "FAIL"
      fail_count = fail_count + 1
    else
      status = "PENDING"
      pending_count = pending_count + 1
    end
  end
  table.insert(results, string.format("%s %s %s", status, tag, name))
end

-- 1. Pre-VeryLazy state capture
local eager_plugins = {}
for name, p in pairs(require("lazy.core.config").plugins) do
  if p._ and p._.loaded then
    table.insert(eager_plugins, name)
  end
end
table.sort(eager_plugins)
local eager_map = {}
for _, p in ipairs(eager_plugins) do
  eager_map[p] = true
end

-- Tag: eager (pre-VeryLazy assertions)
local expected_10_map = {}
for name in string.gmatch(expected_10_csv, "[^,]+") do
  expected_10_map[vim.trim(name)] = true
end
if declared_allowance then
  expected_10_map["plenary.nvim"] = true
  expected_10_map["nui.nvim"] = true
end

local eager_subset_ok = true
for _, p_name in ipairs(eager_plugins) do
  if not expected_10_map[p_name] then
    eager_subset_ok = false
    break
  end
end

-- Eager subset check: target task 1 (the single failing gate)
check("eager", "eager_set_subset_expected_10", 1, eager_subset_ok)
-- Frozen plugins check: vim-sleuth AND vimtex must stay eager
check("eager", "frozen_plugins_present", 1, (eager_map["vim-sleuth"] == true and eager_map["vimtex"] == true))

-- Tag: dap (startup check)
local dap_family = { "nvim-dap", "nvim-dap-ui", "nvim-dap-virtual-text" }
local dap_unloaded = true
for _, d_name in ipairs(dap_family) do
  if eager_map[d_name] then
    dap_unloaded = false
    break
  end
end
check("dap", "dap_family_unloaded_at_startup", 13, dap_unloaded)

-- Tag: explorer (startup check)
local neo_p = require("lazy.core.config").plugins["neo-tree.nvim"]
-- Gated on task 12, not 6: neo-tree's spec becomes lazy in task 6, but xcodebuild.nvim
-- (lazy=false, swift.lua:10) requires neo-tree.events, so it stays LOADED until task 12
-- removes that eager flag. Task 6 cannot satisfy this.
check("explorer", "neotree_lazy_at_startup", 12, (neo_p and neo_p._ and neo_p._.loaded == nil))

local ok_init, init = pcall(require, "lazyvim.config.init")
local exp_def = ok_init and init.get_default("explorer")
check("explorer", "get_default_explorer", 6, (exp_def and exp_def.name == "neo-tree" and exp_def.origin == "global"))

-- The picker's counterpart to the explorer check above. LazyVim resolves a picker of "auto"
-- by branching on install_version in lazyvim.json, which is gitignored and rewritten on every
-- launch, so losing that file silently changes the picker. Asserting origin == "global" is what
-- proves the in-repo pin was read rather than a default coincidentally agreeing.
local pick_def = ok_init and init.get_default("picker")
check("explorer", "get_default_picker", 19, (pick_def and pick_def.name == "snacks" and pick_def.origin == "global"))

-- jdtls resolution must not depend on $MASON. Every other jdtls assertion here runs with
-- mason force-loaded (see the fixture LSP block), so $MASON expands and LazyVim's own formula
-- resolves -- which is why those checks stayed green through a crash that killed jdtls in real
-- sessions. This one poisons the variable so ONLY a resolution derived from stdpath("data")
-- can pass, then restores it: later checks resolve mason binaries and must not see the poison.
local jdtls_env_independent = false
do
	local saved_mason = vim.env.MASON
	vim.env.MASON = "/nonexistent-poison"
	local plug = require("lazy.core.config").plugins["nvim-jdtls"]
	if plug then
		local ok_vals, o = pcall(function()
			return require("lazy.core.plugin").values(plug, "opts", true)
		end)
		if ok_vals and type(o) == "table" then
			-- opts.cmd only. Calling opts.full_cmd() here would reach LazyVim's root_dir,
			-- which indexes require("jdtls") -- nil before nvim-jdtls loads -- and takes the
			-- whole harness down. resolve_cmd() rewrites opts.cmd at config time anyway.
			local cmd = o.cmd
			if type(cmd) == "table" and #cmd > 0 then
				local want_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
				local agent_seen, agent_ok = false, true
				for _, a in ipairs(cmd) do
					local p = tostring(a):match("%-javaagent:(.+)$")
					if p then
						agent_seen = true
						-- Absolute, readable, and specifically not the "/share/..." shape an
						-- empty $MASON produces. A dropped agent is the sanctioned degrade.
						agent_ok = p:sub(1, 1) == "/"
							and not p:match("^/share/")
							and vim.fn.filereadable(p) == 1
					end
				end
				jdtls_env_independent = cmd[1] == want_bin and (not agent_seen or agent_ok)
			end
		end
	end
	vim.env.MASON = saved_mason
end
check("extras", "jdtls_cmd_resolves_without_mason_env", 19, jdtls_env_independent)

-- Tag: floats & hover (monkeypatch checks)
--
-- Both checks assert PROVENANCE: the function still is the one Neovim shipped, not a
-- wrapper. The previous forms asserted something much weaker than their names claim.
--
-- `nvim_open_win` was `what == "C" or not source:find("options.lua")`. The `or` is the
-- defect: a wrapper installed from ANY file other than options.lua satisfies the second
-- disjunct, so the check could only ever catch a monkey-patch from that one file, while
-- reporting `PASS floats nvim_open_win_is_core`. `nvim_open_win` is a C function, so
-- `what == "C"` is both necessary and sufficient, and no filename appears anywhere.
local info_open_win = debug.getinfo(vim.api.nvim_open_win)
check("floats", "nvim_open_win_is_core", 7, info_open_win.what == "C")

-- `open_floating_preview` is core *Lua* ($VIMRUNTIME/lua/vim/lsp/util.lua), so the
-- `what == "C"` test used above would be wrong here -- the assertion has to be where the
-- definition lives. The previous form tested only that the source is not options.lua,
-- which is true of core, of every plugin wrapper, and of every user file alike: it never
-- asserted core-ness at all. Now: the definition must sit under $VIMRUNTIME.
local info_hover = debug.getinfo(vim.lsp.util.open_floating_preview)
local hover_src = vim.fs.normalize((tostring(info_hover.source):gsub("^@", "")))
local nvim_runtime = vim.fs.normalize(tostring(vim.env.VIMRUNTIME or vim.fn.expand("$VIMRUNTIME")))
local hover_is_core = (nvim_runtime ~= "" and nvim_runtime ~= "$VIMRUNTIME" and vim.startswith(hover_src, nvim_runtime))
check("hover", "open_floating_preview_is_core", 8, hover_is_core)

-- Fire VeryLazy for post-VeryLazy checks
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })

-- Tag: eager (difi post-VeryLazy)
local difi_p = require("lazy.core.config").plugins["difi.nvim"]
check("eager", "difi_unloaded_post_verylazy", 16, (difi_p and difi_p._ and difi_p._.loaded == nil))

-- Post-VeryLazy companions for the dap and neo-tree startup assertions above. Those two run
-- during pre-VeryLazy capture, where only 6 plugins are loaded; 13 more load when VeryLazy
-- fires. A regression that moved either target into that cohort would leave the startup
-- assertions green while the plugin was in fact loaded, so on its own each names less than it
-- implies -- the defect class this harness exists to catch. Measured: neither the dap family
-- nor neo-tree is among the 13, so both legitimately stay unloaded here and these are
-- assertions rather than guesses. difi above already established the pattern; it was simply
-- never generalised.
local dap_unloaded_post = true
for _, d_name in ipairs(dap_family) do
	local dp = require("lazy.core.config").plugins[d_name]
	if dp and dp._ and dp._.loaded then
		dap_unloaded_post = false
		break
	end
end
check("dap", "dap_family_unloaded_post_verylazy", 13, dap_unloaded_post)

local neo_post = require("lazy.core.config").plugins["neo-tree.nvim"]
check("explorer", "neotree_lazy_post_verylazy", 12, (neo_post and neo_post._ and neo_post._.loaded == nil))

-- Tag: messages
--
-- Read AFTER VeryLazy, never before. LazyVim sources lua/config/keymaps.lua from its
-- VeryLazy handler, so while this check ran at startup the branch's most-edited config
-- file was sourced *after* the only assertion that reads the log -- anything it logged
-- was structurally invisible (A-18 timing hole).
--
-- Detection is the E-class matcher already proven in this file at the LSP fixture gate
-- (`line:match("E%d+:")`), applied line-by-line for the same reason it is used there:
-- Neovim renders errors as `E492:`/`E477:`/`E325:`, and a literal `"Error"` substring
-- test matches NONE of them. The previous form was blind to every E-class error nvim
-- can emit (A-18 pattern hole) -- including the `E477` that lua/config/autocmds.lua's
-- bang forwarding exists to prevent. The runner itself never print()s, so nothing
-- inspected here is this check's own output.
--
-- BOUND -- what this CANNOT see, measured, so the name is not read wider than it is.
-- "messages clean" means exactly that: nvim's message log. This is NOT a config-load
-- assertion. A Lua error in a VeryLazy-sourced config file produces ZERO bytes here.
-- LazyVim loads `config.*` through `lazy.core.util.try`, which xpcall's and never
-- rethrows (lazy/core/util.lua:135), then defers the text with vim.schedule ->
-- M.error -> vim.notify (:127, :400, :375). nvim's own error path is never entered and
-- nothing lands in the log, so this check PASSES on a config file that failed to load --
-- reproduced by driving that exact path: log_bytes=0, marker=nil, 38 PASS / 0 FAIL, and
-- the settle poll below does not change it. Broken config files are the effect-probing
-- checks' job (Q/BD existence, keymap presence). A PASS here is not evidence the config
-- loaded.
local function messages_text()
	return vim.api.nvim_exec2("messages", { output = true }).output or ""
end

-- VeryLazy handlers hand work to vim.schedule, so the log can keep growing after
-- nvim_exec_autocmds returns. Poll until three consecutive samples agree rather than
-- sleeping a fixed interval: returns in ~150ms on a quiet log, and it is bounded.
local msg_len, msg_stable = -1, 0
vim.wait(2000, function()
	local n = #messages_text()
	if n == msg_len then
		msg_stable = msg_stable + 1
	else
		msg_len, msg_stable = n, 0
	end
	return msg_stable >= 3
end, 50)

local msgs = messages_text()
local msg_marker, msg_evidence = nil, ""
for line in msgs:gmatch("[^\r\n]+") do
	local m = line:match("E%d+:")
		or (line:find("deprecated", 1, true) and "deprecated")
		or (line:find("Error", 1, true) and "Error")
		or (line:find("stack traceback", 1, true) and "stack traceback")
	if m then
		msg_marker = m
		msg_evidence = " :: " .. line:sub(1, 160)
		break
	end
end
check("messages", "messages_clean_and_no_deprecations", 1, msg_marker == nil)
table.insert(
	results,
	string.format("INFO messages log_bytes=%d marker=%s%s", #msgs, tostring(msg_marker), msg_evidence)
)

-- Tag: quit
local cmds = vim.api.nvim_get_commands({})
-- Two legs, so the name is measured and not just declared. `bang == true` reads the
-- definition table; nvim_parse_cmd puts "Q!" through the SAME command-line parser that
-- raised the E477 this check is named for, and it raises "E477: No ! allowed" when the
-- bang is not permitted -- without executing anything, so the runner is never quit out
-- from under itself. The introspective leg is kept, not replaced: nothing is weakened.
local q_parse_ok = pcall(vim.api.nvim_parse_cmd, "Q!", {})
local q_bang_ok = (cmds.Q ~= nil and cmds.Q.bang == true) and q_parse_ok
check("quit", "no_e477_on_force_quit", 5, q_bang_ok)

-- Behavioral, never textual. The previous form was an absence-of-string test: it grepped
-- `cabbrev q` for the loose `getcmdline() == 'q'` and passed on its absence. Absence is
-- satisfied by every wrong state as well as the right one -- deleting the abbreviation
-- outright passes, and so does reintroducing the ORIGINAL defect by a different route
-- (`cnoreabbrev q Q`, unconditional, no getcmdline() anywhere), which is exactly the
-- `:g/pat/q` breakage the check is named for. Mutation-proven: `cnoreabbrev q Q` reported
-- PASS.
--
-- Asserted instead, by driving the real cmdline with no source text read anywhere -- two
-- OPPOSITE conditions, so no single state can satisfy both by accident:
--   (a) bare `:q` followed by a non-keyword char MUST expand to `Q` (the feature works);
--   (b) `:g/x/q` followed by the same char MUST NOT expand (the guard holds).
-- A cmdline abbreviation expands when a non-keyword char is typed after it, and
-- CmdlineChanged fires after each edit, so getcmdline() there observes the expansion.
-- `<C-c>` aborts, so nothing is ever executed.
local function cmdline_expansion(typed)
	local seen = {}
	local au = vim.api.nvim_create_autocmd("CmdlineChanged", {
		callback = function()
			seen[#seen + 1] = vim.fn.getcmdline()
		end,
	})
	pcall(vim.fn.feedkeys, typed, "xt")
	pcall(vim.fn.feedkeys, vim.api.nvim_replace_termcodes("<C-c>", true, false, true), "xt")
	pcall(vim.api.nvim_del_autocmd, au)
	return seen[#seen]
end

local abbrev_fires_bare = (cmdline_expansion(":q ") == "Q ")
-- Leg (b) has to be a position where THE GUARD is what stops the expansion. `:g/x/q `
-- is not such a position: Vim leaves it unexpanded with the guard, without the guard,
-- and with the original unconditional `cnoreabbrev q Q` defect alike -- it is a
-- CONSTANT, so `tight_guard` silently collapsed to leg (a) and the check could not
-- fail for the defect it is named after (A-20 / A-4 reopened).
--
-- `:Man q ` is the discriminating position, and it is the one
-- lua/config/autocmds.lua:140 names in its own comment. The abbreviation head sits at
-- cmdline position 5, so the guard's `getcmdpos() == #cmd + 1` is false and it must
-- return 'q'; under the unconditional defect the same keys yield `Man Q `. Two
-- OPPOSITE conditions across legs (a) and (b), and now genuinely so.
local abbrev_holds_at_offset = (cmdline_expansion(":Man q ") == "Man q ")
-- Kept as a third leg, not as the discriminator: the `:g/pat/q` corruption this check
-- was written for still gets an assertion, but its sensitivity comes from leg (b).
local abbrev_holds_in_g = (cmdline_expansion(":g/x/q ") == "g/x/q ")
local tight_guard = abbrev_fires_bare
	and abbrev_holds_at_offset
	and abbrev_holds_in_g
	and (cmds.Q ~= nil)
check("quit", "abbreviation_guard_positional", 5, tight_guard)
table.insert(
	results,
	string.format(
		"INFO quit abbreviation_guard legs: bare_q_expands=%s offset_q_unexpanded=%s g_command_unexpanded=%s Q_command=%s",
		tostring(abbrev_fires_bare),
		tostring(abbrev_holds_at_offset),
		tostring(abbrev_holds_in_g),
		tostring(cmds.Q ~= nil)
	)
)

-- `:BD` had ZERO gate coverage: the two checks above test `Q` only, so the E477 fix that
-- gave BD its bang was guarded by nothing and could regress unnoticed. BD is defined in
-- lua/config/keymaps.lua, which LazyVim loads on VeryLazy (fired above) -- not at
-- startup -- so `cmds` must be re-read here rather than reusing the capture from before.
local bd_cmds = vim.api.nvim_get_commands({})
local bd_cmd = bd_cmds.BD

-- Leg 1: the bang exists AND the command-line parser accepts it. Same pairing as `Q`
-- above, and the direct regression gate: dropping `bang = true` makes `:BD!` raise
-- "E477: No ! allowed", which is the defect this originally fixed.
local bd_parse_ok = pcall(vim.api.nvim_parse_cmd, "BD!", {})
check("quit", "bd_command_accepts_bang", 5, (bd_cmd ~= nil) and (bd_cmd.bang == true) and bd_parse_ok)

-- Drives the real `:BD`/`:BD!` against a genuinely modified buffer in its own split, so
-- the discard is observed rather than inferred. The split is what makes "keeps the
-- window" falsifiable: window identity and count are compared across the call, and a
-- delete that took the window with it shows up as an invalid win or a dropped count.
local function bd_probe(command, confirm_ret)
	local wins_before = #vim.api.nvim_list_wins()
	local ok_new = pcall(vim.cmd, "noautocmd new")
	if not ok_new then
		return { setup = false }
	end
	local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "unsaved change" })
	local r = { setup = vim.bo[buf].modified == true, asked = 0 }
	-- confirm() MUST be stubbed, not merely tolerated: headless with stdin at EOF it
	-- returns 1 == "&Yes", which sends Snacks.bufdelete into nvim_buf_call(buf, :write)
	-- on an unnamed buffer. Counting the calls is also the assertion for the no-bang
	-- leg -- "did it ASK before discarding" is the property, not "did it refuse".
	local real_confirm = vim.fn.confirm
	vim.fn.confirm = function()
		r.asked = r.asked + 1
		return confirm_ret
	end
	r.ok_cmd = pcall(vim.cmd, command)
	vim.fn.confirm = real_confirm
	-- `is_loaded`, NOT `is_valid`: `:bdelete!` unloads and unlists but does not wipe, so
	-- the handle stays VALID afterwards and an is_valid test can never observe the
	-- discard. Measured: buf_valid was still true on a confirmed successful `:BD!`.
	r.buf_loaded = vim.api.nvim_buf_is_loaded(buf)
	r.buf_valid = vim.api.nvim_buf_is_valid(buf)
	r.buf_listed = r.buf_valid and vim.bo[buf].buflisted or false
	r.buf_modified = r.buf_loaded and vim.bo[buf].modified or false
	r.win_valid = vim.api.nvim_win_is_valid(win)
	r.wins_after = #vim.api.nvim_list_wins()
	r.wins_kept = (r.wins_after == wins_before + 1)
	if r.win_valid and r.wins_after > wins_before then
		pcall(vim.api.nvim_win_close, win, true)
	end
	return r
end

-- 3 == "&Cancel", so a compliant `:BD` leaves the buffer exactly as it found it.
local bd_bang = bd_probe("BD!", 3)
local bd_plain = bd_probe("BD", 3)

local bd_bang_ok = (bd_bang.setup == true)
	and (bd_bang.ok_cmd == true)
	and (bd_bang.buf_loaded == false)
	and (bd_bang.buf_listed == false)
	and (bd_bang.win_valid == true)
	and (bd_bang.wins_kept == true)
	and (bd_bang.asked == 0)
check("quit", "bd_bang_discards_modified_buffer_keeps_window", 5, bd_bang_ok)

local bd_plain_ok = (bd_plain.setup == true)
	and (bd_plain.ok_cmd == true)
	and (bd_plain.asked == 1)
	and (bd_plain.buf_loaded == true)
	and (bd_plain.buf_modified == true)
check("quit", "bd_without_bang_does_not_discard_silently", 5, bd_plain_ok)

table.insert(
	results,
	string.format(
		"INFO quit BD legs: defined=%s bang=%s parse_bang_ok=%s || BD! setup=%s ok=%s unloaded=%s unlisted=%s win_alive=%s wins_kept=%s asked=%d || BD setup=%s ok=%s asked=%d loaded=%s still_modified=%s",
		tostring(bd_cmd ~= nil),
		tostring(bd_cmd and bd_cmd.bang),
		tostring(bd_parse_ok),
		tostring(bd_bang.setup),
		tostring(bd_bang.ok_cmd),
		tostring(bd_bang.buf_loaded == false),
		tostring(bd_bang.buf_listed == false),
		tostring(bd_bang.win_valid),
		tostring(bd_bang.wins_kept),
		bd_bang.asked or -1,
		tostring(bd_plain.setup),
		tostring(bd_plain.ok_cmd),
		bd_plain.asked or -1,
		tostring(bd_plain.buf_loaded),
		tostring(bd_plain.buf_modified)
	)
)

-- Tag: safequit
-- Behavioral, never textual. Both names previously shared ONE identical grep of
-- autocmds.lua for "get_installed_packages", so neither ever invoked safe_quit(),
-- get_busy_tasks() or vim.ui.select: commenting the whole feature out left both
-- PASSing, and two opposite names asserting one condition inflated the PASS count.
--
-- Both checks below drive the real `:Q` user command -- the only public entry point
-- to the file-local safe_quit() -- and distinguish its two branches by observing
-- which one actually ran. `vim.cmd` is swapped for a recorder so the quit is captured
-- instead of executed (a real `:q` would kill the verify run mid-flight), and the
-- busy/idle state is driven through mason-registry, the same source get_busy_tasks()
-- consults. Recording `get_all_packages` calls as well preserves the original grep's
-- intent -- that busy-detection reads the INSTALLED set, not the whole registry --
-- as a behavioral consequence rather than a string match.
local sq_prompt_ok, sq_quit_ok = false, false
if active_tags["safequit"] then
  local ok_mr, mason_registry = pcall(require, "mason-registry")
  -- get_busy_tasks() reaches for dap and lazy's checker. Force those loads BEFORE the
  -- vim.cmd recorder is installed, or a lazy on-demand load's own vim.cmd() calls land
  -- in the recording and are indistinguishable from a quit.
  pcall(require, "dap")
  local ok_ck, lazy_checker = pcall(require, "lazy.manage.checker")

  local quit_cmd_set = {
    ["q"] = true, ["qa"] = true, ["wq"] = true, ["wqa"] = true,
    ["q!"] = true, ["qa!"] = true, ["wq!"] = true, ["wqa!"] = true,
  }
  local real_cmd = vim.cmd
  local real_select = vim.ui.select
  local real_installed = ok_mr and mason_registry.get_installed_packages or nil
  local real_all = ok_mr and mason_registry.get_all_packages or nil
  local busy_pkg = { is_installing = function() return true end }

  -- Drive `:<name>` with mason reporting `installing`, and report what safe_quit did.
  local function drive_quit(name, installing)
    local installed_calls, all_calls, prompted, quits = 0, 0, false, {}
    if ok_mr then
      mason_registry.get_installed_packages = function()
        installed_calls = installed_calls + 1
        return installing and { busy_pkg } or {}
      end
      mason_registry.get_all_packages = function()
        all_calls = all_calls + 1
        return installing and { busy_pkg } or {}
      end
    end
    -- Pin the remaining busy sources quiet so only the mason lever is in play.
    local ck_was = ok_ck and lazy_checker.running or nil
    if ok_ck then lazy_checker.running = false end
    vim.ui.select = function(_, _, on_choice)
      prompted = true
      -- Answer "No": proves the prompt is honored and nothing quits behind it.
      if on_choice then on_choice("No") end
    end
    vim.cmd = function(c)
      if type(c) == "string" and quit_cmd_set[c] then
        table.insert(quits, c)
      end
    end
    local ok_drive = pcall(function() real_cmd(name) end)
    vim.cmd, vim.ui.select = real_cmd, real_select
    if ok_ck then lazy_checker.running = ck_was end
    if ok_mr then
      mason_registry.get_installed_packages = real_installed
      mason_registry.get_all_packages = real_all
    end
    return {
      ok = ok_drive, prompted = prompted, quits = quits,
      installed_calls = installed_calls, all_calls = all_calls,
    }
  end

  -- Installing -> must prompt, must NOT quit, and must have consulted the INSTALLED set.
  local busy = drive_quit("Q", true)
  sq_prompt_ok = (busy.ok and busy.prompted and #busy.quits == 0
    and busy.installed_calls > 0 and busy.all_calls == 0)

  -- Not installing -> must quit straight through with the exact command, no prompt.
  -- `:Q!` additionally proves the bang is forwarded (the E477 fix) rather than dropped.
  local idle = drive_quit("Q", false)
  local idle_bang = drive_quit("Q!", false)
  sq_quit_ok = (idle.ok and not idle.prompted and #idle.quits == 1 and idle.quits[1] == "q"
    and idle_bang.ok and not idle_bang.prompted and #idle_bang.quits == 1 and idle_bang.quits[1] == "q!")
end
check("safequit", "safequit_prompts_when_installing", 5, sq_prompt_ok)
check("safequit", "safequit_quits_when_not_installing", 5, sq_quit_ok)

-- Tag: explorer (keymaps)
local has_e = (vim.fn.maparg("<leader>e", "n") ~= "")
local has_E = (vim.fn.maparg("<leader>E", "n") ~= "")
local has_fe = (vim.fn.maparg("<leader>fe", "n") ~= "")
local exp_enabled = (exp_def and exp_def.name == "neo-tree" and neo_p and neo_p.enabled ~= false)
check("explorer", "keymaps_target_enabled_explorer", 6, (has_e and has_E and has_fe and exp_enabled))

-- Tag: keymaps
-- Real LSP buffer. A scratch buffer + synthetic `nvim_exec_autocmds("LspAttach", ...)`
-- attaches no client, so LazyVim's on-attach keys never apply and every buffer-local
-- assertion below passes vacuously. Attach a real server instead and poll for it.
local real_clients_on_buf = 0
if active_tags["keymaps"] then
  local tmp_lua = vim.fn.tempname() .. ".lua"
  local tf = io.open(tmp_lua, "w")
  if tf then
    tf:write("local M = {}\n\nfunction M.greet(name)\n  return \"hello \" .. name\nend\n\nreturn M\n")
    tf:close()
  end
  pcall(vim.cmd, "edit " .. vim.fn.fnameescape(tmp_lua))
  local lsp_buf = vim.api.nvim_get_current_buf()
  vim.wait(45000, function()
    return #vim.lsp.get_clients({ bufnr = lsp_buf }) > 0
  end, 100)
  real_clients_on_buf = #vim.lsp.get_clients({ bufnr = lsp_buf })
  -- LazyVim applies its LSP keys from an on-attach hook, so settle after the client lands
  vim.wait(2000, function()
    return false
  end, 100)
end

-- `gt` and `gi` must reach their BUILT-INs, which means nothing may map them in normal
-- mode in EITHER scope. The previous form was `maparg(k,"n",false,true).buffer ~= 1`,
-- which is true for three different states: unmapped (`buffer` nil), globally shadowed
-- (`buffer` 0), and buffer-local-on-another-buffer. Only a buffer-local shadow on the
-- current buffer could ever fail it, so re-adding the exact regression as a global
-- mapping -- the far likelier form, and how LazyVim itself would set one -- reported
-- PASS. Mutation-proven with `vim.keymap.set("n","gt"/"gi",...)`.
--
-- Asserted instead over both keymap scopes explicitly, mirroring the `<C-t>` check
-- below: the lhs must appear in neither the global table nor the current buffer's.
local function lhs_mapped_in(list, want)
	for _, m in ipairs(list) do
		if m.lhs == want then
			return true
		end
	end
	return false
end

local global_n_maps = vim.api.nvim_get_keymap("n")
local buflocal_n_maps = vim.api.nvim_buf_get_keymap(0, "n")
local function builtin_unshadowed(lhs)
	return not lhs_mapped_in(global_n_maps, lhs) and not lhs_mapped_in(buflocal_n_maps, lhs)
end

check("keymaps", "gt_builtin_restored", 9, builtin_unshadowed("gt"))
check("keymaps", "gi_builtin_restored", 9, builtin_unshadowed("gi"))

-- `<C-t>` must reach the BUILT-IN pop-tag-stack. The previous form inspected the
-- maparg() STRING, which for a Lua-callback mapping is only "<Lua NNN: <file>:<line>>"
-- and never the callback body -- so find("terminal") and find("Snacks") were dead
-- clauses that could not match the mapping form the original defect actually used.
-- The sole live clause was the literal "keymaps.lua:28", i.e. a hardcoded line number:
-- re-introducing the exact same regression one line down reported PASS.
--
-- Asserted instead, with no line number anywhere: (a) nothing maps <C-t> in normal mode,
-- global or buffer-local, and (b) the built-in actually pops -- a synthesized one-entry
-- tag stack, cursor moved away, `<C-t>` fed, then the cursor must land back on the
-- recorded `from` position with curidx decremented. A re-shadowed <C-t> fails both.
local ct_dict = vim.fn.maparg("<C-t>", "n", false, true)
local ct_unmapped = (type(ct_dict) ~= "table" or vim.tbl_isempty(ct_dict))
local ct_pops = false
if active_tags["keymaps"] then
  -- Every piece of window state touched here is restored below: later checks in this
  -- tag (notably gr_unshadowed_in_lsp_buf) read buffer-local maps off the LSP buffer.
  local prev_buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local prev_cursor = vim.api.nvim_win_get_cursor(win)
  local prev_stack = vim.fn.gettagstack(win)

  local tag_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(tag_buf, 0, -1, false, { "l1", "l2", "l3", "l4", "l5", "l6", "l7", "l8" })
  local ok_probe = pcall(function()
    vim.api.nvim_set_current_buf(tag_buf)
    local from_line = 2
    vim.api.nvim_win_set_cursor(win, { from_line, 0 })
    vim.fn.settagstack(win, {
      items = { { tagname = "verify_pop_probe", from = { tag_buf, from_line, 1, 0 } } },
      curidx = 2,
    }, "r")
    vim.api.nvim_win_set_cursor(win, { 7, 0 })
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "nx", false)
    local after = vim.fn.gettagstack(win)
    ct_pops = (vim.api.nvim_win_get_cursor(win)[1] == from_line and after.curidx == 1)
  end)
  if not ok_probe then
    ct_pops = false
  end

  -- Restore: buffer, cursor, tag stack; then drop the scratch buffer.
  pcall(vim.api.nvim_set_current_buf, prev_buf)
  pcall(vim.api.nvim_win_set_cursor, win, prev_cursor)
  pcall(vim.fn.settagstack, win, prev_stack, "r")
  pcall(vim.api.nvim_buf_delete, tag_buf, { force = true })
end
check("keymaps", "c_t_pop_tag_stack_restored", 10, (ct_unmapped and ct_pops))

local ck_mapped = (vim.fn.maparg("<leader>ck", "n") ~= "")
check("keymaps", "ck_signature_help_rebind", 9, ck_mapped)

local c_backslash_mapped = (vim.fn.maparg("<C-\\>", "n") ~= "")
check("keymaps", "c_backslash_terminal_rebind", 10, c_backslash_mapped)

local all_defaults = true
for _, k in ipairs({ "grn", "gra", "grr", "gri", "grt" }) do
  if vim.fn.maparg(k, "n") == "" then
    all_defaults = false
    break
  end
end
check("keymaps", "grn_gra_grr_gri_grt_mapped", 1, all_defaults)

local gr_empty_in_lsp_buf = (vim.fn.maparg("gr", "n") == "")
local gr_unshadowed = (real_clients_on_buf > 0 and gr_empty_in_lsp_buf)
check("keymaps", "gr_unshadowed_in_lsp_buf real_clients_on_buf=" .. real_clients_on_buf, 9, gr_unshadowed)

local xcode_keys_mapped = true
for _, suffix in ipairs({ "b", "r", "t", "T", "d", "p", "l", "c" }) do
  if vim.fn.maparg("<leader>X" .. suffix, "n") == "" then
    xcode_keys_mapped = false
    break
  end
end
check("keymaps", "xcode_leader_X_mapped", 11, xcode_keys_mapped)

-- Who actually OWNS <leader>xt / <leader>xT at runtime. The previous form grepped
-- swift.lua for the double-quoted literal '"<leader>xt"', so re-claiming the key with
-- single quotes -- or from any other file, or via any computed lhs -- still PASSed.
-- Reading the live mapping descriptions is quote-style- and file-agnostic: whoever wins
-- the key is whoever is reported here.
local function map_desc(lhs)
  local d = vim.fn.maparg(lhs, "n", false, true)
  if type(d) ~= "table" then
    return ""
  end
  return tostring(d.desc or "")
end
local xt_desc, xT_desc = map_desc("<leader>xt"), map_desc("<leader>xT")
local Xt_desc, XT_desc = map_desc("<leader>Xt"), map_desc("<leader>XT")
-- lowercase xt/xT must still be Todo (todo-comments via Trouble); uppercase Xt/XT are
-- Xcode's. Asserting both halves is what makes "uncontested" mean anything: it fails if
-- Xcode annexes the lowercase pair AND if the Xcode keys silently went missing.
local todo_owns_xt = (xt_desc:lower():find("todo") ~= nil and xT_desc:lower():find("todo") ~= nil)
local xcode_off_xt = (xt_desc:lower():find("xcode") == nil and xT_desc:lower():find("xcode") == nil)
local xcode_owns_Xt = (Xt_desc:lower():find("xcode") ~= nil and XT_desc:lower():find("xcode") ~= nil)
check("keymaps", "xt_xT_todo_comments_uncontested", 11, (todo_owns_xt and xcode_off_xt and xcode_owns_Xt))

local has_gd = (vim.fn.maparg("<leader>gd", "n") ~= "")
local has_gh = (vim.fn.maparg("<leader>gh", "n") ~= "")
local has_df = (vim.fn.maparg("<leader>df", "n") ~= "")
check("keymaps", "gd_gh_df_retention_mapped", 1, (has_gd and has_gh and has_df))

-- Tag: whichkey
-- Behavioral, never textual. The previous form grepped which-key.lua for '"<leader>X"'
-- and 'group = "xcode"', so commenting the whole group spec out still PASSed -- it never
-- established that which-key had actually ingested the spec, only that the file said so.
--
-- Asserted instead against which-key's own resolved state: the plugin's opts function is
-- run by lazy, which-key parses the spec into a per-buffer node tree, and each declared
-- group must resolve there with group == true and the label we declared. That covers the
-- whole pipeline (spec merge -> parse -> tree), any of which can break silently.
--
-- which-key defers its load() through vim.schedule_wrap, and in `nvim --headless -c` the
-- chunk runs with vim_did_enter == 0, so setup() parks load() on VimEnter -- an event that
-- would never arrive before this script ends.
--
-- Firing VimEnter globally is NOT safe here, and neither is invoking every VimEnter Lua
-- callback: doing either also runs project_nvim's command-string autocmd (`on_buf_enter()`)
-- and Neovim's own treesitter `_fold.lua` handler out of context, which injects an error
-- into the message log that the extras block later samples as its first error line.
-- So: invoke only vim.schedule_wrap'd callbacks (which-key's `_load` is one, identified by
-- its wrapper's source rather than by index), and stop the moment Config.loaded flips.
-- Poll for it, never sleep.
local wk_groups_ok = false
if active_tags["whichkey"] then
  local ok_wkcfg, wkcfg = pcall(require, "which-key.config")
  if ok_wkcfg and not wkcfg.loaded then
    for _, au in ipairs(vim.api.nvim_get_autocmds({ event = "VimEnter" })) do
      if wkcfg.loaded then
        break
      end
      if type(au.callback) == "function" and tostring(debug.getinfo(au.callback, "S").source):find("vim/_core/editor", 1, true) then
        pcall(au.callback, {
          id = au.id,
          event = "VimEnter",
          file = "",
          match = "",
          buf = vim.api.nvim_get_current_buf(),
        })
        vim.wait(5000, function()
          return wkcfg.loaded == true
        end, 50)
      end
    end
  end

  -- The 5 groups below are the ones which-key.lua declares that are unconditionally
  -- present in a plain buffer's tree. The other two it declares, <leader>cw (workspace)
  -- and <leader>j (java), are deliberately NOT asserted: cw fronts buffer-local LSP keys
  -- set by autocmds.lua's LspAttach, and j fronts filetype-specific java keys, so neither
  -- has a node outside those contexts. Asserting them here would assert something false,
  -- not something stricter -- they are excluded on those grounds, not to reach green.
  local expected_groups = {
    { "<leader>X", "xcode" },
    { "<leader>t", "trouble" },
    { "<leader>T", "test" },
    { "<leader>d", "debug" },
    { "<leader>c", "code" },
  }
  -- pcall the tree read: an unguarded throw here would abort the whole chunk and exit 2
  -- instead of reporting this one check as FAIL.
  local ok_tree = pcall(function()
    local wkbuf = require("which-key.buf")
    local wk_mode = wkbuf.get({ mode = "n", update = true })
    if not (ok_wkcfg and wkcfg.loaded and wk_mode and wk_mode.tree) then
      return
    end
    for _, pair in ipairs(expected_groups) do
      local node = wk_mode.tree:find(pair[1])
      local mapping = node and node.mapping
      if not (mapping and mapping.group == true and tostring(mapping.desc) == pair[2]) then
        return
      end
    end
    -- The xcode group must also actually front the eight Xcode keys, not sit empty:
    -- a label over nothing is not a coherent group.
    local xnode = wk_mode.tree:find("<leader>X")
    for _, suffix in ipairs({ "b", "r", "t", "T", "d", "p", "l", "c" }) do
      if not (xnode and xnode._children and xnode._children[suffix]) then
        return
      end
    end
    wk_groups_ok = true
  end)
  if not ok_tree then
    wk_groups_ok = false
  end
end
check("whichkey", "group_labels_coherent", 11, wk_groups_ok)

-- Tag: dap
local dap_keys_expected = {
  "db", "dB", "dc", "da", "dC", "dg", "di", "dj", "dk",
  "dl", "do", "dO", "dp", "dr", "ds", "dt", "dw", "du", "de"
}
local dap_keys_ok = true
for _, k in ipairs(dap_keys_expected) do
  if vim.fn.maparg("<leader>" .. k, "n") == "" then
    dap_keys_ok = false
    break
  end
end
check("dap", "leader_d_keymaps_mapped", 1, dap_keys_ok)
-- Behavioral, never textual. The previous form grepped dap.lua for "configurations.java",
-- so commenting the table.insert out still PASSed. The runtime alternative is trivial:
-- require("dap") loads the plugin on demand, its config runs, and configurations.java is
-- a live table -- so assert the table.
--
-- Both entries are asserted because this is a two-way non-clobber invariant. The LazyVim
-- java extra ASSIGNS dap.configurations.java (contributing "Debug (Attach) - Remote"),
-- which is exactly why dap.lua moved its insert from `opts` to `config`. Requiring OUR
-- launch entry proves the extra did not clobber us; requiring the extra's attach entry
-- proves we did not clobber it. Either direction failing is a real regression.
local java_dap_ok = false
if active_tags["dap"] then
  local ok_dap, dap_mod = pcall(require, "dap")
  local java_cfgs = ok_dap and dap_mod.configurations and dap_mod.configurations.java or nil
  if type(java_cfgs) == "table" then
    local has_launch_current_file, has_attach = false, false
    for _, cfg in ipairs(java_cfgs) do
      if cfg.type == "java" and cfg.request == "launch" and cfg.mainClass == "${file}" then
        has_launch_current_file = true
      end
      if cfg.type == "java" and cfg.request == "attach" then
        has_attach = true
      end
    end
    java_dap_ok = (has_launch_current_file and has_attach)
  end
end
check("dap", "java_dap_config_present", 1, java_dap_ok)

-- Tag: formatters
-- Behavioral, never textual. All three checks below interrogate conform itself --
-- `list_formatters_for_buffer()` plus `get_formatter_info(name, bufnr).available` --
-- because a grep of lua/plugins/formatting.lua passes with the formatter uninstalled,
-- with conform misconfigured, or with the fixture resolving to another filetype
-- entirely. The previous `per_fixture_formatters_resolve` was the extreme case: it
-- grepped lua/plugins/mason.lua for the string "prettier" and asserted nothing about
-- any fixture, any formatter list, or any executable.
--
-- Resolution is delegated to scripts/lib/probe_common.lua :: formatters(), the SAME
-- function that produces tests/baseline/formatters.json, so this gate and that
-- baseline can never disagree about how a per-fixture formatter list is computed.
if active_tags["formatters"] then
  -- draft:329 / plan:403 -- per-fixture formatter list -> EXACT expected list, all
  -- executables resolvable. Lists are sorted because probe_common.formatters() sorts
  -- the flattened result. An empty `want` is itself an assertion: adding a formatter
  -- for one of those filetypes has to surface here rather than pass silently.
  local FMT_FIXTURES = {
    { file = "fixture.c", ft = "c", want = {} },
    { file = "fixture.dart", ft = "dart", want = { "dart_format" } },
    { file = "Dockerfile", ft = "dockerfile", want = {} },
    { file = "COMMIT_EDITMSG", ft = "gitcommit", want = {} },
    { file = "fixture.go", ft = "go", want = { "gofmt", "goimports" } },
    { file = "helmfile.yaml", ft = "helm", want = {} },
    { file = "Fixture.java", ft = "java", want = { "palantir-java-format" } },
    { file = "fixture.json", ft = "json", want = { "prettier" } },
    { file = "fixture.kt", ft = "kotlin", want = { "ktlint" } },
    { file = "fixture.md", ft = "markdown", want = { "prettier" } },
    { file = "fixture.py", ft = "python", want = { "ruff_format", "ruff_organize_imports" } },
    { file = "fixture.rs", ft = "rust", want = { "rustfmt" } },
    { file = "fixture.sql", ft = "sql", want = { "sqlfluff" } },
    { file = "fixture.swift", ft = "swift", want = { "swiftformat" } },
    { file = "fixture.html", ft = "html", want = { "prettier" } },
    { file = "fixture.tf", ft = "terraform", want = { "terraform_fmt" } },
    { file = "fixture.tex", ft = "tex", want = {} },
    { file = "fixture.toml", ft = "toml", want = {} },
    { file = "fixture.ts", ft = "typescript", want = { "prettier" } },
    { file = "fixture.vue", ft = "vue", want = { "prettier" } },
    { file = "fixture.yaml", ft = "yaml", want = { "prettier" } },
    { file = "fixture.zig", ft = "zig", want = {} },
  }

  -- Pre-existing, out-of-scope unavailability: dart's binary is absent and sqlfluff
  -- wants a project root neither of which this branch introduced, so neither may force
  -- a red. Keyed by formatter, valued by the exact conform reason -- a formatter is
  -- skippable ONLY when it is unavailable for THE recorded reason, so this table can
  -- never widen into a blanket amnesty: any other message is still a FAIL, and an
  -- unavailability that later disappears simply starts counting as resolved.
  local FMT_PREEXISTING = {
    dart_format = "Command 'dart' not found",
    sqlfluff = "Root directory not found",
  }

  -- Backstop, mirroring MIN_ATTACHED in the extras block: a check whose every row is a
  -- skip is indistinguishable from a real pass. 13 fixtures resolve a non-empty,
  -- fully-available list today (12 in the baseline + swift), so this floor has one unit
  -- of slack and still collapses to 0 if conform stops loading.
  local MIN_RESOLVED = 12

  -- probe_common.lua is a plain dofile module. It only needs SNAPSHOT_LIB to locate its
  -- siblings and SNAPSHOT_OUT to *compute* (never create) an output path; nothing below
  -- calls C.write*, so no snapshot or baseline file is touched.
  local lib_dir = repo_root .. "/scripts/lib"
  vim.env.SNAPSHOT_LIB = lib_dir
  vim.env.SNAPSHOT_OUT = vim.env.SNAPSHOT_OUT or vim.fn.tempname()
  local resolve = nil
  local ok_lib, PC = pcall(dofile, lib_dir .. "/probe_common.lua")
  if ok_lib and type(PC) == "table" and type(PC.formatters) == "function" then
    resolve = PC.formatters
  end

  -- conform.nvim is lazy (cmd/keys/BufWritePre) and VeryLazy never fires headless on its
  -- own. Without an explicit load every fixture resolves to an empty list and the whole
  -- tag measures nothing -- the same blindness the diagnostics block hit with
  -- nvim-lspconfig. Poll for the load, never sleep a fixed amount.
  pcall(function()
    require("lazy").load({ plugins = { "conform.nvim" } })
    vim.wait(15000, function()
      local p = require("lazy.core.config").plugins["conform.nvim"]
      return p and p._ and p._.loaded
    end, 50)
  end)
  local conform_p = require("lazy.core.config").plugins["conform.nvim"]
  local conform_loaded = (conform_p and conform_p._ and conform_p._.loaded) and true or false

  local fmt_lines, fmt_fails, fmt_skips = {}, {}, {}
  local by_ft = {}
  local resolved_count = 0
  -- Fixtures are opened with a real `edit` so filetype detection, buffer name and cwd --
  -- and therefore root-dir dependent availability such as sqlfluff's -- behave exactly
  -- as they do in the snapshot probe. `noautocmd edit` would leave filetype empty and
  -- every list would resolve to {}.
  --
  -- `eventignore=FileType` is what keeps this tag hermetic. Filetype detection runs on
  -- BufRead and merely *sets* the option, so `vim.bo.filetype` is still correct, but the
  -- FileType autocmd that vim.lsp.enable() hangs server startup off never fires. Without
  -- this, opening fixture.swift starts sourcekit-lsp, which declares c/cpp/objc as well
  -- as swift; the still-running client is then reused by the extras tag's fixture.c and
  -- reports "Error in command line:", failing a check in a different tag. Conform
  -- resolution reads only filetype and its own config, so suppressing LSP costs nothing
  -- here and removes ~16 server spawns from the run.
  local prev_swapfile, prev_eventignore = vim.o.swapfile, vim.o.eventignore
  vim.o.swapfile = false
  vim.o.eventignore = "FileType"

  for _, spec in ipairs(FMT_FIXTURES) do
    local fpath = repo_root .. "/tests/fixtures/" .. spec.file
    local row = { ft = "?", got = {}, notes = {}, list_ok = false, avail_ok = false, skipped = false }
    if not vim.uv.fs_stat(fpath) then
      row.detail = "fixture missing on disk"
    else
      local ok_edit, edit_err = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(fpath))
      if not ok_edit then
        row.detail = "edit raised: " .. tostring(edit_err)
      else
        local buf = vim.api.nvim_get_current_buf()
        row.ft = vim.bo[buf].filetype
        local info = resolve and resolve(buf) or { error = "probe_common.formatters unavailable" }
        row.got = info.list_formatters_for_buffer or {}

        local ft_ok = (row.ft == spec.ft)
        local list_ok = ft_ok and (#row.got == #spec.want)
        if list_ok then
          for i = 1, #spec.want do
            if row.got[i] ~= spec.want[i] then
              list_ok = false
              break
            end
          end
        end
        row.list_ok = list_ok
        if info.error then
          row.detail = tostring(info.error)
        elseif not ft_ok then
          row.detail = "filetype " .. row.ft .. " != expected " .. spec.ft
        elseif not list_ok then
          row.detail = "list {" .. table.concat(row.got, ",") .. "} != expected {" .. table.concat(spec.want, ",") .. "}"
        end

        local avail_ok = true
        for _, name in ipairs(row.got) do
          local fi = (info.formatter_info or {})[name] or {}
          if fi.available == true then
            table.insert(row.notes, name .. "=true")
          else
            local msg = tostring(fi.available_msg or fi.error or "unknown")
            if FMT_PREEXISTING[name] and msg:find(FMT_PREEXISTING[name], 1, true) then
              row.skipped = true
              table.insert(row.notes, name .. '=false "' .. msg .. '" [pre-existing, out of scope]')
            else
              avail_ok = false
              table.insert(row.notes, name .. '=false "' .. msg .. '" [UNEXPECTED]')
            end
          end
        end
        row.avail_ok = avail_ok
        if list_ok and avail_ok and not row.skipped and #row.got > 0 then
          resolved_count = resolved_count + 1
        end
        pcall(vim.cmd, "bdelete!")
      end
    end

    local status
    if row.detail or not row.list_ok or not row.avail_ok then
      status = "FAILED "
      table.insert(fmt_fails, spec.file .. " [" .. tostring(row.detail or table.concat(row.notes, " ")) .. "]")
    elseif row.skipped then
      status = "skipped"
      table.insert(fmt_skips, spec.file .. " [" .. table.concat(row.notes, " ") .. "]")
    else
      status = "ok     "
    end
    table.insert(
      fmt_lines,
      string.format(
        "INFO formatters   %s %-16s ft=%-10s list={%s} available={%s}%s",
        status,
        spec.file,
        row.ft,
        table.concat(row.got, ","),
        table.concat(row.notes, " "),
        row.detail and (" :: " .. row.detail) or ""
      )
    )
    by_ft[spec.ft] = row
  end
  vim.o.swapfile = prev_swapfile
  vim.o.eventignore = prev_eventignore

  local resolve_ok = (resolve ~= nil) and conform_loaded and (#fmt_fails == 0)
  if resolved_count < MIN_RESOLVED then
    resolve_ok = false
    table.insert(
      fmt_fails,
      string.format("coverage floor: only %d fixtures fully resolved, need >= %d", resolved_count, MIN_RESOLVED)
    )
  end

  -- python resolves through conform to exactly {ruff_format, ruff_organize_imports},
  -- both available; the explicit black/isort membership test keeps the name literal.
  local py = by_ft["python"] or {}
  local py_ruff_ok = (py.list_ok == true)
    and (py.avail_ok == true)
    and (py.skipped ~= true)
    and not vim.tbl_contains(py.got or {}, "black")
    and not vim.tbl_contains(py.got or {}, "isort")
  check("formatters", "python_ruff_not_black_isort", 17, py_ruff_ok)

  -- swift resolves through conform to exactly {swiftformat} with available = true,
  -- via tests/fixtures/fixture.swift -- without that fixture swift formatting was
  -- unverifiable and this check could only ever have been a source grep.
  local sw = by_ft["swift"] or {}
  local swift_fmt_ok = (sw.list_ok == true) and (sw.avail_ok == true) and (sw.skipped ~= true)
  check("formatters", "swift_swiftformat", 17, swift_fmt_ok)

  check("formatters", "per_fixture_formatters_resolve", 17, resolve_ok)

  -- Coverage must be visible, or a check full of skips looks identical to a real pass.
  table.insert(
    results,
    string.format(
      "INFO formatters per_fixture_formatters_resolve conform_loaded=%s resolved=%d skipped=%d failed=%d of %d fixtures (floor >= %d)",
      tostring(conform_loaded),
      resolved_count,
      #fmt_skips,
      #fmt_fails,
      #FMT_FIXTURES,
      MIN_RESOLVED
    )
  )
  for _, l in ipairs(fmt_lines) do
    table.insert(results, l)
  end
end

-- Tag: diagnostics
-- Explicitly load nvim-lspconfig because lazy lspconfig owns opts.diagnostics.
-- LazyVim only applies opts.diagnostics when nvim-lspconfig loads; without this,
-- vim.diagnostic.config() returns core defaults when testing diagnostics in isolation.
if active_tags["diagnostics"] then
  pcall(function()
    require("lazy").load({ plugins = { "nvim-lspconfig" } })
    vim.wait(5000, function()
      local p = require("lazy.core.config").plugins["nvim-lspconfig"]
      return p and p._ and p._.loaded
    end)
  end)
end

local diag_cfg = vim.diagnostic.config() or {}
local diag_ok = (diag_cfg.virtual_text == false and type(diag_cfg.virtual_lines) == "table" and diag_cfg.virtual_lines.current_line == true)
check("diagnostics", "virtual_text_false_and_virtual_lines_current_line", 18, diag_ok)

local format_fn = type(diag_cfg.virtual_lines) == "table" and diag_cfg.virtual_lines.format
local format_shows_source = false
if type(format_fn) == "function" then
  local sample = { source = "TEST_SOURCE", code = "123", message = "msg" }
  local out = tostring(format_fn(sample))
  if out:find("TEST_SOURCE") then
    format_shows_source = true
  end
end
check("diagnostics", "virtual_lines_format_shows_source", 18, format_shows_source)

-- Tag: extras
if active_tags["extras"] then
  local expected_fixtures = {
    "fixture.c", "fixture.dart", "Dockerfile", "COMMIT_EDITMSG", "fixture.go",
    "helmfile.yaml", "Fixture.java", "fixture.json", "fixture.kt", "fixture.md",
    "fixture.py", "fixture.rs", "fixture.sql", "fixture.html", "fixture.tf",
    "fixture.tex", "fixture.toml", "fixture.ts", "fixture.vue", "fixture.yaml",
    "fixture.zig",
    -- swift is LAST on purpose, and it is here rather than absent on purpose.
    -- Here: this list is "every fixture on disk", not "every LazyVim lang extra"
    -- (swift is not one -- lua/plugins/swift.lua + the `sourcekit` entry at
    -- lua/plugins/lspconfig.lua:61 own it). Omitting it left sourcekit gated by
    -- nothing while the sibling FMT_FIXTURES above already treated swift as a
    -- first-class fixture -- the two lists disagreed.
    -- Last: sourcekit-lsp declares c/cpp/objc as well as swift, so a still-running
    -- sourcekit client gets reused by any LATER fixture whose filetype it claims,
    -- which is how it previously contaminated fixture.c. Nothing follows it here.
    "fixture.swift",
  }
  -- This check was intermittently FAILing (measured ~3 in 7 runs) and the cause was
  -- neither the config nor the fixtures. `swapfile` is left at its default here, so
  -- `edit` consults the swap directory, and any OTHER process holding a swapfile for
  -- the same fixture makes `edit` raise `E325: ATTENTION` -- which pcall reports as a
  -- failure and this check reports as a config defect. Proven both directions against a
  -- live holder: unguarded -> ok_edit=false, E325, buffer opened readonly; with the
  -- guard below -> ok_edit=true, no error. A swapfile whose owning process is DEAD is
  -- silently reaped by headless nvim and is harmless, which is why "stale swapfile" never
  -- reproduced -- only a LIVE owner does it.
  -- The live owner is routine, not exotic: scripts/snapshot.sh opens every one of these
  -- same fixtures and holds each one for its LSP settle window, so any overlapping
  -- snapshot and verify run collides. The formatters block above and the LSP-attach
  -- block below both already suppress swap for this exact reason; this loop was the
  -- only fixture loop that did not, which is why only this one flaked.
  local prev_swapfile_smoke = vim.o.swapfile
  vim.o.swapfile = false

  -- Per-fixture records, never a bare `break`. The previous form set one boolean and
  -- broke out, so a FAIL named no fixture and carried no error text -- which is why three
  -- separate investigations could not identify the trigger from the gate's own output.
  local smoke_fails, smoke_opened = {}, 0
  for _, fname in ipairs(expected_fixtures) do
    local fpath = repo_root .. "/tests/fixtures/" .. fname
    if not vim.uv.fs_stat(fpath) then
      table.insert(smoke_fails, fname .. " [fixture missing on disk]")
    else
      local ok_edit, edit_err = pcall(vim.cmd, "noautocmd edit " .. vim.fn.fnameescape(fpath))
      if not ok_edit then
        table.insert(smoke_fails, fname .. " [edit raised: " .. tostring(edit_err):gsub("%s+", " ") .. "]")
      else
        smoke_opened = smoke_opened + 1
      end
      local ok_del, del_err = pcall(vim.cmd, "noautocmd bdelete!")
      if not ok_del then
        -- A failed teardown is not cosmetic: the next iteration inherits this buffer as
        -- current, so silently dropping it converts one fault into a cascade.
        table.insert(smoke_fails, fname .. " [bdelete raised: " .. tostring(del_err):gsub("%s+", " ") .. "]")
      end
    end
  end
  vim.o.swapfile = prev_swapfile_smoke

  -- Floor, mirroring MIN_RESOLVED and MIN_ATTACHED: "zero failures" over zero opened
  -- fixtures is indistinguishable from a real pass, so the count has to be asserted too.
  local smoke_ok = (#smoke_fails == 0) and (smoke_opened == #expected_fixtures)
  check("extras", "language_fixtures_smoke_zero_errors", 1, smoke_ok)
  table.insert(
    results,
    string.format(
      "INFO extras language_fixtures_smoke coverage: opened=%d failed=%d of %d fixtures",
      smoke_opened,
      #smoke_fails,
      #expected_fixtures
    )
  )
  for _, l in ipairs(smoke_fails) do
    table.insert(results, "INFO extras   smoke FAILED " .. l)
  end

  -- fixture_lsp_attach_zero_errors (task 20) -- the missing half of the smoke check above.
  -- That sibling opens every fixture with `noautocmd edit`, which suppresses FileType and
  -- BufReadPost and therefore guarantees LSP can never attach. This check opens the same
  -- fixtures with autocmds ENABLED and asserts:
  --   1. `edit` raises no Lua error                                     (all 22 fixtures)
  --   2. no error-level message lands in the delta of a fixture that DID attach a client
  --   3. a fixture whose filetype has an installed server MUST attach, unless that
  --      server is observed erroring on startup (then it is a reported skip)
  --   4. at least MIN_ATTACHED fixtures attached, so the check can never pass vacuously
  --
  -- "Zero errors" deliberately does NOT mean "every fixture attaches a client". Several
  -- fixtures have no installed server (dart's binary is absent) or no server at all
  -- (gitcommit, sql), so demanding universal attach would fail for reasons unrelated to
  -- config correctness. Two rules keep the skip set honest rather than convenient:
  --   * Only a MISSING BINARY is treated as statically disqualifying. Absent project
  --     roots are NOT: nvim falls back to single-file mode and helm_ls attaches happily
  --     without a Chart.yaml. An empty init_options table (which vim.json encodes as the
  --     spec-violating `[]`) is NOT either: jdtls tolerates it and attaches.
  --   * Everything else is decided by OBSERVATION, never prediction. A server that had a
  --     usable binary yet produced no client is a FAIL when it failed silently, and a
  --     reported skip only when it visibly errored -- with that error text carried into
  --     the report so the skip is auditable instead of invisible.
  -- Assertion 4 is the backstop: a systemic regression (lspconfig not loading, mason off
  -- PATH, a throwing on_attach) turns every fixture into a "skip", and only the floor
  -- catches that.
  --
  -- nvim-lspconfig owns the server definitions and mason.nvim owns their PATH entry, and
  -- both are lazy. Load them explicitly or every filetype looks server-less and this
  -- check silently measures nothing -- the same blindness the diagnostics block above hit.
  local MIN_ATTACHED = 12
  for _, pname in ipairs({ "mason.nvim", "nvim-lspconfig" }) do
    pcall(function()
      require("lazy").load({ plugins = { pname } })
      vim.wait(15000, function()
        local pl = require("lazy.core.config").plugins[pname]
        return pl and pl._ and pl._.loaded
      end, 50)
    end)
  end

  local fixture_dir = repo_root .. "/tests/fixtures"

  local server_names = {}
  do
    local lsp_plugin = require("lazy.core.config").plugins["nvim-lspconfig"]
    local ok_opts, lsp_opts = pcall(function()
      -- is_list MUST be false; `true` merges via ipairs and silently drops dict keys
      return require("lazy.core.plugin").values(lsp_plugin, "opts", false)
    end)
    if ok_opts and type(lsp_opts) == "table" and type(lsp_opts.servers) == "table" then
      for s_name, _ in pairs(lsp_opts.servers) do
        -- "*" is the wildcard config applied to every server; never classify or disable it
        if s_name ~= "*" then
          table.insert(server_names, s_name)
        end
      end
    end
    table.sort(server_names)
  end

  local function server_config(name)
    local ok_cfg, cfg = pcall(function()
      return vim.lsp.config[name]
    end)
    if ok_cfg and type(cfg) == "table" then
      return cfg
    end
    return nil
  end

  local ft_installed = {}
  local no_binary = {}
  for _, s_name in ipairs(server_names) do
    local cfg = server_config(s_name)
    if cfg then
      local why = nil
      local cmd = cfg.cmd
      if type(cmd) == "table" then
        if type(cmd[1]) ~= "string" or vim.fn.executable(cmd[1]) ~= 1 then
          why = "binary not on PATH (" .. tostring(cmd[1]) .. ")"
        end
      elseif type(cmd) ~= "function" then
        why = "no cmd"
      end
      if why then
        no_binary[s_name] = why
      else
        for _, ft in ipairs(cfg.filetypes or {}) do
          ft_installed[ft] = ft_installed[ft] or {}
          table.insert(ft_installed[ft], s_name)
        end
      end
    end
  end

  local disabled_servers = {}
  for s_name, why in pairs(no_binary) do
    -- suppress the spawn failure a missing binary would otherwise write into assertion 2
    if pcall(vim.lsp.enable, s_name, false) then
      table.insert(disabled_servers, s_name .. " (" .. why .. ")")
    end
  end
  table.sort(disabled_servers)

  local attach_ok = true
  local attached_report = {}
  local skipped_report = {}
  local failed_report = {}
  -- the smoke check above just opened these same paths; suppress swap so a stale
  -- swapfile cannot raise E325 and be misread as a config error
  local prev_swapfile = vim.o.swapfile
  vim.o.swapfile = false

  for _, fname in ipairs(expected_fixtures) do
    local fpath = fixture_dir .. "/" .. fname
    if not vim.uv.fs_stat(fpath) then
      attach_ok = false
      table.insert(failed_report, fname .. " [fixture missing on disk]")
    else
      local msgs_before = vim.fn.execute("messages")
      local ok_edit, edit_err = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(fpath))
      local buf = vim.api.nvim_get_current_buf()
      local ft = vim.bo[buf].filetype
      local cands = ft_installed[ft] or {}
      -- poll, never sleep a fixed amount: an installed server gets a real budget
      -- (jdtls is slow), an absent one costs a short bounded timeout instead of a hang
      local budget = (#cands > 0) and 15000 or 2000
      vim.wait(budget, function()
        return #vim.lsp.get_clients({ bufnr = buf }) > 0
      end, 50)
      local client_names = {}
      for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        table.insert(client_names, c.name)
      end
      -- settle so on-attach hooks and async server replies land inside THIS window
      vim.wait(300, function()
        return false
      end, 100)
      -- Delta, not absolute: :messages already holds output from earlier checks. This
      -- block never print()s, so nothing in `delta` is this runner's own output.
      local msgs_after = vim.fn.execute("messages")
      local delta = msgs_after
      if msgs_after:sub(1, #msgs_before) == msgs_before then
        delta = msgs_after:sub(#msgs_before + 1)
      end
      local marker, evidence = nil, ""
      for line in delta:gmatch("[^\r\n]+") do
        local m = line:match("E%d+:")
          or (line:find("Error", 1, true) and "Error")
          or (line:find("stack traceback", 1, true) and "stack traceback")
        if m then
          marker = m
          evidence = " :: " .. line:sub(1, 160)
          break
        end
      end
      if not ok_edit then
        attach_ok = false
        table.insert(failed_report, fname .. " [edit raised: " .. tostring(edit_err) .. "]")
      elseif #client_names > 0 and marker then
        attach_ok = false
        table.insert(
          failed_report,
          fname .. " [ft=" .. ft .. " attached " .. table.concat(client_names, ",") .. " but errored: " .. marker .. evidence .. "]"
        )
      elseif #client_names > 0 then
        table.insert(attached_report, fname .. " [ft=" .. ft .. " clients=" .. table.concat(client_names, ",") .. "]")
      elseif #cands > 0 and not marker then
        attach_ok = false
        table.insert(
          failed_report,
          fname .. " [ft=" .. ft .. " installed {" .. table.concat(cands, ",") .. "} attached nothing, and failed silently]"
        )
      elseif #cands > 0 then
        table.insert(
          skipped_report,
          fname .. " [ft=" .. ft .. " installed {" .. table.concat(cands, ",") .. "} errored on startup: " .. marker .. evidence .. "]"
        )
      else
        local why = {}
        for _, s_name in ipairs(server_names) do
          local cfg = server_config(s_name)
          if cfg and vim.tbl_contains(cfg.filetypes or {}, ft) then
            table.insert(why, s_name .. ": " .. tostring(no_binary[s_name]))
          end
        end
        if #why == 0 then
          why = { "no server declares ft=" .. ft }
        end
        table.insert(skipped_report, fname .. " [ft=" .. ft .. " " .. table.concat(why, "; ") .. "]")
      end
      pcall(vim.cmd, "bdelete!")
    end
  end
  vim.o.swapfile = prev_swapfile

  if #attached_report < MIN_ATTACHED then
    attach_ok = false
    table.insert(
      failed_report,
      string.format("coverage floor: only %d fixtures attached, need >= %d", #attached_report, MIN_ATTACHED)
    )
  end

  check("extras", "fixture_lsp_attach_zero_errors", 20, attach_ok)

  -- One plan criterion that had no gate at all (plan:1436), so nothing verified it either way.
  -- This is the POSITIVE direction -- the negative "unloaded at startup" half is covered above,
  -- and a lazy plugin that never loads when it should satisfies that half while being broken.
  -- Asserted here because the fixture sweep has already opened fixture.swift, and measured true
  -- before being written. Falsified by stripping swift.lua's `ft` trigger: this reports FAIL.
  --
  -- plan:1623's positive direction (nvim-treesitter-context loads on file open) was DELIBERATELY
  -- NOT added. A check was written and then removed: giving the plugin a bogus `ft` still left it
  -- loaded, so the mutation could not make the assertion fail. treesitter-context is pulled in
  -- with nvim-treesitter, so "exists but unloaded" is likely unreachable here and the check would
  -- have been tautological -- the same "cannot fail" class this harness exists to eliminate.
  local xcb_p = require("lazy.core.config").plugins["xcodebuild.nvim"]
  local xcb_loaded = xcb_p and xcb_p._ and xcb_p._.loaded ~= nil
  check("extras", "xcodebuild_loads_on_swift_with_commands", 12, (xcb_loaded and vim.fn.exists(":XcodebuildBuild") == 2))
  -- Coverage must be visible, or a check full of skips looks identical to a real pass.
  table.insert(
    results,
    string.format(
      "INFO extras fixture_lsp_attach coverage: attached=%d skipped=%d failed=%d of %d fixtures",
      #attached_report,
      #skipped_report,
      #failed_report,
      #expected_fixtures
    )
  )
  for _, l in ipairs(attached_report) do
    table.insert(results, "INFO extras   attached " .. l)
  end
  for _, l in ipairs(skipped_report) do
    table.insert(results, "INFO extras   skipped  " .. l)
  end
  for _, l in ipairs(failed_report) do
    table.insert(results, "INFO extras   FAILED   " .. l)
  end
  for _, l in ipairs(disabled_servers) do
    table.insert(results, "INFO extras   disabled " .. l)
  end
end

-- Tag: lockfile
local current_hash = ""
local lf = io.open(repo_root .. "/lazy-lock.json", "r")
if lf then
  current_hash = vim.fn.sha256(lf:read("*a"))
  lf:close()
end
local base_hash = ""
local bf = io.open(repo_root .. "/tests/baseline/lazy_lock.json", "r")
if bf then
  local bj = vim.json.decode(bf:read("*a"))
  base_hash = bj and bj.sha256 or ""
  bf:close()
end
check("lockfile", "lazy_lock_diff_valid", 1, (current_hash ~= "" and current_hash == base_hash))

-- Write clean output lines to out_path
local of = io.open(out_path, "w")
if of then
  for _, line in ipairs(results) do
    of:write(line .. "\n")
  end
  of:write(string.format("__SUMMARY__ pass=%d fail=%d pending=%d total=%d\n", pass_count, fail_count, pending_count, #results))
  of:close()
end

vim.cmd("qa!")
LUA_SCRIPT

# Run plain headless nvim with output captured to LOG_TMP
NVIM_RC=0
${RUN_TIMEOUT} nvim --headless -c "luafile ${LUA_TMP}" >"${LOG_TMP}" 2>&1 || NVIM_RC=$?

# Defect 2 fix: on non-zero exit, dump log to stderr and exit 2
if [[ ${NVIM_RC} -ne 0 ]]; then
  echo "error: nvim --headless failed with exit code ${NVIM_RC}" >&2
  cat "${LOG_TMP}" >&2
  exit 2
fi

# Defect 1 fix: hard self-guard verification
if [[ -n "${LAZYVIM_HASH_BEFORE}" && -f "${LAZYVIM_JSON}" ]]; then
  LAZYVIM_HASH_AFTER="$(shasum -a 256 "${LAZYVIM_JSON}" | awk '{print $1}')"
  if [[ "${LAZYVIM_HASH_BEFORE}" != "${LAZYVIM_HASH_AFTER}" ]]; then
    cp "${LAZYVIM_BAK}" "${LAZYVIM_JSON}"
    echo "FATAL: verify.sh mutated lazyvim.json! Restored original bytes." >&2
    exit 2
  fi
fi

# Defect 2 fix: if results file is missing or empty, dump log to stderr and exit 2
if [[ ! -s "${OUT_TMP}" ]]; then
  echo "error: verify runner failed to produce results" >&2
  cat "${LOG_TMP}" >&2
  exit 2
fi

# Read results from temporary file
FAIL_COUNT=0
PASS_COUNT=0
PENDING_COUNT=0
TOTAL_COUNT=0

while IFS= read -r line; do
  if [[ "${line}" =~ ^PASS[[:space:]] ]]; then
    ((PASS_COUNT++)) || true
    ((TOTAL_COUNT++)) || true
    echo "${line}"
  elif [[ "${line}" =~ ^FAIL[[:space:]] ]]; then
    ((FAIL_COUNT++)) || true
    ((TOTAL_COUNT++)) || true
    echo "${line}"
  elif [[ "${line}" =~ ^PENDING[[:space:]] ]]; then
    ((PENDING_COUNT++)) || true
    ((TOTAL_COUNT++)) || true
    echo "${line}"
  elif [[ "${line}" =~ ^INFO[[:space:]] ]]; then
    # Diagnostic context only: echoed for visibility, never counted as a check result
    echo "${line}"
  fi
done < "${OUT_TMP}"

if [[ ${REPORT_ONLY} -eq 1 ]]; then
  exit 0
fi

if [[ ${FAIL_COUNT} -gt 0 ]]; then
  exit 1
fi

exit 0
