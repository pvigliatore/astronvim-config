-- Navigate between words in normal mode
vim.keymap.set("n", "<A-Left>", "b")
vim.keymap.set("n", "<A-Right>", "w")

-- Keymaps for oil.nvim
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Select all text
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })

-- Not sure where these keymaps are set by I hate them!
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")
vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "References" })

if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}
