export PS1
export PROMPT_COMMAND



function _zcurses_init {
    zmodload zsh/curses
    zcurses init
    zcurses addwin aotwin $(tput lines) $(tput cols) 0 0
    zcurses end
}



function _gototop_zsh {
    
    zcurses init
    zcurses move aotwin 0 0
    zcurses end
    
}



function _gototop_bash {
    # go to the top of the screen and clear in both directions
    # zsh seems to have very strong opinions about redrawing all of the screen
    # when this is called
    tput cup 0 0 
    tput el 
    tput el1
}



function alwaysontop {
    PS1=`perl -e '$newps1 = $ENV{"PS1"}; $newps1 =~ s/\Q$ENV{"ALWAYSONTOP_INDICATOR"}//; print $newps1'`
    if [[ "$ALWAYSONTOP" != "TRUE" ]]
    then
        if [[ "$SHELL" == *"bash"* ]]
        then
            export ALWAYSONTOP="TRUE"
            export OLD_PROMPT_COMMAND_AOT="$PROMPT_COMMAND"
            if [ "$PROMPT_COMMAND" ]
            then
                # before showing the prompt and doing whatever you're supposed to do
                # when you do that, go to the top of the screen and clear in both directions
                PROMPT_COMMAND="$PROMPT_COMMAND ; _gototop_bash"
                PROMPT_COMMAND=$(echo $PROMPT_COMMAND | sed -e 's/;\s*;/;/')
            else
                PROMPT_COMMAND=" _gototop_bash "
            fi
        else
          #  zsh
          add-zsh-hook precmd _gototop_zsh
        fi
        
        PS1="$ALWAYSONTOP_INDICATOR$PS1"
        #PS1="$PS1"
    fi
    
    echo -e "[alwaysontop.sh] ${COLOR_BIPurple}always on top${COLOR_off} ${COLOR_BGreen}ON${COLOR_off}."
}


function unalwaysontop {
    if [[ "$ALWAYSONTOP" == "TRUE"  ]]
    then
        if [[ "$SHELL" == *"bash"* ]]
        then
            if [ -n $OLD_PRMOPT_COMMAND_AOT ]
            then
                PROMPT_COMMAND="$OLD_PRMOPT_COMMAND_AOT"
            fi
        else
            # zsh
            add-zsh-hook -d precmd _gototop_zsh  
        fi
        ALWAYSONTOP="FALSE"
       
	   # use some perl to remove the indicator, because I suck at sed 
        PS1=`perl -e '$newps1 = $ENV{"PS1"}; $newps1 =~ s/\Q$ENV{"ALWAYSONTOP_INDICATOR"}//; print $newps1'`
    fi
   
    echo -e "[alwaysontop.sh] ${COLOR_BIPurple}always on top${COLOR_off} ${COLOR_BRed}OFF${COLOR_off}."
}


function autoclear {
    if [[ "$AUTOCLEAR" != "TRUE" ]]
    then
        export AUTOCLEAR="TRUE"
        
        # replace the enter key with a form feed (clears the screen) and an enter key
        if [[ "$SHELL" == *"bash"* ]]
        then
            bind 'RETURN: "\C-l\C-j"'
        else
            # make a copy of the original accept line, and use our own widget which calls it after clearing the screen
            zle -A accept-line original-accept-line
            function accept-line {
                zle clear-screen
                zle original-accept-line
            }
            zle -N accept-line
            
        fi
        PS1="$AUTOCLEAR_INDICATOR$PS1"
        
    fi
    
    # since we are going to be clearing the screen after every command, might as well have cd also be an ls
    alias "cd"=cdls
    
    # all those little navigation functions that basically just cd into a directory?
    # let them know to use the new cd function
    # i'm thinking, for example, of whatever magic rvm uses
    renavigate    
    
    echo -e "[alwaysontop.sh] ${COLOR_BIYellow}autoclear${COLOR_off} ${COLOR_BGreen}ON${COLOR_off}."
}


function unautoclear {
    export AUTOCLEAR="FALSE"
    
    if [[ "$SHELL" == *"bash"* ]]
    then
        bind 'RETURN: "\C-j"'
    else
        zle -A original-accept-line accept-line
    fi
        
    PS1=`perl -e '$newps1 = $ENV{"PS1"}; $newps1 =~ s/\Q$ENV{"AUTOCLEAR_INDICATOR"}//; print $newps1'`
    
    unalias "cd"
    renavigate
    
    echo -e "[alwaysontop.sh] ${COLOR_BIYellow}autoclear${COLOR_off} ${COLOR_BRed}OFF${COLOR_off}."
}


# turn on both alwaysontop and autoclear
function autotop {
    clear
    autoclear
    alwaysontop
}


# turn off both alwaysontop and autoclear
function unautotop {
    unalwaysontop
    unautoclear
}


function hr {
    echo -en "${COLOR_IBlack}"
    eval printf '%.0s-' {1..$(tput cols)}
    echo -en $COLOR_off 
}


function cdls {
    # go into a directory
    # if that succees, print the git status and a horizontal rule (if we are in a git repository)
    # then print the directory contents, abbreviating if necessary
    # 

    # this ls is a BSD (read: mac osx) thing
    # -G is for color
    # -p is for / after directories
    # -x is for columns
    # CLICOLOR_FORCE and COLUMNS is for ls
    DISPLAY_LINES=20
    LSCMD="CLICOLOR_FORCE=1 COLUMNS=$(tput cols) ls -Gp -x "
    DIR="$@"  
   
    if [[ "$@" == "" ]]
    then
      DIR="$HOME"
    fi

    GIT_CMD="git -c color.status=always status -bs 2>/dev/null"
    SVN_CMD='[[ -d .svn ]] && (
        svn info 2>/dev/null | grep "^URL:\|^Revision:" 2>/dev/null && 
        svn status 2>/dev/null
    )'
    
    VERSION_STATUS_CMD="(($GIT_CMD) || ($SVN_CMD))"
    
    
    command cd "$DIR" && ((eval $VERSION_STATUS_CMD && hr); eval $LSCMD | head -n $DISPLAY_LINES ) &&  
    if [[ $( eval $LSCMD | wc -l ) -gt $DISPLAY_LINES ]]; then
        echo "..."
        eval $LSCMD | tail -n 3
    fi
}


function renavigate {
    ## reloads my navigation functions so that they get the new cd alias
    ## or do nothing
    ## think of the magic that rvm does with your cd function, for example

    # source $BASHINCLUDES_DIR/navigation.sh
    ## or
    # echo "[autotop.sh] renavigate not implemented." > /dev/stderr
    ## or noop
    :
}


function alwaysontop_help {
    echo -e "alwaysontop.sh - keep the prompt at the top of the screen."
    echo -e "Peter Swire - swirepe.com"
    echo -e "Included commands:"
    echo -e "    "
    echo -e "    alwaysontop_help  This screen"
    echo -e "    "
    echo -e "    autotop           Turn ${COLOR_BGreen}ON${COLOR_off} always on top and autoclear"
    echo -e "    unautotop         Turn ${COLOR_BRed}OFF${COLOR_off} always on top and autoclear"
    echo -e "    "                 
    echo -e "    alwaysontop       Turn ${COLOR_BGreen}ON${COLOR_off} always on top"
    echo -e "    unalwaysontop     Turn ${COLOR_BRed}OFF${COLOR_off} always on top"
    echo -e "    "                 
    echo -e "    autoclear         Turn ${COLOR_BGreen}ON${COLOR_off} clear-screen after each command."
    echo -e "    unautoclear       Turn ${COLOR_BRed}OFF${COLOR_off} clear-screen after each command."
    echo -e "    "
    echo -e "    alwaysontop indicator:  ${COLOR_BIPurple}↑↑${COLOR_off}"
    echo -e "    autoclear indicator:    ${COLOR_BIYellow}◎${COLOR_off}"

}




COLOR_off='\033[0m' 
COLOR_BIPurple='\033[1;95m' 
COLOR_BIYellow='\033[1;93m'
COLOR_IBlack='\033[0;90m'
COLOR_BGreen='\033[1;32m'
COLOR_BRed='\033[1;31m'



# setup the colors used here for the two shells we support
if [[ "$SHELL" == *"bash" ]]
then
    PROMPT_COLOR_off='\[\033[0m\]' 
    PROMPT_COLOR_BIPurple='\[\033[1;95m\]' 
    PROMPT_COLOR_BIYellow='\[\033[1;93m\]'
    PROMPT_COLOR_IBlack='\[\033[0;90m\]'
    PROMPT_COLOR_BGreen='\[\033[1;32m\]'
    PROMPT_COLOR_BRed='\[\033[1;31m\]'
    
elif [[ "$SHELL" == *"zsh" ]]
then
    autoload -U colors && colors
    autoload -U add-zsh-hook
    _zcurses_init
    
    PROMPT_COLOR_off='%{$reset_color%}' 
    PROMPT_COLOR_BIPurple='%{$fg_bold[magenta]%}' 
    PROMPT_COLOR_BIYellow='%{$fg_bold[yellow]%}'
    PROMPT_COLOR_IBlack='%{$fg_bold[black]%}'
    PROMPT_COLOR_BGreen='%{$fg_bold[green]%}'
    PROMPT_COLOR_BRed='%{$fg_bold[red]%}' 
    
else
    echo "Sorry, only bash and zsh are supported." > /dev/stderr
    return 1
fi


## the custom indicators
export ALWAYSONTOP_INDICATOR="${PROMPT_COLOR_BIPurple}↑↑${PROMPT_COLOR_off} "
export AUTOCLEAR_INDICATOR="${PROMPT_COLOR_BIYellow}◎${PROMPT_COLOR_off} "

#export ALWAYSONTOP_INDICATOR="^^ "
#export AUTOCLEAR_INDICATOR="@@ "



if [[ "$BASH_SOURCE" == "$0" ]]
then
    echo "[alwaysontop.sh] You should source this file." > /dev/stderr
    exit 1
else
    
    autotop
    echo "    "  
    alwaysontop_help
fi


