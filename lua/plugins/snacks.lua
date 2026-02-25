return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          exclude = { "vendor/" },
        },
        grep = {
          hidden = true,
          exclude = { "vendor/" },
        },
      },
    },
  },
  keys = {
    {
      "<Leader>fF",
      function() Snacks.picker.files { exclude = {} } end,
      desc = "Find all files",
    },
    {
      "<Leader>fG",
      function() Snacks.picker.files { exclude = {} } end,
      desc = "Find all files (no filter)",
    },
    {
      "<Leader>fW",
      function() Snacks.picker.grep { exclude = {} } end,
      desc = "Find words in all files",
    },
  },
}
