#!/bin/bash

# Constants
LOCAL_DIR=$HOME/git/dotfiles
REPO_URL="https://github.com/phill4y/dotfiles.git"
DOTBOT_BIN_DIR=$LOCAL_DIR/dotbot/bin/dotbot
OS=$(uname)

# Check if directory exists
if [ ! -d "$LOCAL_DIR" ]; then
    mkdir -p "${LOCAL_DIR}" && \
        git clone ${REPO_URL} "${LOCAL_DIR}"
else
    echo "Directory $LOCAL_DIR already exists."
fi

# Change to the directory
cd "${LOCAL_DIR}" || exit

# Assuming dotbot is included as a submodule in your dotfiles repository
# Initialize and update submodules (for dotbot)
git submodule update --init --recursive
chmod +x "${DOTBOT_BIN_DIR}"

# Set as default (Requires logout)
if [ "$OS" == "Linux" ]; then
    echo "Install zsh on Linux"
    sudo apt-get install zsh
fi

echo "Installing zsh plugins.."

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k/gitstatus/install

# Configure dotfiles using dotbot
if [ -f "install.conf.yaml" ]; then
    DOTBOT_BIN_DIR -c install.conf.yaml
else
    echo "Could not find 'install.conf.yaml' or 'install.conf.json' for dotbot configuration."
fi

# Set as default (Requires logout)
if [ "$OS" == "Linux" ]; then
    echo "Change default shell to zsh for Linux OS, Please logout for changes to take effect"
    chsh -s "$(which zsh)"
fi

echo "Dotfiles setup completed!"
