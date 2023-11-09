return {
  colorscheme = "everforest",
  plugins = {
    {
      "sainnhe/everforest",
      init = function() vim.g.everforest_background = "soft" end
    }, {
    "sainnhe/gruvbox-material",
    init = function()
      vim.g.gruvbox_material_background = "hard"
    end
  }
  }
}
