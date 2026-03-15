PACKAGES := tmux ghostty zsh
STOW_FLAGS := --target=$(HOME)

.PHONY: install uninstall brew brew-dump $(PACKAGES)

install: $(PACKAGES)

uninstall:
	stow -D $(STOW_FLAGS) $(PACKAGES)

brew:
	brew bundle --file=Brewfile

brew-dump:
	brew bundle dump --file=Brewfile --force

$(PACKAGES):
	stow $(STOW_FLAGS) $@
