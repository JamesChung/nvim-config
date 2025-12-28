return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		enable_git_status = true,
		default_component_configs = {
			icon = {
				folder_closed = "",
				folder_open = "",
				folder_empty = "",
				folder_empty_open = "",
				default = "*",
				highlight = "NeoTreeFileIcon",
			},
			modified = {
				symbol = "[+]",
				highlight = "NeoTreeModified",
			},
			name = {
				trailing_slash = false,
				use_git_status_colors = true,
				highlight = "NeoTreeFileName",
			},
			git_status = {
				symbols = {
					added = "",
					modified = "",
					deleted = "",
					renamed = "",
					untracked = "",
					ignored = "",
					unstaged = "",
					staged = "",
					conflict = "",
				},
			},
		},
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
