-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Moves highlighted lines above or below considering tabs
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- Allows cursor to remain in place when appending line to previous one
-- vim.keymap.set("n", "J", "mzJ`z")

-- Keeps cursor in the middle while navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Allows paste to maintain current clipboard when replacing
vim.keymap.set("x", "p", [["_dP]])

-- Yanks into system clipboard
-- vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete to void register, to prevent yanking when deleting
-- Not needed since I got used to the default function.
-- vim.keymap.set({ "n", "v" }, "d", [["_d]])

-- Calls tmux sessionizer from within vim
vim.keymap.set("n", "<leader><enter>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Sessionizer" })

-- Calls tmux cheat.sh from within vim
vim.keymap.set("n", "<leader>i", "<cmd>silent !tmux neww tmux-cht<CR>", { desc = "cheat.sh" })

-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Quick fix navigating
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search and Replace
vim.keymap.set("n", "<leader>h", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace Current" })

-- Make current file executable
-- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Reload nvim config
-- vim.keymap.set("n", "<leader><leader>", function()
--   vim.cmd("so")
-- end)
--
