# dotfiles

macOS setup managed with [GNU Stow](https://www.gnu.org/software/stow/) and a
[Brewfile](Brewfile).

## Bootstrap a new machine

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:fp-crypto/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
make brew       # install everything in the Brewfile
make install    # stow every package into $HOME
make foundry    # forge, cast, anvil via foundryup
make gcloud     # gke-gcloud-auth-plugin, needed by kubectl for GKE clusters
```

## Packages

Each top-level directory is a stow package mirroring `$HOME`.

| Package  | Installs                                                        |
| -------- | --------------------------------------------------------------- |
| `zsh`    | `~/.zshrc` and helpers in `~/.config/zsh/`                      |
| `tmux`   | `~/.tmux.conf` (TokyoNight theme, tpm plugins)                  |
| `ghostty`| `~/.config/ghostty/config` (tmux keybinds under cmd)            |
| `colima` | `~/.colima/_templates/default.yaml`, used when a profile is created |
| `pnpm`   | `~/Library/Preferences/pnpm/config.yaml` (release-age and trust-policy hardening) |

Stow runs with `--no-folding`, so only files are symlinked and directories like
`~/.colima` stay real.

Machine-specific secrets go in `~/.zshrc.local`, which `.zshrc` sources if present
and git ignores.

## Not covered by brew

These need a manual step after `make install`.

- **oh-my-zsh**: `.zshrc` expects it at `~/.oh-my-zsh`.
  `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- **tpm**: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`,
  then `prefix + I` inside tmux.
- **neovim config**: lives in its own repo.
  `git clone git@github.com:fp-crypto/nvim-config.git ~/.config/nvim`
- **Font**: Ghostty is set to `Consolas NF`, a Nerd Font patch of Microsoft's
  Consolas. The font is proprietary and not redistributable, so copy the four
  `Consolas * Nerd Font Complete Mono Windows Compatible.ttf` files into
  `~/Library/Fonts` from a backup. `brew install --cask font-cascadia-code-nf`
  is the closest open alternative if you'd rather change `font-family`.
- **colima**: `colima start` creates the VM from the stowed template.
  Then link buildx: `mkdir -p ~/.docker/cli-plugins && ln -sfn $(brew --prefix)/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx`
- **Claude Code**: installed from the `claude-code@latest` cask.
  `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` in `.zshrc` lets it run
  `brew upgrade` on its own. If a native install exists, remove it so the two
  don't conflict: `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude`.

## Maintenance

- `make brew-dump` rewrites the Brewfile from what's installed. Review the diff
  before committing, since it will pull in every leaf package on the machine.
- `make uninstall` removes all stowed symlinks.
