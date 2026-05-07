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

abbr -a ll ls -alF

abbr -a so source ./venv/bin/activate.fish

zoxide init --cmd cd fish | source

