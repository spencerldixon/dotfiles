-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})


local map = vim.keymap.set

-- nvim-tree mappings
--map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" }) -- native mapping but interferes with zellij
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
--map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })


-- telescope
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles'})
map('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind [G]rep' })
map('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp tags' })
map('n', '<leader>.', builtin.current_buffer_fuzzy_find, { desc = '[F]ind in current buffer' })

-- Navigate between buffers with Shift+h or Shift+l and <leader>bd to delete the buffer
map('n', '<S-h>', '<cmd>bprev<CR>', { desc = 'Navigate left to previous buffer' })
map('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Navigate right to next buffer' })
map('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[b]uffer [d]elete' })

-- Top and bottom of file with Backspace and Enter
map('n', '<BS>', 'gg', { desc = 'Navigate to top of file' })
map('n', '<CR>', 'G', { desc = 'Navigate to bottom of file' })

-- Quick save with <leader>w
map('n', '<leader>w', '<cmd>w<CR>', { desc = '[w]rite buffer' })

-- vim: ts=2 sts=2 sw=2 et

