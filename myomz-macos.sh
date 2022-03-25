#!/bin/sh
# MyOMZ! Script.
# MACOS VERSION.
# Apache-2.0 License
# GitHub URL: https://github.com/Lapis-Apple/myomz/
# by Lapis Apple. Twitter @dLapisApple
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
        echo "WARNING: wget is not installed, falling back to curl. this may cause error."
        echo "It is strongly recommended you press Ctrl+C now and install wget, then run thi script again."
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

if [ -d "$HOME/oh-my-zsh" ]; then
    echo "FATAL: ~/oh-my-zsh exists! Please delete it before install."
    exit 1

#    read -p "WARNING: Do you want to ignore this error? (y/N)" ANSWER
#    if [ "$ANSWER" != "Y" -o "$ANSWER" != "y" ]; then
#        exit 1
#    fi
fi

if [ `whoami` == "root" ];then
	echo "WARNING: Root user. root user is not recommended in macOS"
fi

if [ "$(uname)" != "Darwin" ]; then
    echo "You're not using macOS, please use mainline script, not this macOS version!!"
    exit 1
fi

self_check
echo "You're Using Experimental macOS support mode. "
echo "Note that macOS is not fully supported and YOU MAY RAN INTO PROBLEM."

read -p "What mirror do you want to use? G=GitHub F=FastGit E=Gitee > " MIRRORANSWER
#if [ "$MIRRORANSWER" != "F" -o "$MIRRORANSWER" != "f" -o "$MIRRORANSWER" != "g" -o "$MIRRORANSWER" != "G" -o "$MIRRORANSWER" != "E" -o "$MIRRORANSWER" != "e" ]; then
#    echo "FATAL: Selection invaild."
#    exit 1
#fi

echo "Now downloading install script.."
if [ $USED_DOWNLOADER = curl ]; then
    DOWNLOAD_CMD="$USED_DOWNLOADER -o install.sh" 
else
    DOWNLOAD_CMD="$USED_DOWNLOADER"
fi

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    $DOWNLOAD_CMD https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
elif [ "$MIRRORANSWER" = "F" -o "$MIRRORANSWER" = "f" ]; then
    $DOWNLOAD_CMD https://raw.fastgit.org/ohmyzsh/ohmyzsh/master/tools/install.sh
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    $DOWNLOAD_CMD https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh
elif [ "$MIRRORANSWER" = "o" -o "$MIRRORANSWER" = "O" ]; then
    $DOWNLOAD_CMD https://codechina.csdn.net/mirrors/ohmyzsh/ohmyzsh/-/raw/master/tools/install.sh

else
    echo "FATAL: Selection invaild. "
    exit 1
fi


chmod +x ./install.sh

echo "----- RUNNING OH-MY-ZSH INSTALL SCRIPT -----"
if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    RUNZSH=no ./install.sh
elif [ "$MIRRORANSWER" = "F" -o "$MIRRORANSWER" = "f" ]; then
    RUNZSH=no REPO=${REPO:-ohmyzsh/ohmyzsh} REMOTE=${REMOTE:-https://hub.fastgit.xyz/${REPO}.git} ./install.sh
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    RUNZSH=no REPO=${REPO:-mirrors/oh-my-zsh} REMOTE=${REMOTE:-https://gitee.com/${REPO}.git} ./install.sh
elif [ "$MIRRORANSWER" = "o" -o "$MIRRORANSWER" = "O" ]; then
    MIRRORANSWER="f"
    echo "Thank you for testing CodeChina Mirror! I'll redirect you to FastGit after this."
    RUNZSH=no REPO=${REPO:-ohmyzsh/ohmyzsh} REMOTE=${REMOTE:-https://codechina.csdn.net/mirrors/${REPO}.git} ./install.sh
else
    echo "What? How do you get there? Please report this as a bug if you're not developer."
fi
if [ $? != 0 ];then
    echo "WARNING: Install script returned error!"
    read -p "WARNING: Do you want to ignore this error? (y/N)" ANSWER
    if [ "$ANSWER" != "Y" -o "$ANSWER" != "y" ]; then
        exit 1
    fi
fi
echo "----- OH-MY-ZSH INSTALL SCRIPT COMPLETED -----"
cp $HOME/oh-my-zsh/templates/zshrc.zsh-template $HOME/oh-my-zsh/templates/zshrc.zsh-template.bak
rm ~/.zshrc

echo "Now patching zshrc file.."

sed -i '' "s#\$HOME/.oh-my-zsh#\"/usr/share/oh-my-zsh\"#g"  $HOME/oh-my-zsh/templates/zshrc.zsh-template
sed -i '' "s#robbyrussell#gentoo#g"  $HOME/oh-my-zsh/templates/zshrc.zsh-template
sed -i '' "s#plugins=(git)#plugins=(git extract sudo cp pip z wd zsh-syntax-highlighting zsh-autosuggestions adb docker)#g"  $HOME/oh-my-zsh/templates/zshrc.zsh-template
echo "Now installing zsh-syntax-highlighting."

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/oh-my-zsh/plugins/zsh-syntax-highlighting
elif [ "$MIRRORANSWER" = "F" -o "$MIRRORANSWER" = "f" ]; then
    git clone https://hub.fastgit.xyz/zsh-users/zsh-syntax-highlighting.git $HOME/oh-my-zsh/plugins/zsh-syntax-highlighting
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    git clone https://gitee.com/mirror-github/zsh-syntax-highlighting.git $HOME/oh-my-zsh/plugins/zsh-syntax-highlighting
fi

echo "Now installing zsh-autosuggestions."

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/oh-my-zsh/plugins/zsh-autosuggestions
elif [ "$MIRRORANSWER" = "F" -o "$MIRRORANSWER" = "f" ]; then
    git clone https://hub.fastgit.xyz/zsh-users/zsh-autosuggestions.git $HOME/oh-my-zsh/plugins/zsh-autosuggestions
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    git clone https://gitee.com/mirror-github/zsh-autosuggestions.git $HOME/oh-my-zsh/plugins/zsh-autosuggestions
fi

echo "Applying patched zshrc file.."
cp $HOME/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

echo -e "\033[33mAll completed! Run zsh to try it out.\033[0m"

exit 0
