return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          exclude = { "vendor" },
        },
        grep = {
          exclude = { "vendor" },
        },
      },
    },
  },
  keys = {
    { "<Leader>fF", function() Snacks.picker.files { exclude = {} } end, desc = "Find files (all)" },
    { "<Leader>fG", function() Snacks.picker.grep { exclude = {} } end, desc = "Find files (all)" },
  },
}
