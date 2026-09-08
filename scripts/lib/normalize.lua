-- Path / volatility normalization for the baseline snapshot harness.
--
-- Every string that lands in a snapshot passes through `N.scrub()` so the
-- output is byte-stable across machines, runs, and PIDs. Replacement order is
-- longest-prefix-first: `$NVIM_DATA` must win over `$HOME`.

local N = {}

local function realpath(p)
	if not p or p == "" then
		return nil
	end
	local r = vim.uv.fs_realpath(p)
	return r or p
end

-- Built once per nvim instance; stdpath() and getcwd() never change mid-run.
local function build_rules()
	local rules = {}
	local function add(value, placeholder)
		if value and value ~= "" and value ~= "/" then
			rules[#rules + 1] = { value = value, placeholder = placeholder }
			local rp = realpath(value)
			if rp and rp ~= value then
				rules[#rules + 1] = { value = rp, placeholder = placeholder }
			end
		end
	end

	add(vim.fn.stdpath("data") .. "/lazy", "$LAZY_ROOT")
	add(vim.fn.stdpath("data") .. "/mason", "$MASON_ROOT")
	add(vim.fn.stdpath("config"), "$NVIM_CONFIG")
	add(vim.fn.stdpath("data"), "$NVIM_DATA")
	add(vim.fn.stdpath("state"), "$NVIM_STATE")
	add(vim.fn.stdpath("cache"), "$NVIM_CACHE")
	add(vim.fn.stdpath("run"), "$NVIM_RUN")
	add(vim.fn.stdpath("log"), "$NVIM_LOG")
	add(vim.env.VIMRUNTIME, "$VIMRUNTIME")
	add(vim.fn.fnamemodify(vim.env.VIMRUNTIME or "", ":h:h"), "$NVIM_PREFIX")
	add(os.getenv("TMPDIR") and os.getenv("TMPDIR"):gsub("/$", "") or nil, "$TMPDIR")
	add(vim.fn.getcwd(), "$CWD")
	add(os.getenv("HOME"), "$HOME")

	-- Longest literal first so nested prefixes normalize correctly. Duplicate
	-- literals are dropped (stdpath("config") == getcwd() here) and `idx` keeps the
	-- comparator total, which byte-stability depends on.
	local seen, uniq = {}, {}
	for i, r in ipairs(rules) do
		if not seen[r.value] then
			seen[r.value] = true
			r.idx = i
			uniq[#uniq + 1] = r
		end
	end
	table.sort(uniq, function(a, b)
		if #a.value ~= #b.value then
			return #a.value > #b.value
		end
		return a.idx < b.idx
	end)
	return uniq
end

local rules = nil

function N.init()
	rules = rules or build_rules()
end

--- Normalize a single string: paths -> placeholders, PID-bearing substrings -> `<pid>`.
---
--- STRINGS ONLY, by design -- non-strings are returned untouched. A bare number is
--- indistinguishable from a meaningful count once it reaches here, so a raw numeric
--- buffer/window/PID handle is NEVER scrubbed. Volatile numbers must be dropped or
--- reduced at the CAPTURE site instead (see `probe_common.keymap_row`'s
--- `buffer_local`). The previous wording promised "PIDs/handles -> <n>"
--- unconditionally; that false promise is what let a raw buffer handle reach the
--- gating `keymaps_buflocal.json` and flip `snapshot.sh --check` on a clean tree.
function N.scrub(s)
	if type(s) ~= "string" then
		return s
	end
	rules = rules or build_rules()
	for _, r in ipairs(rules) do
		-- Plain (non-pattern) substring replacement.
		local at = 1
		while true do
			local i, j = string.find(s, r.value, at, true)
			if not i then
				break
			end
			s = s:sub(1, i - 1) .. r.placeholder .. s:sub(j + 1)
			at = i + #r.placeholder
		end
	end
	-- Residual volatility that survives path normalization.
	s = s:gsub("%$NVIM_RUN[%w%._%-/]*", "$NVIM_RUN/<volatile>")
	s = s:gsub("%$TMPDIR[%w%._%-/]*", "$TMPDIR/<volatile>")
	s = s:gsub("nvim%.%d+%.%d+", "nvim.<pid>.<n>")
	s = s:gsub("(/nvim%.)%d+", "%1<pid>")
	return s
end

--- Recursively scrub every string key and value in `v`.
function N.deep(v)
	local ty = type(v)
	if ty == "string" then
		return N.scrub(v)
	elseif ty ~= "table" then
		return v
	end
	local out = {}
	if getmetatable(v) ~= nil then
		setmetatable(out, getmetatable(v))
	end
	for k, val in pairs(v) do
		out[type(k) == "string" and N.scrub(k) or k] = N.deep(val)
	end
	return out
end

-- Explicit injection, not `require`: `scripts/` is deliberately off the runtimepath.
function N.set_json(json)
	N._json = json
end

--- Stable SHA-256 of a canonical JSON rendering of `v`.
function N.hash(v)
	return vim.fn.sha256(N._json.encode(N.deep(v)))
end

return N
