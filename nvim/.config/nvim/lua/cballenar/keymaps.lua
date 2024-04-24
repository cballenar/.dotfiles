-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keeps cursor in the middle while navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Allows paste to maintain current clipboard when replacing
vim.keymap.set("x", "p", [["_dP]])

-- Calls tmux sessionizer from within vim
vim.keymap.set("n", "<leader><enter>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Sessionizer" })

-- Calls tmux cheat.sh from within vim
vim.keymap.set("n", "<leader>i", "<cmd>silent !tmux neww tmux-cht<CR>", { desc = "cheat.sh" })

-- Quick fix navigating
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search and Replace
vim.keymap.set("n", "<leader>h", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace Current" })

-- Make current file executable
-- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
