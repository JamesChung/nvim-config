require("fidget").setup {}
require("telescope").setup {}
require("nvim-tree").setup {}
require("nvim-web-devicons").setup {}
require("toggleterm").setup {
    direction = 'float',
}
require("trouble").setup {
    position = "right",
}
require("deferred-clipboard").setup {
    fallback = "unnamedplus",
    lazy = true,
}
require("mason").setup {
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
}
require("nvim-treesitter.configs").setup {
    ensure_installed = {
        "bash", "c", "cpp", "css", "go", "hcl",
        "html", "javascript", "json", "lua", "make",
        "python", "query", "regex", "rust", "sql",
        "toml", "tsx", "typescript", "yaml", "zig"
    },
    auto_install = true,
    highlight = {
        enabled = true,
    }
}
require("bufferline").setup {
    options = {
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        themable = true,
        diagnostics = "coc",
        sort_by = 'insert_at_end',
        hover = {
            enabled = true,
            delay = 200,
            reveal = { 'close' }
        },
        get_element_icon = function(element)
            local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
            return icon, hl
        end
    }
}
local dap = require("dap")
dap.adapters.bashdb = {
    type = 'executable',
    command = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/bash-debug-adapter',
    name = 'bashdb',
}
dap.configurations.sh = {
    {
        type = 'bashdb',
        request = 'launch',
        name = "Launch file",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
        pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = '${workspaceFolder}',
        pathCat = "cat",
        pathBash = "/opt/homebrew/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        env = {},
        terminalKind = "integrated",
    }
}
require("dap-go").setup {
    dap_configurations = {
        type = "go",
        name = "Attach remote",
        mode = "remote",
        request = "attach",
    },
    delve = {
        initialize_timeout_sec = 20,
        port = "${port}",
    },
}
