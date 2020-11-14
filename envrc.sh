#!/usr/bin/env bash

# shellcheck disable=SC2016
# shellcheck disable=SC2034
PROMPT="PROMPT='%{\$fg_bold[blue]%}#%{\$reset_color%} %{\$fg_bold[green]%}(%m)%{\$reset_color%} in %{\$fg_bold[magenta]%}%~%{\$reset_color%} %B%F{245}[%D %*]%{\$reset_color%}%(?..%{\$fg_bold[white]%} C:%{\$reset_color%}%{\$fg_bold[red]%}%?%{\$reset_color%}) %B%F{160}%#%{\$reset_color%} '"
LANG="export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8"
USER_BIN='export PATH=$PATH:$HOME/dev/bin'

NVIM_BASIC='" 设置主题
set background=dark
colorscheme oceanic_material
"colorscheme onedark
" 设置显示行号
set number
" 显示相对行号
set relativenumber
" 高亮语法
syntax enable
" 自动缩进
set autoindent
" 智能缩进
set smartindent
" 设置tab制表符宽度为4
set tabstop=4
" 表示每一级缩进的长度
set shiftwidth=4
" 设置按 tab 时缩进的宽度为 4
set softtabstop=4
" 输入时显示相对应的括号
set showmatch
" 设置搜索文本高亮
set hlsearch
exec "nohlsearch"
" 边输入搜索关键字边高亮
set incsearch
set backspace=2
" 高亮当前行
set cursorline

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

set ttimeout
set ttimeoutlen=1
set listchars=tab:>-,trail:~,extends:>,precedes:<,space:.
set ttyfast

map Q :q<CR>
map W :w<CR>
map R :source $MYVIMRC<CR>'