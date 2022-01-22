set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

function! TwfExit(path)
  function! TwfExitClosure(job_id, data, event) closure
    bd!
    try
      let out = filereadable(a:path) ? readfile(a:path) : []
    finally
      silent! call delete(a:path)
    endtry
    if !empty(out)
      execute 'edit! ' . out[0]
    endif
  endfunction
  return funcref('TwfExitClosure')
endfunction

function! Twf()
  let temp = tempname()
  call termopen('twf ' . @% . ' > ' . temp, { 'on_exit': TwfExit(temp) })
  startinsert
endfunction

nnoremap <silent> ;twf :call Twf()<CR>

" lua <<EOF
" require'nvim-treesitter.configs'.setup {
"   ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
"   ignore_install = {}, -- List of parsers to ignore installing
"   highlight = {
"     enable = true,              -- false will disable the whole extension
"     disable = {},  -- list of language that will be disabled
"     incremental_selection = { enable = true },
"     textobjects = { enable = true },
"   },
" }
" EOF

" NOTE: change theme to auto once installed via .vimrc proper
lua << END
require('lualine').setup {
  options = {
      icons_enabled = true,
      theme = 'onedark',
      -- component_separators = { left = '', right = ''},
      -- section_separators = { left = '', right = ''},
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {'help'},
      always_divide_middle = true,
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'location'},
      lualine_z = {
        {
            'diagnostics',
            sources = {'ale', 'nvim_lsp', 'nvim_diagnostic'},
            sections = {'error', 'warn'},
            symbols = {error = '🕱 ', warn = '⚠ ', info = '🛈 ', hint = '🏄'},
            colored = true,
            always_visible = false,
            update_in_insert = false
        }
      }
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    extensions = {'quickfix', 'fzf'}
}
END

lua << EOF
  require('neorg').setup {
    -- Tell Neorg what modules to load
    load = {
      ["core.defaults"] = {}, -- Load all the default modules
      ["core.norg.concealer"] = {}, -- Allows for use of icons
      ["core.norg.dirman"] = { -- Manage your directories with Neorg
      config = {
        workspaces = {
          my_workspace = "~/neorg"
          }
        }
      }
    },
  }
EOF
