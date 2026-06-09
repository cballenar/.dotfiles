# XDG Base Directory variables
export XDG_CONFIG_HOME="$HOME/.config"

# Use XDG directory for ddev's configuration
export DDEV_GLOBAL_CONFIG_DIR="$XDG_CONFIG_HOME/ddev"

# Base PATH additions
export PATH=~/.local/bin:$PATH

# Rust Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Lando
[ -d "$HOME/.lando/bin" ] && export PATH="$HOME/.lando/bin${PATH+:$PATH}"

# Bun
if [ -d "$HOME/.bun/bin" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# Ollama Host
export OLLAMA_HOST=0.0.0.0:11434

# Third-party tools PATH additions
export PATH="$PATH:/Users/cballenar/.lmstudio/bin"
export PATH="/Users/cballenar/.antigravity/antigravity/bin:$PATH"
export PATH="/Users/cballenar/.antigravity-ide/antigravity-ide/bin:$PATH"
