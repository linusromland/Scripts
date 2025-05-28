require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "tsserver", "gopls", "jsonls" },
  handlers = {
    function(server)
      require("lspconfig")[server].setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      })
    end,
  },
})

