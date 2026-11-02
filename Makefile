PACKAGES := tmux ghostty zsh colima pnpm
STOW_FLAGS := --target=$(HOME) --no-folding

.PHONY: install uninstall brew brew-dump foundry gcloud $(PACKAGES)

install: $(PACKAGES)

uninstall:
	stow -D $(STOW_FLAGS) $(PACKAGES)

brew:
	brew bundle --file=Brewfile

brew-dump:
	brew bundle dump --file=Brewfile --force

gcloud:
	gcloud components install gke-gcloud-auth-plugin

foundry:
	curl -L https://foundry.paradigm.xyz | bash && $(HOME)/.foundry/bin/foundryup

$(PACKAGES):
	stow $(STOW_FLAGS) $@
