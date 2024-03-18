# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set Config Home
# Shouldn't this be already set? Is it a macOS thing?
export XDG_CONFIG_HOME="$HOME/.config"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/cballenar/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
HIST_STAMPS="yyyy-mm-dd"

HISTSIZE=99999
HISTFILESIZE=99999

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git gh thefuck fzf zsh-bat tmux zsh-autosuggestions zsh-syntax-highlighting you-should-use)

export ZSH_TMUX_CONFIG="$XDG_CONFIG_HOME/tmux/tmux.conf"
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Ends Zsh Customization
# ==============================================================================

# configure nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/cballenar/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/cballenar/google-cloud-sdk/path.zsh.inc'; fi


# The next line enables shell command completion for gcloud.
if [ -f '/Users/cballenar/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/cballenar/google-cloud-sdk/completion.zsh.inc'; fi


# Docker Desktop
source /Users/cballenar/.docker/init-zsh.sh || true # Added by Docker Desktop
