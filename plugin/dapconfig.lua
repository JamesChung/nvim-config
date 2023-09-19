local dap = require("dap")
dap.adapters.bashdb = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
    name = "bashdb",
}
dap.configurations.sh = {
    {
        type = "bashdb",
        request = "launch",
        name = "Launch file",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
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

-- Configure nvim-dap settings
vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939", bg = "#31353f" })
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef", bg = "#31353f" })
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379", bg = "#31353f" })

vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DapBreakpoint",
    linehl = "",
    numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
    text = "",
    texthl = "DapBreakpoint",
    linehl = "DapBreakpoint",
    numhl = "",
})
vim.fn.sign_define("DapBreakpointRejected", {
    text = "",
    texthl = "DapBreakpoint",
    linehl = "DapBreakpoint",
    numhl = "",
})
vim.fn.sign_define("DapLogPoint", {
    text = "",
    texthl = "DapLogPoint",
    linehl = "DapLogPoint",
    numhl = "",
})
vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "DapStopped",
    linehl = "DapStopped",
    numhl = "",
})
