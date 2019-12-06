# quick-log

Tools for logging program runs or login sessions, mostly bash functions and aliases, goes in your .bashrc

# TL;DR
Yesterday I wrote a set of tools for logging program runs and sessions.  Can't believe I didn't write them 20 years ago....
Simple usage example:

Runs the program `run` and creates `~/logs/run-2019-12-05T23:54:43` and logs all the program output to the log file.
```
justlog run rcn rcn-work-* 'ps -ef -o lstart,cmd | grep [s]upervisor'
```

View the newly created log file in less
```
lesslog run
```

# Install

Just add it to your .bashrc, or source it from your .bashrc.

The ugly way (not really recommended):

```
cat quick-log.bash >> ~/.bashrc
```

The clean way:

```
echo "source /home/wwalker/git/quick-log/quick-log.bash" >> ~/.bashrc
```

# Why?

As a sysadmin, I'm always needing to log a login session, or the output of some command, which may be a binary.  To solve these problems, I've written a few things.

For recording a login session, the easiest is to use the program `script`.  But, I found that calling `script` (without any arguments) would often result in me overwriting the output ( the file `typescript`, which `script` creates by default) from a previous session.  So I created an `scr` alias.  All it does is prevent overwriting.  You need a ~/tmp directory.

```
$ alias scr='script ~/tmp/typescript-$(date +%FT%T)'
$ scr
Script started, file is /home/wwalker/tmp/typescript-2019-12-05T18:56:31
$
```

That is great when I want to catch an interactive session.

However, when I want to log the output of a command (script or binary), I either want the exact output, or I want the output with timestamps in front of each line.  So I wrote these some bash functions:

`justlog <command and its arguments>` - run the command passed in as arguments, automatically writing stdout and stderr to a new unique log file ( ~/logs/<program-name>-YYYY-MM-DD-HH:MM:SS )
`timelog <command and its arguments>` - just like justlog, except it prefixes everyline with a timestamp ( YYYY-MM-DD-HH:MM:SS.micros )
`newestlog <program-name>` - returns the name the newest log file for program-name
`lesslog <program-name>` - opens the newest log file for program-name using less
`viewlog <program-name>` - opens the newest log file for program-name using view
`greplog <program-name> <grep arguments and regular expression>` - runs grep on the newest log file for program-name

Just run your command like you normally would prefixing it with either `justlog` or `timelog`:

```
justlog run rcn rcn-work-* 'ps -ef -o lstart,cmd | grep [s]upervisor'
```
or
```
timelog run rcn rcn-work-* 'ps -ef -o lstart,cmd | grep [s]upervisor'
```

This will painlessly create 2 files like this:

```
wwalker@polonium:~ ✓ $ ls -l ~/logs/run*
-rw-r--r-- 1 wwalker wwalker  7623 2019-12-05 18:25:07.873 /home/wwalker/logs/run-2019-12-05T18:25:06
-rw-r--r-- 1 wwalker wwalker 10296 2019-12-05 18:34:59.546 /home/wwalker/logs/run-2019-12-05T18:34:57
```

But, Wait there's more!!

I didn't want to have to do an ls to find the name of the log file that justlog or timelog just created for me.

So, you run your command with justlog (or timelog), and then you just use lesslog or viewlog (I'll probably create an emacs log for Those people):

```
justlog run rcn rcn-work\\\\\* 'ps -ef -o lstart,cmd | grep [s]upervisor'
lesslog run
```

That's it, no `ls -lrt ~/tmp`, no tab completion games to find the file name. Just run lesslog (or viewlog if you like using vim to look at logs).

But, Wait there's more!!

`lesslog`, `viewlog`, and `newestlog` only look at the first argument; so, you can be lazy:

```
justlog make -D prefix=/opt
```

Now, you just up arrow and change "just" to "less", and your looking at the recent log file:

```
lesslog make -D prefix=/opt
```

`lesslog` (and `viewlog` and `newestlog`) just ignore the extra arguments.

But, wait! There's more!

You get programmable completion (tab completion) for whatever commands you put after `justlog` and `timelog`.

But, wait! There's even more!

"I use grep all the time on my log files" - And the answer is, you guessed it, `greplog`

First, get the text from all 800 servers' /etc/cron.d/atop files that are broken:

```
justlog fordcrun 'grep -F "0 0 * * root" /etc/cron.d/atop'
```

Then get the hostnames (on the line above the output in the file :-) ) with greplog (without having to look up the log file name):

```
wwalker@polonium:~ ✓ $ greplog fordcrun  -B1 -F "0 0 * * root"
int-salt-01:
    0 0 * * root systemctl restart atop
--
rcn-pg-01:
    0 0 * * root systemctl restart atop
rcn-pg-02:
    0 0 * * root systemctl restart atop
rcn-pg-03:
    0 0 * * root systemctl restart atop
```

Coming soon to a repo near you:

* command completion of the log file names for when you need to look at al older log.

