#!/usr/bin/env bash -e

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Setup Finder Commands
# Show Library Folder in Finder
chflags nohidden ~/Library

# Show Hidden Files in Finder
defaults write com.apple.finder AppleShowAllFiles YES

# Show Path Bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show Status Bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Check for Homebrew, and then install it
if test ! "$(which brew)"; then
  echo "Installing homebrew..."
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  echo "Homebrew installed successfully"
else
  echo "Homebrew already installed!"
fi

# Install XCode Command Line Tools
echo 'Checking to see if XCode Command Line Tools are installed...'
brew config

# Updating Homebrew.
echo "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae.
echo "Upgrading Homebrew..."
brew upgrade

# Install iTerm2
echo "Installing iTerm2..."
brew install --cask iterm2

# Update the Terminal
# Install oh-my-zsh
if [[ -z "${ZSH}" ]]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  echo "Need to logout now to start the new SHELL..."
  logout
else
  "$ZSH/tools/upgrade.sh"
fi

# Install Git
echo "Installing ASDF, Curl, Coreutilities, and Git..."
brew install asdf coreutils git curl

# Install GPG Agent and configure it as the primary SSH agent:
brew install gnupg2 pinentry-mac

mkdir -p ~/.gnupg
chown -R $(whoami) ~/.gnupg/
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

cat << EOF > ~/.gnupg/gpg-agent.conf
pinentry-program $(which pinentry-mac)
default-cache-ttl 3600
default-cache-ttl-ssh 3600
max-cache-ttl 7200
max-cache-ttl-ssh 7200
enable-ssh-support
EOF

# Configure zsh plugins:
sed -i -e '/^plugins=/{
h
s/=.*/=(asdf git gpg-agent)/
}
${
x
/^$/{
s//plugins=(asdf git gpg-agent)/
H
}
x
}' ~/.zshrc

# Install Powerline fonts
if [[ ! $(system_profiler SPFontsDataType | grep Powerline) ]]; then
  echo "Installing Powerline fonts..."
  git clone https://github.com/powerline/fonts.git
  cd fonts || exit
  sh -c ./install.sh
  cd ../
  rm -rf fonts
fi

# Install a network scanning tool:
brew install nmap

# Install other useful binaries.
brew install speedtest_cli
brew install vim

# Core casks
brew install --appdir="/Applications" --cask alfred

# Misc casks
brew install --appdir="/Applications" --cask firefox
brew install --appdir="/Applications" --cask 1password
brew install --appdir="/Applications" --cask caffeine

# Remove outdated versions from the cellar.
echo "Running brew cleanup..."
brew cleanup
echo "You're done!"

# Reload zsh:
exec zsh
