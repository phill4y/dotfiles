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

echo "Configure dotfiles using dotbot.."
if [ -f "install.conf.yaml" ]; then
    $DOTBOT_BIN_DIR -c install.conf.yaml
else
    echo "Could not find 'install.conf.yaml' or 'install.conf.json' for dotbot configuration."
fi

echo "Installing zsh plugins.."

# Install oh my zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    (RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")

    # Check the exit status
    if [ $? -ne 0 ]; then
        echo "Oh My Zsh installation failed!"
        echo "Try and run the following command manually and then rerun the install script!"
        echo 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
        exit 1
    fi

    # Remove and replace
    rm ~/.zshrc
    mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
else
    echo "oh-my-zsh already installed"
fi

# Install plugins
echo "Installing oh-my-zsh plugins..."
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k/gitstatus/install

echo "Dotfiles setup completed!"
