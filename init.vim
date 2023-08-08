filetype plugin indent on

set number                  " Show line numbers
set relativenumber          " Relative line numbers
set autoindent              " Enable auto-indenting
set expandtab               " Use spaces instead of tabs
set tabstop=4               " Set tab width to 4 spaces
set softtabstop=4           " Set soft tabstop to 4 spaces
set shiftwidth=4            " Set indentation width to 4 spaces
set nohls
set incsearch
set wildmode=longest,list
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
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-treesitter/playground'
Plug 'mfussenegger/nvim-dap'
Plug 'leoluz/nvim-dap-go'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'VonHeikemen/lsp-zero.nvim', { 'branch': 'v2.x' }

" Package manager
Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }
Plug 'williamboman/mason-lspconfig.nvim'

" General Plugins ---------------------------------------------

" Adds tabs for buffers
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
" Toggle a terminal
Plug 'akinsho/toggleterm.nvim', { 'tag': '*' }
" Performant bi-directional clipboard
Plug 'EtiamNullam/deferred-clipboard.nvim'
" Shows LSP progress information
Plug 'j-hui/fidget.nvim', { 'tag': 'legacy' }
" Show and remove trailing whitespace
Plug 'jdhao/whitespace.nvim'
" Detailed information errors (Only works with native nvim lsp)
Plug 'folke/trouble.nvim'
" Support for Git
Plug 'tpope/vim-fugitive'
" Support for surrounding pairs
Plug 'tpope/vim-surround'
" Support for commenting code
Plug 'tpope/vim-commentary'
" Support for split diff view
Plug 'sindrets/diffview.nvim'
" Shows git blame information to the side
Plug 'f-person/git-blame.nvim'
" Shows git changes for each line(s)
Plug 'lewis6991/gitsigns.nvim'
" File searcher
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
" Scrollbar
Plug 'dstein64/nvim-scrollview'
" Autopair
Plug 'windwp/nvim-autopairs'
" -------------------------------------------------------------

" Themes ------------------------------------------------------
Plug 'catppuccin/nvim'
Plug 'rose-pine/neovim'
Plug 'olimorris/onedarkpro.nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
" -------------------------------------------------------------
call plug#end()

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

" Find files using Telescope command-line sugar.
nnoremap <leader>tf <Cmd>Telescope find_files<CR>
nnoremap <leader>tg <Cmd>Telescope live_grep<CR>
nnoremap <leader>tb <Cmd>Telescope buffers<CR>
nnoremap <leader>th <Cmd>Telescope help_tags<CR>

" General NvimTree toggle binding
nnoremap <leader>nt <Cmd>NvimTreeToggle<CR>

" TroubleToggle
nnoremap <leader>tt <Cmd>TroubleToggle<CR>

" Open/Close Mason menu
nnoremap <leader>ma <Cmd>Mason<CR>

" nvim-dap debugger config
nmap <silent> <leader>dp :lua require('dap').toggle_breakpoint()<CR>
nmap <silent> <leader>dc :lua require('dap').continue()<CR>
nmap <silent> <leader>do :lua require('dap').step_over()<CR>
nmap <silent> <leader>di :lua require('dap').step_into()<CR>
nmap <silent> <leader>dr :lua require('dap').repl.open()<CR>
nmap <silent> <leader>dt :lua require('dap-go').debug_test()<CR>

" Additional vim settings in lua
lua require('vim')
