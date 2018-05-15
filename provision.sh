#!/usr/bin/env bash

set -o errexit
set -o pipefail

user=$(id -un)
group=staff
basename = $0

#
# Execute commands as the superuser
#
sudo --validate

#
# Install brew
#
which -s brew
if [[ $? != 0 ]] ; then
	echo "Homebrew not installed, installing now..."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew install caskroom/cask/brew-cask
fi

echo "Brew updating"
brew update
brew bundle --file=modules/Brewfile
brew doctor
echo "Brew update completed"

#
# Create symbolic links to Git config files
#
ln ./modules/git/.gitconfig ~/.gitconfig
ln ./modules/git/.gitignore-global ~/.gitignore-global

#
# Install Git pair program (TEAM WORKSTATION ONLY)
#
#gem install pivotal_git_scripts
#echo "Git pair installed"
#ln ./modules/git/.pairs ~/.pairs

#
# Start docker containers
#
echo "Starting docker containers"
if [[ $(docker ps -a -q) == 0 ]] ; then
    docker kill $(docker ps -a -q)
fi
docker-compose -f modules/docker-compose.yml up &

#
# Set Zsh as default shell
#
chsh -s $(which zsh)
zsh -f
