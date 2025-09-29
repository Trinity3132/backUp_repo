return {
    -- Mini Nvim
    { "echasnovski/mini.nvim", version = false },

    -- Comments
    {
        "echasnovski/mini.comment",
        version = false,
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            require("ts_context_commentstring").setup {
                enable_autocmd = false,
            }

            require("mini.comment").setup {
                options = {
                    custom_commentstring = function()
                        return require("ts_context_commentstring.internal").calculate_commentstring({ key = "commentstring" })
                            or vim.bo.commentstring
                    end,
                },
            }
        end,
    },

    -- File explorer
    {
        "echasnovski/mini.files",
        config = function()
            local MiniFiles = require("mini.files")
            MiniFiles.setup({
                mappings = {
                    go_in = "<CR>",
                    go_in_plus = "L",
                    go_out = "-",
                    go_out_plus = "H",
                },
            })
            vim.keymap.set("n", "<leader>ee", "<cmd>lua MiniFiles.open()<CR>", { desc = "Toggle mini file explorer" })
            vim.keymap.set("n", "<leader>ef", function()
                MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
                MiniFiles.reveal_cwd()
            end, { desc = "Toggle into currently opened file" })
        end,
    },

    -- Surround
    {
        "echasnovski/mini.surround",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            highlight_duration = 300,
            mappings = {
                add = "sa",
                delete = "ds",
                find = "sf",
                find_left = "sF",
                highlight = "sh",
                replace = "sr",
                update_n_lines = "sn",
                suffix_last = "l",
                suffix_next = "n",
            },
            n_lines = 20,
            respect_selection_type = false,
            search_method = "cover",
            silent = false,
        },
    },

    -- Get rid of whitespace
    {
        "echasnovski/mini.trailspace",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local miniTrailspace = require("mini.trailspace")
            miniTrailspace.setup({ only_in_normal_buffers = true })

            vim.keymap.set("n", "<leader>cw", function() miniTrailspace.trim() end, { desc = "Erase Whitespace" })

            vim.api.nvim_create_autocmd("CursorMoved", {
                pattern = "*",
                callback = function()
                    require("mini.trailspace").unhighlight()
                end,
            })
        end,
    },

    -- Split & join
    {
        "echasnovski/mini.splitjoin",
        config = function()
            local miniSplitJoin = require("mini.splitjoin")
            miniSplitJoin.setup({ mappings = { toggle = "" } })
            vim.keymap.set({ "n", "x" }, "sj", function() miniSplitJoin.join() end, { desc = "Join arguments" })
            vim.keymap.set({ "n", "x" }, "sk", function() miniSplitJoin.split() end, { desc = "Split arguments" })
        end,
    },

    -- Minimap (mini.map)
    {
        "echasnovski/mini.map",
        config = function()
            local map = require("mini.map")
            map.setup({
                integrations = {
                    map.gen_integration.builtin_search(),
                    map.gen_integration.diagnostic(),
                    map.gen_integration.gitsigns(),
                },
               symbols = {
                 encode = map.gen_encode_symbols.dot('3x4'),
                },
                window = {
                    side = "right",
                    width = 20,   -- minimap width
                    winblend = 50 -- transparency
                },
            })

            -- Define colors for minimap
            vim.api.nvim_set_hl(0, "MiniMapNormal", { fg = "#666666", bg = "#1e1e1e" })
            vim.api.nvim_set_hl(0, "MiniMapSymbolCount", { fg = "#ffaa00" })
            vim.api.nvim_set_hl(0, "MiniMapSymbolLine", { fg = "#00ff00" })
            vim.api.nvim_set_hl(0, "MiniMapSymbolView", { fg = "#ffffff", bg = "#333333", bold = true })

            -- Toggle minimap
            vim.keymap.set("n", "<leader>mm", function()
                map.toggle()
            end, { desc = "Toggle minimap" })
        end,
    },
}
