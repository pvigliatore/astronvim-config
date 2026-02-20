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
    display = {
      diff = {
        enabled = false,
      },
    },
    rules = {
      -- Custom rule group to load all files from .rules folder
      project_rules = {
        description = "Project-specific rules from .rules folder",
        files = {
          { path = ".rules", files = "*.md" },
          { path = ".skills", files = "*.md" },
        },
      },
      opts = {
        chat = {
          -- Autoload both default rules and project-specific rules
          autoload = { "default", "project_rules" },
          enabled = true,
        },
      },
    },
    interactions = {
      chat = {
        adapter = {
          name = "copilot",
          model = "claude-opus-4.6",
        },
        tools = {
          -- File operations don't require approval
          ["insert_edit_into_file"] = {
            opts = {
              require_approval_before = { buffer = false, file = false },
              require_confirmation_after = false,
            },
          },
          ["read_file"] = {
            opts = {
              require_approval_before = false,
              require_cmd_approval = false,
            },
          },
          ["grep_search"] = {
            opts = {
              require_approval_before = false,
              require_cmd_approval = false,
            },
          },
          ["file_search"] = {
            opts = {
              require_cmd_approval = false,
            },
          },
          ["list_code_usages"] = {
            opts = {
              require_approval_before = false,
            },
          },
          ["create_file"] = {
            opts = { require_approval_before = false },
          },
          ["delete_file"] = {
            opts = { require_approval_before = true },
          },
          -- External commands still require approval (default)
          ["cmd_runner"] = {
            opts = {
              requires_approval = function(input)
                local cmd = vim.trim(input.cmd)

                -- Block anything with chaining operators or redirection
                local has_chain = cmd:match("[;|&>]") ~= nil

                -- Simple whitelisted commands (any arguments allowed)
                local simple = { "helm", "cd" }
                local first = vim.split(cmd, " ")[1]
                for _, allowed in ipairs(simple) do
                  if first == allowed then return false end
                end

                -- grep: allow only when not chained/redirected
                if first == "grep" and not has_chain then return false end

                -- go test: allow the specific subcommand only
                if cmd:match("^go%s+test") and not has_chain then return false end

                return true
              end,
            },
          },
        },
      },
    },
  },
}
