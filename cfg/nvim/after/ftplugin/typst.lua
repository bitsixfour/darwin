local homework_dir = vim.fs.normalize(vim.fn.expand("~/.config/homework"))
local buffer_path = vim.fs.normalize(vim.api.nvim_buf_get_name(0))

local function compile_typst_pdf(bufnr)
  local source_path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
  if source_path == "" then
    vim.notify("Share requires a saved Typst file", vim.log.levels.ERROR)
    return nil
  end

  vim.cmd.update()

  local pdf_path = vim.fn.fnamemodify(source_path, ":r") .. ".pdf"
  local result = vim.system({ "typst", "compile", source_path, pdf_path }, { text = true }):wait()

  if result.code ~= 0 then
    local output = result.stderr ~= "" and result.stderr or result.stdout
    vim.fn.setqflist({}, " ", {
      title = "Typst Share",
      lines = vim.split(output, "\n", { trimempty = true }),
    })
    vim.cmd.copen()
    vim.notify("Typst compile failed", vim.log.levels.ERROR)
    return nil
  end

  return pdf_path
end

local function open_path(path)
  if vim.fn.executable("xdg-open") ~= 1 then
    vim.notify("xdg-open is not available", vim.log.levels.ERROR)
    return
  end

  local result = vim.system({ "xdg-open", path }, { text = true }):wait()
  if result.code ~= 0 then
    local output = result.stderr ~= "" and result.stderr or result.stdout
    if output == "" then
      output = "Failed to open " .. path
    end
    vim.notify(output, vim.log.levels.ERROR)
  end
end

if vim.fn.exists(":TypstPreview") == 2 then
  vim.keymap.set("n", "<leader>p", "<cmd>TypstPreview<cr>", { buffer = 0 })
end

vim.api.nvim_buf_create_user_command(0, "Share", function()
  local pdf_path = compile_typst_pdf(0)
  if not pdf_path then
    return
  end

  open_path(pdf_path)
end, {
  desc = "Compile this Typst file to PDF and open it",
})

vim.cmd([[
  cnoreabbrev <buffer> <expr> share getcmdtype() ==# ':' && getcmdline() ==# 'share' ? 'Share' : 'share'
]])

if vim.startswith(buffer_path, homework_dir .. "/") then
  vim.api.nvim_buf_create_user_command(0, "Submit", function()
    local current_pdf = vim.fn.expand("%:t:r") .. ".pdf"

    for _, pdf in ipairs(vim.fn.globpath(homework_dir, "*.pdf", false, true)) do
      if vim.fn.fnamemodify(pdf, ":t") ~= current_pdf then
        vim.fn.delete(pdf)
      end
    end

    local ok = pcall(vim.cmd, "make")
    if not ok then
      return
    end

    if vim.fn.executable("xdg-open") == 1 then
      vim.fn.jobstart({ "xdg-open", homework_dir }, { detach = true })
    end
  end, {
    desc = "Compile homework, prune other PDFs, and open the homework folder",
  })

  vim.cmd([[
    cnoreabbrev <buffer> <expr> submit getcmdtype() ==# ':' && getcmdline() ==# 'submit' ? 'Submit' : 'submit'
  ]])
end

local ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
if ok then
  textobjects.setup({
    select = {
      lookahead = true,
      selection_modes = {
        ["@math.inner"] = "v",
        ["@math.outer"] = "V",
      },
      include_surrounding_whitespace = false,
    },
  })

  vim.keymap.set({ "x", "o" }, "am", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@math.outer", "textobjects")
  end, { buffer = 0 })

  vim.keymap.set({ "x", "o" }, "im", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@math.inner", "textobjects")
  end, { buffer = 0 })
end

vim.cmd([[
  setlocal spell
]])
