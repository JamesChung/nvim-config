local C = dofile(vim.env.SNAPSHOT_LIB .. "/probe_common.lua")

local PRE_MS = tonumber(vim.env.SNAPSHOT_PRE_MS) or 3000
local POST_MS = tonumber(vim.env.SNAPSHOT_POST_MS) or 3000

local function messages()
	local ok, res = pcall(vim.api.nvim_exec2, "messages", { output = true })
	if ok then
		return res.output or ""
	end
	local ok2, res2 = pcall(vim.fn.execute, "messages")
	return ok2 and res2 or "<capture failed>"
end

local function split(text)
	local lines = {}
	for line in tostring(text):gmatch("[^\n]+") do
		if line:match("%S") then
			lines[#lines + 1] = line
		end
	end
	return C.json.arr(lines)
end

local function mason_packages()
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return { error = "mason-registry not available" }
	end
	local names = {}
	for _, pkg in ipairs(registry.get_installed_packages()) do
		names[#names + 1] = pkg.name
	end
	table.sort(names)
	return { installed = C.json.arr(names), count = #names }
end

-- Force-load nvim-lspconfig before reading the diagnostic config. It owns
-- `opts.diagnostics`, it is LAZY, and `vim.diagnostic` is a CORE module -- so
-- requiring it never trips lazy.nvim's module loader. Without this the capture
-- records core defaults: 3 of 6 declared keys were wrong (severity_sort, signs,
-- virtual_lines) and deleting the entire declared block left this gating
-- baseline byte-identical.
--
-- Every failure arm below is LOUD (recorded error + non-zero exit via C.fail):
-- discarding `vim.wait`'s verdict is what let the previous revision regenerate
-- that same wrong baseline in silence -- exit 0, empty log, zero error markers.
--
-- The poll gates on `_.loaded.time`, NOT `_.loaded`: lazy.nvim sets `_.loaded = {}`
-- BEFORE calling `M.config(plugin)` and `_.loaded.time` only after it returns
-- (loader.lua:329 vs :361-365), so the previous comment's claim that this poll
-- "guarantees the plugin's config function has actually run" was false.
local LSPCONFIG = "nvim-lspconfig"

local function lspconfig_config_ran()
	local ok, cfg = pcall(require, "lazy.core.config")
	if not ok then
		return false
	end
	local p = cfg.plugins[LSPCONFIG]
	return p ~= nil and p._ ~= nil and p._.loaded ~= nil and p._.loaded.time ~= nil
end

local function diagnostic_config()
	local errors = {}
	-- Sampled before the forced load so the applied-value arm can distinguish
	-- "the plugin's opts reached vim.diagnostic" from "still on core defaults".
	local was_loaded = lspconfig_config_ran()
	local before = C.norm.hash(vim.diagnostic.config())

	local ok, err = pcall(function()
		require("lazy").load({ plugins = { LSPCONFIG } })
	end)
	if not ok then
		errors[#errors + 1] = string.format("lazy.load(%s) raised: %s", LSPCONFIG, tostring(err))
	end
	if not vim.wait(5000, lspconfig_config_ran, 50) then
		errors[#errors + 1] = LSPCONFIG .. " config() did not complete within 5000ms"
	end

	local cfg = vim.diagnostic.config()
	if #errors == 0 and not was_loaded and C.norm.hash(cfg) == before then
		errors[#errors + 1] = LSPCONFIG
			.. " reported loaded but vim.diagnostic.config() is unchanged from core"
			.. " defaults -- opts.diagnostics never reached vim.diagnostic"
	end

	if #errors == 0 then
		return { diagnostic_config = cfg }
	end

	local message = table.concat(errors, "; ")
	C.fail("diagnostics capture is UNTRUSTWORTHY: " .. message)
	-- Deliberately NOT written under `diagnostic_config`: anything reading that key
	-- would otherwise receive core defaults dressed up as a valid capture, which is
	-- the precise failure this arm exists to make impossible.
	return {
		error = message,
		capture_trustworthy = false,
		diagnostic_config_observed = cfg,
	}
end

vim.defer_fn(function()
	local msgs = split(messages())
	C.write("messages.json", { startup_messages = msgs, count = #msgs })

	local pre = C.loaded_plugins()

	vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })

	vim.defer_fn(function()
		local post = C.loaded_plugins()
		C.write("plugins.json", {
			plugins_eager_pre_verylazy = pre,
			plugins_eager_pre_verylazy_count = #pre,
			plugins_loaded_post_verylazy = post,
			plugins_loaded_post_verylazy_count = #post,
			plugins_total_in_spec = vim.tbl_count(require("lazy.core.config").plugins),
		})

		local contested = C.contested_keys()
		C.write("keymaps_global.json", {
			note = "captured after VeryLazy was fired manually (it never fires headless)",
			modes = C.json.arr(C.MODES),
			keymaps = C.keymaps_global(contested),
			contested_keys = contested,
		})

		C.write("options_global.json", { options = C.options_global() })
		C.write("diagnostics.json", diagnostic_config())
		C.write("mason_packages.json", mason_packages())

		C.finish()
	end, POST_MS)
end, PRE_MS)
