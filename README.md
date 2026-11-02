# dotfiles

macOS setup managed with [GNU Stow](https://www.gnu.org/software/stow/) and a
[Brewfile](Brewfile).

## Bootstrap a new machine

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:fp-crypto/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
make bootstrap
```

`bootstrap` runs these in order, each of which can also be run alone:

| Target    | Does                                                              |
| --------- | ----------------------------------------------------------------- |
| `brew`    | `brew bundle` on the Brewfile                                     |
| `install` | stows every package into `$HOME`                                  |
| `omz`     | installs oh-my-zsh unattended; stows `zsh` first so the installer keeps that `.zshrc` |
| `tpm`     | clones the tmux plugin manager; run `prefix + I` in tmux after    |
| `nvim`    | clones [nvim-config](https://github.com/fp-crypto/nvim-config)    |
| `fonts`   | copies `.ttf`/`.otf` files from `fonts/` into `~/Library/Fonts`   |
| `foundry` | forge, cast, anvil via foundryup                                  |
| `gcloud`  | `gke-gcloud-auth-plugin`, needed by kubectl for GKE clusters      |

The clone targets skip when the directory already exists.

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

These need a manual step after `make bootstrap`.

- **Font**: Ghostty is set to `Consolas NF`, a Nerd Font patch of Microsoft's
  Consolas. The font is proprietary and not redistributable, so it isn't in the
  repo. Drop the four `Consolas * Nerd Font Complete Mono Windows Compatible.ttf`
  files into the gitignored `fonts/` directory before `make bootstrap`, or point
  at them directly: `make fonts FONT_DIR=/path/to/fonts`. The target skips when
  no fonts are found. `brew install --cask font-cascadia-code-nf` is the closest
  open alternative if you'd rather change `font-family`.
- **colima**: `colima start` creates the VM from the stowed template.
  Then link buildx: `mkdir -p ~/.docker/cli-plugins && ln -sfn $(brew --prefix)/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx`
- **Claude Code**: installed from the `claude-code@latest` cask.
  `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` in `.zshrc` lets it run
  `brew upgrade` on its own. If a native install exists, remove it so the two
  don't conflict: `rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude`.

## Moving to a new machine without GitHub access

`make dist` zips the repo, including `.git` and whatever is in `fonts/`, to
`~/Desktop/dotfiles.zip`. Unzip it to `~/dev/dotfiles` on the new machine and
run `make bootstrap`. Override the output path with `make dist DIST=/path/to.zip`.

## Maintenance

- `make brew-dump` rewrites the Brewfile from what's installed. Review the diff
  before committing, since it will pull in every leaf package on the machine.
- `make uninstall` removes all stowed symlinks.
