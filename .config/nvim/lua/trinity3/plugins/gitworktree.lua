return {
	"ThePrimeagen/git-worktree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},

	config = function()
		local gitworktree = require("git-worktree")
		gitworktree.setup()
		require("telescope").load_extension("git_worktree")

		local function in_git_repo()
			return vim.fn.isdirectory(".git") == 1
				or vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null") == "true\n"
		end

		-- Prompt user to initialize repo if none exists
		local function ensure_git_repo()
			if in_git_repo() then
				return true
			end

			local answer = vim.fn.input("Not a Git repo. Initialize one? (y/N): ")
			if answer:lower() == "y" then
				vim.fn.system("git init")
				vim.notify("Initialized empty Git repository in " .. vim.fn.getcwd())
				return true
			else
				vim.notify("Aborted: not a Git repository", vim.log.levels.WARN)
				return false
			end
		end

		-- List worktrees
		vim.keymap.set("n", "<leader>wl", function()
			if ensure_git_repo() then
				require("telescope").extensions.git_worktree.git_worktrees()
			end
		end, { desc = "List Git Worktrees" })

		-- Create/switch worktree
		vim.keymap.set("n", "<leader>wc", function()
			if ensure_git_repo() then
				require("telescope").extensions.git_worktree.create_git_worktree()
			end
		end, { desc = "Create Git Worktree" })
	end,
}
