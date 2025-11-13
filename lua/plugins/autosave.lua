return {
  "https://git.sr.ht/~nedia/auto-save.nvim",
  event = { "BufReadPre" },
  opts = {
    events = { "CursorHold", "InsertLeave", "BufLeave" },
    silent = false,
    exclude_ft = { "neo-tree" },
    timeout = 100,
  },
}
