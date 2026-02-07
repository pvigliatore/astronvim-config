return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "AstroNvim/astrocore", opts = {
      mappings = {
        n = {
          ["<Leader>a"] = { desc = "AI Assistant" },
          ["<Leader>ac"] = { "<Cmd>CodeCompanionChat<CR>", desc = "New Chat" },
          ["<Leader>at"] = { "<Cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle Chat" },
        },
      },
    }},
  },
  opts = {
    interactions = {
      chat = {
        adapter = {
          name = "copilot",
          model = "claude-opus-4.5",
        }
      },
    },
    tools = {
      confirm_file_access = false, -- Grant implicit access to all workspace files
    },
  },
}
