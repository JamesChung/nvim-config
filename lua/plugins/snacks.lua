return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      enabled = false,
    },
    picker = {
      sources = {
        files = {
          hidden = false,  -- Don't show dot-files by default
          ignored = false, -- Don't show .gitignore files by default
        },
      },
    },
  },
}
