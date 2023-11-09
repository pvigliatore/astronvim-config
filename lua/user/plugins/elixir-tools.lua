return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup {
      nextls = {
        enable = false,         -- defaults to false
        init_options = {
          mix_env = "dev",
          mix_target = "host",
          experimental = { completions = { enable = false } }
        }
      },
      credo = { enable = true },
      elixirls = {
        -- default settings, use the `settings` function to override settings
        settings = elixirls.settings {
          dialyzerEnabled = true,
          fetchDeps = true,
          enableTestLenses = false,
          suggestSpecs = true
        },
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<space>Ef", ":ElixirFromPipe<cr>",
            { buffer = true, noremap = true })
          vim.keymap.set("n", "<space>Et", ":ElixirToPipe<cr>",
            { buffer = true, noremap = tre })
          vim.keymap.set("v", "<space>Em", ":ElixirExpandMacro<cr>",
            { buffer = true, noremap = true })

          vim.api.nvim_command(
            "au BufWritePost *.ex,*.exs,*.heex lua vim.lsp.buf.format()")
        end
      }
    }
  end,
  dependencies = { "nvim-lua/plenary.nvim" }
}
