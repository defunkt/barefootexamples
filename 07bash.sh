alias io='touch ~/.io_history && rm ~/.io_history && io'
alias ike='io ike.io'

# projects
alias fs='fam; sudo ./script/server -p80'
alias free='cd ~/ruby/rails/errfree'
alias rr='cd ~/ruby/rails/projects/rewrite-it'
alias fam='cd ~/ruby/rails/famspam'
alias hub='cd ~/ruby/rails/github'
alias srb='cd ~/Desktop/Training/sakerb'
alias like='cd ~/ruby/rails/musiclike'
alias ffs='cd ~/ruby/rails/ffs'
alias grit='cd ~/ruby/projects/grit'
alias err='cd ~/ruby/projects/err'
alias amb='cd ~/ruby/projects/ambition'
alias take='ruby ~/ruby/projects/svn/projects/sake/lib/sake.rb'
alias fu='cd ~/ruby/projects/plugins/cache_fu'
alias mofo='cd ~/ruby/projects/err/mofo'
alias plugins='cd ~/ruby/projects/plugins'
alias proj='cd ~/ruby/projects/'
alias rock='cd ~/ruby/projects/svn/projects/rock'

# slices
alias samurai='ssh samurai'
alias ninja='ssh ninja -p 53251'
alias pirate='ssh pirate'
alias ncp='scp -P 53251'
alias github1='ssh ey02-s00098'
alias github2='ssh ey02-s00099'
alias ffs-staging='ssh ffs-staging'

# shoes
alias shoe='DYLD_LIBRARY_PATH=. PANGO_RC_FILE=pangorc /Users/chris/ruby/shoes/Shoes.app/Contents/MacOS/shoes'
alias pmp='cd /Users/chris/ruby/shoes/Shoes.app/Contents/MacOS'
alias s='./shoes-launch'

# clients
alias clients='cd ~/ruby/rails/clients'

# rbx
alias rbx='./shotgun/rubinius '
alias sirb='rbx bin/sirb.rb -y'
alias rubin='cd ~/ruby/projects/rubinius'

# gems 
alias gemi='gem install --no-rdoc --no-ri -y'
export GEM_HOME="$HOME/.gems" 
export GEM_PATH="$GEM_HOME"
export PATH="$HOME/.gems/bin:$PATH" 

# github
alias gitgem='cd ~/ruby/projects/github'

# general
alias vtouch='rtouch $1 && vi $1'
alias rcov_units='rake test:units:rcov SHOW_ONLY=m'
alias rcov_funcs='rake test:functionals:rcov SHOW_ONLY=c,h'
alias bashrc='vi ~/.bashrc && source ~/.bashrc'
alias svnst='svn st | grep -v status | grep \s'
alias ack='ack -a'
alias dns='lookupd -flushcache'
alias deploy='git push && cap production deploy'
alias ls='ls -G'
alias grep='grep --color'
alias less='less -r'
alias xterm='xterm -foreground white -background black -geometry 160x40'
alias artest='AR_TX_FIXTURES=yes ruby -I connections/native_mysql'
alias pi='piston import'
alias rake='rake -s'
alias sc='./script/console'
alias ss='./script/server'
alias sshproxy='ssh -D 8080 -f -C -q -N chris@errtheblog.com'
alias screen='screen -e^Gg'
alias sl='screen -ls'
alias sr='screen -R'
alias ns='screen -t'
alias heel='heel --no-highlighting'
alias m='mate'

function hit {
  curl -s -o /dev/null http://localhost:3000/$1
}

function vimgrep {
  vim -O `egrep -r -l $1 * | grep -v .svn`
}

# git
alias gb='git branch -a -v'
alias gs='git status'
alias gd='git diff'

# gc      => git checkout master
# gc bugs => git checkout bugs
function gc {
  if [ -z "$1" ]; then
    git checkout master
  else
    git checkout $1
  fi
}

function hubgrab {
  wget $1;
  tar xzvf *.tar.gz;
  rm *.tar.gz;
}

# Cache, and complete, Cheats
if [ ! -r ~/.cheats ]; then
  echo "Rebuilding Cheat cache... "
  cheat sheets | egrep '^ ' | awk {'print $1'} > ~/.cheats
fi
complete -W "$(cat ~/.cheats)" cheat
complete -C ~/.raketab -o default rake

# environment
export TERM=xterm-color
export EDITOR=vim
export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/bin:$PATH
export EVENT_NOKQUEUE=1
export PATH=$PATH:/usr/local/bin:/usr/local/mysql/bin
export PATH=$PATH:/opt/local/lib/postgresql81/bin:/Applications/Graphviz.app/Contents/MacOS

# put current git branch in the prompt
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function proml {
  local        BLUE="\[\033[0;34m\]"
  local         RED="\[\033[0;31m\]"
  local   LIGHT_RED="\[\033[1;31m\]"
  local       GREEN="\[\033[0;32m\]"
  local LIGHT_GREEN="\[\033[1;32m\]"
  local       WHITE="\[\033[1;37m\]"
  local  LIGHT_GRAY="\[\033[0;37m\]"
  case $TERM in
    xterm*)
    TITLEBAR='\[\033]0;\u@\h:\w\007\]'
    ;;
    *)
    TITLEBAR=""
    ;;
  esac

PS1="${TITLEBAR}\
$BLUE[$RED\$(date +%H:%M)$BLUE]\
$BLUE[$RED\u@\h:\w$GREEN\$(parse_git_branch)$BLUE]\
$LIGHT_GRAY\$ "
PS2='> '
PS4='+ '
}
proml

function prs {
  PS1="$ "
}
