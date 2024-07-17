-- Set leader to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable nerd font
vim.g.have_nerd_font = true

-- Require other stuff
require 'config.lazy'
require 'options'
require 'keymaps'
