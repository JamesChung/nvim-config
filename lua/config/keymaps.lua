-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Note: Line/selection movement is handled by mini.move (Alt+hjkl)

-- Override :bd to use Snacks.bufdelete() to preserve window layout
vim.api.nvim_create_user_command("BD", function(opts)
  Snacks.bufdelete()
end, { desc = "Delete buffer (keep window)" })

-- Create abbreviation so :bd becomes :BD
vim.cmd([[cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'BD' : 'bd']])
