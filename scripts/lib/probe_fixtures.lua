local C = dofile(vim.env.SNAPSHOT_LIB .. "/probe_common.lua")

local MANIFEST = vim.json.decode(vim.env.SNAPSHOT_MANIFEST)
local OPTION_FILETYPES = vim.json.decode(vim.env.SNAPSHOT_OPTION_FILETYPES)

local START_MS = tonumber(vim.env.SNAPSHOT_PRE_MS) or 3000
local WAIT_MS = tonumber(vim.env.SNAPSHOT_LSP_WAIT_MS) or 12000
local SETTLE_MS = tonumber(vim.env.SNAPSHOT_LSP_SETTLE_MS) or 2500
local POLL_MS = tonumber(vim.env.SNAPSHOT_LSP_POLL_MS) or 250

local keymaps, clients, formatters, caps_hash, options_local = {}, {}, {}, {}, {}
local contested = {}
local want_options = {}
for _, ft in ipairs(OPTION_FILETYPES) do
	want_options[ft] = true
end

local function capture(entry, bufnr)
	local ft = vim.bo[bufnr].filetype
	local names, caps = C.lsp_clients(bufnr)

	keymaps[entry.extra] = {
		filetype = ft,
		buffer_keymaps = C.keymaps_buffer(bufnr, contested),
	}
	clients[entry.extra] = { filetype = ft, clients = names, client_count = #names }
	formatters[entry.extra] = vim.tbl_extend("error", { filetype = ft }, C.formatters(bufnr))

	local hashes = {}
	for name, cap in pairs(caps) do
		hashes[name] = C.norm.hash(cap)
	end
	caps_hash[entry.extra] = { filetype = ft, server_capabilities_sha256 = hashes }

	if want_options[ft] then
		options_local[ft] = {
			source = "fixture:" .. entry.file,
			options = C.options_local(bufnr, vim.api.nvim_get_current_win()),
		}
	end
end

-- Waits until the attached-client set has been unchanged for SETTLE_MS (so slow
-- servers such as jdtls and rust-analyzer are not raced), or until WAIT_MS.
-- Without the settle window the LSP capture is timing-dependent and the whole
-- snapshot stops being idempotent.
local function wait_for_lsp(bufnr, done)
	local elapsed, last_count, stable = 0, -1, 0
	local function tick()
		local n = #vim.lsp.get_clients({ bufnr = bufnr })
		if n == last_count then
			stable = stable + POLL_MS
		else
			last_count, stable = n, 0
		end
		elapsed = elapsed + POLL_MS
		if elapsed >= WAIT_MS or (n > 0 and stable >= SETTLE_MS) then
			return done()
		end
		vim.defer_fn(tick, POLL_MS)
	end
	vim.defer_fn(tick, POLL_MS)
end

local function capture_scratch_filetypes(done)
	for ft, spec in pairs(want_options) do
		if spec and not options_local[ft] then
			local buf = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_set_current_buf(buf)
			vim.bo[buf].filetype = ft
			options_local[ft] = {
				source = "scratch-buffer:filetype=" .. ft,
				options = C.options_local(buf, vim.api.nvim_get_current_win()),
			}
		end
	end
	done()
end

local function write_all()
	C.write("keymaps_buflocal.json", { fixtures = keymaps, contested_keys = contested })
	C.write("lsp_clients.json", { fixtures = clients })
	C.write("formatters.json", { fixtures = formatters })
	C.write("options_buflocal.json", { filetypes = options_local })
	C.write_info("lsp_capabilities_hash.json", { fixtures = caps_hash })
	C.finish()
end

local function record_error(entry, message)
	keymaps[entry.extra] = { error = message }
	clients[entry.extra] = { error = message }
	formatters[entry.extra] = { error = message }
	caps_hash[entry.extra] = { error = message }
end

local function step(i)
	local entry = MANIFEST[i]
	if not entry then
		return capture_scratch_filetypes(write_all)
	end
	local ok = pcall(vim.cmd.edit, vim.fn.fnameescape(entry.path))
	if not ok then
		record_error(entry, "edit failed")
		return step(i + 1)
	end
	local bufnr = vim.api.nvim_get_current_buf()
	wait_for_lsp(bufnr, function()
		-- A throwing capture must be RECORDED, never dropped: discarding the pcall
		-- result made the fixture vanish from all four outputs with exit 0 and an
		-- empty log, so baseline generation silently produced a short baseline.
		local captured, err = pcall(capture, entry, bufnr)
		if not captured then
			record_error(entry, "capture failed: " .. tostring(err))
		end
		step(i + 1)
	end)
end

vim.defer_fn(function()
	vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
	vim.defer_fn(function()
		-- Must be read before any fixture loads a plugin and clears its keys handler.
		contested = C.contested_keys()
		step(1)
	end, 1000)
end, START_MS)
