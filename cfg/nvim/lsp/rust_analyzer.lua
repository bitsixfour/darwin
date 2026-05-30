local namespace = vim.api.nvim_create_namespace("user-rust-type-hints")
local type_hint_kind = 1

local function request_rust_type_hints(client, bufnr)
  if not client or not client:supports_method("textDocument/inlayHint") then
    return
  end

  client:request("textDocument/inlayHint", {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = {
        line = math.max(vim.api.nvim_buf_line_count(bufnr) - 1, 0),
        character = 0,
      },
    },
  }, function(err, result, ctx)
    if err or not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
      return
    end

    local current = vim.lsp.get_client_by_id(ctx.client_id)
    if not current or current.id ~= client.id then
      return
    end

    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local line_hints = {}
    for _, hint in ipairs(result or {}) do
      if hint.kind == nil or hint.kind == type_hint_kind then
        local text = ""
        if type(hint.label) == "string" then
          text = hint.label
        else
          for _, part in ipairs(hint.label) do
            text = text .. part.value
          end
        end

        if text ~= "" then
          local lnum = hint.position.line
          line_hints[lnum] = line_hints[lnum] or {}
          table.insert(line_hints[lnum], text)
        end
      end
    end

    for lnum, hints in pairs(line_hints) do
      vim.api.nvim_buf_set_extmark(bufnr, namespace, lnum, 0, {
        virt_text = { { table.concat(hints, "  "), "LspInlayHint" } },
        virt_text_pos = "eol_right_align",
      })
    end
  end, bufnr)
end

local function setup_rust_type_hints(client, bufnr)
  local group = vim.api.nvim_create_augroup("user-rust-type-hints-" .. bufnr, { clear = true })
  local timer = vim.uv.new_timer()

  local function refresh()
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
      return
    end
    request_rust_type_hints(client, bufnr)
  end

  local function schedule_refresh()
    if not timer then
      return
    end

    timer:stop()
    timer:start(120, 0, vim.schedule_wrap(refresh))
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = bufnr,
    callback = schedule_refresh,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = bufnr,
    callback = function()
      vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      if timer then
        timer:stop()
        timer:close()
        timer = nil
      end
    end,
  })

  refresh()
end

local function toggle_rust_lsp_display(client, bufnr)
  local diagnostics_enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
  local next_state = not diagnostics_enabled

  vim.diagnostic.enable(next_state, { bufnr = bufnr })

  if client:supports_method("textDocument/inlayHint") then
    if next_state then
      request_rust_type_hints(client, bufnr)
    else
      vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end
  end

  vim.notify(
    string.format("Rust LSP display %s", next_state and "enabled" or "disabled"),
    vim.log.levels.INFO,
    { title = "rust-analyzer" }
  )
end

return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = {
    "Cargo.toml",
    "rust-project.json",
    ".git",
  },
  on_attach = function(client, bufnr)
    if client:supports_method("textDocument/inlayHint") then
      vim.keymap.set("n", "<leader>uh", function()
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, { limit = 1 })
        if #marks > 0 then
          vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        else
          request_rust_type_hints(client, bufnr)
        end
      end, {
        buffer = bufnr,
        desc = "Toggle inlay hints",
      })

      setup_rust_type_hints(client, bufnr)
    end

    vim.keymap.set("n", "<F2>", function()
      toggle_rust_lsp_display(client, bufnr)
    end, {
      buffer = bufnr,
      desc = "Toggle Rust LSP hints and diagnostics",
    })
  end,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        allTargets = true,
        buildScripts = {
          enable = true,
        },
      },
      check = {
        command = "check",
        allTargets = true,
      },
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
      inlayHints = {
        bindingModeHints = {
          enable = true,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 20,
        },
        closureCaptureHints = {
          enable = true,
        },
        closureReturnTypeHints = {
          enable = "always",
        },
        discriminantHints = {
          enable = "fieldless",
        },
        expressionAdjustmentHints = {
          enable = "always",
          hideOutsideUnsafe = false,
          mode = "prefix",
        },
        lifetimeElisionHints = {
          enable = "skip_trivial",
          useParameterNames = true,
        },
        maxLength = 40,
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "always",
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
    },
  },
}
