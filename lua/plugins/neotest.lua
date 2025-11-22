return {
  "nvim-neotest/neotest",
  keys = {
    -- Remap all test bindings to use capital T instead of lowercase t
    {
      "<leader>TT",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Run File (Neotest)",
    },
    {
      "<leader>Ta",
      function()
        require("neotest").run.attach()
      end,
      desc = "Attach (Neotest)",
    },
    {
      "<leader>Tr",
      function()
        require("neotest").run.run()
      end,
      desc = "Run Nearest (Neotest)",
    },
    {
      "<leader>Tl",
      function()
        require("neotest").run.run_last()
      end,
      desc = "Run Last (Neotest)",
    },
    {
      "<leader>Ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle Summary (Neotest)",
    },
    {
      "<leader>To",
      function()
        require("neotest").output.open({ enter = true, auto_close = true })
      end,
      desc = "Show Output (Neotest)",
    },
    {
      "<leader>TO",
      function()
        require("neotest").output_panel.toggle()
      end,
      desc = "Toggle Output Panel (Neotest)",
    },
    {
      "<leader>TS",
      function()
        require("neotest").run.stop()
      end,
      desc = "Stop (Neotest)",
    },
    {
      "<leader>Tw",
      function()
        require("neotest").watch.toggle(vim.fn.expand("%"))
      end,
      desc = "Toggle Watch (Neotest)",
    },
    {
      "<leader>Td",
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      desc = "Debug Nearest (Neotest)",
    },
    -- Disable all default lowercase t bindings
    { "<leader>tt", false },
    { "<leader>tT", false },
    { "<leader>tr", false },
    { "<leader>tl", false },
    { "<leader>ts", false },
    { "<leader>to", false },
    { "<leader>tO", false },
    { "<leader>tS", false },
    { "<leader>tw", false },
    { "<leader>td", false },
    { "<leader>ta", false },
  },
}
