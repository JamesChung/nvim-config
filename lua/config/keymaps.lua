-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Note: Line/selection movement is handled by mini.move (Alt+hjkl)

-- Override :bd to use Snacks.bufdelete() to preserve window layout
vim.api.nvim_create_user_command("BD", function(opts)
	if Snacks and Snacks.bufdelete then
		Snacks.bufdelete()
	else
		vim.cmd("bdelete")
	end
end, { desc = "Delete buffer (keep window)" })

-- Create abbreviation so :bd becomes :BD
vim.cmd([[cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'BD' : 'bd']])

-- User command to toggle Snacks terminal
vim.api.nvim_create_user_command("SnacksTerminal", function()
	if Snacks and Snacks.terminal then
		Snacks.terminal.toggle()
	end
end, { desc = "Toggle Snacks Terminal" })

-- Terminal mappings
vim.keymap.set("t", "<C-[>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set({ "n", "t" }, "<C-t>", function() Snacks.terminal.toggle() end, { desc = "Toggle Terminal" })
vim.keymap.set({ "n", "t" }, "<C-`>", function() Snacks.terminal.toggle() end, { desc = "Toggle Terminal" })

-- Git Quickfix mapping
vim.keymap.set("n", "<leader>gq", function()
	if package.loaded.gitsigns then
		require("gitsigns").setqflist("all")
	end
end, { desc = "Git Quickfix (All Hunks)" })
