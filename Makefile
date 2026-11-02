PACKAGES := tmux ghostty zsh colima pnpm
STOW_FLAGS := --target=$(HOME) --no-folding
FONT_DIR := fonts
DIST := $(HOME)/Desktop/dotfiles.zip

.PHONY: bootstrap install uninstall brew brew-dump dist omz tpm nvim fonts foundry gcloud $(PACKAGES)

bootstrap: brew install omz tpm nvim fonts foundry gcloud

install: $(PACKAGES)

uninstall:
	stow -D $(STOW_FLAGS) $(PACKAGES)

brew:
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
	echo "$$found" | while IFS= read -r f; do cp -v "$$f" $(HOME)/Library/Fonts/; done

gcloud:
	gcloud components install gke-gcloud-auth-plugin

foundry:
	curl -L https://foundry.paradigm.xyz | bash && $(HOME)/.foundry/bin/foundryup

$(PACKAGES):
	stow $(STOW_FLAGS) $@
