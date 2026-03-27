return {
  "https://git.sr.ht/~nedia/auto-save.nvim",
  event = { "BufReadPre" },
  opts = {
    events = { "CursorHold", "InsertLeave", "BufLeave" },
    silent = false,
    exclude_ft = { "codecompanion", "neo-tree" },
    timeout = 100,
    -- When the save is deferred (timeout > 0), the current buffer may have
    -- changed by the time save_fn fires (e.g. after BufLeave).  The default
    -- save_fn blindly runs `:w` on whatever buffer is current at that point,
    -- which explodes with E382 if the new buffer has a non-empty buftype.
    save_fn = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype ~= "" then return end
      vim.cmd("w")
    end,
  },
}
