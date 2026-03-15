# Intercept vim commands typed accidentally in the terminal
# and forward them to the nvim instance in the current tmux window

function _send-to-nvim() {
    local vim_command="$1"

    # Check if we're in tmux
    if [[ -z "$TMUX" ]]; then
        echo "Error: Not in a tmux session"
        return 1
    fi

    # Get the socket path for the current tmux window
    local sock="/tmp/nvimsocket$(tmux display-message -p '#{window_id}')"

    # Check if the socket exists
    if [[ ! -S "$sock" ]]; then
        echo "Error: No nvim instance found for this tmux window"
        echo "  Expected socket: $sock"
        return 1
    fi

    # Send the command to nvim and capture output
    command nvr --servername "$sock" --remote-send "$vim_command"

    # Brief pause to let nvim process
    sleep 0.1

    # Get and display the last message from nvim
    local result=$(command nvr --servername "$sock" --remote-expr "execute('messages')" 2>/dev/null | tail -1)

    if [[ -n "$result" ]]; then
        echo "$result"
    fi
}

# Alias vim commands to forward to nvim
alias ':w'='_send-to-nvim ":w<CR>"'
alias ':q'='_send-to-nvim ":q<CR>"'
alias ':wq'='_send-to-nvim ":wq<CR>"'
alias ':x'='_send-to-nvim ":x<CR>"'
