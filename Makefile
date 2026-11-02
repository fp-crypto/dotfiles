PACKAGES := tmux ghostty zsh git colima pnpm
BREW_PREFIX := /opt/homebrew
export PATH := $(BREW_PREFIX)/bin:$(PATH)
STOW_FLAGS := --target=$(HOME) --no-folding
FONT_DIR := fonts
DIST := $(HOME)/Desktop/dotfiles.zip

.PHONY: bootstrap install uninstall homebrew brew brew-dump dist omz tpm nvim fonts foundry gcloud $(PACKAGES)

bootstrap: brew install omz tpm nvim fonts foundry gcloud

install: $(PACKAGES)

uninstall:
	stow -D $(STOW_FLAGS) $(PACKAGES)

homebrew:
	test -x $(BREW_PREFIX)/bin/brew || \
		NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew: homebrew
	brew bundle --file=Brewfile

brew-dump:
	brew bundle dump --file=Brewfile --force

dist:
	rm -f $(DIST)
	cd .. && zip -qr $(DIST) $(notdir $(CURDIR)) -x '*.DS_Store'
	@echo "wrote $(DIST)"; unzip -l $(DIST) | tail -1

omz: zsh
	test -d $(HOME)/.oh-my-zsh || \
		KEEP_ZSHRC=yes sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

tpm:
	test -d $(HOME)/.tmux/plugins/tpm || \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm

nvim:
	test -d $(HOME)/.config/nvim || \
		git clone https://github.com/fp-crypto/nvim-config.git $(HOME)/.config/nvim

fonts:
	@found=$$(find "$(FONT_DIR)" -maxdepth 1 \( -name '*.ttf' -o -name '*.otf' \) 2>/dev/null); \
	if [ -z "$$found" ]; then echo "no fonts in $(FONT_DIR), skipping (set FONT_DIR=/path to override)"; exit 0; fi; \
	mkdir -p $(HOME)/Library/Fonts; \
	set --; \
	while IFS= read -r f; do \
		cp -v "$$f" $(HOME)/Library/Fonts/; \
		set -- "$$@" "$(HOME)/Library/Fonts/$$(basename "$$f")"; \
	done <<< "$$found"; \
	swift scripts/register-fonts.swift "$$@"

gcloud:
	gcloud components install gke-gcloud-auth-plugin

foundry:
	curl -L https://foundry.paradigm.xyz | bash && $(HOME)/.foundry/bin/foundryup

$(PACKAGES):
	stow $(STOW_FLAGS) $@
