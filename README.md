# nvim-config

## Auto Configure Install

```sh
source <(curl -s https://raw.githubusercontent.com/JamesChung/nvim-config/main/setup.sh)
```

## vim-plug

```sh
https://github.com/junegunn/vim-plug
```

## CoC

> Common LSPs

```vim
:CocInstall coc-json coc-sh coc-clangd coc-git coc-html coc-lua coc-tsserver coc-eslint coc-styled-components coc-markdownlint coc-pyright
```

### Handy Information

`ctrl + w + w` swaps between windows. This is handy when using `shift + k` to look at documentation with CoC LSP.

## Treesitter

```vim
:TSInstall bash c cpp css go hcl html javascript json lua make python regex rust sql toml tsx typescript yaml zig
```

