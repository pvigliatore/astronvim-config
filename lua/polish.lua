-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

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

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local opts = { buffer = event.buf }
    local references = { buffer = event.buf, desc = "References" }

    -- Hover seems to work already
    -- vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    --
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", references)
    vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", references)
    vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", references)
    vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", references)
    vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", references)
    vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", references)
    vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
    vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
    vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
  end,
})

-- Stuff for Work
require("lspconfig").gopls.setup {
  settings = {
    gopls = {
      buildFlags = { "-tags=integration,paper" },
      gofumpt = true,
    },
  },
}
