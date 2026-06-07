# source /usr/share/cachyos-fish-config/cachyos-config.fish

if status is-interactive
# Commands to run in interactive sessions can go here
end

set -g fish_greeting

abbr -a gs git status
abbr -a ga git add .
abbr -a gc git commit -a
abbr -a gp git push
abbr -a gpl git pull
abbr -a lg lazygit

function set-wall
    awww img $argv[1] --transition-type grow --transition-duration 2
end

abbr -a ll ls -alF

abbr -a so source ./venv/bin/activate.fish

zoxide init --cmd cd fish | source

