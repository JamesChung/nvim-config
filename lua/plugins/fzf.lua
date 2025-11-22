return {
  "ibhagwan/fzf-lua",
  opts = {
    files = {
      -- Respect gitignore and exclude hidden files by default
      cmd = "fd --type f --hidden --exclude .git",
      -- Alternative using rg (ripgrep):
      -- cmd = "rg --files --hidden --glob '!.git'",
    },
  },
}
