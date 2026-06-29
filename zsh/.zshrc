# Global Aliases (Meant to work even in dumb environments)
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

# Early Exits (Must be first to prevent unnecessary execution)
# Exit if the terminal is 'dumb' (e.g., Raycast).
if [ -z "$TERM" ] || [ "$TERM" = "dumb" ]; then
  return
fi

# Terminal Multiplexer Auto-start
# Auto-start tmux only over SSH (local Ghostty handles its own tmux startup)
if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "zed" ]] && [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
  tmux attach -t main || tmux new -s main
fi

# Powerlevel10k Instant Prompt
# Must go after initialization that requires user input, but before everything else.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zsh Environment Variables & History
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export ZSH="/Users/cballenar/.oh-my-zsh"
export ZSH_TMUX_CONFIG="$XDG_CONFIG_HOME/tmux/tmux.conf"

ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_MAGIC_FUNCTIONS="true"

HISTSIZE=99999
HISTFILESIZE=99999
HIST_STAMPS="yyyy-mm-dd"

# Oh-My-Zsh Initialization
plugins=(git gh thefuck fzf zsh-autosuggestions zsh-syntax-highlighting you-should-use)
source $ZSH/oh-my-zsh.sh

# Prompt Customization (Must be last UI modification)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Ends Zsh Customization
# ==============================================================================

# configure nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/cballenar/bin/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/cballenar/bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/cballenar/bin/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/cballenar/bin/google-cloud-sdk/completion.zsh.inc'; fi

# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/cballenar/.zsh/completions:"* ]]; then export FPATH="/Users/cballenar/.zsh/completions:$FPATH"; fi

# bun completions
[ -s "/Users/cballenar/.bun/_bun" ] && source "/Users/cballenar/.bun/_bun"

# Deno
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# Initialize zsh completions (added by deno install script)
autoload -Uz compinit
compinit

# DDEV Docker Check
# This function checks if Docker is running before executing a `ddev` command.
# If Docker is not running, it attempts to start Docker and waits for it to be ready.
# If no .ddev folder is found in the current directory, it checks for cms/.ddev and runs the command from there.
if command -v ddev >/dev/null 2>&1; then
  function ddev() {
    if ! docker info >/dev/null 2>&1; then
      echo "Docker is not running. Starting Docker..."
      open -a Docker
      sleep 5
    fi

    # Check if .ddev exists in current directory
    if [ -d ".ddev" ]; then
      command ddev "$@"
    elif [ -d "cms/.ddev" ]; then
      echo "Running DDEV command from cms/ directory..."
      (cd cms && command ddev "$@")
    else
      command ddev "$@"
    fi
  }
fi
