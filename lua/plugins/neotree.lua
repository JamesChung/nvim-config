return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		enable_git_status = true,
		filesystem = {
			follow_current_file = {
				enabled = true,
				leave_dirs_open = true,
			},
			filtered_items = {
				visible = true,
			},
		},
		window = {
			width = 40,
			mappings = {
				["%"] = "add",
				["D"] = "delete",
				["R"] = "rename",
				["a"] = "", -- I don't want a to do anything
				["d"] = "add_directory",
				["r"] = "refresh",
			},
		},
	},
}
