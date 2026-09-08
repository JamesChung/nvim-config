-- Canonical JSON encoder for the baseline snapshot harness.
--
-- Why not `vim.json.encode`? Two reasons:
--   1. Object key order is unspecified, so output is not byte-stable.
--   2. An empty Lua table is indistinguishable from an empty array, so
--      `vim.json.encode({})` yields `{}` where downstream `jq '.[]'` needs `[]`.
--
-- This module produces deterministic output: object keys are sorted
-- lexicographically, indentation is two spaces, and arrays are explicitly
-- tagged via `J.arr()`.
--
-- Untagged tables are classified by their key set, NOT by "does [1] exist".
-- Only a table whose keys are exactly 1..n encodes as an array; a table that
-- mixes positional and string keys (which is what merged lazy.nvim `opts`
-- fragments routinely look like -- `{ "gr", desc = "..." }`) encodes as an
-- OBJECT so both halves survive. The earlier `t[1] ~= nil` test silently
-- discarded every string key, which made `probe.sh optval` report "value
-- unchanged" after metadata had in fact been deleted.
--
-- OUTPUT IS PURE ASCII. Every byte >= 0x7F is escaped, because artifacts that
-- carry raw high bytes are not merely awkward -- they produce wrong answers.
-- `lhsraw` records Neovim's internal key encoding (`<80>kb` = `K_BS`, plus the
-- 0xFC/0xFD modifier sentinels), which is not valid UTF-8. When those bytes
-- reached the file:
--   * Python's `json.load` REJECTED keymaps_global.json / keymaps_buflocal.json
--     outright,
--   * `jq` silently replaced them (0x80 byte count 96 -> 3) so any jq-based
--     analysis of the artifact was quietly reading corrupted data, and
--   * a `sed` normalization over the artifacts aborted mid-stream with
--     `RE error: illegal byte sequence` and emitted TRUNCATED output. That
--     truncation reported 1231 hunks / 6 differing hashes ("the fix failed")
--     where the true figures were 3176 hunks / 6-of-6 identical. A correct fix
--     was one step from being reverted on the strength of a byte-safety
--     artifact bug.
-- So `esc()` is UTF-8 aware rather than byte-blind:
--   * a valid UTF-8 sequence is decoded and re-emitted as its real codepoint
--     (`\uXXXX`, or a surrogate pair above U+FFFF), so nerd-font glyphs and
--     `…`/`⋅`/`╱` round-trip through jq and Python byte-for-byte;
--   * a byte that is NOT part of a valid UTF-8 sequence is emitted as `\u00XX`
--     for its own value, so the original byte stays visible and recoverable
--     (Python: `s.encode('latin-1')`).
-- Known, deliberate ambiguity: raw byte 0x80 and the character U+0080 both
-- render `\u0080`. A genuine U+0080 arrives as the two bytes `C2 80`, so the
-- two are indistinguishable after escaping. The alternative -- PEP 383 lone
-- surrogates (`\udc80`) -- is bijective but jq rewrites lone surrogates to
-- U+FFFD on output, which would re-break the jq analysis this exists to fix.
-- Byte transparency for the reader wins; no live artifact contains U+0080.

local J = {}

local ARRAY = {}
J.ARRAY = ARRAY

--- Tag a table as a JSON array (even when empty).
function J.arr(t)
	return setmetatable(t or {}, ARRAY)
end

function J.is_arr(t)
	return getmetatable(t) == ARRAY
end

--- Tag a table as a JSON object (even when empty).
function J.obj(t)
	return t or {}
end

local ESCAPES = {
	[0x22] = '\\"',
	[0x5C] = "\\\\",
	[0x08] = "\\b",
	[0x0C] = "\\f",
	[0x0A] = "\\n",
	[0x0D] = "\\r",
	[0x09] = "\\t",
}

-- Anything in this class forces the slow, byte-walking path: C0 controls, the
-- two structural characters, DEL, and every high byte.
local NEEDS_ESC = '[%c"\\\127-\255]'

--- Decode one UTF-8 sequence starting at byte `i`.
--- Returns `codepoint, length`, or nil when `i` does not begin a well-formed
--- sequence. Overlong forms, UTF-16 surrogates encoded as UTF-8 (CESU-8) and
--- anything above U+10FFFF are all rejected, so the emitted escapes can never
--- contain a lone surrogate.
local function utf8_decode(s, i)
	local c = s:byte(i)
	local want, cp, floor
	if c >= 0xC2 and c <= 0xDF then
		want, cp, floor = 2, c - 0xC0, 0x80
	elseif c >= 0xE0 and c <= 0xEF then
		want, cp, floor = 3, c - 0xE0, 0x800
	elseif c >= 0xF0 and c <= 0xF4 then
		want, cp, floor = 4, c - 0xF0, 0x10000
	else
		return nil
	end
	if i + want - 1 > #s then
		return nil
	end
	for k = 1, want - 1 do
		local cont = s:byte(i + k)
		if cont < 0x80 or cont > 0xBF then
			return nil
		end
		cp = cp * 64 + (cont - 0x80)
	end
	if cp < floor or cp > 0x10FFFF or (cp >= 0xD800 and cp <= 0xDFFF) then
		return nil
	end
	return cp, want
end

--- Render one codepoint as `\uXXXX`, or as a surrogate pair above U+FFFF.
local function u_escape(cp)
	if cp <= 0xFFFF then
		return string.format("\\u%04x", cp)
	end
	local rest = cp - 0x10000
	return string.format("\\u%04x\\u%04x", 0xD800 + math.floor(rest / 0x400), 0xDC00 + (rest % 0x400))
end

local function esc(s)
	if not s:find(NEEDS_ESC) then
		return '"' .. s .. '"'
	end
	local parts, n = {}, 0
	local i, len = 1, #s
	while i <= len do
		local b = s:byte(i)
		local piece, step
		if b < 0x80 then
			piece, step = ESCAPES[b], 1
			if not piece then
				piece = (b < 0x20 or b == 0x7F) and u_escape(b) or s:sub(i, i)
			end
		else
			local cp, want = utf8_decode(s, i)
			if cp then
				piece, step = u_escape(cp), want
			else
				-- Not valid UTF-8: keep the byte's own value visible.
				piece, step = u_escape(b), 1
			end
		end
		n = n + 1
		parts[n] = piece
		i = i + step
	end
	return '"' .. table.concat(parts) .. '"'
end

-- LuaJIT (5.1) has no `math.type`, so integrality is tested by value.
-- The bound is inclusive: 2^53 itself is exactly representable, so it must
-- format as 9007199254740992 and not as the lossy `9.007199254741e+15`.
local function num(n)
	if n ~= n then
		return '"NaN"'
	end
	if n == math.huge or n == -math.huge then
		return n > 0 and '"Infinity"' or '"-Infinity"'
	end
	if n == math.floor(n) and math.abs(n) <= 2 ^ 53 then
		return string.format("%d", n)
	end
	return string.format("%.14g", n)
end

-- Rank keys by type so that two keys rendering to the same name still have a
-- total order. Numbers sort first, preserving the pre-existing tiebreak in
-- which `t[1]` precedes `t["1"]`.
local KEY_RANK = { number = 1, string = 2, boolean = 3 }

--- Deterministic name for any Lua key.
--- `tostring` is deliberately avoided for tables/functions/userdata/threads: it
--- embeds the address, which differs between processes and would make the
--- output non-byte-deterministic -- the one property every baseline depends on.
local function key_name(k)
	local ty = type(k)
	if ty == "string" then
		return k
	elseif ty == "number" then
		-- num() quotes its non-finite forms; a key name carries no quotes.
		return (num(k):gsub('^"(.*)"$', "%1"))
	elseif ty == "boolean" then
		return k and "true" or "false"
	end
	return "<" .. ty .. ">"
end

local encode_value

local function encode_array(t, indent, pad, seen)
	if #t == 0 then
		return "[]"
	end
	local inner = pad .. indent
	local parts = {}
	for i = 1, #t do
		parts[i] = inner .. encode_value(t[i], indent, inner, seen)
	end
	return "[\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "]"
end

local function encode_object(t, indent, pad, seen)
	local inner = pad .. indent
	local entries, taken = {}, {}
	for k, v in pairs(t) do
		local name = key_name(k)
		taken[name] = true
		-- Encoding here (before the sort) is safe: a value's rendering never
		-- depends on its position, and having `enc` up front gives the sort a
		-- final tiebreak for keys that no name can distinguish.
		entries[#entries + 1] = {
			name = name,
			rank = KEY_RANK[type(k)] or 4,
			enc = encode_value(v, indent, inner, seen),
		}
	end
	if #entries == 0 then
		return "{}"
	end
	-- Sorted by rendered key for byte-stability; `pairs()` order is neutralised.
	-- The rank tiebreak keeps the order total in the one case where two distinct
	-- Lua keys render identically (`t[1]` and `t["1"]`); the `enc` tiebreak
	-- covers keys that share both name and type (two table keys, say). When name,
	-- rank and enc are all equal the two entries are indistinguishable in the
	-- output, so either order yields identical bytes.
	table.sort(entries, function(a, b)
		if a.name ~= b.name then
			return a.name < b.name
		end
		if a.rank ~= b.rank then
			return a.rank < b.rank
		end
		return a.enc < b.enc
	end)
	-- De-collide names. Sorting alone made the ORDER total but still emitted
	-- `"1"` twice for `t[1]` + `t["1"]`; jq keeps the last, so one value was
	-- silently lost -- the same "a value just vanishes" class as the mixed-table
	-- bug above. The first (lowest-sorting) entry keeps the plain name and later
	-- ones take a `#2`, `#3`, ... suffix, skipping any name a real key already
	-- occupies so a suffix can never shadow another field.
	local used, renamed = {}, false
	for _, e in ipairs(entries) do
		if used[e.name] then
			local base, j = e.name, 2
			local cand = base .. "#" .. j
			while used[cand] or taken[cand] do
				j = j + 1
				cand = base .. "#" .. j
			end
			e.name = cand
			renamed = true
		end
		used[e.name] = true
	end
	-- Renaming can push an entry out of lexicographic position (`1#3` was chosen
	-- while `1#2` belonged to a real key sorting after it), so re-sort on the
	-- final names. They are unique by construction, so name alone is a total
	-- order and "object keys are sorted lexicographically" still holds.
	if renamed then
		table.sort(entries, function(a, b)
			return a.name < b.name
		end)
	end
	local parts = {}
	for i, e in ipairs(entries) do
		parts[i] = inner .. esc(e.name) .. ": " .. e.enc
	end
	return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
end

--- True only when `t`'s keys are exactly the integers 1..n (n > 0).
local function is_pure_array(t)
	local n = 0
	for k in pairs(t) do
		if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
			return false
		end
		n = n + 1
	end
	if n == 0 then
		return false
	end
	for i = 1, n do
		if t[i] == nil then
			return false
		end
	end
	return true
end

encode_value = function(v, indent, pad, seen)
	local ty = type(v)
	if v == nil or v == vim.NIL then
		return "null"
	elseif ty == "boolean" then
		return v and "true" or "false"
	elseif ty == "number" then
		return num(v)
	elseif ty == "string" then
		return esc(v)
	elseif ty == "table" then
		-- Cycle guard. `seen` tracks the tables on the CURRENT path and is
		-- cleared on the way out, so a table reached twice through different
		-- branches still encodes in full -- only a genuine loop degrades. Without
		-- this a self-referential table overflowed the stack and killed the whole
		-- snapshot pass, contradicting the "a surprise value never aborts a pass"
		-- intent below.
		if seen[v] then
			return esc("<cycle>")
		end
		seen[v] = true
		local out
		-- An explicit `J.arr()` tag wins for positional content, so a tagged
		-- empty table still renders as `[]` and every baseline array keeps its
		-- committed shape. But the tag must not become a way to LOSE data: a
		-- tagged table carrying extra non-positional keys used to encode as
		-- `["a","b"]`, dropping `desc` -- exactly the mixed-table bug the untagged
		-- path was fixed for. Such a table falls back to an object so both halves
		-- survive. Unreachable today (all call sites pass pure arrays); this keeps
		-- it that way for the next author.
		if J.is_arr(v) and (next(v) == nil or is_pure_array(v)) then
			out = encode_array(v, indent, pad, seen)
		elseif is_pure_array(v) then
			out = encode_array(v, indent, pad, seen)
		else
			out = encode_object(v, indent, pad, seen)
		end
		seen[v] = nil
		return out
	end
	-- Functions, userdata, threads: record the type rather than failing, so a
	-- surprise value never aborts a whole snapshot pass.
	return esc("<" .. ty .. ">")
end

--- Encode `value` as canonical JSON with a trailing newline.
function J.encode(value)
	return encode_value(value, "  ", "", {}) .. "\n"
end

--- Write canonical JSON to `path`, creating parent directories as needed.
function J.write(path, value)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	local fh = assert(io.open(path, "w"))
	fh:write(J.encode(value))
	fh:close()
end

return J
