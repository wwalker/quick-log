# https://github.com/wwalker/quick-log
# Original Author Wayne Walker, wwalker@solid-constructs.com
#
# Most up to date README.md: https://github.com/wwalker/quick-log/blob/master/README.md
#
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
#    log-time barman -a -b -c -d asdf qwer
#
#  This will do the same with no added timestamps:
#    log-plain barman -a -b -c -d asdf qwer
#
#  Instead of having to ls or play completion tabbing game, you can look
#  at, in view or in less, without having to know the name of the file:
#
#  log-view and log-less ignore everything after the first arg (barman)
#
#    log-view barman
#    log-view barman -a -b -c -d asdf qwer
#    log-view !!:1
#
#  or in less:
#    log-less barman
#    log-less barman -a -b -c -d asdf qwer
#
#  You can grep out of the file without looking up the filename:
#    log-grep barman -B1 -F "FAILED"
#
#  You can get the filename of the newest log
#    ls -l $(log-newest barman)

# Set up programmable completion :-)
complete -F _command log-time
complete -F _command log-plain
complete -F _command log-less
complete -F _command log-view
complete -F _grep    log-grep
complete -F _command log-newest

alias iso8601="date +%Y-%m-%dT%H:%M:%S"

alias scr='script ~/logs/typescript-$(iso8601)'

_ql_args=()

_ql_init_vars(){
  _ql_opt_header=0
  _ql_opt_tee=0
  _ql_opt_ts=0
  _ql_opt_usage=
  _ql_opt_directory=$HOME/logs/
  _ql_opt_process_name=
}

_ql_usage(){
  printf "Unrecognized options %s\n" "$_ql_opt_usage"
  printf "Usage message goes here\n"
  return 1
}

_ql_parse_args(){
  _ql_done=0
  while [[ $_ql_done = 0 ]]
  do
    key="$1"

    case $key in
      -h|--header)
        _ql_opt_header=1
        shift
        ;;
      --ts)
        _ql_opt_ts=1
        shift
        ;;
      -t|--tee)
        _ql_opt_tee=1
        shift
        ;;
      -d|--directory)
        _ql_opt_directory=$2
        shift
        shift
        ;;
      -p|--process-name)
        _ql_opt_process_name=$2
        shift
        shift
        ;;
      -*) # unknown option
        _ql_opt_usage+=" $1"
        shift
        ;;
      *)
        _ql_done=1
        ;;
    esac
  done

  if [[ -n "$_ql_opt_usage" ]]
  then
    _ql_usage "$_ql_opt_usage"
    return 1
  fi

  _ql_args=()
  while [[ $# -gt 0 ]]
  do
    _ql_args+=("$1")
    shift
  done
}

_ql_logfile_name(){
  if [[ -z "$_ql_opt_process_name" ]]
  then
    _ql_opt_process_name=$(basename "$1")
  fi
}

_ql_timestamp(){
echo
}
_ql_logfile_path(){
  _ql_logfile_name "$1"
  _ql_filepath=$(printf "%s/%s-%s" "$_ql_opt_directory" "$_ql_opt_process_name" "$(date +%Y-%m-%dT%H:%M:%S)")
}

_ql_ts_cmd(){
  local cmd_path
  if cmd_path=$(command -v ilts)
  then
    _ql_append+=" | $cmd_path -S -E "
    return
  fi
  if cmd_path=$(command -v ts)
  then
    _ql_append+=" | $cmd_path "
    return
  fi
  _ql_append+=" | awk '{ print strftime(\"%Y-%m-%d %H:%M:%S\"), \$0; fflush(); }' "
}

log-plain(){
  _ql_init_vars
  if ! _ql_parse_args "$@"
  then
    # parsing arguments failed
    return 1
  fi

  set -- "${_ql_args[@]}"
  # debug line...
  # set | grep '^_ql_opt_[a-z]*='
  #
  # Compute the path to the log file based on the command and the options
  # Which it puts in _ql_filepath
  _ql_logfile_path "$1"
  _ql_append=" cat "
  if [[ "1" = "$_ql_opt_ts" ]]
  then
    # if using time stamped lines (_ql_opt_ts, from log-time),
    # call _ql_opt_ts which figure out whether to use ilts, ts, or awk
    # which it then appends to _ql_append
    _ql_ts_cmd
  fi

  if [[ "$_ql_opt_tee" = "1" ]]
  then
    _ql_append+=" | tee $(tty)"
  fi

  # printf "%s\n" "$_ql_append"

  if [[ "$_ql_opt_header" = "1" ]]
  then
    # printf "%s\n" "( echo \"$@\"; \"$@\" ) | bash -c  \"$_ql_append\" > \"$_ql_filepath\" 2>&1"
    ( ( echo "$@"; "$@" ) | bash -c  "$_ql_append" ) > "$_ql_filepath" 2>&1
  else
    ( "$@" | bash -c  "$_ql_append" ) > "$_ql_filepath" 2>&1
  fi
}

log-time(){
  # log-time is just like log-plain except for the timestamping
  # So, we just set the time stamp option and call log-plain
  log-plain --ts "$@"
}

log-view(){
  name=$(basename "$1")
  view "$( log-newest "$name" )"
}

log-less(){
  name=$(basename "$1")
  less "$( log-newest "$name" )"
}

log-grep(){
  name=$(basename "$1")
  shift
  grep "$@" "$( log-newest "$name" )"
}

log-newest(){
  name=$(basename "$1")
  ls  ~/logs/"${name}"* ~/permanent/"${name}"* ~/tmp/"${name}"* 2> /dev/null | tail -1
}
