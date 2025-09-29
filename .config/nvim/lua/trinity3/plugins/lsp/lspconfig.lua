
-- ~/.config/nvim/lua/trinity3/plugins/lsp/lspconfig.lua

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" }, -- lazy-load LSP
  config = function()
    -- Capabilities (for autocompletion)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Common on_attach
    local on_attach = function(client, bufnr)
      local bufmap = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      bufmap("n", "gd", vim.lsp.buf.definition, "Go to Definition")
      bufmap("n", "K", vim.lsp.buf.hover, "Hover Docs")
      bufmap("n", "gr", vim.lsp.buf.references, "Find References")
      bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
      bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      bufmap("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, "Format buffer")
    end

    ---------------------------------------------------------------------------
    -- LSP SERVER CONFIGS
    ---------------------------------------------------------------------------

    -- Python
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Lua
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    -- TypeScript / JavaScript
    vim.lsp.config("tsserver", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- C / C++
    vim.lsp.config("clangd", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- HTML
    vim.lsp.config("html", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- CSS
    vim.lsp.config("cssls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- JSON
    vim.lsp.config("jsonls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Go
    vim.lsp.config("gopls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Rust
    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = { command = "clippy" },
        },
      },
    })

    ---------------------------------------------------------------------------
    -- ENABLE LSPs
    ---------------------------------------------------------------------------
    vim.lsp.enable("pyright")
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("tsserver")
    vim.lsp.enable("clangd")
    vim.lsp.enable("html")
    vim.lsp.enable("cssls")
    vim.lsp.enable("jsonls")
    vim.lsp.enable("gopls")
    vim.lsp.enable("rust_analyzer")
  end,
}
