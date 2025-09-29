return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
        local eslint = lint.linters.eslint_d

        -- Define custom linters for C, C++, and Rust
        lint.linters.clang_tidy = {
            cmd = "clang-tidy",
            stdin = false,
            args = { "%file", "--", "-std=c++17" }, -- adjust std for your project
        }

        lint.linters.clippy = {
            cmd = "cargo",
            stdin = false,
            args = { "clippy", "--message-format=json" },
        }

        -- Linters by filetype
        lint.linters_by_ft = {
            javascript = { "biomejs" },
            typescript = { "biomejs" },
            javascriptreact = { "biomejs" },
            typescriptreact = { "biomejs" },
            svelte = { "biomejs" },
            python = { "pylint" },
            rust = { "clippy" },
            c = { "clang_tidy" },
            cpp = { "clang_tidy" },
        }

        eslint.args = {
            "--no-warn-ignored",
            "--format",
            "json",
            "--stdin",
            "--stdin-filename",
            function()
                return vim.fn.expand("%:p")
            end,
        }

        -- Auto lint on BufEnter, BufWritePost, InsertLeave
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        -- Keymap to manually trigger linting
        vim.keymap.set("n", "<leader>l", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}
