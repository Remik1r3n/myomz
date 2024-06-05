#!/bin/sh
# MyOMZ! Script.
# GitHub URL: https://github.com/Remik1r3n/myomz/
# by Remik1r3n

command_exists() {
        command -v "$@" >/dev/null 2>&1
}
self_check() {
if ! command_exists zsh; then
    echo "FATAL: zsh is not installed. Please install it first."
    exit 1
fi

if ! command_exists wget; then
    if ! command_exists curl; then
        echo "FATAL: wget or curl is not installed. Please install one or both of it(wget recommended)."
        exit 1
    else
        echo "WARNING: wget is not installed, falling back to curl. this may cause error!"
        echo "It is strongly recommended that you press Ctrl+C now, install wget, then run this script again."
        echo "Waiting for 10s.."
        sleep 10s
        USED_DOWNLOADER='curl'
    fi
else
    USED_DOWNLOADER='wget'
fi

if ! command_exists git; then
    echo "FATAL: git is not installed. Please install it first."
    exit 1
fi

if [ -d "/usr/share/oh-my-zsh" ]; then
    echo "FATAL: /usr/share/oh-my-zsh exists! May be already installed? \nIf not, please delete it before install. Otherwise, check your configuration."
    exit 1
fi

if [ `whoami` != "root" ];then
	echo "FATAL: Use root user."
	exit 1
fi
}
self_check

echo "MyOMZ Script - by Remi 2021-2024"
echo ""
echo "Pick a mirror:"
echo "[G] - GitHub -- Best compatibility, but may be slow in China Mainland."
echo "[C] - China  -- Use proxy service to accelerate GitHub access in China Mainland."
read -p "Select > " MIRRORANSWER

echo "Now downloading install script.."

rm /tmp/omz_install.sh

if [ $USED_DOWNLOADER = curl ]; then
    DOWNLOAD_CMD="$USED_DOWNLOADER -Lo /tmp/omz_install.sh" 
elif [ $USED_DOWNLOADER = wget ]; then
    DOWNLOAD_CMD="$USED_DOWNLOADER -O /tmp/omz_install.sh"
fi

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    $DOWNLOAD_CMD https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
elif [ "$MIRRORANSWER" = "C" -o "$MIRRORANSWER" = "c" ]; then
    $DOWNLOAD_CMD https://gh.api.99988866.xyz/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    $DOWNLOAD_CMD https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh

else
    echo "FATAL: Selection invaild. "
    exit 1
fi

chmod +x /tmp/omz_install.sh

echo "----- RUNNING OH-MY-ZSH INSTALL SCRIPT -----"
if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    RUNZSH=no ZSH=${ZSH:-/usr/share/oh-my-zsh} /tmp/omz_install.sh
elif [ "$MIRRORANSWER" = "C" -o "$MIRRORANSWER" = "c" ]; then
    RUNZSH=no ZSH=${ZSH:-/usr/share/oh-my-zsh} REPO=${REPO:-ohmyzsh/ohmyzsh} REMOTE=${REMOTE:-https://gh.api.99988866.xyz/https://github.com/${REPO}.git} /tmp/omz_install.sh
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    RUNZSH=no ZSH=${ZSH:-/usr/share/oh-my-zsh} REPO=${REPO:-mirrors/oh-my-zsh} REMOTE=${REMOTE:-https://gitee.com/${REPO}.git} /tmp/omz_install.sh
fi
if [ $? != 0 ];then
    echo "ERROR: Install script returned error! INSTALLATION FAILED!!"
    read -p "Ignore this error? (DO NOT!) (y/N)" ANSWER
    if [ "$ANSWER" != "Y" -o "$ANSWER" != "y" ]; then
        exit 1
    fi
fi
echo "----- OH-MY-ZSH INSTALL SCRIPT COMPLETED -----"
cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template /usr/share/oh-my-zsh/templates/zshrc.zsh-template.original.bak
rm ~/.zshrc

echo "Now patching zshrc file.."

sed -i "s#\$HOME/.oh-my-zsh#\"/usr/share/oh-my-zsh\"#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template
sed -i "s#robbyrussell#gentoo#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template
sed -i "s#plugins=(git)#plugins=(git extract sudo zsh-syntax-highlighting zsh-autosuggestions)#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template

echo "Now installing zsh-syntax-highlighting."

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/plugins/zsh-syntax-highlighting
elif [ "$MIRRORANSWER" = "C" -o "$MIRRORANSWER" = "c" ]; then
    git clone https://gh.api.99988866.xyz/https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/plugins/zsh-syntax-highlighting
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    git clone https://gitee.com/mirror-github/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/plugins/zsh-syntax-highlighting
fi

echo "Now installing zsh-autosuggestions."

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/oh-my-zsh/plugins/zsh-autosuggestions
elif [ "$MIRRORANSWER" = "C" -o "$MIRRORANSWER" = "c" ]; then
    git clone https://gh.api.99988866.xyz/https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/oh-my-zsh/plugins/zsh-autosuggestions
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    git clone https://gitee.com/mirror-github/zsh-autosuggestions.git /usr/share/oh-my-zsh/plugins/zsh-autosuggestions
fi

echo "Applying patched zshrc file.."
cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

echo ""
echo "------------------"
echo "All done! Run zsh to try it out."
echo "if you want to let oh-my-zsh works in other user, switch to that user and execute:"
echo "cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc"

exit 0
