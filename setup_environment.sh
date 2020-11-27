#!/usr/bin/env bash

# This script is used to initialize a new computer so
# that it always uses its own specific software and environment

Base="\033["
Reset="${Base}0m"
Bold="${Base}1;"

Black="${Bold}30m"
Red="${Bold}31m"
Green="${Bold}32m"
Yellow="${Bold}33m"
Blue="${Bold}34m"
Magenta="${Bold}35m"
Cyan="${Bold}36m"
White="${Bold}37m"
BrightBlack_Gray="${Bold}90m"
BrightRed="${Bold}91m"
BrightGreen="${Bold}92m"
BrightYellow="${Bold}93m"
BrightBlue="${Bold}94m"
BrightMagenta="${Bold}95m"
BrightCyan="${Bold}96m"
BrightWhite="${Bold}97m"

echo "Test Colors Start"
echo -e "${Black}Color: Black${Reset}"
echo -e "${Red}Color: Red${Reset}"
echo -e "${Green}Color: Green${Reset}"
echo -e "${Yellow}Color: Yellow${Reset}"
echo -e "${Blue}Color: Blue${Reset}"
echo -e "${Magenta}Color: Magenta${Reset}"
echo -e "${Cyan}Color: Cyan${Reset}"
echo -e "${White}Color: White${Reset}"
echo -e "${BrightBlack_Gray}Color: BrightBlack_Gray${Reset}"
echo -e "${BrightRed}Color: BrightRed${Reset}"
echo -e "${BrightGreen}Color: BrightGreen${Reset}"
echo -e "${BrightYellow}Color: BrightYellow${Reset}"
echo -e "${BrightBlue}Color: BrightBlue${Reset}"
echo -e "${BrightMagenta}Color: BrightMagenta${Reset}"
echo -e "${BrightCyan}Color: BrightCyan${Reset}"
echo -e "${BrightWhite}Color: BrightWhite${Reset}"
echo "Test Colors End"

. envrc.sh

isMacOS=false
linuxAction=""
bashPath=$(command -v bash)
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
	echo -e "⚠️  ${Yellow}$1${Reset}"
}

function beerEcho() {
	echo -e "🍻 ${Green}$1${Reset}"
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
		isMacOS=true
	elif [[ $os =~ $linux ]]; then
		echo "GNU/Linux操作系统"
		source /etc/os-release
		case $ID in
		debian | ubuntu | devuan)
			linuxAction="apt-get"
			;;
		centos | fedora | rhel)
			linuxAction="yum"
			if test "$(echo "$VERSION_ID >= 22" | bc)" -ne 0; then
				linuxAction="dnf"
			fi
			;;
		*)
			exit 1
			;;
		esac
	fi
}

function ask() {
	echo -e -n "❓ ${Magenta}$1 ${White}(y/N) ${BrightBlack_Gray}[default: y]${Reset} "
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

	if [[ $chose == "" ]]; then
		chose="Yes"
	fi
	beerEcho "You chose $chose"
	return 1
}

# create the dir loop
function mkdirs() {
	# shellcheck disable=SC2206
	local dirs=($2)
	for key in "${dirs[@]}"; do
		dir_mk "$1/$key"
	done
}

function brewInstall() {
	# shellcheck disable=SC2206
	local formulas=($1)
	local isCask=$2
	bi=$(command -v brew)
	for formula in "${formulas[@]}"; do
		if [[ $isCask == true ]]; then
			$bi install --display-times cask "$formula"
		else
			$bi install --display-times "$formula"
		fi
	done
}

checkOS

# check git is installed
if ! $isMacOS && ! command_exists git; then
	sudo $linuxAction install -y git
fi

# xcode-select --install command line tools
if [[ $isMacOS ]]; then
	xcode-select --install
	result=$?
	if [[ $result == 0 ]]; then
		warnEcho "Waiting for xcode-select command line tools installed, then rerun this script"
		exit 1
	fi
fi

# check curl is installed
if ! $isMacOS && ! command_exists curl; then
	sudo $linuxAction install -y curl
fi

# install brew
if ! command_exists brew; then
	$bashPath -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	ask "Do you want to not update homebrew every time in the future?"
	if [[ $? == 1 ]]; then
		# set `export HOMEBREW_NO_AUTO_UPDATE=0` to `.zshrc` AND `.bashrc` profile
		echo "export HOMEBREW_NO_AUTO_UPDATE=0" >>"$HOME"/.bash_profile
		ZSHRC=$(append ZSHRC "# 设置homebrew执行时不自动更新\nexport HOMEBREW_NO_AUTO_UPDATE=0")
	fi
fi

# dev dir
dev_dir="$HOME/dev"
dirs=("bin" "environment" "go" "java" ".config")
mkdirs "$dev_dir" "${dirs[*]}"

config_dir="${HOME}/.config"
sub_config_dirs=("nvim" "zsh")
mkdirs "$config_dir" "${sub_config_dirs[*]}"

if ! command_exists zsh; then 
	brewInstall zsh
	# setting zsh to default shell
	chsh -s "$(command -v zsh)"
fi

# start install program
needInstall=("trash" "zsh-syntax-highlighting" "zsh-autosuggestions" "zsh-completions" "jq" "go" "lazygit" "nvim" "gping")
# do not update homebrew for this times
export HOMEBREW_NO_AUTO_UPDATE=0

brewInstall "${needInstall[*]}"
brewInstall "homebrew/cask/iina" true

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
echo "$ZSH_ALIAS" > "$ZSH_ALIAS_PATH"
beerEcho "Successful setting zsh alias: $ZSH_ALIAS_PATH"

# VIMRC: $HOME/.config/nvim/init.vim
NVIM_RC_PATH="$HOME/.config/nvim/init.vim"
NVIM_RC=$(append NVIM_RC "$NVIM_BASIC")
echo "$NVIM_RC" > "$NVIM_RC_PATH"
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
echo "$ZSHRC" > "$ZSHRC_PATH"
beerEcho "Successful setting zshrc: $ZSHRC_PATH"
