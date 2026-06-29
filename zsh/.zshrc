# Global Aliases (Meant to work even in dumb environments)
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

# Early Exits (Must be first to prevent unnecessary execution)
# Exit if the terminal is 'dumb' (e.g., Raycast).
if [ -z "$TERM" ] || [ "$TERM" = "dumb" ]; then
  return
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

# Terminal Multiplexer Auto-start
# Auto-start tmux over SSH, or locally in IDEs (local Ghostty handles its own tmux startup)
if [[ -z "$TMUX" ]]; then
  if [[ "$TERM_PROGRAM" == "vscode" || "$TERM_PROGRAM" == "zed" ]]; then
    # IDEs: Create a unique session tied to the current project directory.
    # $PWD:t gets the basename of the current directory, and we replace periods/colons with underscores.
    SESSION_NAME="${${PWD:t}//[.:]/_}"
    tmux attach -t "$SESSION_NAME" || tmux new -s "$SESSION_NAME"
  elif [[ -n "$SSH_CONNECTION" ]]; then
    # SSH: Default to the agnostic 'main' session.
    tmux attach -t main || tmux new -s main
  fi
fi

# Powerlevel10k Instant Prompt
# Must go after initialization that requires user input, but before everything else.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

    # Detect if we are in the root of a bare git repository with a "current" worktree branch
    if [ "$(git rev-parse --is-bare-repository 2>/dev/null)" = "true" ] && [ -d "current" ]; then
      echo "Detected bare repository root. Moving to 'current' worktree..."
      cd current || return 1
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
