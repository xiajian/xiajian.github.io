"local user setting "
syntax enable                " 启动语法高亮
syntax on                    " 开启文件类型侦测
" common configure {{
set autoindent               " 自动缩进
set history=200              " 设置vim记录的历史命令数
set bs=2                     " 在insert模式下用退格键删除
set wildmode=longest,list    " 设置ex命令的自动补全方式
set ignorecase smartcase     " 匹配忽略大小写
set showmatch                " 代码匹配
set smartindent              " 智能自动缩进
set ruler                    " 右下角显示光标位置的状态行
set laststatus=2             " 总是显示状态行 
set expandtab                " 以下三个配合使用
set shiftwidth=2             " 设置<>平移的空格数 
set tabstop=2               
"set cursorline               " 为光标所在行加下划线
set number                   " 显示行号
set autoread                 " 文件在Vim之外修改过，自动重新读入
set autowrite                " 在多个文件之间编辑时，自动保存
set hls                      " 高亮搜索
set is                       " 查找执行前预览匹配
set helplang=cn              " 将帮助系统设置为中文
"set selectmode+=mouse        " 设置选择模式
"set foldmethod=syntax        " 代码折叠
set foldcolumn=2             " 显示折叠
set nocompatible             " vi不兼容模式
"set formatoptions+=ro        " 设置注释
set mouse=a                  " 设置鼠标选择
set fileencodings=ucs-bom,utf-8,gb2312,gbk " 设置文件加载的编码
" }}

" conf for tabs,配置通过ctrl h/l切换标签
nnoremap <C-l> gt 
nnoremap <C-h> gT
nnoremap <F2> :NERDTreeToggle<CR>
nnoremap <C-A> :Ack 
nnoremap <F3> :wa<CR>
inoremap <F3> <Esc><F3>
nnoremap <F4> :wqa<CR>
inoremap <F4> <Esc><F4>
nnoremap <F5> :source ~/.vimrc<CR>
inoremap <F5> <Esc><F5>
nnoremap <F6> :wq<CR>
inoremap <F6> <Esc><F5>
" 关于退出保存，使用ZZ即可，仔细想想也就两次按键，不是特别麻烦
nnoremap <C-P> :CtrlP<CR>
inoremap <C-P> <Esc><C-P>
" <C-B>原有的功能是上下滚半屏
nnoremap <C-B> :CtrlPBuffer<CR>
inoremap <C-B> <Esc><C-B>
" <C-l>清除重绘先前的模式
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" gui configure {{
set guifont=Monospace\ 12
"}}

" configure for plugins {{
" disable powerline just because I hate muti-colour gui status bar
"powerline{ 
"set guifont=PowerlineSymbols\ for\ Powerline 
"set nocompatible 
"set t_Co=256 
"let g:Powerline_symbols = 'fancy' 
"} 

" pathogen 是Vim用来管理插件的插件 
"pathogen{ 
execute pathogen#infect() 
"}

" CommandT{
" command CT CommandT 
" command CB CommandTBuffer 
"}

" tComment{

"}

" emment{
let g:user_emmet_leader_key='<Tab>'
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
"}
" SnipMate{
let g:snipMate = {}
let g:snipMate.scope_aliases = {}
let g:snipMate.scope_aliases['ruby'] = 'ruby,ruby-rails'
"}

" vim-ruby{
let g:ruby_indent_access_modifier_style = 'indent'
"}

" vim-indent-guides{
let g:indent_guides_auto_colors = 1
let g:indent_guides_guide_size = 1 

"autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
"autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4

hi IndentGuidesOdd guibg=red ctermbg=3
hi IndentGuidesEven guibg=green ctermbg=4
" }
" Markdown vim{
let g:vim_markdown_folding_disabled=1   " disable folding
let g:vim_markdown_initial_foldlevel=1
" }
"}}
filetype indent on           " 针对不同的文件类型采用不同的缩进格式
filetype plugin on           " 针对不同的文件类型加载对应的插件
filetype plugin indent on    " 启用自动补全

" set man page windows
runtime! ftplugin/man.vim
runtime! macros/matchit.vim
