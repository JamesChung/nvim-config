set number relativenumber
set nohls
set incsearch
set wildmode=longest,list
set autoindent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set scrolloff=10
set termguicolors

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
" Core plugins
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-context'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Package manager
Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }

" General Plugins ---------------------------------------------

" Adds tabs for buffers
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
" Toggle a terminal
Plug 'akinsho/toggleterm.nvim', { 'tag': '*' }
" Shows LSP progress information
Plug 'j-hui/fidget.nvim'
" Show and remove trailing whitespace
Plug 'jdhao/whitespace.nvim'
" Highlight indent guides
Plug 'lukas-reineke/indent-blankline.nvim'
" Detailed information errors (Only works with native nvim lsp)
Plug 'folke/trouble.nvim'
" Support for Git
Plug 'tpope/vim-fugitive'
" Support for commenting code
Plug 'tpope/vim-commentary'
" Support for split diff view
Plug 'sindrets/diffview.nvim'
" Shows git blame information to the side
Plug 'f-person/git-blame.nvim'
" File searcher
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
" -------------------------------------------------------------

" Themes ------------------------------------------------------
Plug 'catppuccin/nvim'
Plug 'rose-pine/neovim'
Plug 'olimorris/onedarkpro.nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
" -------------------------------------------------------------
call plug#end()

" Themes
"colorscheme onedark
"colorscheme onelight
"colorscheme onedark_vivid
"colorscheme onedark_dark
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

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Move lines up/down for Mac
nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
inoremap ∆ <Esc>:m .+1<CR>==gi
inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

" Remap space to be leader rather than the default backslash key
map <Space> <Leader>

" Allow for tab completion when coc suggestions are visible
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<Tab>"

" MacOS ToggleTerm binding
autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><C-`> <Cmd>exe v:count1 . "ToggleTerm"<CR>
" By applying the mappings this way you can pass a count to your
" mapping to open a specific window.
" For example: 2<C-`> will open terminal 2
nnoremap <silent><C-`> <Cmd>exe v:count1 . "ToggleTerm"<CR>
inoremap <silent><C-`> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

" General ToggleTerm binding
autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
" By applying the mappings this way you can pass a count to your
" mapping to open a specific window.
" For example: 2<C-t> will open terminal 2
nnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
inoremap <silent><C-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

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

" Additional vim settings in lua
lua require('vim')
