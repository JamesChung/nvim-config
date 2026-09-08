local lib = vim.env.SNAPSHOT_LIB
local json = dofile(lib .. "/json.lua")
local norm = dofile(lib .. "/normalize.lua")
norm.set_json(json)
-- Pin path rules before any plugin (project.nvim) can chdir out from under us.
norm.init()

local M = { json = json, norm = norm }

M.out = vim.env.SNAPSHOT_OUT
M.info = M.out .. "/informational"

M.MODES = { "n", "i", "v", "x", "s", "o", "c", "t", "l" }

function M.write(rel, value)
	json.write(M.out .. "/" .. rel, norm.deep(value))
end

function M.write_info(rel, value)
	json.write(M.info .. "/" .. rel, norm.deep(value))
end

function M.write_text(path, text)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	local fh = assert(io.open(path, "w"))
	fh:write(norm.scrub(text))
	fh:close()
end

local function keymap_row(m)
	return {
		mode = m.mode,
		lhs = m.lhs,
		lhsraw = m.lhsraw,
		rhs = m.rhs,
		desc = m.desc,
		callback = m.callback ~= nil and "<function>" or nil,
		noremap = m.noremap,
		silent = m.silent,
		expr = m.expr,
		nowait = m.nowait,
		script = m.script,
		-- Not `m.buffer`: a raw buffer HANDLE. jdtls transiently creates+destroys a
		-- buffer while attaching to Fixture.java, advancing the per-process counter
		-- without changing the surviving set -- which renumbered 14 of 21 fixtures and
		-- produced the 5,086-line `keymaps_buflocal.json` churn that flipped
		-- `snapshot.sh --check` on an unchanged tree. `normalize.scrub()` cannot help:
		-- it rewrites strings only, so a bare number bypasses it. Widening
		-- SNAPSHOT_LSP_SETTLE_MS is NOT the fix -- that stabilises the attached-client
		-- set, not the handle counter (drift reproduced at a 4s wait). The owning
		-- buffer is already identified by the artifact's per-fixture key.
		buffer_local = (m.buffer or 0) ~= 0,
		replace_keycodes = m.replace_keycodes,
	}
end

-- `lhs` alone is not a unique key: <leader>x can exist in several modes with
-- different rhs, so rows are sorted by the full identity tuple. The encoded row is
-- the final tiebreak so the comparator is a total order even for rows that differ
-- only in a field not named here.
local function sort_keymaps(rows)
	for _, r in ipairs(rows) do
		r._key = r.mode .. "\0" .. r.lhs .. "\0" .. json.encode(r)
	end
	table.sort(rows, function(a, b)
		return a._key < b._key
	end)
	for _, r in ipairs(rows) do
		r._key = nil
	end
	return rows
end

-- Neovim mode strings that stand for several atomic modes. Two mappings on the
-- same lhs collide only if their expanded sets intersect.
local MODE_EXPAND = {
	[""] = { "n", "v", "o" },
	v = { "x", "s" },
	["!"] = { "i", "c" },
}

--- lhs values whose winning mapping is decided by hash-table iteration order.
---
--- lazy.nvim's `Handler.setup()` walks `pairs(Config.plugins)` and its keys handler
--- walks `pairs(values)`, so when two specs claim the same lhs in overlapping modes
--- the last writer wins in an order that varies per process. Those rows are
--- therefore excluded from the keymap arrays and reported here instead: the claim
--- set is derived from the resolved specs, so it IS stable.
function M.contested_keys()
	local claims = {}
	for name, plugin in pairs(require("lazy.core.config").plugins) do
		local handler = plugin._ and plugin._.handlers and plugin._.handlers.keys
		for _, k in pairs(handler or {}) do
			local mode = k.mode or "n"
			local lhs = vim.api.nvim_replace_termcodes(k.lhs, true, true, true)
			claims[lhs] = claims[lhs] or {}
			for _, atomic in ipairs(MODE_EXPAND[mode] or { mode }) do
				claims[lhs][atomic] = claims[lhs][atomic] or {}
				table.insert(claims[lhs][atomic], {
					plugin = name,
					label = string.format("%s (mode=%s, desc=%s)", name, mode, tostring(k.desc)),
				})
			end
		end
	end

	local out = {}
	for lhs, by_mode in pairs(claims) do
		local labels, contested = {}, false
		for _, list in pairs(by_mode) do
			if #list > 1 then
				contested = true
			end
			for _, c in ipairs(list) do
				labels[c.label] = true
			end
		end
		if contested then
			local sorted = vim.tbl_keys(labels)
			table.sort(sorted)
			out[lhs] = json.arr(sorted)
		end
	end
	return out
end

-- The number of rows nvim_get_keymap returns for a contested lhs is itself
-- volatile (a mode="v" winner yields 3 rows, mode="x"+"s" winners yield 4), so the
-- dropped rows are counted nowhere -- `contested_keys` is the stable record.
local function drop_contested(rows, contested)
	local kept = {}
	for _, r in ipairs(rows) do
		if not contested[r.lhs] then
			kept[#kept + 1] = r
		end
	end
	return json.arr(kept)
end

function M.keymaps_global(contested)
	local rows = {}
	for _, mode in ipairs(M.MODES) do
		for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
			rows[#rows + 1] = keymap_row(m)
		end
	end
	return drop_contested(sort_keymaps(rows), contested)
end

function M.keymaps_buffer(bufnr, contested)
	local rows = {}
	for _, mode in ipairs(M.MODES) do
		for _, m in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
			rows[#rows + 1] = keymap_row(m)
		end
	end
	return drop_contested(sort_keymaps(rows), contested)
end

-- Terminal geometry comes from the host TTY; statusline/tabline/winbar hold
-- lualine's *rendered* text, which embeds a wall clock and live diagnostic counts.
-- Neither is config signal and both destroy byte-stability.
local OPTION_DENYLIST = {
	columns = true,
	lines = true,
	statusline = true,
	tabline = true,
	winbar = true,
}

-- `flaglist` ('shortmess') and `commalist` ('runtimepath') options are stored in
-- insertion order, and both plugin load order and flag-append order vary between
-- runs. Canonicalizing to a sorted form keeps additions/removals visible while
-- making the ordering itself non-signal.
local function canonical(meta, v)
	if type(v) ~= "string" then
		return v
	end
	if meta.flaglist then
		local chars = {}
		for c in v:gmatch(".") do
			chars[#chars + 1] = c
		end
		table.sort(chars)
		return table.concat(chars)
	end
	if meta.commalist then
		local items = vim.split(v, ",", { trimempty = true })
		table.sort(items)
		return json.arr(items)
	end
	return v
end

function M.options_global()
	local out = {}
	for name, meta in pairs(vim.api.nvim_get_all_options_info()) do
		if not OPTION_DENYLIST[name] then
			local ok, v = pcall(vim.api.nvim_get_option_value, name, { scope = "global" })
			if ok then
				out[name] = { scope = meta.scope, value = canonical(meta, v) }
			end
		end
	end
	return out
end

function M.options_local(bufnr, winid)
	local out = {}
	for name, meta in pairs(vim.api.nvim_get_all_options_info()) do
		if not OPTION_DENYLIST[name] and (meta.scope == "buf" or meta.scope == "win") then
			local opts = meta.scope == "buf" and { buf = bufnr } or { win = winid }
			local ok, v = pcall(vim.api.nvim_get_option_value, name, opts)
			if ok then
				out[name] = { scope = meta.scope, value = canonical(meta, v) }
			end
		end
	end
	return out
end

function M.loaded_plugins()
	local names = {}
	for name, p in pairs(require("lazy.core.config").plugins) do
		if p._ and p._.loaded then
			names[#names + 1] = name
		end
	end
	table.sort(names)
	return json.arr(names)
end

function M.lsp_clients(bufnr)
	local names, caps = {}, {}
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		names[#names + 1] = c.name
		caps[c.name] = c.server_capabilities or {}
	end
	table.sort(names)
	return json.arr(names), caps
end

function M.formatters(bufnr)
	local ok, conform = pcall(require, "conform")
	if not ok then
		return { error = "conform not available" }
	end
	local listed = conform.list_formatters_for_buffer(bufnr)
	local flat, entries = {}, {}
	local function collect(v)
		if type(v) == "table" then
			for _, x in ipairs(v) do
				collect(x)
			end
		elseif type(v) == "string" then
			flat[#flat + 1] = v
		end
	end
	collect(listed)
	for _, name in ipairs(flat) do
		local iok, i = pcall(conform.get_formatter_info, name, bufnr)
		entries[name] = iok
				and {
					available = i.available,
					available_msg = i.available_msg,
					command = i.command,
				}
			or { error = "get_formatter_info failed" }
	end
	table.sort(flat)
	return {
		list_formatters_for_buffer = json.arr(flat),
		formatter_info = entries,
		autoformat_enabled = vim.g.autoformat,
	}
end

local fatal = {}

--- Record an unrecoverable capture defect.
---
--- The probe still writes every artifact, so the failure is inspectable, but
--- `M.finish()` then exits NON-ZERO -- which makes `snapshot.sh`'s `run_probe`
--- abort. A capture that could not read what it claims to read must never exit 0:
--- a missing gating baseline is recoverable, a silently wrong one is not.
function M.fail(message)
	fatal[#fatal + 1] = tostring(message)
	io.stderr:write("probe: FATAL: " .. tostring(message) .. "\n")
end

function M.finish()
	vim.schedule(function()
		if #fatal > 0 then
			io.stderr:write(string.format("probe: aborting with %d fatal capture defect(s)\n", #fatal))
			vim.cmd("cquit 1")
		else
			vim.cmd("qa!")
		end
	end)
end

return M
