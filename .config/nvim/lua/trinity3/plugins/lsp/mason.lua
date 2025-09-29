
return {
    "williamboman/mason.nvim",
    lazy = false,
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "neovim/nvim-lspconfig",
    },
    config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            automatic_installation = true,
            ensure_installed = {
                -- Core
                "lua_ls",
                "ts_ls",
                "html",
                "cssls",
                "tailwindcss",
                "gopls",
                "angularls",
                "emmet_ls",
                "marksman",

                -- Extras
                "clangd",        -- C/C++
                "rust_analyzer", -- Rust
                "pyright",       -- Python
                "denols",        -- Deno
            },
        })

        mason_tool_installer.setup({
            ensure_installed = {
                -- Formatters
                "prettier",      -- JavaScript/TypeScript/HTML/CSS
                "stylua",        -- Lua
                "isort",         -- Python imports
                "black",         -- Python formatter
                "clang-format",  -- C/C++ formatter
                "rustfmt",       -- Rust formatter

                -- Linters
                "pylint",        -- Python
                "eslint_d",      -- JS/TS
            },
        })
    end,
}
