#!/bin/bash

if [ $commands[brew] ]; then
    brew install neovim
else
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
    tar xzf nvim-macos.tar.gz
    ./nvim-macos/bin/nvim
fi

if [ ! -d "$HOME/.config/nvim" ]; then
    mkdir -p "$HOME/.config.nvim"
fi

if [ $commands[git] ]; then
    git clone https://github.com/JamesChung/nvim-config.git "$HOME/.config/nvim"
else
    echo "You don't have git installed."
    exit 1
fi

