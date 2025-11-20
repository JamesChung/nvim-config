return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      -- Create a single autocmd group for jdtls setup
      local jdtls_augroup = vim.api.nvim_create_augroup("JdtlsSetup", { clear = true })

      -- FileType autocmd to start jdtls when opening Java files
      vim.api.nvim_create_autocmd("FileType", {
        group = jdtls_augroup,
        pattern = "java",
        callback = function()
          local jdtls = require("jdtls")

          -- Get the Mason install path for jdtls
          local mason_path = vim.fn.stdpath("data") .. "/mason"
          local jdtls_path = mason_path .. "/packages/jdtls"

          -- Configuration directory (detect OS automatically)
          local config_dir
          if vim.fn.has("mac") == 1 then
            config_dir = jdtls_path .. "/config_mac"
          elseif vim.fn.has("unix") == 1 then
            config_dir = jdtls_path .. "/config_linux"
          else
            config_dir = jdtls_path .. "/config_win"
          end

          -- Data directory for workspace storage
          local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:t")

          -- Find the launcher jar
          local launcher_jars = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)

          if not launcher_jars or #launcher_jars == 0 then
            vim.notify("jdtls launcher jar not found. Please install jdtls via Mason.", vim.log.levels.ERROR)
            return
          end

          local launcher_jar = launcher_jars[1]

          -- Setup jdtls configuration
          local config = {
            cmd = {
              "java",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dlog.protocol=true",
              "-Dlog.level=ALL",
              "-Xmx1g",
              "--add-modules=ALL-SYSTEM",
              "--add-opens", "java.base/java.util=ALL-UNNAMED",
              "--add-opens", "java.base/java.lang=ALL-UNNAMED",
              "-jar", launcher_jar,
              "-configuration", config_dir,
              "-data", workspace_dir,
            },

            root_dir = function(fname)
              local found = vim.fs.find({".git", "mvnw", "gradlew", "pom.xml", "build.gradle"}, {
                upward = true,
                path = vim.fs.dirname(fname)
              })[1]
              return found and vim.fs.dirname(found) or vim.fn.getcwd()
            end,

            settings = {
              java = {
                eclipse = {
                  downloadSources = true,
                },
                configuration = {
                  updateBuildConfiguration = "interactive",
                },
                maven = {
                  downloadSources = true,
                },
                implementationsCodeLens = {
                  enabled = true,
                },
                referencesCodeLens = {
                  enabled = true,
                },
                references = {
                  includeDecompiledSources = true,
                },
                format = {
                  enabled = true,
                },
                signatureHelp = { enabled = true },
                completion = {
                  favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                  },
                },
                contentProvider = { preferred = "fernflower" },
                sources = {
                  organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                  },
                },
                codeGeneration = {
                  toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                  },
                  useBlocks = true,
                },
              },
            },

            flags = {
              allow_incremental_sync = true,
            },

            init_options = {
              bundles = {},
              extendedClientCapabilities = jdtls.extendedClientCapabilities,
            },
          }

          -- Start jdtls
          jdtls.start_or_attach(config)
        end,
      })

      -- Single LspAttach autocmd for Java-specific keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = jdtls_augroup,
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if client and client.name == "jdtls" then
            local jdtls = require("jdtls")
            local opts = { noremap = true, silent = true, buffer = bufnr }

            -- Java-specific keymaps
            vim.keymap.set("n", "<leader>co", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
            vim.keymap.set("n", "<leader>cv", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
            vim.keymap.set("v", "<leader>cv", [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]], vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
            vim.keymap.set("n", "<leader>cc", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
            vim.keymap.set("v", "<leader>cc", [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
            vim.keymap.set("v", "<leader>cm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], vim.tbl_extend("force", opts, { desc = "Extract Method" }))
            vim.keymap.set("n", "<leader>ct", jdtls.test_class, vim.tbl_extend("force", opts, { desc = "Test Class" }))
            vim.keymap.set("n", "<leader>tn", jdtls.test_nearest_method, vim.tbl_extend("force", opts, { desc = "Test Nearest Method" }))
          end
        end,
      })
    end,
  },
}
