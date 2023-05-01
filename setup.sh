#!/bin/bash

if [ -x "$(command -v brew)" ]; then
    brew install neovim
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install neovim
fi

# Install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if [ ! -d "$HOME/.config/nvim" ]; then
    mkdir -p "$HOME/.config/nvim"
fi

if [ -x "$(command -v git)" ]; then
    git clone https://github.com/JamesChung/nvim-config.git "$HOME/.config/nvim"
else
    echo "You don't have git installed."
    exit 1
fi

nvim -c PlugInstall | CocInstall coc-json coc-sh coc-clangd coc-go coc-git coc-html coc-tsserver coc-eslint coc-styled-components coc-markdownlint coc-pyright coc-rust-analyzer coc-zig | TSInstall bash c cpp css go hcl html javascript json lua make python regex rust sql toml tsx typescript yaml zig
