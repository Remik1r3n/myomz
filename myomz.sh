#!/bin/sh
# MyOMZ! Script.
# GitHub URL: https://github.com/Remik1r3n/myomz/
# by Remik1r3n

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

is_macos() {
    [ "$(uname)" = "Darwin" ]
}

parse_arguments() {
    SINGLE_USER_INSTALL=false
    while [ $# -gt 0 ]; do
        case "$1" in
            --single-user-install)
                SINGLE_USER_INSTALL=true
                ;;
            *)
                echo "Unknown argument: $1"
                exit 1
                ;;
        esac
        shift
    done
}

self_check() {
    if ! command_exists zsh; then
        echo "FATAL: zsh is not installed. Please install it first."
        exit 1
    fi

    if ! command_exists wget && ! command_exists curl; then
        echo "FATAL: wget or curl is not installed. Please install one or both."
        exit 1
    fi

    if ! command_exists git; then
        echo "FATAL: git is not installed. Please install it first."
        exit 1
    fi

    if [ "$SINGLE_USER_INSTALL" = false ] && ! is_macos && [ "$(id -u)" -ne 0 ]; then
        echo "FATAL: Please run as root."
        exit 1
    fi
}

download_script() {
    local url="$1"
    local dest="$2"

    if [ "$USED_DOWNLOADER" = "curl" ]; then
        curl -Lo "$dest" "$url"
    elif [ "$USED_DOWNLOADER" = "wget" ]; then
        wget -O "$dest" "$url"
    fi
}

install_plugin() {
    local repo_url="$1"
    local dest_dir="$2"

    git clone "$repo_url" "$dest_dir"
}

main() {
    parse_arguments "$@"
    self_check

    if [ "$SINGLE_USER_INSTALL" = true ] || is_macos; then
        INSTALL_PATH="$HOME/.oh-my-zsh"
    else
        INSTALL_PATH="/usr/share/oh-my-zsh"
    fi

    echo "MyOMZ Script - by Remi 2021-2024"
    echo ""
    echo "Pick a mirror:"
    echo "[G] - GitHub -- Best compatibility, but may be slow in China Mainland."
    echo "[C] - China  -- Use proxy service to accelerate GitHub access in China Mainland."
    echo "[E] - Gitee -- Alternative for China Mainland."
    read -p "Select > " MIRRORANSWER

    echo "Now downloading install script.."

    rm -f /tmp/omz_install.sh

    case "$MIRRORANSWER" in
        G|g)
            download_script "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "/tmp/omz_install.sh"
            ;;
        C|c)
            download_script "https://gh-proxy.com/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "/tmp/omz_install.sh"
            ;;
        E|e)
            download_script "https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh" "/tmp/omz_install.sh"
            ;;
        *)
            echo "FATAL: Invalid selection."
            exit 1
            ;;
    esac

    chmod +x /tmp/omz_install.sh

    echo "----- RUNNING OH-MY-ZSH INSTALL SCRIPT -----"
    RUNZSH=no ZSH="$INSTALL_PATH" /tmp/omz_install.sh
    if [ $? -ne 0 ]; then
        echo "ERROR: Install script returned an error! INSTALLATION FAILED!!"
        exit 1
    fi

    echo "----- OH-MY-ZSH INSTALL SCRIPT COMPLETED -----"
    cp "$INSTALL_PATH/templates/zshrc.zsh-template" "$INSTALL_PATH/templates/zshrc.zsh-template.original.bak"
    rm -f ~/.zshrc

    echo "Now patching zshrc file.."
    sed -i "s#\$HOME/.oh-my-zsh#$INSTALL_PATH#g" "$INSTALL_PATH/templates/zshrc.zsh-template"
    sed -i "s#robbyrussell#gentoo#g" "$INSTALL_PATH/templates/zshrc.zsh-template"
    sed -i "s#plugins=(git)#plugins=(git extract sudo zsh-syntax-highlighting zsh-autosuggestions)#g" "$INSTALL_PATH/templates/zshrc.zsh-template"

    echo "Now installing zsh-syntax-highlighting."
    install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$INSTALL_PATH/plugins/zsh-syntax-highlighting"

    echo "Now installing zsh-autosuggestions."
    install_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$INSTALL_PATH/plugins/zsh-autosuggestions"

    echo "Applying patched zshrc file.."
    cp "$INSTALL_PATH/templates/zshrc.zsh-template" ~/.zshrc

    echo ""
    echo "------------------"
    echo "All done! Run zsh to try it out."
    echo "If you want to let oh-my-zsh work for another user, switch to that user and execute:"
    echo "cp $INSTALL_PATH/templates/zshrc.zsh-template ~/.zshrc"

    exit 0
}

main "$@"
