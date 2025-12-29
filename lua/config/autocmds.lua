-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Use LspAttach autocommand to set up custom LSP keybindings
-- Note: LazyVim provides standard bindings (gd, gD, gr, K, gI, gy, <leader>ca, <leader>cr)
-- This config keeps preferred alternatives and unique bindings
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }

		-- Preferred alternative bindings (override LazyVim defaults)
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts) -- Prefer gt over LazyVim's gy
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts) -- Prefer gi over LazyVim's gI
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts) -- Normal mode signature help
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Prefer <leader>rn over <leader>cr

		-- Custom code action bindings
		vim.keymap.set({ "n", "v" }, "<D-.>", vim.lsp.buf.code_action, opts) -- macOS Cmd+.
		vim.keymap.set({ "n", "v" }, "<leader>Ca", vim.lsp.buf.code_action, opts) -- Alternative binding

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
				if common_indent == 1 or common_indent > 8 then
					common_indent = 4
				elseif common_indent == 3 or common_indent == 5 or common_indent == 6 or common_indent == 7 then
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
