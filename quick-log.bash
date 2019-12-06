# Once (on each machine):
#  mkdir ~/logs
#
#  OR add this to your .bashrc
#  mkdir -p ~/logs
#
#  Programmable completion is supported (using _command function)
#
#  This will run "barman -a -b -c -d asdf qwer" add time stamps to each
#  line of stdout or stderr into ~/logs/barman-2019-11-12T21:53:34:
#    timelog barman -a -b -c -d asdf qwer
#
#  This will do the same with no added timestamps:
#    justlog barman -a -b -c -d asdf qwer
#
#  Instead of having to ls or play completion tabbing game, you can look
#  at, in view or in less, without having to know the name of the file:
#
#  viewlog and lesslog ignore 3everything after the first arg (barman)
#
#    viewlog barman
#    viewlog barman -a -b -c -d asdf qwer
#    viewlog !!:1
#
#  or in less:
#    lesslog barman
#    lesslog barman -a -b -c -d asdf qwer
#
#  You can grep out of the file without looking up the filename:
#    greplog barman -B1 -F "FAILED"
#
#  You can get the filename of the newest log
#    ls -l $(newestlog barman)

# Set up programmable completion :-)
complete -F _command timelog
complete -F _command justlog
complete -F _command lesslog
complete -F _command viewlog
complete -F _command greplog
complete -F _command newestlog

alias iso8601="date +%Y-%m-%dT%H:%M:%S"

alias scr='script ~/tmp/typescript-$(iso8601)'

justlog(){
  name=$(basename "$1")
  log=~/logs/${name}-$(iso8601)
  "$@" > "$log" 2>&1
}

timelog(){
  name=$(basename "$1")
  log=~/logs/${name}-$(iso8601)
  # You could replace ilts with ts if it is installed
  # /usr/bin/ts %FT%H:%M:%.S
  "$@" |& ilts -S -E > "$log" 2>&1
}

viewlog(){
  name=$(basename "$1")
  view $( newestlog "$name" )
}

lesslog(){
  name=$(basename "$1")
  less $( newestlog "$name" )
}

greplog(){
  name=$(basename "$1")
  shift
  grep "$@" $( newestlog "$name" )
}

newestlog(){
  name=$(basename "$1")
  ls  ~/logs/"${name}"* | tail -1
}

