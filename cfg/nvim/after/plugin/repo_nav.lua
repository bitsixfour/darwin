local ok, builtin = pcall(require, "telescope.builtin")
if not ok then
  return
end

local map = vim.keymap.set

map("n", "<leader>pf", builtin.git_files, { desc = "Git files" })
map("n", "<leader>ps", builtin.grep_string, { desc = "Search word under cursor" })
map("n", "<leader>mw", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
map("n", "<leader>md", builtin.lsp_definitions, { desc = "Definitions" })
map("n", "<leader>mi", builtin.lsp_implementations, { desc = "Implementations" })
map("n", "<leader>mr", builtin.lsp_references, { desc = "References" })
map("n", "<leader>tt", "<cmd>Oil --float<cr>", { desc = "Explorer float" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-extra-lsp-nav", { clear = true }),
  callback = function(args)
    local opts = { buffer = args.buf }
    map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
    map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
    map("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
  end,
})
