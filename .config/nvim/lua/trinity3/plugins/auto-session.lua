return {
  "rmagatti/auto-session",
  lazy = false,
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore = false, -- don't auto-restore on startup
      auto_save = true,     -- still save on exit
      cwd_change_handling = true,

      -- Only suppress in these dirs
      suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "~/Desktop/", "~/Videos" },

      -- OR: if you only want ~/Dev tracked, uncomment this:
      allowed_dirs = { "~/workSpace/*", "~/workSpace/" },
    })

    -- Keymaps for session management
    local keymap = vim.keymap
    keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session (cwd or named)" })
    keymap.set("n", "<leader>wr", "<cmd>AutoSession search<CR>", { desc = "Fuzzy search sessions" })
 end,
}

