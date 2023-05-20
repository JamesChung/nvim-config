-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.bashls.setup {}
lspconfig.denols.setup {}
lspconfig.docker_compose_language_service.setup {}
lspconfig.dockerls.setup {}
lspconfig.dotls.setup {}
lspconfig.eslint.setup {}
lspconfig.gopls.setup {}
lspconfig.jsonls.setup {}
lspconfig.pyright.setup {}
lspconfig.rust_analyzer.setup {}
lspconfig.terraformls.setup {}
lspconfig.tsserver.setup {}
lspconfig.vimls.setup {}
lspconfig.yamlls.setup {}
lspconfig.zls.setup {}
