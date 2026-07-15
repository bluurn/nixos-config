vim.filetype.add({
  extension = {
    jsx = "javascriptreact",
    tsx = "typescriptreact",
    mdx = "markdown.mdx",
    gotmpl = "gotmpl",
  },
  filename = {
    ["go.work"] = "gowork",
    ["go.work.sum"] = "gowork",
  },
  pattern = {
    [".*%.go%.tmpl"] = "gotmpl",
    [".*%.tmpl"] = "gotmpl",
  },
})
