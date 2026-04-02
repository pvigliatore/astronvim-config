--- Dynamically discover rule groups from skills/rules directories.
---
--- Discovery sources are defined as a list of { path, opts } pairs.
--- Each source is scanned with two rules:
---   1. Subdirectories → each becomes a rule group  (files: "dir/*")
---   2. Loose .md files at the root → each becomes its own rule group
---
--- Group names are derived from the directory or file name, kebab-cased
--- and prefixed with an optional namespace to avoid collisions across sources.

local M = {}

--- Normalise a name into a valid, readable rule-group key.
--- "jira-write-quality-ticket" → "jira_write_quality_ticket"
---@param name string
---@return string
local function to_key(name)
  return name:gsub("%-", "_"):gsub("[^%w_]", ""):lower()
end

--- Build a human-readable description from a kebab-case directory name.
--- "jira-write-quality-ticket" → "Jira write quality ticket"
---@param name string
---@return string
local function to_description(name)
  local desc = name:gsub("%-", " "):gsub("_", " ")
  return desc:sub(1, 1):upper() .. desc:sub(2)
end

---@class DiscoverSource
---@field path string          Absolute path or ~ prefixed path to scan
---@field prefix? string       Optional prefix for rule group keys (e.g. "global")
---@field file_pattern? string Glob pattern for the files field (uses path as-is if absolute, ~ ok)

---@param sources DiscoverSource[]
---@return table<string, table> rule_groups  keyed by group name, value = { description, files }
function M.discover(sources)
  local groups = {}

  for _, source in ipairs(sources) do
    local expanded = vim.fn.expand(source.path)
    local prefix = source.prefix

    -- Skip sources that don't exist on disk
    if vim.fn.isdirectory(expanded) ~= 1 then goto continue end

    local handle = vim.uv.fs_scandir(expanded)
    if not handle then goto continue end

    while true do
      local name, type = vim.uv.fs_scandir_next(handle)
      if not name then break end

      -- Skip hidden entries
      if name:sub(1, 1) == "." then goto next end

      local key = prefix and (prefix .. "_" .. to_key(name)) or to_key(name)

      if type == "directory" then
        -- Rule 1: directory → rule group with all files inside
        local dir_path = source.path .. "/" .. name
        groups[key] = {
          description = to_description(name),
          files = { dir_path .. "/*" },
        }
      elseif type == "file" and name:match("%.md$") then
        -- Rule 2: loose .md file → individual rule group
        local stem = name:gsub("%.md$", "")
        key = prefix and (prefix .. "_" .. to_key(stem)) or to_key(stem)
        groups[key] = {
          description = to_description(stem),
          files = { source.path .. "/" .. name },
        }
      end

      ::next::
    end

    ::continue::
  end

  return groups
end

return M
