# Neovim Keymap Reference

Custom keybindings for Neovim using LazyVim with extras.

## Mode Legend

| Abbrev | Mode |
|--------|------|
| n | Normal |
| v | Visual |
| i | Insert |
| o | Operator-pending |
| c | Command |

---

## LSP Navigation

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition (Snacks picker) |
| `gD` | n | Go to declaration |
| `gt` | n | Go to type definition |
| `gi` | n | Go to implementation |
| `gr` | n | Go to references |
| `K` | n | Hover documentation |
| `<C-k>` | n | Signature help |
| `]d` | n | Next diagnostic |
| `[d` | n | Previous diagnostic |
| `]e` | n | Next error |
| `[e` | n | Previous error |
| `]w` | n | Next warning |
| `[w` | n | Previous warning |

## LSP Actions

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ca` | n, v | Code action |
| `<D-.>` | n, v | Code action (macOS Cmd+.) |
| `<leader>rn` | n | Rename symbol |
| `<leader>cf` | n | Format (LazyVim) |
| `<leader>f` | n | Format (custom) |
| `<leader>cd` | n | Line diagnostics |

## Workspace

| Key | Mode | Action |
|-----|------|--------|
| `<leader>wa` | n | Add workspace folder |
| `<leader>wr` | n | Remove workspace folder |
| `<leader>wl` | n | List workspace folders |

---

## Java (nvim-jdtls)

*Only available in Java files*

| Key | Mode | Action |
|-----|------|--------|
| `<leader>jb` | n | Show bytecode |
| `<leader>jc` | n | Compile |
| `<leader>jC` | n | Compile (full rebuild) |
| `<leader>jr` | n | Set runtime (switch JDK) |
| `<leader>js` | n | Open Jshell REPL |
| `<leader>jR` | n | Restart LSP |

---

## Debugging (DAP)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>dc` | n | Continue / Start |
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dB` | n | Breakpoint condition |
| `<leader>da` | n | Run with args |
| `<leader>dC` | n | Run to cursor |
| `<leader>dg` | n | Go to line (no execute) |
| `<leader>di` | n | Step into |
| `<leader>do` | n | Step out |
| `<leader>dO` | n | Step over |
| `<leader>dj` | n | Down (stack frame) |
| `<leader>dk` | n | Up (stack frame) |
| `<leader>dl` | n | Run last |
| `<leader>dP` | n | Pause |
| `<leader>dr` | n | Toggle REPL |
| `<leader>ds` | n | Session |
| `<leader>dt` | n | Terminate |
| `<leader>dw` | n | Widgets |
| `<leader>du` | n | DAP UI |
| `<leader>de` | n | Eval |

---

## Testing (Neotest)

*Remapped from `<leader>t` to `<leader>T`*

| Key | Mode | Action |
|-----|------|--------|
| `<leader>TT` | n | Run file |
| `<leader>Tr` | n | Run nearest |
| `<leader>Tl` | n | Run last |
| `<leader>Ts` | n | Toggle summary |
| `<leader>To` | n | Show output |
| `<leader>TO` | n | Toggle output panel |
| `<leader>TS` | n | Stop |
| `<leader>Tw` | n | Toggle watch |
| `<leader>Td` | n | Debug nearest |
| `<leader>Ta` | n | Attach to test |

---

## Swift/Xcode (xcodebuild.nvim)

*Only available in Swift files*

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Xb` | n | Xcode build |
| `<leader>Xr` | n | Xcode build & run |
| `<leader>Xt` | n | Xcode test |
| `<leader>XT` | n | Xcode test target |
| `<leader>Xd` | n | Select device |
| `<leader>Xp` | n | Select scheme |
| `<leader>Xl` | n | Toggle logs |
| `<leader>Xc` | n | Toggle coverage |

---

## File Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Buffers |
| `<leader>fr` | n | Recent files |
| `<leader>/` | n | Grep (root dir) |
| `<leader>e` | n | Explorer (Neotree) |
| `<leader>E` | n | Explorer (cwd) |

## Buffer Management

| Key | Mode | Action |
|-----|------|--------|
| `<S-h>` | n | Previous buffer |
| `<S-l>` | n | Next buffer |
| `[b` | n | Previous buffer |
| `]b` | n | Next buffer |
| `<leader>bb` | n | Switch to other buffer |
| `<leader>bd` | n | Delete buffer |
| `<leader>bo` | n | Delete other buffers |
| `<leader>bD` | n | Delete buffer and window |
| `:BD` | c | Delete buffer (preserve layout) |

## Window Management

| Key | Mode | Action |
|-----|------|--------|
| `<C-h>` | n | Go to left window |
| `<C-j>` | n | Go to lower window |
| `<C-k>` | n | Go to upper window |
| `<C-l>` | n | Go to right window |
| `<C-Up>` | n | Increase window height |
| `<C-Down>` | n | Decrease window height |
| `<C-Left>` | n | Decrease window width |
| `<C-Right>` | n | Increase window width |
| `<leader>-` | n | Split below |
| `<leader>\|` | n | Split right |
| `<leader>wd` | n | Delete window |
| `<leader>wm` | n | Toggle zoom |

## Tab Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader><tab><tab>` | n | New tab |
| `<leader><tab>d` | n | Close tab |
| `<leader><tab>l` | n | Last tab |
| `<leader><tab>f` | n | First tab |
| `<leader><tab>]` | n | Next tab |
| `<leader><tab>[` | n | Previous tab |
| `<leader><tab>o` | n | Close other tabs |

---

## Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gg` | n | Lazygit (root dir) |
| `<leader>gG` | n | Lazygit (cwd) |
| `<leader>gb` | n | Git blame line |
| `<leader>gB` | n | Git browse (open) |
| `<leader>gf` | n | Git file history |
| `<leader>gl` | n | Git log |
| `<leader>gL` | n | Git log (cwd) |
| `<leader>gY` | n | Git browse (copy URL) |

---

## Search & Replace

| Key | Mode | Action |
|-----|------|--------|
| `<leader>sr` | n | Search and replace (Grug-far) |
| `s` | n, v, o | Flash jump |
| `S` | n | Flash treesitter |
| `r` | o | Remote flash |
| `R` | o, v | Treesitter search |
| `<C-s>` | c | Toggle flash search |

---

## Terminal

| Key | Mode | Action |
|-----|------|--------|
| `<C-t>` | n | Toggle terminal |
| `` <C-`> `` | n | Toggle terminal |
| `<leader>ft` | n | Terminal (root dir) |
| `<leader>fT` | n | Terminal (cwd) |
| `<C-/>` | n | Terminal (root dir) |

---

## AI (Claude Code)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ac` | n | Toggle Claude |
| `<leader>af` | n | Focus Claude |
| `<leader>ar` | n | Resume Claude |
| `<leader>aC` | n | Continue Claude |
| `<leader>ab` | n | Add current buffer |
| `<leader>as` | v | Send selection to Claude |
| `<leader>aa` | n | Accept diff |
| `<leader>ad` | n | Deny diff |

---

## REST Client (kulala.nvim)

*Only available in HTTP files*

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Rs` | n | Send request |
| `<leader>Rr` | n | Replay last request |
| `<leader>Rb` | n | Open scratchpad |
| `<leader>Rc` | n | Copy as cURL |
| `<leader>RC` | n | Paste from cURL |
| `<leader>Re` | n | Set environment |
| `<leader>Rg` | n | Download GraphQL schema |
| `<leader>Ri` | n | Inspect request |
| `<leader>Rn` | n | Next request |
| `<leader>Rp` | n | Previous request |
| `<leader>Rq` | n | Close window |
| `<leader>RS` | n | Show stats |
| `<leader>Rt` | n | Toggle headers/body |

---

## Overseer (Task Runner)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ow` | n | Task list |
| `<leader>oo` | n | Run task |
| `<leader>oq` | n | Action recent task |
| `<leader>oi` | n | Overseer info |
| `<leader>ob` | n | Task builder |
| `<leader>ot` | n | Task action |
| `<leader>oc` | n | Clear cache |

---

## Toggles & UI

| Key | Mode | Action |
|-----|------|--------|
| `<leader>uf` | n | Toggle format on save |
| `<leader>uF` | n | Toggle format on save (buffer) |
| `<leader>us` | n | Toggle spelling |
| `<leader>uw` | n | Toggle wrap |
| `<leader>ul` | n | Toggle line numbers |
| `<leader>uL` | n | Toggle relative numbers |
| `<leader>ud` | n | Toggle diagnostics |
| `<leader>uc` | n | Toggle conceal |
| `<leader>uh` | n | Toggle inlay hints |
| `<leader>uT` | n | Toggle treesitter |
| `<leader>ub` | n | Toggle dark background |
| `<leader>uz` | n | Toggle zen mode |
| `<leader>ur` | n | Redraw / clear hlsearch |

---

## Utilities

| Key | Mode | Action |
|-----|------|--------|
| `<leader>l` | n | Lazy (plugin manager) |
| `<leader>L` | n | LazyVim changelog |
| `<leader>ma` | n | Mason (LSP installer) |
| `<leader>fn` | n | New file |
| `<leader>xl` | n | Location list |
| `<leader>xq` | n | Quickfix list |
| `[q` | n | Previous quickfix |
| `]q` | n | Next quickfix |
| `<leader>qq` | n | Quit all |
| `<leader>ui` | n | Inspect position |
| `<leader>uI` | n | Inspect tree |
| `<leader>?` | n | Buffer keymaps (which-key) |

---

## Editing

| Key | Mode | Action |
|-----|------|--------|
| `<` | v | Indent left (keep selection) |
| `>` | v | Indent right (keep selection) |
| `<A-j>` | n, i, v | Move line down |
| `<A-k>` | n, i, v | Move line up |
| `gco` | n | Add comment below |
| `gcO` | n | Add comment above |
| `gc` | n, v | Toggle comment |
| `<C-s>` | n, i | Save file |

## Surround (mini.surround)

| Key | Mode | Action |
|-----|------|--------|
| `gsa` | n, v | Add surrounding |
| `gsd` | n | Delete surrounding |
| `gsr` | n | Replace surrounding |
| `gsf` | n | Find right surrounding |
| `gsF` | n | Find left surrounding |
| `gsh` | n | Highlight surrounding |
| `gsn` | n | Update n_lines |

## Completion (blink.cmp)

| Key | Mode | Action |
|-----|------|--------|
| `<Tab>` | i | Accept completion |
| `<C-Space>` | i | Toggle completion menu |
| `<C-n>` | i | Next item |
| `<C-p>` | i | Previous item |

---

## Neotree Mappings

*Inside Neotree window*

| Key | Action |
|-----|--------|
| `%` | Add file |
| `d` | Add directory |
| `D` | Delete |
| `R` | Rename |
| `r` | Refresh |

---

## Custom Commands

| Command | Action |
|---------|--------|
| `:E` | Open Neotree |
| `:BD` | Delete buffer (preserve window layout) |
| `:Q` | Safe quit (checks JDTLS indexing) |
| `:Qa` | Safe quit all |
| `:Wq` | Safe write and quit |
| `:Wqa` | Safe write and quit all |
