#!/bin/sh
# MyOMZ! Script.
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
    echo "FATAL: /usr/share/oh-my-zsh exists! Please delete it before install."
    exit 1
fi

if [ `whoami` != "root" ];then
	echo "FATAL: Use root user."
	exit 1
fi
}
self_check

echo "Welcome to MyOMZ!"
echo "What mirror do you want to use?"
echo "G. GitHub. Best compatibility. Recommended if you're not in China Mainland."
echo "F. China Proxy(Based on FastGit and GHProxy). Recommended if you're in China Mainland."
echo "E. Gitee. Slower sync. Not recommended. Only use it if FastGit is unusable!"
read -p "Which? > " MIRRORANSWER

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

else
    echo "FATAL: Selection invaild. "
    exit 1
fi


chmod +x ./install.sh

echo "----- RUNNING OH-MY-ZSH INSTALL SCRIPT -----"
if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    RUNZSH=no ZSH=${ZSH:-/usr/share/oh-my-zsh} ./install.sh
elif [ "$MIRRORANSWER" = "F" -o "$MIRRORANSWER" = "f" ]; then
    RUNZSH=no ZSH=${ZSH:-/usr/share/oh-my-zsh} REPO=${REPO:-ohmyzsh/ohmyzsh} REMOTE=${REMOTE:-https://ghproxy.com/github.com/${REPO}.git} ./install.sh
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    RUNZSH=no ZSH=${ZSH:-/usr/share/oh-my-zsh} REPO=${REPO:-mirrors/oh-my-zsh} REMOTE=${REMOTE:-https://gitee.com/${REPO}.git} ./install.sh
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
cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template /usr/share/oh-my-zsh/templates/zshrc.zsh-template.bak
rm ~/.zshrc

echo "Now patching zshrc file.."

if [ "$(uname)" == "Darwin" ]; then
    echo "macOS Detected. Using Experimental macOS support mode. "
    echo "Note that macOS is not fully supported and YOU MAY RAN INTO PROBLEM."
    sed -i '' "s#\$HOME/.oh-my-zsh#\"/usr/share/oh-my-zsh\"#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template
    sed -i '' "s#robbyrussell#gentoo#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template
    sed -i '' "s#plugins=(git)#plugins=(git extract sudo cp pip z wd zsh-syntax-highlighting zsh-autosuggestions adb docker)#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template

else
    sed -i "s#\$HOME/.oh-my-zsh#\"/usr/share/oh-my-zsh\"#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template
    sed -i "s#robbyrussell#gentoo#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template
    sed -i "s#plugins=(git)#plugins=(git extract sudo cp pip z wd zsh-syntax-highlighting zsh-autosuggestions adb docker)#g"  /usr/share/oh-my-zsh/templates/zshrc.zsh-template
fi
echo "Now installing zsh-syntax-highlighting."

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/plugins/zsh-syntax-highlighting
elif [ "$MIRRORANSWER" = "F" -o "$MIRRORANSWER" = "f" ]; then
    git clone https://ghproxy.com/github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/plugins/zsh-syntax-highlighting
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    git clone https://gitee.com/mirror-github/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/plugins/zsh-syntax-highlighting
fi

echo "Now installing zsh-autosuggestions."

if [ "$MIRRORANSWER" = "G" -o "$MIRRORANSWER" = "g" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/oh-my-zsh/plugins/zsh-autosuggestions
elif [ "$MIRRORANSWER" = "F" -o "$MIRRORANSWER" = "f" ]; then
    git clone https://ghproxy.com/github.com/zsh-users/zsh-autosuggestions.git /usr/share/oh-my-zsh/plugins/zsh-autosuggestions
elif [ "$MIRRORANSWER" = "e" -o "$MIRRORANSWER" = "E" ]; then
    git clone https://gitee.com/mirror-github/zsh-autosuggestions.git /usr/share/oh-my-zsh/plugins/zsh-autosuggestions
fi

echo "Applying patched zshrc file.."
cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

echo -e "\033[33mAll completed! Run zsh to try it out.\033[0m" && echo "if you want to let oh-my-zsh works in other user, go to that user and execute:" && echo -e "\033[36mcp /usr/share/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \033[0m"

exit 0
