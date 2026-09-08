return {
	{
		"mfussenegger/nvim-jdtls",
		keys = {
			{ "<leader>jb", "<cmd>JdtBytecode<cr>", desc = "Show bytecode", ft = "java" },
			{ "<leader>jc", "<cmd>JdtCompile<cr>", desc = "Compile", ft = "java" },
			{ "<leader>jC", "<cmd>JdtCompile full<cr>", desc = "Compile (full)", ft = "java" },
			{ "<leader>jr", "<cmd>JdtSetRuntime<cr>", desc = "Set runtime", ft = "java" },
			{ "<leader>js", "<cmd>JdtJshell<cr>", desc = "Jshell", ft = "java" },
			{ "<leader>jR", "<cmd>JdtRestart<cr>", desc = "Restart LSP", ft = "java" },
		},
		opts = function(_, opts)
			-- DO NOT REMOVE AS "REDUNDANT" (regressed once already, commit a8f50c5).
			-- mason.nvim only exports $MASON and prepends its bin/ to PATH once LOADED.
			-- mason is lazy-loaded while nvim-jdtls loads on the `java` filetype, so
			-- LazyVim's extra can build its command first, yielding a stray PATH jdtls
			-- and a lombok path of "/share/jdtls/lombok.jar" from the empty $MASON.
			-- A -javaagent on a nonexistent jar makes the JVM refuse to start (exit 1).
			-- stdpath("data") is load-order independent, so resolve from it instead.
			local mason_root = vim.fn.stdpath("data") .. "/mason"
			local mason_jdtls = mason_root .. "/bin/jdtls"
			local lombok_jar = mason_root .. "/share/jdtls/lombok.jar"

			-- Idempotent, so it is safe to apply at both config and server-start time.
			local function resolve_cmd(cmd)
				if type(cmd) ~= "table" then
					return cmd
				end

				-- PATH order is non-deterministic; prefer the install this config manages.
				if vim.fn.executable(mason_jdtls) == 1 then
					cmd[1] = mason_jdtls
				end

				-- Absolutize the lombok agent, or DROP it: losing the agent only costs
				-- lombok codegen, whereas a broken agent path is fatal.
				local has_lombok = vim.fn.filereadable(lombok_jar) == 1
				for i = #cmd, 1, -1 do
					if type(cmd[i]) == "string" and cmd[i]:match("^%-%-jvm%-arg=%-javaagent:.*lombok") then
						if has_lombok then
							cmd[i] = "--jvm-arg=-javaagent:" .. lombok_jar
						else
							table.remove(cmd, i)
						end
					end
				end

				return cmd
			end

			resolve_cmd(opts.cmd)

			-- attach_jdtls() builds the real command from full_cmd at server-start time,
			-- so re-resolve there too in case anything rewrites opts.cmd after us.
			local lazyvim_full_cmd = opts.full_cmd
			if type(lazyvim_full_cmd) == "function" then
				opts.full_cmd = function(o)
					return resolve_cmd(lazyvim_full_cmd(o))
				end
			end

			-- Add JVM args for performance
			local jvm_args = {
				"--jvm-arg=-Xmx8g",
				"--jvm-arg=-XX:+UseZGC",
				"--jvm-arg=-XX:+UseStringDeduplication",
				"--jvm-arg=-XX:ReservedCodeCacheSize=1g",
				"--jvm-arg=-XX:SoftRefLRUPolicyMSPerMB=50",
				"--jvm-arg=-XX:-OmitStackTraceInFastThrow",
			}
			for _, arg in ipairs(jvm_args) do
				table.insert(opts.cmd, arg)
			end

			-- Disable main class scanning (performance killer on large monorepos)
			opts.dap_main = false

			-- Define all Java settings in one place
			local java_settings = {
				-- Disable built-in formatter (using palantir-java-format via conform.nvim)
				format = { enabled = false },

				-- Multiple JDK runtimes for project switching
				configuration = {
					updateBuildConfiguration = "automatic",
					runtimes = {
						{
							name = "JavaSE-17",
							path = "/Library/Java/JavaVirtualMachines/applejdk-17.jdk/Contents/Home",
						},
						{
							name = "JavaSE-21",
							path = "/Library/Java/JavaVirtualMachines/applejdk-21.jdk/Contents/Home",
							default = true,
						},
						{
							name = "JavaSE-25",
							path = "/Library/Java/JavaVirtualMachines/applejdk-25.jdk/Contents/Home",
						},
					},
				},

				-- Hybrid mode: fast startup, full features in background
				server = { launchMode = "Hybrid" },

				autobuild = { enabled = true },

				-- Completion optimizations
				completion = {
					chain = { enabled = true },
					postfix = { enabled = true },
					lazyResolveTextEdit = { enabled = true },
				},

				-- JDT Language Server features
				jdt = {
					ls = {
						lombokSupport = { enabled = true },
						protobufSupport = { enabled = true },
					},
				},

				-- Code lens (shows references/implementations above methods)
				referencesCodeLens = { enabled = false }, -- Expensive in monorepos
				implementationsCodeLens = { enabled = true },

				-- Download dependency sources for go-to-definition
				maven = {
					downloadSources = true,
					updateSnapshots = false,
				},

				-- Use fernflower for better decompiled source quality
				contentProvider = {
					preferred = "fernflower",
				},

				-- Better workspace symbol search
				symbols = {
					includeSourceMethodDeclarations = true,
				},

				-- Disable telemetry for corporate environments
				telemetry = {
					enabled = false,
				},

				-- Import organization
				sources = {
					organizeImports = {
						starThreshold = 999,
						staticStarThreshold = 999,
					},
				},

				-- Gradle settings
				-- NOTE: offline mode skips network dependency resolution for faster startup.
				-- If you add new dependencies, run `./gradlew build --refresh-dependencies` first.
				import = {
					gradle = {
						offline = { enabled = false },
					},
					exclusions = {
						"**/node_modules/**",
						"**/.git/**",
						"**/.idea/**",
					},
				},

				-- Signature help with javadoc descriptions
				signatureHelp = {
					enabled = true,
					description = { enabled = true },
				},

				-- Include decompiled sources in references
				references = {
					includeDecompiledSources = true,
				},

				inlayHints = {
					parameterNames = { enabled = "literals" },
					variableTypes = { enabled = true },
					methodReturnTypes = { enabled = true },
				},

				-- Auto-organize imports on save (disabled - using palantir-java-format)
				-- saveActions = {
				-- 	organizeImports = true,
				-- },

				-- Cleanup actions on save (disabled - using palantir-java-format)
				-- cleanup = {
				-- 	actions = {
				-- 		"addOverride",
				-- 		"addDeprecated",
				-- 		"lambdaExpression",
				-- 		"removeUnusedImports",
				-- 	},
				-- },
			}

			-- Set via opts.jdtls (gets merged into final config by LazyVim)
			-- Pass settings via init_options (like VS Code Java does) so they're available
			-- during initial Gradle import, before workspace/configuration is requested.
			opts.jdtls = opts.jdtls or {}
			opts.jdtls.settings = { java = java_settings }
			opts.jdtls.init_options = opts.jdtls.init_options or {}
			opts.jdtls.init_options.settings = { java = java_settings }

			return opts
		end,
	},
}
