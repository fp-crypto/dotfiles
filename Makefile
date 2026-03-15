PACKAGES := tmux ghostty zsh
STOW_FLAGS := --target=$(HOME)

.PHONY: install uninstall $(PACKAGES)

install: $(PACKAGES)

uninstall:
	stow -D $(STOW_FLAGS) $(PACKAGES)

$(PACKAGES):
	stow $(STOW_FLAGS) $@
