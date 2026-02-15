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
