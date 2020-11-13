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

isMacOS=false
isLinuxApt=false
linuxAction=""
bashPath=$(command -v bash)

# check dir is exists then mkdir "$1"
function dir_mk() {
	if [[ ! -e $1 || ! -d $1 ]]; then
		mkdir -p "$1"
	else
		echo "$1 is exists"
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
			isLinuxApt=true
			;;
		centos | fedora | rhel)
			linuxAction="yum"
			isLinuxApt=false
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

# check zsh or install
function install_zsh() {
	if [[ $isMacOS ]]; then
		brew install zsh
	elif [[ ${SHELL##/*/} != "zsh" ]]; then
		if command_exists zsh; then
			echo -e -n "${Cyan}Do you like to use zsh? ${White}(y/N)${Reset}"
			read -rp " " like
			if [[ $like == "y" || $like == "" ]]; then
				echo "Like zsh"
				sudo $linuxAction install zsh
			fi
		else
			# setting
			chsh -s "$(command -v zsh)"
		fi
	fi
}

function mkdirs() {
	# shellcheck disable=SC2206
	local dirs=($2)
	for key in "${dirs[@]}"; do
		dir_mk "$1/$key"
	done
}

function brewInstall() {
	echo "BrewInstall:" "$1"
	# shellcheck disable=SC2206
	local formulas=($1)
	bi=$(command -v brew)
	for formula in "${formulas[@]}" ; do
	    $bi install "$formula"
	done
}

checkOS
#echo "
#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8" >> "$HOME/.bashrc"
## shellcheck source="${HOME}/.bashrc"
#source "${HOME}/.bashrc"

# check git is installed
if ! $isMacOS && ! command_exists git; then
	sudo $linuxAction install -y git
fi

# check curl is installed
if ! $isMacOS && ! command_exists curl; then
	sudo $linuxAction install -y curl
fi

# install brew
if ! command_exists brew; then
	$bashPath -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# dev dir
dev_dir="$HOME/dev"
dirs=("bin" "environment" "go" "java")
mkdirs "$dev_dir" "${dirs[*]}"

config_dir="${HOME}/.config"
sub_config_dirs=("nvim" "zsh")
mkdirs "$config_dir" "${sub_config_dirs[*]}"

# start install program
needInstall=("zsh" "zsh-autosuggestions" "zsh-completions" "jq")
brewInstall "${needInstall[*]}"
