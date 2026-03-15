function tmux-quit-nvim() {
    local failed_panes=()
    local success_count=0
    
    # Find all panes running nvim
    local nvim_panes=($(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}" | grep -E "\s(nvim|vim)$" | cut -d' ' -f1))
    
    if [[ ${#nvim_panes[@]} -eq 0 ]]; then
        echo "No neovim sessions found in tmux"
        return 0
    fi
    
    echo "Found ${#nvim_panes[@]} neovim session(s):"
    
    for pane in $nvim_panes; do
        echo "  Sending :qa to $pane"
        
        # Send the quit command
        tmux send-keys -t "$pane" ':qa' Enter
        
        # Brief pause to let nvim process the command
        sleep 0.2
        
        # Check if nvim is still running
        local current_cmd=$(tmux list-panes -t "$pane" -F "#{pane_current_command}" 2>/dev/null)
        
        if [[ "$current_cmd" =~ (nvim|vim) ]]; then
            failed_panes+=("$pane")
        else
            ((success_count++))
        fi
    done
    
    echo "\nResults:"
    echo "  Successfully quit: $success_count"
    
    if [[ ${#failed_panes[@]} -gt 0 ]]; then
        echo "  Failed to quit: ${#failed_panes[@]}"
        echo "  Failed panes: ${failed_panes[*]}"
        echo "  (These may have unsaved changes - use :qa\! to force quit)"
        return 1
    else
        echo "  All neovim sessions quit successfully\!"
        return 0
    fi
}
