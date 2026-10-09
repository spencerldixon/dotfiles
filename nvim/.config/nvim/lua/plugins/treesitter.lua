return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'bash',
        'c',
        'css',
        'diff',
        'html',
        'htmldjango',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'python',
        'ruby',
        'terraform',
        'toml',
        'typescript',
        'vim',
        'vimdoc',
      }
      -- Installs missing parsers asynchronously
      require('nvim-treesitter').install(parsers)

      -- main branch no longer auto-enables highlighting
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
