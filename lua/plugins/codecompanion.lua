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
  init = function()
    -- Pause auto-save while CodeCompanion tools are running to prevent
    -- writes that conflict with in-flight file edits.
    local group = vim.api.nvim_create_augroup("CodeCompanionAutoSave", { clear = true })

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "CodeCompanionToolsStarted",
      callback = function(request)
        -- Clear the plugin's augroup to stop all auto-save triggers
        vim.api.nvim_create_augroup("AutoSavePlug", { clear = true })

        -- Pre-populate the approval cache for insert_edit_into_file so that
        -- the tool's `is_approved` check passes and buffers are saved to disk
        -- automatically after edits (via `silent write` in edit_buffer).
        local chat_bufnr = request.data and request.data.bufnr
        if chat_bufnr then
          local ok, approvals = pcall(require, "codecompanion.interactions.chat.tools.approvals")
          if ok then approvals:always(chat_bufnr, { tool_name = "insert_edit_into_file" }) end
        end
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "CodeCompanionToolsFinished",
      callback = function()
        -- Re-run setup to restore the plugin's autocmds
        local ok, auto_save = pcall(require, "auto-save")
        if ok then auto_save.setup() end
      end,
    })
  end,
  opts = {
    display = {
      diff = {
        enabled = false,
      },
    },
    rules = {
      my_rules = {
        description = "Rules that should always be applied",
        files = {
          ".cursor/rules/**/*.md",
          "~/projects/ai-prompts/rules/**/*.md",
        },
      },
      portfolio_history = {
        description = "Skills relevant to the portfolio history project",
        files = {
          "~/projects/ai-prompts/skills/portfolio-history/*.md",
        },
      },
      project_skills = {
        description = "Find skills in project folders",
        files = {
          ".cursor/skills/**/*.md",
        },
      },
      jira_execution = {
        description = "Jira-related skills (manage, evaluate, write, and break down tickets)",
        files = {
          "~/projects/skills/product/jira/SKILL.md",
          "~/projects/skills/product/jira-ticket-todos/SKILL.md",
        },
      },
      jira_writing = {
        description = "Skills for writing Jira tickets",
        files = {
          "~/projects/skills/product/jira/SKILL.md",
          "~/projects/skills/product/jira-ticket-todos/SKILL.md",
          "~/projects/skills/product/jira-write-quality-ticket/SKILL.md",
          "~/projects/skills/product/jira-evaluate-ticket-quality/SKILL.md",
        },
      },
      opts = {
        chat = {
          autoload = { "default", "my_rules" },
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
            default_tools = { "agent" },
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
          ["run_command"] = {
            opts = {
              require_approval_before = function(tool, _)
                local cmd = vim.trim(tool.args.cmd)

                -- Strip harmless shell redirections before splitting so they
                -- don't create bogus segments (e.g. "2>&1" splitting on "&").
                local clean = cmd:gsub("%d*>[>&]?[%d/a-zA-Z._-]*", "")

                -- Split on actual shell operators: ;  |  ||  &&
                -- This avoids splitting on & inside redirections.
                local segments = {}
                for seg in clean:gmatch "[^;|&]+" do
                  seg = vim.trim(seg)
                  if #seg > 0 then table.insert(segments, seg) end
                end

                -- ── Denylist: always require approval ──
                local denied_cmds = {
                  "bash",
                  "chflags",
                  "chmod",
                  "chown",
                  "csh",
                  "dd",
                  "defaults",
                  "diskutil",
                  "eval",
                  "exec",
                  "fish",
                  "kill",
                  "killall",
                  "launchctl",
                  "ln",
                  "mkfs",
                  "mv",
                  "nohup",
                  "pkill",
                  "reboot",
                  "rm",
                  "rmdir",
                  "sh",
                  "shutdown",
                  "source",
                  "sudo",
                  "xargs",
                  "zsh",
                }
                local denied_git = { "clean", "reset" }

                for _, seg in ipairs(segments) do
                  local first = vim.split(seg, " ")[1]

                  for _, d in ipairs(denied_cmds) do
                    if first == d then return true end
                  end

                  -- Destructive git subcommands
                  if first == "git" then
                    for _, sub in ipairs(denied_git) do
                      if seg:match("^git%s+" .. sub) then return true end
                    end
                    if seg:match "^git%s+push%s+%-%-force" or seg:match "^git%s+push%s+%-f%s" then return true end
                    if seg:match "^git%s+checkout%s+%-%-?%s+%." then return true end
                  end

                  -- Block piping curl/wget into a shell
                  if seg:match "curl.-|" or seg:match "wget.-|" then return true end

                  -- Block wrappers used to invoke a denied command indirectly
                  -- e.g. "env bash -c ..." or "command rm -rf"
                  for _, d in ipairs(denied_cmds) do
                    if seg:match("%s" .. d .. "%s") or seg:match("%s" .. d .. "$") then return true end
                  end
                end

                -- ── Allowlist: auto-approve if every segment is allowed ──
                -- Commands that are safe regardless of arguments.
                local simple_allowed = {
                  ["basename"] = true,
                  ["cat"] = true,
                  ["cd"] = true,
                  ["command"] = true,
                  ["cut"] = true,
                  ["date"] = true,
                  ["diff"] = true,
                  ["dirname"] = true,
                  ["echo"] = true,
                  ["env"] = true,
                  ["file"] = true,
                  ["find"] = true,
                  ["gofmt"] = true,
                  ["gofumpt"] = true,
                  ["golangci-lint"] = true,
                  ["grep"] = true,
                  ["head"] = true,
                  ["helm"] = true,
                  ["jq"] = true,
                  ["less"] = true,
                  ["ls"] = true,
                  ["make"] = true,
                  ["printenv"] = true,
                  ["printf"] = true,
                  ["pwd"] = true,
                  ["readlink"] = true,
                  ["realpath"] = true,
                  ["sort"] = true,
                  ["stat"] = true,
                  ["stylua"] = true,
                  ["tail"] = true,
                  ["tee"] = true,
                  ["tr"] = true,
                  ["tree"] = true,
                  ["type"] = true,
                  ["uname"] = true,
                  ["uniq"] = true,
                  ["wc"] = true,
                  ["which"] = true,
                  ["whoami"] = true,
                  ["yq"] = true,
                }
                -- Commands allowed as a prefix — any subcommand that survives
                -- the denylist above is auto-approved.
                local prefix_allowed = {
                  ["docker"] = true,
                  ["git"] = true,
                  ["go"] = true,
                  ["kubectl"] = true,
                }

                local all_allowed = true
                for _, seg in ipairs(segments) do
                  local first = vim.split(seg, " ")[1]
                  if not simple_allowed[first] and not prefix_allowed[first] then
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
