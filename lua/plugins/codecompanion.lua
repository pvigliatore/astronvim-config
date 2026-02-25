return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>a"] = { desc = "AI Assistant" },
            ["<Leader>aa"] = { "<Cmd>CodeCompanionActions<CR>", desc = "Actions Pallete" },
            ["<Leader>ac"] = { "<Cmd>CodeCompanionChat<CR>", desc = "New Chat" },
            ["<Leader>at"] = { "<Cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle Chat" },
          },
        },
      },
    },
  },
  opts = {
    display = {
      diff = {
        enabled = false,
      },
    },
    rules = {
      cursor_rules = {
        description = "Detect rules in the .cursor/rules/ directory",
        files = { ".cursor/rules/**/*.md" },
      },
      project_skills = {
        description = "Find skills in project folders",
        files = {
          ".cursor/skills/**/*.md",
        },
      },
      opts = {
        chat = {
          autoload = { "default", "cursor_rules" },
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
          opts = {
            auto_submit_errors = true,
            auto_submit_success = true,
            default_tools = { "full_stack_dev" },
          },

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
              require_approval_before = function(tool, _tools)
                local cmd = vim.trim(tool.args.cmd)

                -- Split the full command into segments on shell operators
                -- so we can check every part of a chained command.
                local segments = vim.split(cmd, "[;|&]+", { trimempty = true })

                local denied_cmds = {
                  "chmod",
                  "chown",
                  "dd",
                  "kill",
                  "killall",
                  "mkfs",
                  "pkill",
                  "reboot",
                  "rm",
                  "rmdir",
                  "shutdown",
                  "sudo",
                }
                local denied_git = {
                  "clean",
                  "reset",
                }

                -- Check every segment for denied commands
                for _, seg in ipairs(segments) do
                  seg = vim.trim(seg)
                  local seg_first = vim.split(seg, " ")[1]

                  for _, d in ipairs(denied_cmds) do
                    if seg_first == d then return true end
                  end

                  -- Destructive git subcommands
                  if seg_first == "git" then
                    for _, sub in ipairs(denied_git) do
                      if seg:match("^git%s+" .. sub) then return true end
                    end
                    if seg:match "^git%s+push%s+%-%-force" or seg:match "^git%s+push%s+%-f%s" then return true end
                    if seg:match "^git%s+checkout%s+%-%-?%s+%." then return true end
                  end

                  -- Block piping curl/wget into a shell
                  if seg:match "curl.-|" or seg:match "wget.-|" then return true end
                end

                -- ── Allowlist: auto-approve if every segment is allowed ──
                local simple_allowed = {
                  ["cat"] = true,
                  ["cd"] = true,
                  ["command"] = true,
                  ["diff"] = true,
                  ["echo"] = true,
                  ["env"] = true,
                  ["file"] = true,
                  ["find"] = true,
                  ["grep"] = true,
                  ["head"] = true,
                  ["helm"] = true,
                  ["jq"] = true,
                  ["less"] = true,
                  ["ls"] = true,
                  ["make"] = true,
                  ["printenv"] = true,
                  ["printf"] = true,
                  ["stat"] = true,
                  ["tail"] = true,
                  ["type"] = true,
                  ["wc"] = true,
                  ["which"] = true,
                  ["yq"] = true,
                }
                local sub_allowed = {
                  go = { "test", "vet", "build", "mod", "fmt", "run" },
                  git = { "status", "log", "diff", "show", "branch", "stash" },
                  kubectl = { "get", "describe", "logs", "explain", "api%-resources" },
                  docker = { "ps", "images", "logs", "inspect" },
                }

                local all_allowed = true
                for _, seg in ipairs(segments) do
                  seg = vim.trim(seg)
                  local seg_first = vim.split(seg, " ")[1]

                  if simple_allowed[seg_first] then
                    -- ok
                  elseif sub_allowed[seg_first] then
                    local matched = false
                    for _, sub in ipairs(sub_allowed[seg_first]) do
                      if seg:match("^" .. seg_first .. "%s+" .. sub) then
                        matched = true
                        break
                      end
                    end
                    if not matched then
                      all_allowed = false
                      break
                    end
                  else
                    all_allowed = false
                    break
                  end
                end

                return not all_allowed
              end,
            },
          },
        },
      },
    },
  },
}
