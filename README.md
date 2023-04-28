# nvim-config

## Auto Configure Install

```sh
bash <(curl -s https://github.com/JamesChung/nvim-config/setup.sh)
```

## vim-plug

```sh
https://github.com/junegunn/vim-plug
```

## CoC

> Common LSPs

```vim
:CocInstall coc-json coc-sh coc-clangd coc-go coc-git coc-html coc-tsserver coc-markdownlint coc-pyright coc-rust-analyzer coc-zig
```

> Handy Info:

`ctrl + w + w` swaps between windows. This is handy when using `shift + k` to look at documentation with CoC LSP.

## Treesitter

```vim
:TSInstall bash c cpp css go hcl html javascript json lua make python regex rust sql toml tsx typescript yaml zig
```

