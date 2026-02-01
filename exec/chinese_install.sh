yay -Sy

yay -S noto-fonts-cjk noto-fonts-emoji --needed

yay -S adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts --needed

yay -S fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-chinese-addons --needed

if [ ! -d "$HOME/fcitx5/" ]; then
    git clone https://github.com/catppuccin/fcitx5.git ~
    mkdir -p ~/.local/share/fcitx5/themes/
    cp -r ~/fcitx5/src/* ~/.local/share/fcitx5/themes
    echo "In ~/.config/fcitx5/conf/classicui.conf add Theme=catppuccin-mocha-blue"
else
    echo "fcitx5 theme already exist"
fi
