#!/bin/bash

if [ -x "$(command -v brew)" ]; then
    brew install neovim
else
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
    tar xzf nvim-macos.tar.gz
    ./nvim-macos/bin/nvim
fi

# Install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if [ ! -d "$HOME/.config/nvim" ]; then
    mkdir -p "$HOME/.config.nvim"
fi

if [ "$(command -v git)" ]; then
    git clone https://github.com/JamesChung/nvim-config.git "$HOME/.config/nvim"
else
    echo "You don't have git installed."
    exit 1
fi

