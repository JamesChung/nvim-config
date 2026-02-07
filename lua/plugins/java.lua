return {
	{
		"mfussenegger/nvim-jdtls",
		opts = function(_, opts)
			-- Add JVM args for performance (4GB heap, ZGC)
			local jvm_args = {
				"--jvm-arg=-Xms1g",
				"--jvm-arg=-Xmx6g",
				"--jvm-arg=-XX:+UseZGC",
				"--jvm-arg=-XX:+ZGenerational",
				"--jvm-arg=-XX:MaxMetaspaceSize=512m",
				"--jvm-arg=-XX:+UseStringDeduplication",
			}
			for _, arg in ipairs(jvm_args) do
				table.insert(opts.cmd, arg)
			end

			-- Custom cache directory (outside nvim folder)
			opts.jdtls_config_dir = function(project_name)
				return vim.fn.expand("~/.cache/jdtls/") .. project_name .. "/config"
			end
			opts.jdtls_workspace_dir = function(project_name)
				return vim.fn.expand("~/.cache/jdtls/") .. project_name .. "/workspace"
			end

			-- Disable main class scanning (performance killer on large monorepos)
			opts.dap_main = false

			-- Extend JDTLS settings
			opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
				java = {
					-- Multiple JDK runtimes for project switching
					configuration = {
						runtimes = {
							{
								name = "JavaSE-11",
								path = "/Library/Java/JavaVirtualMachines/applejdk-11.0.30.7.1.jdk/Contents/Home",
							},
							{
								name = "JavaSE-17",
								path = "/Library/Java/JavaVirtualMachines/applejdk-17.0.18.8.1.jdk/Contents/Home",
							},
							{
								name = "JavaSE-21",
								path = "/Library/Java/JavaVirtualMachines/applejdk-21.0.10.7.1.jdk/Contents/Home",
								default = true,
							},
							{
								name = "JavaSE-25",
								path = "/Library/Java/JavaVirtualMachines/applejdk-25.0.2.10.1.jdk/Contents/Home",
							},
						},
					},

					-- Completion optimizations
					completion = {
						chain = { enabled = true },
						favoriteStaticMembers = {
							"org.junit.Assert.*",
							"org.junit.jupiter.api.Assertions.*",
							"org.mockito.Mockito.*",
							"org.mockito.ArgumentMatchers.*",
							"org.assertj.core.api.Assertions.*",
						},
						filteredTypes = {
							"java.awt.*",
							"com.sun.*",
							"sun.*",
							"jdk.*",
							"org.graalvm.*",
						},
						guessMethodArguments = "auto",
						importOrder = { "#", "java", "javax", "org", "com", "" },
					},

					-- Import organization
					sources = {
						organizeImports = {
							starThreshold = 5,
							staticStarThreshold = 3,
						},
					},

					-- Gradle settings
					import = {
						gradle = {
							enabled = true,
							wrapper = { enabled = true },
							annotationProcessing = { enabled = true },
						},
					},

					-- Null analysis for NPE detection (interactive = only annotated code)
					compile = {
						nullAnalysis = {
							mode = "interactive",
						},
					},

					-- Inlay hints (already enabled by LazyVim, but ensure "all")
					inlayHints = {
						parameterNames = { enabled = "all" },
					},

					-- Performance settings
					maxConcurrentBuilds = 4,
					autobuild = { enabled = false }, -- Manual builds with :JdtCompile
				},
			})

			return opts
		end,
	},
}
