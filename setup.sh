#!/bin/bash

if [ ! -x "$(command -v brew)" ]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)
            (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> $HOME/.profile
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            ;;
        Darwin*)
            # TODO: Fill this in later
            ;;
    esac
fi

brew install neovim node terraform-ls

if [ -x "$(command -v nvim)" ]; then
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
    nvim -c 'PlugInstall | PlugUpdate'
else
    echo "nvim not installed"
    exit 1
fi

echo 'Install LSPs:'
echo ':CocInstall coc-json coc-sh coc-clangd coc-go coc-git coc-html coc-tsserver coc-eslint coc-styled-components coc-markdownlint coc-pyright coc-rust-analyzer coc-zig'
echo 'Install Treesitter language settings:'
echo ':TSInstall bash c cpp css go hcl html javascript json lua make python regex rust sql toml tsx typescript yaml zig'

