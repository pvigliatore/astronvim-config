return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup {
      nextls = {
        enable = false, -- defaults to false
        init_options = {
          mix_env = "dev",
          mix_target = "host",
          extensions = { credo = { enable = true } },
          experimental = { completions = { enable = true } }
        },
        on_attach = function(_client, _bufnr)
          local opts = { buffer = true, noremap = true }
          -- vim.keymap.set("n", "<space>Ef", ":ElixirFromPipe<cr>", opts)
          -- vim.keymap.set("n", "<space>Et", ":ElixirToPipe<cr>", opts)
          -- vim.keymap.set("n", "<space>Em", ":ElixirExpandMacro<cr>", opts)
          vim.keymap.set("n", "<space>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
          vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts) -- may not be necessary
          vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
          vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)

          -- format on save
          vim.api.nvim_command("au BufWritePost *.ex,*.exs,*.heex lua vim.lsp.buf.format()")
        end
      },
      credo = { enable = true },
      elixirls = {
        -- default settings, use the `settings` function to override settings
        enable = true,
        settings = elixirls.settings {
          dialyzerEnabled = true,
          enableTestLenses = true,
          fetchDeps = true,
          suggestSpecs = true
        },
        on_attach = function(_client, _bufnr)
          local vim = vim
          local opts = { buffer = true, noremap = true }
          vim.keymap.set("n", "<space>Ef", ":ElixirFromPipe<cr>", opts)
          vim.keymap.set("n", "<space>Et", ":ElixirToPipe<cr>", opts)
          vim.keymap.set("n", "<space>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
          vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
          vim.keymap.set("n", "M", ":ElixirExpandMacro<cr>", opts)
          vim.keymap.set("n", "T", "<cmd>lua vim.lsp.codelens.run()<cr>", opts)
          vim.keymap.set("n", "gI", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
          vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
          vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)

          -- format on save
          vim.api.nvim_command("au BufWritePost *.ex,*.exs,*.heex lua vim.lsp.buf.format()")
        end
      }
    }
  end,
  dependencies = { "nvim-lua/plenary.nvim" }
}
