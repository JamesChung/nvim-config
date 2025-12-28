return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"<leader>td",
			"<Cmd>TodoTelescope<CR>",
			desc = "Toggle todo list (todo-comments)",
		},
	},
}
