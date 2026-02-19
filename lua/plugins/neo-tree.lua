return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- Show hidden files as visible (dimmed by default)
        hide_dotfiles = false, -- Do not hide dotfiles
        hide_gitignored = false, -- Optionally also show git-ignored files
      },
    },
  },
}
