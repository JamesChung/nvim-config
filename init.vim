:set number relativenumber
:set nohls
:set incsearch
:set autoindent
:set expandtab
:set wildmode=longest,list
:set tabstop=2
:set softtabstop=2
:set shiftwidth=2
:set scrolloff=10
:set termguicolors

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Plugins
call plug#begin()
" Adds tabs for buffers
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
" Shows LSP progress information
Plug 'j-hui/fidget.nvim'
" Show and remove trailing whitespace
Plug 'jdhao/whitespace.nvim'
" Highlight indent guides
Plug 'lukas-reineke/indent-blankline.nvim'
" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Detailed information errors (Only works with native nvim lsp)
Plug 'folke/trouble.nvim'
" Support for commenting code
Plug 'tpope/vim-commentary'
" Support for split diff view
Plug 'sindrets/diffview.nvim'
" Core plugins
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-context'
" File searcher
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
" Plugin manager
Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }

" Themes
Plug 'catppuccin/nvim'
Plug 'rose-pine/neovim'
Plug 'olimorris/onedarkpro.nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
call plug#end()

" Themes
"colorscheme onedark
"colorscheme onelight
"colorscheme onedark_vivid
"onedark_dark
"colorscheme catppuccin
"colorscheme catppuccin-latte
"colorscheme catppuccin-frappe
"colorscheme catppuccin-macchiato
"colorscheme catppuccin-mocha
"colorscheme rose-pine
colorscheme rose-pine-moon
"colorscheme rose-pine-dawn
"colorscheme tokyonight
"colorscheme tokyonight-night
"colorscheme tokyonight-storm
"colorscheme tokyonight-day
"colorscheme tokyonight-moon

" Remap to move up and down when LSP suggestions popup
imap <C-j> <Down>
imap <C-k> <Up>

" Allow for tab completion when coc suggestions are visible
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<Tab>"

" Use <C-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <C-space> coc#refresh()
else
  inoremap <silent><expr> <C-@> coc#refresh()
endif

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Keybindings
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)
" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Find files using Telescope command-line sugar.
nnoremap <leader>tf <cmd>Telescope find_files<cr>
nnoremap <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <leader>tb <cmd>Telescope buffers<cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)

lua << EOF
vim.opt.list = true
vim.opt.listchars:append "space:⋅"
--vim.opt.listchars:append "eol:↴"

require("trouble").setup {
    position = "right",
}
require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}
require("bufferline").setup {
    options = {
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        themable = true,
        diagnostics = "coc",
        sort_by = 'insert_at_end',
        hover = {
            enabled = true,
            delay = 200,
            reveal = {'close'}
        },
        get_element_icon = function(element)
          local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
          return icon, hl
        end
    }
}
EOF

