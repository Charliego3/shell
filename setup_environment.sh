#!/usr/bin/env bash

# This script is used to initialize a new computer so
# that it always uses its own specific software and environment

BASE="\033["
RESET="${BASE}0m"
BOLD="${BASE}1;"

GREEN="${BOLD}32m"
YELLOW="${BOLD}33m"
MAGENTA="${BOLD}35m"
WHITE="${BOLD}37m"
BRIGHT_BLACK_GRAY="${BOLD}90m"

. envrc.sh

IS_MAC_OS=false
LINUX_ACTION=""
BASH_PATH=$(command -v bash)
ZSHRC=$PROMPT
NVIM_RC=""
ZSH_ALIAS=""

# shellcheck disable=SC2154
function append() {
	var=$1
	newLine=$3
	oldValue=${!var}
	newValue=""
	if [[ $oldValue == "" ]]; then
		newValue="$2"
	elif [[ $newLine == "true" ]]; then
		newValue="${oldValue}\n\n$2"
	else
		newValue="${oldValue}\n$2"
	fi
	echo -e "$newValue"
}

function warnEcho() {
	echo -e "⚠️  ${YELLOW}$1${RESET}"
}

function beerEcho() {
	echo -e "🍻 ${GREEN}$1${RESET}"
}

# check dir is exists then mkdir "$1"
function dir_mk() {
	if [[ ! -e $1 || ! -d $1 ]]; then
		mkdir -p "$1"
		beerEcho "$1 is created"
	else
		warnEcho "$1 is exists"
	fi
}

# check command line program is exists
function command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# check OS type
function checkOS() {
	local macOS="Darwin"
	local linux='Linux'
	os=$(uname -a)
	if [[ $os =~ $macOS ]]; then
		IS_MAC_OS=true
	elif [[ $os =~ $linux ]]; then
		echo "GNU/Linux操作系统"
		source /etc/os-release
		case $ID in
		debian | ubuntu | devuan)
			LINUX_ACTION="apt-get"
			;;
		centos | fedora | rhel)
			LINUX_ACTION="yum"
			if test "$(echo "$VERSION_ID >= 22" | bc)" -ne 0; then
				LINUX_ACTION="dnf"
			fi
			;;
		*)
			exit 1
			;;
		esac
	fi
}

function ask() {
	echo -e -n "❓ ${MAGENTA}$1 ${WHITE}(y/N) ${BRIGHT_BLACK_GRAY}[default: y]${RESET} "
	read -r ans
	answer "$ans" "$2"
}

# answer for ask, use $? == 1 to compare
function answer() {
	local chose="$2"
	if [[ ! $1 == "y" && ! $1 == "Y" && ! $1 == "" ]]; then
		if [[ $chose == "" ]]; then
			chose="No"
		fi
		warnEcho "You chose don't $chose"
		return 0
	fi
	
	beerEcho "You chose $chose"
	return 1
}

# create the dir loop
function mkdirs() {
	# shellcheck disable=SC2206
	local DIRS=($2)
	for key in "${DIRS[@]}"; do
		dir_mk "$1/$key"
	done
}

checkOS

# check git is installed
if ! $IS_MAC_OS && ! command_exists git; then
	sudo $LINUX_ACTION install -y git
fi

# xcode-select --install command line tools
if [[ $IS_MAC_OS ]]; then
	if ! xcode-select -p &>/dev/null; then
		xcode-select --install
		result=$?
		if [[ $result == 0 ]]; then
			warnEcho "Waiting for xcode-select command line tools installed, then rerun this script"
			exit 1
		fi
	fi
fi

# check curl is installed
if ! $IS_MAC_OS && ! command_exists curl; then
	sudo $LINUX_ACTION install -y curl
fi

# install brew
if ! command_exists brew; then
	$BASH_PATH -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	brew tap homebrew/cask
	ask "Do you want to not update homebrew every time in the future?"
	if [[ $? == 1 ]]; then
		# set `export HOMEBREW_NO_AUTO_UPDATE=0` to `.zshrc` AND `.bashrc` profile
		echo "export HOMEBREW_NO_AUTO_UPDATE=0" >>"$HOME"/.bash_profile
		ZSHRC=$(append ZSHRC "# 设置homebrew执行时不自动更新\nexport HOMEBREW_NO_AUTO_UPDATE=0")
	fi
fi

# check homebrew/cask
HOMEBREW_CASK_DIR="/usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask"
if [[ ! -e $HOMEBREW_CASK_DIR || ! -d $HOMEBREW_CASK_DIR ]]; then
	brew tap homebrew/cask
fi

# create dev dir if not exists
DEV_DIR="$HOME/dev"
DIRS=("bin" "environment" "go" "java" ".config")
mkdirs "$DEV_DIR" "${DIRS[*]}"

CONFIG_DIR="${HOME}/.config"
SUB_CONFIG_DIRS=("nvim" "zsh")
mkdirs "$CONFIG_DIR" "${SUB_CONFIG_DIRS[*]}"

# do not update homebrew for this times
export HOMEBREW_NO_AUTO_UPDATE=0

# install zsh
if ! command_exists zsh; then
	brew install zsh
	# setting zsh to default shell
	chsh -s "$(command -v zsh)"
fi

# start install program
install=("trash" "zsh-syntax-highlighting" "zsh-autosuggestions" "zsh-completions" "jq" "go" "lazygit" "nvim" "gping" "telnet" "openjdk")
for formula in "${install[@]}"; do
	if ! command_exists "$formula"; then
		brew install --display-times "$formula"
	else
		brew upgrade "$formula"
	fi
done

LOCAL_APPLICATIONS=("/Applications" "$HOME/Applications" "$HOME/Applications/JetBrains Toolbox")
function caskInstall() {
	# shellcheck disable=SC2206
	local APPLICATIONS=($1)
	for animal in "${APPLICATIONS[@]}"; do
		KEY=${animal%%:*}
		VALUE=${animal#*:}
		FINAL_APP_LOCATION=""
		for dir in "${LOCAL_APPLICATIONS[@]}"; do
			APP_LOCATION="${dir}/${VALUE}"
			if [[ -e "$APP_LOCATION" ]]; then
				FINAL_APP_LOCATION=$APP_LOCATION
				break
			fi
		done

		if [[ $FINAL_APP_LOCATION == "" ]]; then
			brew install cask "$KEY"
		else
			if ! ask "Are you want to reinstall $VALUE?" "install $VALUE"; then
				trash -vy "$FINAL_APP_LOCATION"
				KEY_PATH="$(command -v "$KEY")"
				if [[ "$KEY_PATH" != "" ]]; then
					trash -vy "$KEY"
				fi
				brew reinstall "$KEY"
			fi
		fi
	done
}

# if key is exists then not install
NOT_INSTALL_DIC=("cakebrew:Cakebrew.app" "iina:IINA.app")
caskInstall "${NOT_INSTALL_DIC[*]}"

# TODO intellij-idea:IntelliJ IDEA Ultimate.app 有异常待解决
RE_INSTALL_DIC=("webstorm:WebStorm.app" "intellij-idea:IntelliJ IDEA Ultimate.app" "goland:GoLand.app" "datagrip:DataGrip.app")
caskInstall "${RE_INSTALL_DIC[*]}"

exit 0

# TODO backup old config files
ask "Do you want to backup the current config files?" "backup the current files"
if [[ $? == 1 ]]; then
	echo "Want Backup"
	exit 0
fi

# ZSH_ALIAS: $HOME/.config/zsh/zsh-alias.zsh
ZSH_ALIAS_PATH="$HOME/.config/zsh/zsh-alias.zsh"
if command_exists vim; then
	ZSH_ALIAS=$(append ZSH_ALIAS "alias vim='$(command -v vim)'")
fi
ZSH_ALIAS=$(append ZSH_ALIAS "alias vi='$(command -v nvim)'")
ZSH_ALIAS=$(append ZSH_ALIAS "alias rm='trash'")
ZSH_ALIAS=$(append ZSH_ALIAS "alias c='clear'")
echo "$ZSH_ALIAS" >"$ZSH_ALIAS_PATH"
beerEcho "Successful setting zsh alias: $ZSH_ALIAS_PATH"

# VIMRC: $HOME/.config/nvim/init.vim
NVIM_RC_PATH="$HOME/.config/nvim/init.vim"
NVIM_RC=$(append NVIM_RC "$NVIM_BASIC")
echo "$NVIM_RC" >"$NVIM_RC_PATH"
beerEcho "Successful setting nvim config: $NVIM_RC_PATH"

# end of .zshrc
ZSHRC_PATH="$HOME/.zshrc"
ZSHRC=$(append ZSHRC "$LANG" true)
ZSHRC=$(append ZSHRC "$USER_BIN" true)
ZSHRC=$(append ZSHRC "source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" true)
ZSHRC=$(append ZSHRC "source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh")
ZSHRC=$(append ZSHRC "source $ZSH_ALIAS_PATH")
ZSHRC=$(append ZSHRC "$AUTO_SUGGESTION" true)
#ZSHRC=$(append ZSHRC "source $HOME/.config/zsh/zsh-source.zsh")

# $HOME/.zshrc
echo "$ZSHRC" >"$ZSHRC_PATH"
beerEcho "Successful setting zshrc: $ZSHRC_PATH"
