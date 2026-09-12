return {
	{
		-- Track the v9.x release line rather than the default branch.
		--
		-- rustaceanvim renamed its default branch master -> main in March 2026.
		-- lazy-lock.json still recorded branch = "master", and since `git fetch`
		-- does not prune deleted remote branches, the local origin/master ref
		-- survived pointing at the last pre-rename commit. lazy.nvim compared
		-- HEAD against that stale ref, saw no difference, and reported "already
		-- up to date" while the plugin sat frozen on v8.0.4 for six months.
		--
		-- A tag range cannot go stale the same way. Bump to "^10" deliberately
		-- when v10 ships, after checking its breaking changes.
		"mrcjkb/rustaceanvim",
		version = "^9",
	},
}
