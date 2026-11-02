PACKAGES := tmux ghostty zsh colima pnpm
STOW_FLAGS := --target=$(HOME) --no-folding

.PHONY: bootstrap install uninstall brew brew-dump omz tpm nvim foundry gcloud $(PACKAGES)

bootstrap: brew omz install tpm nvim foundry gcloud

install: $(PACKAGES)

uninstall:
	stow -D $(STOW_FLAGS) $(PACKAGES)

brew:
	brew bundle --file=Brewfile

brew-dump:
	brew bundle dump --file=Brewfile --force

omz:
	test -d $(HOME)/.oh-my-zsh || \
		KEEP_ZSHRC=yes sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

tpm:
	test -d $(HOME)/.tmux/plugins/tpm || \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm

nvim:
	test -d $(HOME)/.config/nvim || \
		git clone git@github.com:fp-crypto/nvim-config.git $(HOME)/.config/nvim

gcloud:
	gcloud components install gke-gcloud-auth-plugin

foundry:
	curl -L https://foundry.paradigm.xyz | bash && $(HOME)/.foundry/bin/foundryup

$(PACKAGES):
	stow $(STOW_FLAGS) $@
