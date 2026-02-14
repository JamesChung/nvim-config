-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Use LspAttach autocommand to set up custom LSP keybindings
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }

		-- Helper: Use Snacks picker if available and LSP supports the method, otherwise fallback
		local function lsp_picker(method, snacks_picker_name, fallback_fn)
			return function()
				local clients = vim.lsp.get_clients({ bufnr = ev.buf, method = method })
				if #clients > 0 and Snacks and Snacks.picker then
					local picker_fn = Snacks.picker[snacks_picker_name]
					if picker_fn then
						picker_fn()
						return
					end
				end
				fallback_fn()
			end
		end

		-- LSP navigation with Snacks picker (fallback to vim.lsp.buf)
		vim.keymap.set("n", "gd", lsp_picker("textDocument/definition", "lsp_definitions", vim.lsp.buf.definition), opts)
		vim.keymap.set("n", "gD", lsp_picker("textDocument/declaration", "lsp_declarations", vim.lsp.buf.declaration), opts)
		vim.keymap.set("n", "gt", lsp_picker("textDocument/typeDefinition", "lsp_type_definitions", vim.lsp.buf.type_definition), opts)
		vim.keymap.set("n", "gi", lsp_picker("textDocument/implementation", "lsp_implementations", vim.lsp.buf.implementation), opts)
		vim.keymap.set("n", "gr", lsp_picker("textDocument/references", "lsp_references", vim.lsp.buf.references), opts)

		-- Other LSP bindings
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

		-- Custom code action binding (macOS Cmd+.)
		vim.keymap.set({ "n", "v" }, "<D-.>", vim.lsp.buf.code_action, opts)

		-- Format binding
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)

		-- Workspace folder management (not provided by LazyVim)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
	end,
})

vim.api.nvim_create_user_command("E", "Neotree", {})

-- Auto-detect indentation
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local lines = vim.api.nvim_buf_get_lines(0, 0, 100, false)
		local tab_count = 0
		local space_counts = {}

		for _, line in ipairs(lines) do
			local leading = line:match("^%s*")
			if #leading > 0 then
				if leading:match("^\t") then
					tab_count = tab_count + 1
				elseif leading:match("^ ") then
					local spaces = #leading
					space_counts[spaces] = (space_counts[spaces] or 0) + 1
				end
			end
		end

		if tab_count > 0 then
			vim.opt_local.expandtab = false
		else
			-- Find the GCD (greatest common divisor) of all indentation levels
			local indent_levels = {}
			for spaces, _ in pairs(space_counts) do
				table.insert(indent_levels, spaces)
			end

			local function gcd(a, b)
				while b ~= 0 do
					a, b = b, a % b
				end
				return a
			end

			local common_indent = 0
			if #indent_levels > 0 then
				common_indent = indent_levels[1]
				for i = 2, #indent_levels do
					common_indent = gcd(common_indent, indent_levels[i])
				end

				-- Ensure reasonable bounds (2, 4, or 8 spaces)
				if not vim.tbl_contains({ 2, 4, 8 }, common_indent) then
					common_indent = 4
				end
			end

			if common_indent > 0 then
				vim.opt_local.tabstop = common_indent
				vim.opt_local.softtabstop = common_indent
				vim.opt_local.shiftwidth = common_indent
				vim.opt_local.expandtab = true
			else
				-- Default to 4 spaces if unable to detect
				vim.opt_local.tabstop = 4
				vim.opt_local.softtabstop = 4
				vim.opt_local.shiftwidth = 4
				vim.opt_local.expandtab = true
			end
		end
	end,
	desc = "Auto-detect indentation on file read",
})

-- Check if JDTLS has active progress (prevents cache corruption on quit)
local function jdtls_is_busy()
	for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
		if client.progress.pending and next(client.progress.pending) then
			return true
		end
	end
	return false
end

local function safe_quit(cmd)
	if jdtls_is_busy() then
		vim.ui.select({ "Yes", "No" }, { prompt = "JDTLS is still indexing. Quit anyway?" }, function(choice)
			if choice == "Yes" then
				vim.cmd(cmd)
			end
		end)
	else
		vim.cmd(cmd)
	end
end

for _, cmd in ipairs({ "q", "qa", "wq", "wqa" }) do
	vim.api.nvim_create_user_command(cmd:gsub("^%l", string.upper), function()
		safe_quit(cmd)
	end, {})
	vim.cmd(([[cnoreabbrev <expr> %s getcmdtype() == ':' && getcmdline() == '%s' ? '%s' : '%s']]):format(
		cmd, cmd, cmd:gsub("^%l", string.upper), cmd
	))
end
