return {
  "christoomey/vim-tmux-navigator",
  config = function()
    -- optional: disable default mappings if you want to set your own
    -- vim.g.tmux_navigator_no_mappings = 1

    vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>",  { silent = true })
    vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>",  { silent = true })
    vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>",    { silent = true })
    vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { silent = true })
  end
}

