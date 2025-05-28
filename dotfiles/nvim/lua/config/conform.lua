require("conform").setup({
  formatters_by_ft = {
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    json = { "biome" },
    markdown = { "biome" },
    lua = { "stylua" },
    go = { "gofmt" },
  },
})

